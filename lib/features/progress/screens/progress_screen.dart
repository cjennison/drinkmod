import 'package:flutter/material.dart';
import '../../../core/services/goal_management_service.dart';
import '../../../core/services/hive_database_service.dart';
import '../../../core/achievements/achievement_helper.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart' as theme;
import '../../../shared/widgets/page_header.dart';
import '../widgets/goal_card.dart';
import '../widgets/goal_history_modal.dart';
import '../services/chart_data_service.dart';
import '../widgets/charts/weekly_adherence_chart.dart';
import '../widgets/charts/weekly_drinking_pattern_chart.dart';
import '../widgets/charts/time_of_day_pattern_chart.dart';
import '../widgets/charts/intervention_success_chart.dart';
import 'goal_setup_wizard.dart';

/// Progress screen for analytics and streak tracking
/// Shows user progress, streaks, and analytics data
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool _isLoading = true;
  bool _hasActiveGoals = false;
  bool _hasGoalHistory = false;
  Map<String, dynamic>? _activeGoalData;
  
  // Chart data
  late final ChartDataService _chartDataService;
  List<WeeklyAdherenceData> _weeklyAdherenceData = [];
  List<DayOfWeekData> _weeklyPatternData = [];
  List<TimeOfDayData> _timeOfDayData = [];
  List<InterventionSuccessData> _interventionData = [];
  
  // Key for the achievements section to allow refreshing
  final GlobalKey<AchievementsSectionState> _achievementsSectionKey = GlobalKey<AchievementsSectionState>();

  @override
  void initState() {
    super.initState();
    _chartDataService = ChartDataService(HiveDatabaseService.instance);
    _checkUserGoals();
    _loadChartData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check achievements asynchronously when returning to this screen
    _checkAchievementsAsync();
  }

  Future<void> _checkUserGoals() async {
    try {
      final activeGoal = await GoalManagementService.instance.getActiveGoal();
      final goalHistory = GoalManagementService.instance.getGoalHistory();
      
      setState(() {
        _hasActiveGoals = activeGoal != null;
        _hasGoalHistory = goalHistory.isNotEmpty;
        _activeGoalData = activeGoal;
        _isLoading = false;
      });
      
    } catch (e) {
      debugPrint('Error checking user goals: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadChartData() async {
    try {
      final adherenceData = _chartDataService.getWeeklyAdherenceData();
      final patternData = _chartDataService.getWeeklyDrinkingPattern();
      final timeData = _chartDataService.getTimeOfDayPattern();
      final interventionData = _chartDataService.getInterventionSuccessData();
      
      setState(() {
        _weeklyAdherenceData = adherenceData;
        _weeklyPatternData = patternData;
        _timeOfDayData = timeData;
        _interventionData = interventionData;
      });
    } catch (e) {
      debugPrint('Error loading chart data: $e');
    }
  }

  /// Check achievements asynchronously with delay to ensure UI doesn't block
  Future<void> _checkAchievementsAsync() async {
    // Run achievement checking in background with delay
    Future.delayed(const Duration(milliseconds: 500), () async {
      await AchievementHelper.checkMultiple([
        'first_goal',
        'first_goal_completed', 
        'first_goal_finished'
      ]);
      
      // Refresh achievements section after checking
      _achievementsSectionKey.currentState?.refreshAchievements();
    });
  }

  void _onGoalCreated() async {
    // Add delay to ensure goal is fully saved before reloading
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Reload goal data after creation
    _checkUserGoals();
  }

  void _showGoalHistory() {
    showDialog(
      context: context,
      builder: (context) => const GoalHistoryModal(),
    );
  }
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Progress'),
          automaticallyImplyLeading: false,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show wizard for first-time users (no goals and no history)
    if (!_hasActiveGoals && !_hasGoalHistory) {
      return Scaffold(
       
        body: GoalSetupWizard(
          onGoalCreated: _onGoalCreated,
          onSkipped: () {
            // For first-time users, we still show them the wizard or empty state
            // This shouldn't normally happen for first-time users
          },
          onShowHistory: () {
            _showGoalHistory();
          },
          canPop: false, // First-time users can't pop because there's no navigation stack
        ),
      );
    }

    // Show progress screen with CTA for returning users (no active goals but has history)
    if (!_hasActiveGoals && _hasGoalHistory) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Column(
              children: [
                PageHeader(
                  title: 'Progress',
                  subtitle: 'Track your journey and achievements',
                  actionButton: PageHeaderActionButton(
                    label: 'History',
                    icon: Icons.history,
                    onTap: _showGoalHistory,
                  ),
                ),
                const SizedBox(height: 24),
                _buildNoActiveGoalContent(),
              ],
            ),
          ),
        ),
      );
    }

    // Show main progress screen for users with goals
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            children: [
              PageHeader(
                title: 'Progress',
                subtitle: 'Track your journey and achievements',
                actionButton: PageHeaderActionButton(
                  label: 'Change',
                  icon: Icons.swap_horiz,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(
                            title: const Text('Change Goal'),
                          ),
                          body: GoalSetupWizard(
                            onGoalCreated: () {
                              Navigator.of(context).pop();
                              _checkUserGoals();
                            },
                            onSkipped: () {
                              Navigator.of(context).pop();
                              _checkUserGoals(); // This will refresh and show the CTA screen
                            },
                            onShowHistory: () {
                              Future.delayed(const Duration(milliseconds: 300), () {
                                _showGoalHistory();
                              });
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              _buildProgressContentWithoutPadding(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressContentWithoutPadding() {
    if (_activeGoalData == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up_outlined,
              size: 80,
              color: theme.AppTheme.greyColor,
            ),
            SizedBox(height: 20),
            Text(
              'No Active Goal',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Create a goal to track your progress',
              style: TextStyle(
                fontSize: 16,
                color: theme.AppTheme.greyColor,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Goal Card
        GoalCard(
          key: ValueKey(_activeGoalData!['id']),
          goalData: _activeGoalData!,
          onGoalCompleted: _navigateToNewGoalWizard,
        ),
        
        const SizedBox(height: 24),
        
        // Achievement Badges Section
        AchievementsSection(key: _achievementsSectionKey),
        const SizedBox(height: 24),
        
        // Progress Charts Section
        _buildProgressChartsSection(),
      ],
    );
  }

  Widget _buildProgressChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Icon(
              Icons.show_chart_outlined,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Progress Analytics',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Charts - Mobile Vertical Layout
        Column(
          children: [
            // Weekly Adherence Chart
            _buildChartCard(
              icon: Icons.trending_up,
              iconColor: theme.AppTheme.greenDark,
              title: 'Weekly Goal Adherence',
              description: 'Your progress over the last 12 weeks',
              chart: WeeklyAdherenceChart(data: _weeklyAdherenceData),
            ),
            
            const SizedBox(height: 16),
            
            // Weekly Pattern Chart
            _buildChartCard(
              icon: Icons.bar_chart,
              iconColor: theme.AppTheme.blueColor,
              title: 'Weekly Drinking Pattern',
              description: 'Average drinks by day of week',
              chart: WeeklyDrinkingPatternChart(data: _weeklyPatternData),
            ),
            
            const SizedBox(height: 16),
            
            // Time of Day Chart
            _buildChartCard(
              icon: Icons.access_time,
              iconColor: theme.AppTheme.orangeDark,
              title: 'Time of Day Patterns',
              description: 'When you typically drink',
              chart: TimeOfDayPatternChart(data: _timeOfDayData),
            ),
            
            const SizedBox(height: 16),
            
            // Intervention Success Chart
            _buildChartCard(
              icon: Icons.shield_outlined,
              iconColor: theme.AppTheme.purpleDark,
              title: 'Intervention Success',
              description: 'How often you resist urges',
              chart: InterventionSuccessChart(data: _interventionData),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required Widget chart,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: theme.AppTheme.greyMedium,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            chart,
          ],
        ),
      ),
    );
  }

  Widget _buildNoActiveGoalContent() {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 100,
            color: theme.AppTheme.greyVeryLight,
          ),
          const SizedBox(height: 24),
          const Text(
            'Ready for Your Next Goal?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.AppTheme.blackText87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'You\'ve made great progress before.\nLet\'s set up a new goal to continue your journey!',
            style: TextStyle(
              fontSize: 16,
              color: theme.AppTheme.greyMedium,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startNewGoalSetup,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.AppTheme.blueColor,
                foregroundColor: theme.AppTheme.whiteColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Create New Goal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _showGoalHistory,
            child: Text(
              'View Previous Goals',
              style: TextStyle(
                fontSize: 16,
                color: theme.AppTheme.blueColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startNewGoalSetup() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          
          body: GoalSetupWizard(
            onGoalCreated: () {
              Navigator.of(context).pop();
              _checkUserGoals();
            },
            onSkipped: () {
              Navigator.of(context).pop();
              _checkUserGoals(); // This will refresh and show the CTA screen
            },
            onShowHistory: () {
              Future.delayed(const Duration(milliseconds: 300), () {
                _showGoalHistory();
              });
            },
          ),
        ),
      ),
    );
  }

  void _navigateToNewGoalWizard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalSetupWizard(
          onGoalCreated: () {
            // Close the wizard and refresh the progress screen
            Navigator.pop(context);
            _checkUserGoals();
          },
          // Don't show skip button when creating a new goal from completed goal
          onSkipped: null,
          onShowHistory: _showGoalHistory,
          canPop: true,
          isReplacingGoal: true, // Indicate this is replacing an existing goal
        ),
      ),
    );
  }
}
