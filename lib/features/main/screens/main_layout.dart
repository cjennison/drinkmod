import 'package:flutter/material.dart';
import '../../home/screens/home_screen.dart';
import '../../tracking/screens/tracking_screen.dart';
import '../../progress/screens/progress_screen.dart';
import '../../profile/screens/profile_screen.dart';

/// Main app layout with Material Design 3 bottom navigation
/// Provides the core navigation structure after onboarding completion
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  // Main app screens following M3 navigation guidelines (3-5 destinations max)
  List<Widget> get _screens => [
    HomeScreen(
      onNavigateToTracking: () => _onDestinationSelected(1),
      onNavigateToProgress: () => _onDestinationSelected(2),
    ),
    const TrackingScreen(),
    const ProgressScreen(),
    const ProfileScreen(),
  ];

  // Navigation destinations with M3 design patterns
  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.add_circle_outline),
      selectedIcon: Icon(Icons.add_circle),
      label: 'Track',
    ),
    NavigationDestination(
      icon: Icon(Icons.trending_up_outlined),
      selectedIcon: Icon(Icons.trending_up),
      label: 'Progress',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: _screens,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: _destinations,
        // M3 Expressive navigation styling
        height: 70,
        elevation: 8,
        shadowColor: Colors.black12,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: Theme.of(context).colorScheme.secondaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}
