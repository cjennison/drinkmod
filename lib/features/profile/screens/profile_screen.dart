import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/onboarding_service.dart';
import '../../../core/constants/onboarding_constants.dart';
import '../widgets/name_editor_dialog.dart';
import '../widgets/motivation_editor_dialog.dart';
import '../widgets/schedule_editor_dialog.dart';
import '../widgets/drink_limit_editor_dialog.dart';
import '../widgets/favorite_drinks_editor_dialog.dart';
import '../widgets/drinking_patterns_editor_dialog.dart';

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

  Future<void> _editNameAndGender() async {
    await showDialog(
      context: context,
      builder: (context) => NameEditorDialog(
        currentName: userData?['name'],
        currentGender: userData?['gender'],
        onDataChanged: (name, gender) {
          setState(() {
            userData?['name'] = name;
            userData?['gender'] = gender;
          });
        },
      ),
    );
  }

  Future<void> _editMotivation() async {
    await showDialog(
      context: context,
      builder: (context) => MotivationEditorDialog(
        currentMotivation: userData?['motivation'],
        onMotivationChanged: (motivation) {
          setState(() {
            userData?['motivation'] = motivation;
          });
        },
      ),
    );
  }

  Future<void> _editSchedule() async {
    await showDialog(
      context: context,
      builder: (context) => ScheduleEditorDialog(
        currentSchedule: userData?['scheduleType'],
        onScheduleChanged: (schedule) {
          setState(() {
            userData?['scheduleType'] = schedule;
          });
          // Note: Database sync will be handled by home screen on next load
        },
      ),
    );
  }

  Future<void> _editDrinkLimit() async {
    await showDialog(
      context: context,
      builder: (context) => DrinkLimitEditorDialog(
        currentLimit: userData?['drinkLimit'],
        onLimitChanged: (limit) async {
          setState(() {
            userData?['drinkLimit'] = limit;
          });
          // Note: Database sync will be handled by home screen on next load
        },
      ),
    );
  }
  
  Future<void> _editFavoriteDrinks() async {
    final currentDrinks = userData?['favoriteDrinks'];
    List<String> drinksList = [];
    
    if (currentDrinks != null) {
      if (currentDrinks is List) {
        drinksList = currentDrinks.cast<String>();
      }
    }
    
    await showDialog(
      context: context,
      builder: (context) => FavoriteDrinksEditorDialog(
        currentDrinks: drinksList,
        onDrinksChanged: (drinks) {
          setState(() {
            userData?['favoriteDrinks'] = drinks;
          });
        },
      ),
    );
  }

  Future<void> _editDrinkingPatterns() async {
    await showDialog(
      context: context,
      builder: (context) => DrinkingPatternsEditorDialog(
        currentFrequency: userData?['drinkingFrequency'],
        currentAmount: userData?['drinkingAmount'],
        onPatternsChanged: (frequency, amount) async {
          setState(() {
            userData?['drinkingFrequency'] = frequency;
            userData?['drinkingAmount'] = amount;
          });
        },
      ),
    );
  }



  String _formatScheduleType(String? scheduleType) {
    if (scheduleType == null) return 'Not set';
    return OnboardingConstants.getDisplayText(scheduleType);
  }

  String _formatMotivation(String? motivation) {
    if (motivation == null) return 'Not set';
    return OnboardingConstants.getDisplayText(motivation);
  }

  String _formatGender(String? gender) {
    if (gender == null) return '';
    return OnboardingConstants.getDisplayText(gender);
  }

  Widget _buildEditableInfoCard(String title, String? value, VoidCallback onEdit) {
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
        trailing: const Icon(Icons.edit),
        onTap: onEdit,
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
            
            _buildEditableInfoCard('Name & Gender', 
              userData?['name'] != null && userData?['gender'] != null
                ? '${userData!['name']} (${_formatGender(userData!['gender'])})'
                : 'Not set', 
              _editNameAndGender),
            _buildEditableInfoCard('Motivation', _formatMotivation(userData?['motivation']), _editMotivation),
            
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
            
            _buildEditableInfoCard('Drinking Patterns', 
              '${OnboardingConstants.getDisplayText(userData?['drinkingFrequency'] ?? '')}, ${OnboardingConstants.getDisplayText(userData?['drinkingAmount'] ?? '')}', 
              _editDrinkingPatterns),
            _buildEditableInfoCard('Schedule Type', _formatScheduleType(userData?['scheduleType']), _editSchedule),
            _buildEditableInfoCard('Drink Limit', userData?['drinkLimit']?.toString(), _editDrinkLimit),
            
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
                trailing: const Icon(Icons.edit),
                onTap: _editFavoriteDrinks,
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
