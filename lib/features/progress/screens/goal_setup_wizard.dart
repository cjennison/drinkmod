import 'package:flutter/material.dart';
import '../../../core/models/user_goal.dart';
import '../../../core/services/goal_management_service.dart';
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
  
  const GoalSetupWizard({
    super.key,
    this.onGoalCreated,
    this.onSkipped,
    this.onShowHistory,
    this.canPop = true, // Default to true for backward compatibility
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
  
  static const int totalSteps = 5;

  @override
  void initState() {
    super.initState();
    _checkForExistingGoal();
  }

  Future<void> _checkForExistingGoal() async {
    final existingGoal = _goalService.getActiveGoal();
    if (existingGoal != null) {
      setState(() {
        _existingGoal = existingGoal;
      });
      await _showGoalReplacementDialog();
    }
  }

  Future<void> _showGoalReplacementDialog() async {
    if (!mounted) return;
    
    final shouldReplace = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Replace Current Goal?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('You already have an active goal:'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _existingGoal?['title'] ?? 'Current Goal',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Type: ${_existingGoal?['goalType'] ?? 'Unknown'}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Creating a new goal will archive your current goal and replace it. Your progress will be saved in your goal history.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep Current Goal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Replace Goal'),
          ),
        ],
      ),
    );

    if (shouldReplace != true && mounted) {
      // User chose to keep current goal, exit wizard
      Navigator.of(context).pop();
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
      
      // Mark that user has completed goal setup
      await _userService.updateUserData({
        'hasSetupGoals': true,
        'firstGoalCreatedAt': DateTime.now().toIso8601String(),
      });
      
      _nextStep(); // Go to confirmation step
    } catch (e) {
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
          if (_currentStep < totalSteps - 2) // Don't show skip on confirmation steps
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
