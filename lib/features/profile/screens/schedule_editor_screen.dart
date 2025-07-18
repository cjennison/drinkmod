import 'package:flutter/material.dart';
import '../../../core/services/onboarding_service.dart';
import '../../../core/constants/onboarding_constants.dart';
import '../widgets/weekly_pattern_selector.dart';

/// Screen for editing user's drinking schedule and limits
class ScheduleEditorScreen extends StatefulWidget {
  final String? currentSchedule;
  final int? currentDailyLimit;
  final int? currentWeeklyLimit;

  const ScheduleEditorScreen({
    super.key,
    this.currentSchedule,
    this.currentDailyLimit,
    this.currentWeeklyLimit,
  });

  @override
  State<ScheduleEditorScreen> createState() => _ScheduleEditorScreenState();
}

class _ScheduleEditorScreenState extends State<ScheduleEditorScreen> {
  String? selectedSchedule;
  int selectedDailyLimit = 2;
  int selectedWeeklyLimit = 4;
  List<int> customWeeklyPattern = [];
  
  final List<Map<String, dynamic>> scheduleOptions = [
    {
      'type': OnboardingConstants.scheduleWeekendsOnly,
      'title': OnboardingConstants.getDisplayText(OnboardingConstants.scheduleWeekendsOnly),
      'description': 'Friday, Saturday, Sunday',
      'isStrict': true,
    },
    {
      'type': OnboardingConstants.scheduleFridayOnly,
      'title': OnboardingConstants.getDisplayText(OnboardingConstants.scheduleFridayOnly),
      'description': 'Social drinking on Fridays',
      'isStrict': true,
    },
    {
      'type': OnboardingConstants.scheduleSocialOccasions,
      'title': OnboardingConstants.getDisplayText(OnboardingConstants.scheduleSocialOccasions),
      'description': 'Flexible schedule with weekly limits',
      'isStrict': false,
    },
    {
      'type': OnboardingConstants.scheduleCustomWeekly,
      'title': OnboardingConstants.getDisplayText(OnboardingConstants.scheduleCustomWeekly),
      'description': 'Custom weekly drinking plan',
      'isStrict': true,
    },
  ];

  bool get _isOpenSchedule {
    if (selectedSchedule == null) return false;
    return OnboardingConstants.scheduleTypeMap[selectedSchedule] == OnboardingConstants.scheduleTypeOpen;
  }

  List<int> get _validDailyLimits {
    if (!_isOpenSchedule) {
      return OnboardingConstants.drinkLimitOptions;
    }
    
    // For open schedules, daily limit cannot exceed half the weekly limit
    final maxDaily = (selectedWeeklyLimit / 2).floor();
    final validLimits = OnboardingConstants.drinkLimitOptions
        .where((limit) => limit <= maxDaily)
        .toList();
    
    // Ensure at least one option is available (minimum 1 drink)
    if (validLimits.isEmpty) {
      return [1];
    }
    
    return validLimits;
  }

  /// Get the current daily limit, ensuring it's valid for the dropdown
  int get _validatedDailyLimit {
    final validLimits = _validDailyLimits;
    
    // If the current selected daily limit is not in the valid options,
    // adjust it to the closest valid option
    if (!validLimits.contains(selectedDailyLimit)) {
      return validLimits.reduce((a, b) => 
        (a - selectedDailyLimit).abs() < (b - selectedDailyLimit).abs() ? a : b);
    }
    
    return selectedDailyLimit;
  }

  /// Get the current weekly limit, ensuring it's valid for the dropdown
  int get _validatedWeeklyLimit {
    final validLimits = OnboardingConstants.weeklyLimitOptions;
    
    // If the current selected weekly limit is not in the valid options,
    // adjust it to the closest valid option
    if (!validLimits.contains(selectedWeeklyLimit)) {
      return validLimits.reduce((a, b) => 
        (a - selectedWeeklyLimit).abs() < (b - selectedWeeklyLimit).abs() ? a : b);
    }
    
    return selectedWeeklyLimit;
  }

