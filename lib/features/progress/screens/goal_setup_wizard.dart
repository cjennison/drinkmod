import 'package:flutter/material.dart';
import '../../../core/models/user_goal.dart';
import '../../../core/services/goal_management_service.dart';
import '../../../core/services/goal_progress_service.dart';
import '../../../core/services/user_data_service.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/goal_wizard_steps/welcome_step.dart';
import '../widgets/goal_wizard_steps/goal_type_selection_step.dart';
import '../widgets/goal_wizard_steps/goal_parameters_step.dart';
import '../widgets/goal_wizard_steps/goal_preview_step.dart';
import '../widgets/goal_wizard_steps/goal_confirmation_step.dart';

/// Comprehensive goal setup wizard for first-time progress screen users
/// Designed with therapeutic UX principles for easy understanding and motivation
class GoalSetupWizard extends StatefulWidget {
  final VoidCallback? onGoalCreated;
  final VoidCallback? onSkipped;
  final VoidCallback? onShowHistory;
  final bool canPop; // New parameter to control navigation behavior
  final bool isReplacingGoal; // New parameter to indicate goal replacement
  
  const GoalSetupWizard({
    super.key,
    this.onGoalCreated,
    this.onSkipped,
    this.onShowHistory,
    this.canPop = true, // Default to true for backward compatibility
    this.isReplacingGoal = false, // Default to false for first-time setup
  });

  @override
  State<GoalSetupWizard> createState() => _GoalSetupWizardState();
}

class _GoalSetupWizardState extends State<GoalSetupWizard> {
  final PageController _pageController = PageController();
  final GoalManagementService _goalService = GoalManagementService.instance;
  final UserDataService _userService = UserDataService.instance;
  
  int _currentStep = 0;
  GoalType? _selectedGoalType;
  Map<String, dynamic> _goalParameters = {};
  String _goalTitle = '';
  String _goalDescription = '';
  Map<String, dynamic>? _existingGoal;
  bool _isFirstGoal = true; // Track if this is the user's first goal
  
  static const int totalSteps = 5;

