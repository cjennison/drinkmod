import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/onboarding_service.dart';
import '../../../core/services/hive_database_service.dart';
import '../../../core/services/goal_management_service.dart';
import '../../../core/utils/progress_metrics_service.dart';
import '../../../core/achievements/achievement_helper.dart';
import '../../tracking/screens/drink_logging_screen.dart';
import '../../tracking/screens/drink_logging_cubit.dart';
import '../../tracking/screens/tracking_screen.dart';
import '../../tracking/widgets/week_overview_widget.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/today_status_card.dart';
import '../widgets/home_quick_actions.dart';
import '../widgets/mini_goal_card.dart';

/// Home screen - main dashboard after onboarding completion
class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToTracking;
  final VoidCallback? onNavigateToProgress;
  
  const HomeScreen({
    super.key,
    this.onNavigateToTracking,
    this.onNavigateToProgress,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userName;
  bool isLoading = true;
  Map<String, dynamic>? dashboardStats;
  List<String> favoriteDrinks = [];
  Map<String, dynamic>? currentUser;
  bool hasActiveGoal = false;
  
  final HiveDatabaseService _databaseService = HiveDatabaseService.instance;
  final GoalManagementService _goalService = GoalManagementService.instance;
  late final ProgressMetricsService _metricsService;

  @override
  void initState() {
    super.initState();
    _metricsService = ProgressMetricsService(_databaseService);
    _initializeServices();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check achievements asynchronously when returning to this screen
    _checkAchievementsAsync();
  }

  Future<void> _initializeServices() async {
    try {
      print('Starting service initialization...');
      // Initialize Hive database
      await _databaseService.initialize();
      print('Hive database initialized');
      
      // Load user data
      await _loadUserData();
      print('User data loaded');
      
      // Load dashboard data
      if (currentUser != null) {
        await _loadDashboardData();
        print('Dashboard data loaded');
      }
      
      // Check for active goal
      await _checkActiveGoal();
      print('Active goal check completed');
      
      // Check for achievements after all data is loaded
      _checkAchievementsAsync();
    } catch (e) {
      debugPrint('Error initializing services: $e');
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize app: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadUserData() async {
    print('Loading user data...');
    try {
      final userData = await OnboardingService.getUserData();
      if (userData != null) {
        userName = userData['name'];
        currentUser = userData;
        
        // Load favorite drinks from user data
        if (userData['favoriteDrinks'] != null) {
          favoriteDrinks = List<String>.from(userData['favoriteDrinks']);
        }
      }

      print('User data loaded: $userName');
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }
  
  Future<void> _loadDashboardData() async {
    if (currentUser == null) return;
    
    try {
      // Get today's drink logs from Hive
      final today = DateTime.now();
      final logs = await _databaseService.getDrinkLogsForDate(today);
      
      // Check if today is a drinking day based on schedule
      final isDrinkingDay = _databaseService.isDrinkingDay();
      final canAddDrink = _databaseService.canAddDrinkToday();
      final remainingDrinks = _databaseService.getRemainingDrinksToday();
      
      // Calculate basic stats
      final totalDrinks = logs.fold<double>(0, (sum, log) => sum + (log['standardDrinks'] ?? 0.0));
      final drinkLimit = currentUser!['drinkLimit'] ?? 2;
      
      final stats = {
        'todaysDrinks': totalDrinks,
        'dailyLimit': drinkLimit,
        'remaining': remainingDrinks,
        'logsToday': logs.length,
        'isAllowedDay': isDrinkingDay,
        'canAddDrink': canAddDrink,
      };
      
      if (mounted) {
        setState(() {
          dashboardStats = stats;
        });
      }
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      // Create default stats if there's an error
      final drinkLimit = currentUser!['drinkLimit'] ?? 2;
      final stats = {
        'todaysDrinks': 0.0,
        'dailyLimit': drinkLimit,
        'remaining': drinkLimit,
        'logsToday': 0,
        'isAllowedDay': true,
        'canAddDrink': true,
      };
      
      if (mounted) {
        setState(() {
          dashboardStats = stats;
        });
      }
    }
  }
  
  Future<void> _checkActiveGoal() async {
    try {
      final activeGoal = await _goalService.getActiveGoal();
      setState(() {
        hasActiveGoal = activeGoal != null;
      });
    } catch (e) {
      debugPrint('Error checking active goal: $e');
      setState(() {
        hasActiveGoal = false;
      });
    }
  }
  
  /// Check account-related achievements asynchronously
  Future<void> _checkAchievementsAsync() async {
    // Run achievement checking in background with delay
    Future.delayed(const Duration(milliseconds: 1000), () async {
      print('🏆 HomeScreen: Checking achievements asynchronously');
      await AchievementHelper.checkMultiple([
        '1_day_down',  // 1 day since account creation
        '3_days_down', // 3 days since account creation  
        '7_days_down', // 7 days since account creation
        'first_goal',  // User has created their first goal
        // Tracking achievements
        'first_drink_logged',
        '5_drinks_logged',
        '10_drinks_logged',
        '25_drinks_logged',
        '50_drinks_logged',
        'week_of_logging',
        'compliant_logger',
        // Intervention achievements
        'first_intervention_win',
        '5_intervention_wins',
        '10_intervention_wins',
        'intervention_champion',
        'streak_saver',
      ]);
    });
  }

  void _handleDetailedLog() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => DrinkLoggingCubit(HiveDatabaseService.instance),
          child: DrinkLoggingScreen(
            selectedDate: DateTime.now(),
          ),
        ),
      ),
    );
    
    if (result == true && mounted) {
      
      // Refresh dashboard after logging
      await _loadDashboardData();
    }
  }
  
  Future<void> _refreshHomeData() async {
    await _loadDashboardData();
    await _checkActiveGoal();
  }
  
  /// Build today's status card (matching Track page design)
  /// Build drink visualizer (matching Track page)
  /// Build quick actions section
  /// Get remaining drinks message (matching Track page)
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Get today's data for status banner
    final today = DateTime.now();
    final entries = _databaseService.getDrinkEntriesForDate(today);
    final totalDrinks = entries.fold<double>(0, (sum, e) => sum + (e['standardDrinks'] as double));
    final dailyLimit = currentUser?['drinkLimit'] ?? 2;
    final isDrinkingDay = _databaseService.isDrinkingDay();
    
    // Calculate real metrics using progress service
    final currentStreak = _metricsService.calculateCurrentStreak();
    final patternAssessment = _metricsService.analyzeWeeklyPattern();
    final motivationalMessage = patternAssessment.recommendation;
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshHomeData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced Dashboard Header with streak
              DashboardHeader(
                userName: userName,
                currentStreak: currentStreak,
                motivationalMessage: motivationalMessage,
                isDrinkingDay: isDrinkingDay,
                todaysDrinks: totalDrinks,
                dailyLimit: dailyLimit,
                databaseService: _databaseService,
              ),
              
              const SizedBox(height: 20),
              
              // Week Overview Widget (no date selection for dashboard)
              WeekOverviewWidget(
                date: today,
                databaseService: _databaseService,
                onDateSelected: null, // Disabled for dashboard view
              ),
              
              const SizedBox(height: 20),
              
              // Always show Mini Goal Card (shows CTA if no goal exists)
              MiniGoalCard(
                onTap: () {
                  // Navigate to progress tab instead of pushing new route
                  widget.onNavigateToProgress?.call();
                },
              ),
              
              const SizedBox(height: 16),
              
              // Today's Status Banner
              TodayStatusCard(
                date: today,
                totalDrinks: totalDrinks,
                dailyLimit: dailyLimit,
                isDrinkingDay: isDrinkingDay,
                databaseService: _databaseService,
              ),
              
              const SizedBox(height: 16),
              
              // Quick Actions
              HomeQuickActions(
                onLogDrink: _handleDetailedLog,
                onViewTracking: widget.onNavigateToTracking ?? () {
                  // Fallback navigation if callback not provided
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TrackingScreen(),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 100), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}
