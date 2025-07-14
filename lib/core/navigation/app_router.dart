import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/onboarding/screens/onboarding_mode_selector.dart';
import '../../features/onboarding/screens/onboarding_classic_screen.dart';
import '../../features/main/screens/main_layout.dart';
import '../../core/services/onboarding_service.dart';

/// Screen that checks onboarding status and redirects accordingly
class OnboardingCheckScreen extends StatefulWidget {
  const OnboardingCheckScreen({super.key});

  @override
  State<OnboardingCheckScreen> createState() => _OnboardingCheckScreenState();
}

class _OnboardingCheckScreenState extends State<OnboardingCheckScreen> {
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    print('OnboardingCheckScreen initState called');
    _checkOnboardingStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check onboarding status every time we return to this screen
    print('OnboardingCheckScreen didChangeDependencies called');
    if (!_isChecking) {
      _checkOnboardingStatus();
    }
  }

  Future<void> _checkOnboardingStatus() async {
    if (_isChecking) return;
    
    try {
      _isChecking = true;
      print('Checking onboarding status...');
      
      // Debug the current state
      await OnboardingService.debugOnboardingState();
      
      final isCompleted = await OnboardingService.isOnboardingCompleted();
      print('Onboarding completed: $isCompleted');
      
      if (mounted) {
        if (isCompleted) {
          print('Navigating to /home');
          context.go('/home');
        } else {
          print('Navigating to /onboarding-selector');
          context.go('/onboarding-selector');
        }
      }
    } catch (e) {
      print('Error checking onboarding status: $e');
      // Fallback to onboarding selector on error
      if (mounted) {
        context.go('/onboarding-selector');
      }
    } finally {
      _isChecking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Checking status...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// App Navigation Configuration
/// Defines all routes and navigation flow for the Drinkmod app
class AppRouter {
  static const String home = '/';
  static const String onboarding = '/onboarding';
  static const String dashboard = '/dashboard';
  static const String tracking = '/tracking';
  static const String analytics = '/analytics';
  static const String milestones = '/milestones';
  static const String settings = '/settings';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      // Home route - checks onboarding status and redirects accordingly
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const OnboardingCheckScreen(),
      ),
      
      // Onboarding mode selector
      GoRoute(
        path: '/onboarding-selector',
        name: 'onboarding-selector',
        builder: (context, state) => const OnboardingModeSelectorScreen(),
      ),
      
      // Onboarding flow - Agent mode
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Onboarding flow - Classic mode
      GoRoute(
        path: '/onboarding-classic',
        name: 'onboarding-classic',
        builder: (context, state) => const OnboardingClassicScreen(),
      ),
      
      // Main home screen after onboarding
      GoRoute(
        path: '/home',
        name: 'main-home',
        builder: (context, state) => const MainLayout(),
      ),
      
      // TODO: Implement other screens in Stage 3
      // // Main app routes
      // GoRoute(
      //   path: dashboard,
      //   name: 'dashboard',
      //   builder: (context, state) => const DashboardScreen(),
      // ),
      
      // GoRoute(
      //   path: tracking,
      //   name: 'tracking',
      //   builder: (context, state) => const TrackingScreen(),
      // ),
      
      // GoRoute(
      //   path: analytics,
      //   name: 'analytics',
      //   builder: (context, state) => const AnalyticsScreen(),
      // ),
      
      // GoRoute(
      //   path: milestones,
      //   name: 'milestones',
      //   builder: (context, state) => const MilestonesScreen(),
      // ),
      
      // GoRoute(
      //   path: settings,
      //   name: 'settings',
      //   builder: (context, state) => const SettingsScreen(),
      // ),
    ],
    
    // Error handling
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: const Center(
        child: Text('The requested page could not be found.'),
      ),
    ),
  );
}