  @override
  void initState() {
    super.initState();
    // Check for existing goal and goal history after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForExistingGoal();
      _checkGoalHistory();
    });
  }

  void _checkGoalHistory() {
    final goalHistory = _goalService.getGoalHistory();
    setState(() {
      _isFirstGoal = goalHistory.isEmpty;
    });
  }

  Future<void> _checkForExistingGoal() async {
    final existingGoal = await _goalService.getActiveGoal();
    if (existingGoal != null) {
      setState(() {
        _existingGoal = existingGoal;
      });
      
      // Check if the existing goal is completed (no days remaining or 100% achievement)
      if (await _isGoalCompleted(existingGoal)) {
        // Goal is completed, proceed directly without replacement dialog
        return;
      }
      
      // Goal is still active, show replacement dialog
      await _showGoalReplacementDialog();
    }
  }

  /// Check if a goal is completed based on days remaining OR percentage completion
  Future<bool> _isGoalCompleted(Map<String, dynamic> goalData) async {
    final startDate = DateTime.tryParse(goalData['startDate'] ?? '');
    if (startDate == null) return false;
    
    final parameters = goalData['parameters'] as Map<String, dynamic>? ?? {};
    final goalType = goalData['goalType']?.toString();
    
    // Check percentage completion first for certain goal types
    if (_shouldCheckPercentageCompletion(goalType)) {
      try {
        final progressService = GoalProgressService.instance;
        final progressData = await progressService.calculateGoalProgress(goalData);
        final percentage = progressData['percentage'] as double? ?? 0.0;
        
        // If goal has reached 100% completion, consider it completed
        if (percentage >= 1.0) {
          return true;
        }
      } catch (e) {
        // If progress calculation fails, fall back to time-based completion
        print('Error calculating goal progress for completion check: $e');
      }
    }
    
    // Calculate end date based on goal type and duration
    DateTime endDate;
    if (goalType?.contains('daily') == true) {
      final weeks = parameters['durationWeeks'] as int? ?? 4;
      endDate = startDate.add(Duration(days: weeks * 7));
    } else if (goalType?.contains('weekly') == true || goalType?.contains('cost') == true) {
      final months = parameters['durationMonths'] as int? ?? 3;
      endDate = DateTime(startDate.year, startDate.month + months, startDate.day);
    } else if (goalType?.contains('intervention') == true) {
      final weeks = parameters['durationWeeks'] as int? ?? 4;
      endDate = startDate.add(Duration(days: weeks * 7));
    } else {
      // Default to 30 days
      endDate = startDate.add(const Duration(days: 30));
    }
    
    // Calculate days remaining
    final now = DateTime.now();
    final difference = endDate.difference(now).inDays;
    return difference <= 0; // Goal is completed if no days remaining
  }

  /// Determine if a goal type should check percentage completion in addition to time
  bool _shouldCheckPercentageCompletion(String? goalType) {
    if (goalType == null) return false;
    
    // Goal types that can reach 100% completion before time expires
    return goalType.contains('cost') ||           // Cost savings goals
           goalType.contains('weekly') ||         // Weekly reduction goals  
           goalType.contains('intervention') ||   // Intervention wins goals
           goalType.contains('alcohol');          // Alcohol-free days goals
  }

  Future<void> _showGoalReplacementDialog() async {
    if (!mounted) return;
    
    final shouldReplace = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildGoalReplacementDialog(),
    );
    
    if (shouldReplace == true) {
      await _archiveCurrentGoal();
      // Continue with goal setup wizard
    } else {
      Navigator.of(context).pop(); // Return to previous screen
    }
  }

  Widget _buildGoalReplacementDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Get properly formatted goal name
    final goalTypeString = _existingGoal?['goalType']?.toString() ?? '';
    final formattedGoalName = goalTypeString.startsWith('GoalType.') 
        ? _formatGoalTypeName(goalTypeString)
        : (_existingGoal?['title'] ?? 'Current Goal');
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: screenWidth * 0.9,
        constraints: const BoxConstraints(
          maxWidth: 400,
          minHeight: 300,
        ),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF39C12), // App warning color
              const Color(0xFF4A90E2), // App primary color
              const Color(0xFF357ABD), // App primary variant
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with icon and title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.swap_horiz,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Replace Current Goal?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Current goal display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Active Goal:',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedGoalName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Explanation text
            const Text(
              'Creating a new goal will save your current progress and start fresh with your new challenge.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Keep Current Goal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFF39C12), // App warning color
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Replace Goal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatGoalTypeName(String goalTypeString) {
    switch (goalTypeString) {
      case 'GoalType.dailyLimit':
        return 'Daily Drink Limit';
      case 'GoalType.weeklyLimit':
      case 'GoalType.weeklyReduction':
        return 'Weekly Reduction';
      case 'GoalType.dryDays':
      case 'GoalType.alcoholFreeDays':
        return 'Alcohol-Free Days';
      case 'GoalType.streakDays':
      case 'GoalType.streakMaintenance':
        return 'Streak Maintenance';
      case 'GoalType.reductionPercent':
        return 'Reduction Goal';
      case 'GoalType.customTarget':
      case 'GoalType.customGoal':
        return 'Custom Goal';
      case 'GoalType.interventionWins':
        return 'Intervention Wins';
      case 'GoalType.moodImprovement':
        return 'Mood Improvement';
      case 'GoalType.costSavings':
        return 'Cost Savings';
      default:
        return 'Current Goal';
    }
  }

  Future<void> _archiveCurrentGoal() async {
    // Archive the current goal by completing it
    try {
      final goalService = GoalManagementService.instance;
      await goalService.completeActiveGoal();
    } catch (e) {
      debugPrint('Error archiving goal: $e');
    }
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _nextStep() {
    if (_currentStep < totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void _onGoalTypeSelected(GoalType goalType) {
    setState(() {
      _selectedGoalType = goalType;
    });
    _nextStep();
  }
  
  void _onParametersSet(Map<String, dynamic> parameters, String title, String description) {
    setState(() {
      _goalParameters = parameters;
      _goalTitle = title;
      _goalDescription = description;
    });
    _nextStep();
  }
  
  void _onPreviewConfirmed() {
    _createGoal();
    _nextStep();
  }
  
  Future<void> _createGoal() async {
    if (_selectedGoalType == null) return;
    
    print('🎯 GoalSetupWizard: Creating goal - Title: $_goalTitle, Type: $_selectedGoalType');
    
    setState(() {
      // Show loading state in UI
    });
    
    try {
      // Determine appropriate chart type based on goal type
      final chartType = _getChartTypeForGoal(_selectedGoalType!);
      
      // Use setActiveGoal to automatically handle existing goal archival
      await _goalService.setActiveGoal(
        title: _goalTitle,
        description: _goalDescription,
        goalType: _selectedGoalType!,
        parameters: _goalParameters,
        associatedChart: chartType,
        priorityLevel: 1,
      );
      
      print('🎯 GoalSetupWizard: Goal created successfully');
      
      // Mark that user has completed goal setup
      await _userService.updateUserData({
        'hasSetupGoals': true,
        'firstGoalCreatedAt': DateTime.now().toIso8601String(),
      });
      
      _nextStep(); // Go to confirmation step
    } catch (e) {
      print('❌ GoalSetupWizard: Error creating goal: $e');
      _showErrorDialog('Failed to create goal: $e');
    } finally {
      setState(() {
        // Hide loading state
      });
    }
  }
  
  ChartType _getChartTypeForGoal(GoalType goalType) {
    switch (goalType) {
      case GoalType.weeklyReduction:
        return ChartType.weeklyDrinksTrend;
      case GoalType.dailyLimit:
        return ChartType.adherenceOverTime;
      case GoalType.alcoholFreeDays:
        return ChartType.adherenceOverTime;
      case GoalType.interventionWins:
        return ChartType.interventionStats;
      case GoalType.moodImprovement:
        return ChartType.moodCorrelation;
      case GoalType.streakMaintenance:
        return ChartType.streakVisualization;
      case GoalType.costSavings:
        return ChartType.costSavingsProgress;
      case GoalType.customGoal:
        return ChartType.weeklyDrinksTrend;
    }
  }
  
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _skipGoalSetup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Goal Setup?'),
        content: const Text(
          'You can always set up goals later in your progress screen. '
          'Goals help track your progress and stay motivated.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onSkipped?.call();
            },
            child: const Text('Skip for Now'),
          ),
        ],
      ),
    );
  }
  
  UserGoal _buildUserGoal() {
    final now = DateTime.now();
    final endDate = _calculateEndDate();
    final targetValue = _goalParameters['targetValue'] as double? ?? 1.0;
    
    final metrics = GoalMetrics(
      currentProgress: 0.0,
      targetValue: targetValue,
      currentValue: 0.0,
      unit: _getGoalUnit(),
      lastUpdated: now,
      milestones: [],
      metadata: {},
    );
    
    return UserGoal(
      goalType: _selectedGoalType!,
      title: _goalTitle,
      description: _goalDescription,
      startDate: now,
      endDate: endDate,
      parameters: _goalParameters,
      requiredCharts: _getRequiredCharts(),
      metrics: metrics,
      createdAt: now,
    );
  }
  
  String _getGoalUnit() {
    switch (_selectedGoalType!) {
      case GoalType.weeklyReduction:
        return 'drinks';
      case GoalType.dailyLimit:
        return 'days';
      case GoalType.alcoholFreeDays:
        return 'days';
      case GoalType.interventionWins:
        return 'wins';
      case GoalType.moodImprovement:
        return 'mood score';
      case GoalType.costSavings:
        return 'dollars';
      case GoalType.streakMaintenance:
        return 'days';
      case GoalType.customGoal:
        return 'units';
    }
  }
  
  List<ChartType> _getRequiredCharts() {
    switch (_selectedGoalType!) {
      case GoalType.weeklyReduction:
        return [ChartType.weeklyDrinksTrend, ChartType.adherenceOverTime];
      case GoalType.dailyLimit:
        return [ChartType.adherenceOverTime, ChartType.riskDayAnalysis];
      case GoalType.alcoholFreeDays:
        return [ChartType.adherenceOverTime, ChartType.streakVisualization];
      case GoalType.interventionWins:
        return [ChartType.interventionStats, ChartType.adherenceOverTime];
      case GoalType.moodImprovement:
        return [ChartType.moodCorrelation, ChartType.adherenceOverTime];
      case GoalType.costSavings:
        return [ChartType.costSavingsProgress, ChartType.weeklyDrinksTrend];
      case GoalType.streakMaintenance:
        return [ChartType.streakVisualization, ChartType.adherenceOverTime];
      case GoalType.customGoal:
        return [ChartType.adherenceOverTime];
    }
  }
  
  DateTime? _calculateEndDate() {
    final now = DateTime.now();
    
    // Calculate end date based on goal parameters
    if (_goalParameters.containsKey('durationWeeks')) {
      final weeks = _goalParameters['durationWeeks'] as int;
      return now.add(Duration(days: weeks * 7));
    } else if (_goalParameters.containsKey('durationMonths')) {
      final months = _goalParameters['durationMonths'] as int;
      return DateTime(now.year, now.month + months, now.day);
    }
    
    // Default to 8 weeks if no duration specified
    return now.add(const Duration(days: 56));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0 
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _previousStep,
            )
          : null,
        actions: [
          if (_currentStep < totalSteps - 2 && !_isFirstGoal && widget.onSkipped != null) // Don't show skip on confirmation steps, for first-time users, or when no skip callback
            TextButton(
              onPressed: _skipGoalSetup,
              child: Text(
                'Skip',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),
          
          // Wizard content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                WelcomeStep(
                  onNext: _nextStep,
                  isReplacingGoal: widget.isReplacingGoal,
                ),
                GoalTypeSelectionStep(
                  onGoalTypeSelected: _onGoalTypeSelected,
                ),
                _buildParametersStep(),
                _buildPreviewStep(),
                _buildConfirmationStep(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildParametersStep() {
    if (_selectedGoalType == null) {
      return const Center(
        child: Text('Please select a goal type first'),
      );
    }
    
    return GoalParametersStep(
      goalType: _selectedGoalType!,
      onParametersSet: _onParametersSet,
    );
  }
  
  Widget _buildPreviewStep() {
    if (_selectedGoalType == null || _goalTitle.isEmpty || _goalParameters.isEmpty) {
      return const Center(
        child: Text('Please complete the previous steps'),
      );
    }
    
    return GoalPreviewStep(
      goal: _buildUserGoal(),
      onConfirm: _onPreviewConfirmed,
      onEdit: _previousStep,
    );
  }
  
  Widget _buildConfirmationStep() {
    if (_selectedGoalType == null || _goalTitle.isEmpty || _goalParameters.isEmpty) {
      return const Center(
        child: Text('Please complete the previous steps'),
      );
    }
    
    return GoalConfirmationStep(
      goal: _buildUserGoal(),
      onViewGoal: () {
        widget.onGoalCreated?.call();
        if (widget.canPop && Navigator.of(context).canPop()) {
          Navigator.of(context).pop(); // Exit wizard only if we can pop
        }
      },
      onViewHistory: () {
        widget.onGoalCreated?.call();
        if (widget.canPop && Navigator.of(context).canPop()) {
          Navigator.of(context).pop(); // Exit wizard only if we can pop
        }
        // Use callback to show history from parent context
        widget.onShowHistory?.call();
      },
    );
  }
  
  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step ${_currentStep + 1} of $totalSteps',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentStep + 1) / totalSteps,
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}
