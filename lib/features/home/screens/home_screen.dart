import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/onboarding_service.dart';
import '../../../core/services/hive_database_service.dart';
import '../../tracking/screens/drink_logging_screen.dart';
import '../../tracking/screens/drink_logging_cubit.dart';
import '../../tracking/screens/tracking_screen.dart';
import '../widgets/dashboard_stats_card.dart';
import '../widgets/today_status_card.dart';
import '../widgets/home_quick_actions.dart';

/// Home screen - main dashboard after onboarding completion
class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToTracking;
  
  const HomeScreen({
    super.key,
    this.onNavigateToTracking,
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
  
  final HiveDatabaseService _databaseService = HiveDatabaseService.instance;

  @override
  void initState() {
    super.initState();
    _initializeServices();
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
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Drink logged successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      // Refresh dashboard after logging
      await _loadDashboardData();
    }
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
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drinkmod'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard Stats (Streak & Weekly)
              if (dashboardStats != null && userName != null)
                DashboardStatsCard(
                  streak: 5, // TODO: Calculate actual streak
                  weeklyAdherence: 0.8, // TODO: Calculate actual weekly adherence
                  motivationalMessage: 'Keep up the great work!',
                ),
              
              const SizedBox(height: 16),
              
              // Welcome Message
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back${userName != null ? ', $userName' : ''}!',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Track your drinks and stay on top of your goals.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Today's Status Banner (matching Track page)
              TodayStatusCard(
                date: today,
                totalDrinks: totalDrinks,
                dailyLimit: dailyLimit,
                isDrinkingDay: isDrinkingDay,
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
