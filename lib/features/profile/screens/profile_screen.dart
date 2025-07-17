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
  bool _showDeveloperTools = false;

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

  Future<void> _debugGoalLoading() async {
    try {
      print('=== DEBUG GOAL LOADING ===');
      
      // Test HiveCore initialization by calling a method that ensures it
      print('Testing goal service initialization...');
      
      // Get all goals (this will trigger initialization)
      print('Getting all goals...');
      final allGoals = GoalManagementService.instance.getAllGoals();
      print('Total goals found: ${allGoals.length}');
      for (int i = 0; i < allGoals.length; i++) {
        final goal = allGoals[i];
        print('Goal $i: ${goal['id']} - ${goal['title']} - Status: ${goal['status']}');
      }
      
      // Get active goals specifically
      print('Getting active goals...');
      final activeGoals = GoalManagementService.instance.getActiveGoals();
      print('Active goals found: ${activeGoals.length}');
      
      // Get the single active goal
      print('Getting single active goal...');
      final activeGoal = await GoalManagementService.instance.getActiveGoal();
      print('Single active goal: ${activeGoal != null ? activeGoal['id'] : 'null'}');
      if (activeGoal != null) {
        print('Active goal details: ${activeGoal.toString()}');
      }
      
      // Get goal history
      print('Getting goal history...');
      final goalHistory = GoalManagementService.instance.getGoalHistory();
      print('Goal history count: ${goalHistory.length}');
      
      print('=== END DEBUG ===');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Debug complete - check console output. Active goal: ${activeGoal != null ? 'Found' : 'None'}'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('=== DEBUG ERROR ===');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Debug failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
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

  Widget _buildEditableInfoCard(String title, String? value, VoidCallback onEdit, {IconData? icon}) {
    return Card(
      child: ListTile(
        leading: icon != null ? Icon(icon, color: Colors.grey[600]) : null,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          value ?? 'Not set',
          style: TextStyle(
            color: value != null ? null : Colors.grey[600],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onEdit,
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(String title, String subtitle, IconData icon, Color color, String status, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
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
        leading: const Icon(Icons.schedule, color: Colors.orange),
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
                color: schedule != null ? null : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (limitInfo.isNotEmpty) ...[
              const SizedBox(height: 4),
              ...limitInfo.map((info) => Text(
                info,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              )),
            ],
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
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
        title: const Text('Profile & Settings'),
        automaticallyImplyLeading: false,
        actions: [
          // Developer toggle (tap 7 times on version to reveal)
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(_showDeveloperTools ? Icons.visibility_off : Icons.developer_mode),
                  title: Text(_showDeveloperTools ? 'Hide Dev Tools' : 'Show Dev Tools'),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () {
                  setState(() {
                    _showDeveloperTools = !_showDeveloperTools;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildSectionHeader(
              'Your Profile',
              'Personal information and motivation',
              Icons.person,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            
            _buildEditableInfoCard('Name & Gender', 
              userData?['name'] != null && userData?['gender'] != null
                ? '${userData!['name']} (${_formatGender(userData!['gender'])})'
                : 'Not set', 
              _editNameAndGender,
              icon: Icons.badge),
            _buildEditableInfoCard('Motivation', _formatMotivation(userData?['motivation']), _editMotivation,
              icon: Icons.psychology),
            
            const SizedBox(height: 32),
            
            // Behavior Settings Section
            _buildSectionHeader(
              'Behavior Settings',
              'Configure your drinking patterns and limits',
              Icons.tune,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            
            _buildScheduleCard(),
            _buildEditableInfoCard('Limit Strictness', _formatStrictnessLevel(userData?['strictnessLevel']), _editStrictnessLevel,
              icon: Icons.security),
            _buildEditableInfoCard('Previous Patterns', 
              _formatDrinkingPatterns(userData), 
              _editDrinkingPatterns,
              icon: Icons.history),
            
            const SizedBox(height: 32),
            
            // Smart Features Section
            _buildSectionHeader(
              'Smart Features',
              'Intelligent tools to support your goals',
              Icons.psychology,
              Colors.purple,
            ),
            const SizedBox(height: 12),
            
            _buildFeatureCard(
              'Smart Reminders',
              'Get nudged at the right moments',
              Icons.notifications_active,
              Colors.purple,
              '0 active', // TODO: Replace with actual count
              () {
                // TODO: Navigate to reminders setup
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Smart Reminders coming soon!')),
                );
              },
            ),
            _buildFeatureCard(
              'Intervention Tracking',
              'Monitor your resistance to urges',
              Icons.shield,
              Colors.teal,
              'Active', // TODO: Replace with actual status
              () {
                // TODO: Navigate to intervention settings
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Intervention settings coming soon!')),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Preferences Section
            _buildSectionHeader(
              'Preferences',
              'Customize your app experience',
              Icons.settings,
              Colors.green,
            ),
            const SizedBox(height: 12),
            
            Card(
              child: ListTile(
                leading: const Icon(Icons.wine_bar, color: Colors.amber),
                title: const Text('Favorite Drinks'),
                subtitle: Text(
                  userData?['favoriteDrinks'] != null 
                    ? (userData!['favoriteDrinks'] as List).join(', ')
                    : 'None selected',
                  style: TextStyle(
                    color: userData?['favoriteDrinks'] != null ? null : Colors.grey[600],
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _editFavoriteDrinks,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Developer Tools Section (conditionally shown)
            if (_showDeveloperTools) ...[
              _buildSectionHeader(
                'Developer Tools',
                'Debug and testing utilities',
                Icons.developer_mode,
                Colors.red,
              ),
              const SizedBox(height: 12),
              
              Card(
                color: Colors.red[50],
                child: ListTile(
                  leading: const Icon(Icons.bug_report, color: Colors.purple),
                  title: const Text('Test Goal Loading'),
                  subtitle: const Text('Test goal data persistence and loading'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _debugGoalLoading,
                ),
              ),
              
              Card(
                color: Colors.red[50],
                child: ListTile(
                  leading: const Icon(Icons.science, color: Colors.purple),
                  title: const Text('Generate Test Persona Data'),
                  subtitle: const Text('Load personas for testing goals'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showPersonaSelector,
                ),
              ),
              
              Card(
                color: Colors.red[50],
                child: ListTile(
                  leading: const Icon(Icons.clear_all, color: Colors.red),
                  title: const Text('Clear Active Goal'),
                  subtitle: const Text('Remove current goal (for development/testing)'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _clearActiveGoals,
                ),
              ),
              
              Card(
                color: Colors.red[50],
                child: ListTile(
                  leading: const Icon(Icons.refresh, color: Colors.orange),
                  title: const Text('Reset Onboarding'),
                  subtitle: const Text('Start over with fresh settings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _resetOnboarding,
                ),
              ),
              
              const SizedBox(height: 32),
            ],
            
            // App Info
            _buildSectionHeader(
              'About',
              'App information and support',
              Icons.info,
              Colors.grey,
            ),
            const SizedBox(height: 12),
            
            Card(
              child: const ListTile(
                leading: Icon(Icons.info_outline, color: Colors.grey),
                title: Text('App Version'),
                subtitle: Text('1.0.0 - Stage 2.5'),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