  @override
  void initState() {
    super.initState();
    selectedSchedule = widget.currentSchedule;
    selectedDailyLimit = widget.currentDailyLimit ?? 2;
    selectedWeeklyLimit = widget.currentWeeklyLimit ?? 4;
    
    // Validate and adjust initial values to ensure they're in valid ranges
    _validateAndAdjustLimits();
    
    // Load current weekly pattern if it exists
    _loadCurrentWeeklyPattern();
  }

  /// Validate and adjust daily/weekly limits to ensure they're within valid ranges
  void _validateAndAdjustLimits() {
    // Ensure weekly limit is in valid options
    if (!OnboardingConstants.weeklyLimitOptions.contains(selectedWeeklyLimit)) {
      selectedWeeklyLimit = OnboardingConstants.weeklyLimitOptions.reduce((a, b) => 
        (a - selectedWeeklyLimit).abs() < (b - selectedWeeklyLimit).abs() ? a : b);
    }
    
    // Ensure daily limit is in valid options and doesn't exceed half of weekly limit for open schedules
    if (_isOpenSchedule) {
      final maxDaily = (selectedWeeklyLimit / 2).floor();
      final validDailyLimits = OnboardingConstants.drinkLimitOptions
          .where((limit) => limit <= maxDaily)
          .toList();
      
      if (validDailyLimits.isNotEmpty && !validDailyLimits.contains(selectedDailyLimit)) {
        selectedDailyLimit = validDailyLimits.reduce((a, b) => 
          (a - selectedDailyLimit).abs() < (b - selectedDailyLimit).abs() ? a : b);
      }
    } else {
      if (!OnboardingConstants.drinkLimitOptions.contains(selectedDailyLimit)) {
        selectedDailyLimit = OnboardingConstants.drinkLimitOptions.reduce((a, b) => 
          (a - selectedDailyLimit).abs() < (b - selectedDailyLimit).abs() ? a : b);
      }
    }
  }

  Future<void> _loadCurrentWeeklyPattern() async {
    try {
      final userData = await OnboardingService.getUserData();
      if (userData != null && userData.containsKey('weeklyPattern')) {
        final pattern = userData['weeklyPattern'];
        if (pattern is List) {
          setState(() {
            customWeeklyPattern = List<int>.from(pattern);
          });
        }
      }
    } catch (e) {
      print('Error loading weekly pattern: $e');
    }
  }

