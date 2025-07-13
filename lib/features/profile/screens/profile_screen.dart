import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/onboarding_service.dart';

/// Profile screen for user data management and settings
/// Allows users to view and edit their information, and reset onboarding
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await OnboardingService.getUserData();
    setState(() {
      userData = data;
      isLoading = false;
    });
  }

  Future<void> _resetOnboarding() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Onboarding'),
        content: const Text(
          'This will delete all your current settings and restart the onboarding process. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (shouldReset == true && mounted) {
      await OnboardingService.clearOnboardingData();
      if (mounted) {
        context.go('/onboarding');
      }
    }
  }

  Widget _buildInfoCard(String title, String? value) {
    return Card(
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          value ?? 'Not set',
          style: TextStyle(
            color: value != null ? null : Colors.grey,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Implement inline editing in future update
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Editing will be available in a future update'),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Section
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildInfoCard('Name', userData?['name']),
            _buildInfoCard('Gender', userData?['gender']),
            _buildInfoCard('Motivation', userData?['motivation']),
            
            const SizedBox(height: 24),
            
            // Drinking Patterns Section
            const Text(
              'Drinking Patterns',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildInfoCard('Frequency', userData?['drinkingFrequency']),
            _buildInfoCard('Amount', userData?['drinkingAmount']),
            _buildInfoCard('Schedule Type', userData?['scheduleType']),
            _buildInfoCard('Drink Limit', userData?['drinkLimit']?.toString()),
            
            const SizedBox(height: 24),
            
            // Favorite Drinks Section
            const Text(
              'Favorite Drinks',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              child: ListTile(
                title: const Text(
                  'Favorite Drinks',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  userData?['favoriteDrinks'] != null 
                    ? (userData!['favoriteDrinks'] as List).join(', ')
                    : 'None selected',
                  style: TextStyle(
                    color: userData?['favoriteDrinks'] != null ? null : Colors.grey,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Editing will be available in a future update'),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Settings Section
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              child: ListTile(
                leading: const Icon(Icons.refresh, color: Colors.orange),
                title: const Text('Reset Onboarding'),
                subtitle: const Text('Start over with fresh settings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _resetOnboarding,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // App Info
            Card(
              child: const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('App Version'),
                subtitle: Text('1.0.0 - Stage 2.5'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
