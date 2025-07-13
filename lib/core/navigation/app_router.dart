import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../core/services/onboarding_service.dart';

/// Screen that checks onboarding status and redirects accordingly
class OnboardingCheckScreen extends StatefulWidget {
  const OnboardingCheckScreen({super.key});

  @override
  State<OnboardingCheckScreen> createState() => _OnboardingCheckScreenState();
}

class _OnboardingCheckScreenState extends State<OnboardingCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final isCompleted = await OnboardingService.isOnboardingCompleted();
    
    if (mounted) {
      if (isCompleted) {
        context.go('/home');
      } else {
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
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
      
      // Onboarding flow
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Main home screen after onboarding
      GoRoute(
        path: '/home',
        name: 'main-home',
        builder: (context, state) => const HomeScreen(),
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