  Future<void> _autoSave() async {
    if (selectedSchedule == null) return;

    try {
      final Map<String, dynamic> updateData = {
        'schedule': selectedSchedule,
        'drinkLimit': selectedDailyLimit,
      };
      
      if (_isOpenSchedule) {
        updateData['weeklyLimit'] = selectedWeeklyLimit;
      }
      
      // Add custom weekly pattern for custom schedules
      if (selectedSchedule == OnboardingConstants.scheduleCustomWeekly) {
        updateData['weeklyPattern'] = customWeeklyPattern;
      }
      
      await OnboardingService.updateUserData(updateData);
    } catch (e) {
      // Silently handle errors in auto-save to avoid disrupting user experience
      print('Auto-save error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Drinking Schedule'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Schedule Selection
            const Text(
              'Drinking Schedule',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose when you plan to drink:',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            
            ...scheduleOptions.map((option) {
              final isSelected = selectedSchedule == option['type'];
              
              return Card(
                color: isSelected 
                  ? Theme.of(context).colorScheme.primaryContainer 
                  : null,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    option['title']!,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(option['description']!),
                  leading: Radio<String>(
                    value: option['type']!,
                    groupValue: selectedSchedule,
                    onChanged: (value) {
                      setState(() {
                        selectedSchedule = value;
                        // Set default limits based on schedule type
                        if (value != null) {
                          if (OnboardingConstants.scheduleTypeMap[value] == OnboardingConstants.scheduleTypeOpen) {
                            selectedWeeklyLimit = OnboardingConstants.defaultWeeklyLimits[value] ?? 4;
                            // Ensure daily limit doesn't exceed half of weekly limit
                            final maxDaily = (selectedWeeklyLimit / 2).floor();
                            selectedDailyLimit = selectedDailyLimit <= maxDaily ? selectedDailyLimit : maxDaily;
                          }
                        }
                      });
                      _autoSave();
                    },
                  ),
                  onTap: () {
                    setState(() {
                      selectedSchedule = option['type'];
                      // Set default limits based on schedule type
                      if (OnboardingConstants.scheduleTypeMap[selectedSchedule] == OnboardingConstants.scheduleTypeOpen) {
                        selectedWeeklyLimit = OnboardingConstants.defaultWeeklyLimits[selectedSchedule] ?? 4;
                        // Ensure daily limit doesn't exceed half of weekly limit
                        final maxDaily = (selectedWeeklyLimit / 2).floor();
                        selectedDailyLimit = selectedDailyLimit <= maxDaily ? selectedDailyLimit : maxDaily;
                      }
                    });
                    _autoSave();
                  },
                ),
              );
            }),
            
            // Custom Weekly Pattern Selector
            if (selectedSchedule == OnboardingConstants.scheduleCustomWeekly) ...[
              const SizedBox(height: 24),
              const Text(
                'Custom Weekly Pattern',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: WeeklyPatternSelector(
                    initialPattern: customWeeklyPattern,
                    onPatternChanged: (pattern) {
                      setState(() {
                        customWeeklyPattern = pattern;
                      });
                      _autoSave();
                    },
                  ),
                ),
              ),
            ],
            
            if (selectedSchedule != null) ...[
              const SizedBox(height: 24),
              
              // Limits Section
              const Text(
                'Drinking Limits',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Daily Limit
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daily Limit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isOpenSchedule 
                          ? 'Maximum drinks per day (cannot exceed half your weekly limit)'
                          : 'Maximum drinks on drinking days',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: _validatedDailyLimit,
                        decoration: const InputDecoration(
                          labelText: 'Drinks per day',
                        ),
                        isExpanded: true,
                        items: _validDailyLimits.map((limit) {
                          return DropdownMenuItem(
                            value: limit,
                            child: Text('$limit drinks'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDailyLimit = value!;
                          });
                          _autoSave();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              // Weekly Limit (for open schedules)
              if (_isOpenSchedule) ...[
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Weekly Limit',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Maximum drinks per week',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          value: _validatedWeeklyLimit,
                          decoration: const InputDecoration(
                            labelText: 'Drinks per week',
                          ),
                          isExpanded: true,
                          items: OnboardingConstants.weeklyLimitOptions.map((limit) {
                            return DropdownMenuItem(
                              value: limit,
                              child: Text('$limit drinks'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedWeeklyLimit = value!;
                              // Ensure daily limit doesn't exceed half of new weekly limit
                              final maxDaily = (selectedWeeklyLimit / 2).floor();
                              if (selectedDailyLimit > maxDaily) {
                                selectedDailyLimit = maxDaily.clamp(1, OnboardingConstants.drinkLimitOptions.last);
                              }
                            });
                            _autoSave();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Schedule Information Card
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Schedule Summary',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildScheduleSummary(),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSummary() {
    if (selectedSchedule == null) return const SizedBox.shrink();
    
    final scheduleDisplay = OnboardingConstants.getDisplayText(selectedSchedule!);
    
    if (_isOpenSchedule) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Schedule: $scheduleDisplay'),
          const SizedBox(height: 4),
          Text('Daily limit: $selectedDailyLimit drinks'),
          const SizedBox(height: 4),
          Text('Weekly limit: $selectedWeeklyLimit drinks'),
          const SizedBox(height: 8),
          const Text(
            'You can drink on any day, but within your daily and weekly limits.',
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Schedule: $scheduleDisplay'),
          const SizedBox(height: 4),
          Text('Daily limit: $selectedDailyLimit drinks'),
          const SizedBox(height: 8),
          const Text(
            'You can only drink on specific days according to your schedule.',
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
          ),
        ],
      );
    }
  }

}
