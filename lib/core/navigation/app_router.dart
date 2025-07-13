import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';

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
      // Home route - will check if user needs onboarding
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      
      // Onboarding flow
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Main app routes
      GoRoute(
        path: dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      
      GoRoute(
        path: tracking,
        name: 'tracking',
        builder: (context, state) => const TrackingScreen(),
      ),
      
      GoRoute(
        path: analytics,
        name: 'analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
      
      GoRoute(
        path: milestones,
        name: 'milestones',
        builder: (context, state) => const MilestonesScreen(),
      ),
      
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
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

// Placeholder screens for Stage 1 - will be implemented in future stages
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Drinkmod')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to Drinkmod',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your companion for mindful drinking',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => context.go(AppRouter.onboarding),
                child: const Text('Get Started'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go(AppRouter.dashboard),
                child: const Text('Go to Dashboard'),
              ),
              const SizedBox(height: 32),
              const Text(
                'Stage 1 Foundation Complete',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Dashboard Screen', style: TextStyle(fontSize: 24)),
            SizedBox(height: 16),
            Text('This will be implemented in Stage 3'),
          ],
        ),
      ),
    );
  }
}

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Drinks')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Tracking Screen', style: TextStyle(fontSize: 24)),
            SizedBox(height: 16),
            Text('This will be implemented in Stage 3'),
          ],
        ),
      ),
    );
  }
}

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Analytics Screen', style: TextStyle(fontSize: 24)),
            SizedBox(height: 16),
            Text('This will be implemented in Stage 4'),
          ],
        ),
      ),
    );
  }
}

class MilestonesScreen extends StatelessWidget {
  const MilestonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Milestones')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Milestones Screen', style: TextStyle(fontSize: 24)),
            SizedBox(height: 16),
            Text('This will be implemented in Stage 5'),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Settings Screen', style: TextStyle(fontSize: 24)),
            SizedBox(height: 16),
            Text('This will be implemented in later stages'),
          ],
        ),
      ),
    );
  }
}
