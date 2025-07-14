import 'package:flutter/material.dart';
import '../../../core/services/onboarding_service.dart';
import '../../../core/services/hive_database_service.dart';
import '../widgets/dashboard_stats_card.dart';
import '../widgets/quick_log_section.dart';
import '../widgets/allowance_display.dart';

/// Home screen - main dashboard after onboarding completion
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
      
      // Calculate basic stats
      final totalDrinks = logs.fold<double>(0, (sum, log) => sum + (log['standardDrinks'] ?? 0.0));
      final drinkLimit = currentUser!['drinkLimit'] ?? 2;
      
      final stats = {
        'todaysDrinks': totalDrinks,
        'dailyLimit': drinkLimit,
        'remaining': (drinkLimit - totalDrinks).clamp(0, drinkLimit),
        'logsToday': logs.length,
        'isAllowedDay': true, // TODO: Check schedule
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
      };
      
      if (mounted) {
        setState(() {
          dashboardStats = stats;
        });
      }
    }
  }
  
  Future<void> _handleQuickLog() async {
    if (currentUser == null) return;
    
    try {
      // Check limit status first
      final currentTotal = dashboardStats?['todaysDrinks'] ?? 0.0;
      final drinkLimit = dashboardStats?['dailyLimit'] ?? 2;
      
      if (currentTotal >= drinkLimit) {
        _showTherapeuticMessage('You\'ve reached your daily limit. Consider taking a break.');
        return;
      }
      
      // Log a quick drink entry
      await _databaseService.logDrink(
        drinkName: 'Quick Log',
        standardDrinks: 1.0,
        timestamp: DateTime.now(),
        notes: 'Quick log from dashboard',
      );
      
      // Refresh dashboard
      await _loadDashboardData();
      
      // Show positive reinforcement
      _showSuccessMessage('Drink logged successfully!');
      
    } catch (e) {
      debugPrint('Error logging drink: $e');
      _showErrorMessage('Failed to log drink. Please try again.');
    }
  }

  void _handleDetailedLog() {
    // TODO: Navigate to detailed logging screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Detailed logging coming soon!'),
      ),
    );
  }
  
  void _showTherapeuticMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Check In'),
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
  
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
  
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drinkmod'),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dashboard Stats
                    if (dashboardStats != null && userName != null)
                      DashboardStatsCard(
                        streak: 5, // TODO: Calculate actual streak
                        weeklyAdherence: 0.8, // TODO: Calculate actual weekly adherence
                        motivationalMessage: 'Keep up the great work!',
                      )
                    else
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: Text('Loading dashboard...'),
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 24),
                    
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
                    
                    const SizedBox(height: 24),
                    
                    // Quick Log Section
                    QuickLogSection(
                      favoriteDrinks: favoriteDrinks,
                      canLogToday: dashboardStats != null ? (dashboardStats!['todaysDrinks'] as double) < (dashboardStats!['dailyLimit'] as int) : true,
                      onQuickLog: _handleQuickLog,
                      onDetailedLog: _handleDetailedLog,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Allowance Display
                    if (dashboardStats != null)
                      AllowanceDisplay(
                        todaysDrinks: (dashboardStats!['todaysDrinks'] as double).round(),
                        dailyLimit: dashboardStats!['dailyLimit'] as int,
                        isAllowedDay: dashboardStats!['isAllowedDay'] as bool,
                        userName: userName ?? 'User',
                      ),
                    
                    const SizedBox(height: 100), // Bottom padding for better UX
                  ],
                ),
              ),
            ),
    );
  }
}
