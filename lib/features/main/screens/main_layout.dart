import 'package:flutter/material.dart';
import '../../home/screens/home_screen.dart';
import '../../tracking/screens/tracking_screen.dart';
import '../../progress/screens/progress_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../mindful/screens/mindful_screen.dart';

/// Main app layout with Material Design 3 bottom navigation
/// Provides the core navigation structure after onboarding completion
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // Main app screens following M3 navigation guidelines (3-5 destinations max)
  final List<Widget> _screens = [
    const HomeScreen(),
    const TrackingScreen(),
    const ProgressScreen(),
    const MindfulScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.track_changes),
              label: 'Track',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.self_improvement),
              label: 'Mindful',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
    );
  }
}
