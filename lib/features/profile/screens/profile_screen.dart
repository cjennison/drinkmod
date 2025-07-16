import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/onboarding_service.dart';
import '../../../core/services/goal_management_service.dart';
import '../../../core/services/persona_data_service.dart';
import '../../../core/constants/onboarding_constants.dart';
import '../widgets/name_editor_dialog.dart';
import '../widgets/motivation_editor_dialog.dart';
import '../widgets/strictness_level_editor_dialog.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload data when returning from sub-pages
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
        context.go('/');
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

  Future<void> _editStrictnessLevel() async {
    await showDialog(
      context: context,
      builder: (context) => StrictnessLevelEditorDialog(
        currentStrictnessLevel: userData?['strictnessLevel'],
        onStrictnessLevelChanged: (strictnessLevel) {
          setState(() {
            userData?['strictnessLevel'] = strictnessLevel;
          });
        },
      ),
    );
  }

  Future<void> _editSchedule() async {
    if (mounted) {
      context.push('/profile/schedule-editor', extra: {
        'currentSchedule': userData?['schedule'],
        'currentDailyLimit': userData?['drinkLimit'],
        'currentWeeklyLimit': userData?['weeklyLimit'],
      });
    }
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

  Future<void> _showCurrentGoals() async {
    try {
      final activeGoal = GoalManagementService.instance.getActiveGoal();
      
      if (!mounted) return;
      
      if (activeGoal == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No active goal found'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Current Active Goal'),
          content: SingleChildScrollView(
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeGoal['title'] ?? 'Untitled Goal',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Type: ${activeGoal['goalType'] ?? 'Unknown'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (activeGoal['parameters'] != null) ...[
                      Text(
                        'Target: ${activeGoal['parameters']['targetValue'] ?? 'N/A'} ${activeGoal['parameters']['targetUnit'] ?? ''}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Duration: ${activeGoal['parameters']['targetPeriodDays'] ?? 'N/A'} days',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                    if (activeGoal['description'] != null && activeGoal['description'].toString().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Description: ${activeGoal['description']}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                    if (activeGoal['metrics'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Progress: ${((activeGoal['metrics']['currentProgress'] ?? 0.0) * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading goal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showGoalHistory() async {
    try {
      final goalHistory = GoalManagementService.instance.getGoalHistory();
      
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Goal History (${goalHistory.length})'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: goalHistory.isEmpty
                  ? [
                      const Text(
                        'No completed goals yet. Keep working on your current goal!',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ]
                  : goalHistory.map((goal) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                goal['title'] ?? 'Completed Goal',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Type: ${goal['goalType'] ?? 'Unknown'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              if (goal['updatedAt'] != null) ...[
                                Text(
                                  'Completed: ${DateTime.parse(goal['updatedAt']).toLocal().toString().split(' ')[0]}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading goal history: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearActiveGoals() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Active Goal'),
        content: const Text(
          'This will remove your active goal and reset your progress. Your goal will be moved to history. Are you sure?',
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
            child: const Text('Clear Goal'),
          ),
        ],
      ),
    );

    if (shouldClear == true) {
      try {
        // Complete the active goal (moves it to history)
        await GoalManagementService.instance.completeActiveGoal();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Active goal cleared and moved to history'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error clearing goal: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showPersonaSelector() async {
    final personas = PersonaDataService.availablePersonas;
    
    final selectedPersona = await showDialog<PersonaDefinition>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Test Persona'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: personas.length,
            itemBuilder: (context, index) {
              final persona = personas[index];
              return Card(
                child: ListTile(
                  title: Text(persona.name),
                  subtitle: Text(persona.description),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).pop(persona),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedPersona != null) {
      await _loadPersonaData(selectedPersona);
    }
  }

  Future<void> _loadPersonaData(PersonaDefinition persona) async {
    final shouldLoad = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Load ${persona.name}?'),
        content: Text(
          'This will:\n'
          '• Clear all existing data\n'
          '• Generate ${persona.days} days of test drink data\n'
          '• Create a ${persona.goalType.name} goal\n'
          '• Set up realistic test scenario\n\n'
          'Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Load Persona'),
          ),
        ],
      ),
    );

    if (shouldLoad == true) {
      try {
        // Show loading indicator
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Loading ${persona.name} data...'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        
        // Generate the persona data
        await PersonaDataService.generatePersonaData(persona);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${persona.name} data loaded successfully!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading persona: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _formatMotivation(String? motivation) {
    if (motivation == null) return 'Not set';
    return OnboardingConstants.getDisplayText(motivation);
  }

  String _formatStrictnessLevel(String? strictness) {
    if (strictness == null) return 'Not set';
    switch (strictness) {
      case OnboardingConstants.strictnessHigh:
        return 'High Strictness (No tolerance)';
      case OnboardingConstants.strictnessMedium:
        return 'Medium Strictness (50% tolerance)';
      case OnboardingConstants.strictnessLow:
        return 'Low Strictness (100% tolerance)';
      default:
        return strictness;
    }
  }

  String _formatGender(String? gender) {
    if (gender == null) return '';
    return OnboardingConstants.getDisplayText(gender);
  }

  String _formatDrinkingPatterns(Map<String, dynamic>? userData) {
    if (userData == null) return 'Not set';
    
    final frequency = userData['drinkingFrequency'] ?? '';
    final amount = userData['drinkingAmount'] ?? '';
    
    final displayFrequency = OnboardingConstants.getDisplayText(frequency);
    final displayAmount = OnboardingConstants.getDisplayText(amount);
    
    // If both are "Not set", just return "Not set"
    if (displayFrequency == 'Not set' && displayAmount == 'Not set') {
      return 'Not set';
    }
    
    // If one is "Not set", only show the other
    if (displayFrequency == 'Not set') {
      return displayAmount;
    }
    if (displayAmount == 'Not set') {
      return displayFrequency;
    }
    
    // Both have values, combine them
    return '$displayFrequency, $displayAmount';
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

  Widget _buildScheduleCard() {
    final schedule = userData?['schedule'];
    final dailyLimit = userData?['drinkLimit'];
    final weeklyLimit = userData?['weeklyLimit'];
    final weeklyPattern = userData?['weeklyPattern'] as List<dynamic>?;
    
    String scheduleText = 'Not set';
    List<String> limitInfo = [];
    
    if (schedule != null) {
      scheduleText = OnboardingConstants.getDisplayText(schedule);
      
      // Add weekly pattern display for custom schedules
      if (schedule == OnboardingConstants.scheduleCustomWeekly && weeklyPattern != null) {
        final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final selectedDays = List<int>.from(weeklyPattern)..sort();
        if (selectedDays.isNotEmpty) {
          final daysList = selectedDays.map((day) => dayNames[day]).join(', ');
          scheduleText += ' ($daysList)';
        }
      }
      
      if (dailyLimit != null) {
        limitInfo.add('Daily: $dailyLimit drinks');
      }
      
      final isOpen = OnboardingConstants.scheduleTypeMap[schedule] == OnboardingConstants.scheduleTypeOpen;
      if (isOpen && weeklyLimit != null) {
        limitInfo.add('Weekly: $weeklyLimit drinks');
      }
    }
    
    return Card(
      child: ListTile(
        title: const Text(
          'Drinking Schedule & Limits',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              scheduleText,
              style: TextStyle(
                color: schedule != null ? null : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (limitInfo.isNotEmpty) ...[
              const SizedBox(height: 4),
              ...limitInfo.map((info) => Text(
                info,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              )),
            ],
          ],
        ),
        trailing: const Icon(Icons.edit),
        onTap: _editSchedule,
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
            _buildEditableInfoCard('Limit Strictness', _formatStrictnessLevel(userData?['strictnessLevel']), _editStrictnessLevel),
            _buildEditableInfoCard('Old Drinking Patterns', 
              _formatDrinkingPatterns(userData), 
              _editDrinkingPatterns),
            
            const SizedBox(height: 24),
            
            // Drinking Schedule Section
            const Text(
              'Drinking Schedule & Limits',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildScheduleCard(),
            
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

            // Goal Management Section
            Card(
              child: ListTile(
                leading: const Icon(Icons.visibility, color: Colors.blue),
                title: const Text('View Current Goal'),
                subtitle: const Text('See your active goal and progress'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showCurrentGoals,
              ),
            ),
            
            Card(
              child: ListTile(
                leading: const Icon(Icons.history, color: Colors.green),
                title: const Text('Goal History'),
                subtitle: const Text('View your completed goals'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showGoalHistory,
              ),
            ),
            
            Card(
              child: ListTile(
                leading: const Icon(Icons.science, color: Colors.purple),
                title: const Text('Generate Test Persona Data'),
                subtitle: const Text('Load personas for testing goals'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showPersonaSelector,
              ),
            ),
            
            Card(
              child: ListTile(
                leading: const Icon(Icons.clear_all, color: Colors.red),
                title: const Text('Clear Active Goal'),
                subtitle: const Text('Remove current goal (for development/testing)'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _clearActiveGoals,
              ),
            ),
            
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
