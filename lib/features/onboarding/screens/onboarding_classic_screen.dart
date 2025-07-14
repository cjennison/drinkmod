import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/onboarding_service.dart';
import '../../../core/constants/onboarding_constants.dart';
import '../../profile/widgets/weekly_pattern_selector.dart';

/// Classic single-page onboarding for rapid development testing
class OnboardingClassicScreen extends StatefulWidget {
  const OnboardingClassicScreen({super.key});

  @override
  State<OnboardingClassicScreen> createState() => _OnboardingClassicScreenState();
}

class _OnboardingClassicScreenState extends State<OnboardingClassicScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  String? _selectedGender;
  String? _selectedSchedule;
  int? _selectedLimit;
  int _selectedWeeklyLimit = 4; // For open schedules
  List<int> _customWeeklyPattern = []; // For custom weekly patterns
  String? _selectedMotivation;
  String? _selectedFrequency;
  String? _selectedAmount;
  final List<String> _selectedDrinks = [];

  final List<String> _genderOptions = OnboardingConstants.genderOptions;
  final List<String> _scheduleOptions = OnboardingConstants.scheduleOptions;
  final List<String> _motivationOptions = OnboardingConstants.motivationOptions;
  final List<String> _frequencyOptions = OnboardingConstants.frequencyOptions;
  final List<String> _amountOptions = OnboardingConstants.amountOptions;
  final List<String> _drinkOptions = OnboardingConstants.drinkOptions;

  bool get _isOpenSchedule {
    if (_selectedSchedule == null) return false;
    return OnboardingConstants.scheduleTypeMap[_selectedSchedule!] == OnboardingConstants.scheduleTypeOpen;
  }

  List<int> get _validDailyLimits {
    if (!_isOpenSchedule) {
      return OnboardingConstants.drinkLimitOptions;
    }
    
    // For open schedules, daily limit cannot exceed half the weekly limit
    final maxDaily = (_selectedWeeklyLimit / 2).floor();
    final validLimits = OnboardingConstants.drinkLimitOptions
        .where((limit) => limit <= maxDaily)
        .toList();
    
    // Ensure at least one option is available (minimum 1 drink)
    if (validLimits.isEmpty) {
      return [1];
    }
    
    return validLimits;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _formatLabel(String value) {
    return OnboardingConstants.getDisplayText(value);
  }

  void _saveAndContinue() async {
    // Validate form fields
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate required fields
    List<String> errors = [];

    // Name is required (handled by form validator above)
    
    // Schedule is required (always has a value from dropdown)
    
    // Custom weekly pattern validation
    if (_selectedSchedule == OnboardingConstants.scheduleCustomWeekly && _customWeeklyPattern.isEmpty) {
      errors.add('Please select at least one day for your custom weekly pattern.');
    }

    // Daily limit validation (always has a value from dropdown)
    
    // Weekly limit validation for open schedules (always has a value from dropdown)

    // Show validation errors if any
    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errors.join('\n')),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    // All validation passed, save the data
    final userData = {
      'name': _nameController.text.trim(),
      'schedule': _selectedSchedule!,
      'drinkLimit': _selectedLimit!,
      'onboardingCompleted': true,
    };

    // Add optional fields only if selected
    if (_selectedGender != null) {
      userData['gender'] = _selectedGender!;
    }
    if (_selectedFrequency != null) {
      userData['drinkingFrequency'] = _selectedFrequency!;
    }
    if (_selectedAmount != null) {
      userData['drinkingAmount'] = _selectedAmount!;
    }
    if (_selectedMotivation != null) {
      userData['motivation'] = _selectedMotivation!;
    }
    if (_selectedDrinks.isNotEmpty) {
      userData['favoriteDrinks'] = _selectedDrinks;
    }

    // Add weekly limit for open schedules
    if (_isOpenSchedule) {
      userData['weeklyLimit'] = _selectedWeeklyLimit;
    }

    // Add weekly pattern for custom schedules
    if (_selectedSchedule! == OnboardingConstants.scheduleCustomWeekly) {
      userData['weeklyPattern'] = _customWeeklyPattern;
    }

    await OnboardingService.completeOnboarding(userData);
    
    if (mounted) {
      context.go('/home');
    }
  }

  /// Check if all required form fields are valid
  bool _isFormValid() {
    // Name is required and must be at least 2 characters
    if (_nameController.text.trim().isEmpty || _nameController.text.trim().length < 2) {
      return false;
    }
    
    // Schedule is required
    if (_selectedSchedule == null) {
      return false;
    }
    
    // Daily limit is required
    if (_selectedLimit == null) {
      return false;
    }
    
    // Custom weekly pattern must have at least one day selected
    if (_selectedSchedule == OnboardingConstants.scheduleCustomWeekly && _customWeeklyPattern.isEmpty) {
      return false;
    }
    
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Setup'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Classic Onboarding',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Quick setup for development testing',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Fields marked with * are required',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  hintText: 'Enter your first name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() {}), // Trigger rebuild for summary
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Gender
              const Text('Gender', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select your gender',
                ),
                items: _genderOptions.map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(_formatLabel(gender)),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedGender = value!),
              ),
              const SizedBox(height: 24),

              // Schedule
              const Text('Drinking Schedule *', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              const Text(
                'Choose when you plan to drink',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedSchedule,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select your drinking schedule',
                ),
                items: _scheduleOptions.map((schedule) {
                  return DropdownMenuItem(
                    value: schedule,
                    child: Text(_formatLabel(schedule)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSchedule = value!;
                    // Set default weekly limit for open schedules
                    if (_isOpenSchedule) {
                      _selectedWeeklyLimit = OnboardingConstants.defaultWeeklyLimits[_selectedSchedule!] ?? 4;
                      // Ensure daily limit doesn't exceed half of weekly limit
                      final maxDaily = (_selectedWeeklyLimit / 2).floor();
                      if (_selectedLimit != null && _selectedLimit! > maxDaily) {
                        _selectedLimit = maxDaily.clamp(1, OnboardingConstants.drinkLimitOptions.last);
                      } else if (_selectedLimit == null) {
                        _selectedLimit = maxDaily.clamp(1, OnboardingConstants.drinkLimitOptions.last);
                      }
                    } else {
                      // For strict schedules, set default daily limit if none selected
                      _selectedLimit ??= 2;
                    }
                  });
                },
              ),
              const SizedBox(height: 24),

              // Custom Weekly Pattern (for custom weekly schedules only)
              if (_selectedSchedule == OnboardingConstants.scheduleCustomWeekly) ...[
                const Text('Custom Weekly Pattern *', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                const Text(
                  'Select the days when you plan to drink',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: WeeklyPatternSelector(
                      initialPattern: _customWeeklyPattern,
                      onPatternChanged: (pattern) {
                        setState(() {
                          _customWeeklyPattern = pattern;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Weekly Limit (for open schedules only)
              if (_isOpenSchedule) ...[
                const Text('Weekly Drink Limit *', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                const Text(
                  'Open schedules allow drinking any day but limit total drinks per week.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _selectedWeeklyLimit,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: [2, 3, 4, 5, 6, 7, 8, 10, 12].map((limit) {
                    return DropdownMenuItem(
                      value: limit,
                      child: Text('$limit drinks per week'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedWeeklyLimit = value!;
                      // Ensure daily limit doesn't exceed half of weekly limit
                      final maxDaily = (_selectedWeeklyLimit / 2).floor();
                      if (_selectedLimit != null && _selectedLimit! > maxDaily) {
                        _selectedLimit = maxDaily.clamp(1, OnboardingConstants.drinkLimitOptions.last);
                      } else if (_selectedLimit == null) {
                        _selectedLimit = maxDaily.clamp(1, OnboardingConstants.drinkLimitOptions.last);
                      }
                    });
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Daily Limit
              Text(
                _isOpenSchedule ? 'Maximum Drinks Per Day *' : 'Daily Drink Limit *',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              if (_isOpenSchedule)
                Text(
                  'Cannot exceed half your weekly limit (max ${(_selectedWeeklyLimit / 2).floor()} drinks per day).',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              if (!_isOpenSchedule)
                const Text(
                  'Maximum drinks allowed on your drinking days',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _selectedLimit,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select daily drink limit',
                ),
                items: _validDailyLimits.map((limit) {
                  return DropdownMenuItem(
                    value: limit,
                    child: Text('$limit drink${limit > 1 ? 's' : ''}'),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedLimit = value!),
              ),
              const SizedBox(height: 24),

              // Drinking Frequency
              const Text('How often do you typically drink?', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedFrequency,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select drinking frequency',
                ),
                items: _frequencyOptions.map((frequency) {
                  return DropdownMenuItem(
                    value: frequency,
                    child: Text(_formatLabel(frequency)),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedFrequency = value!),
              ),
              const SizedBox(height: 24),

              // Drinking Amount
              const Text('How much do you typically drink per occasion?', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedAmount,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select typical amount',
                ),
                items: _amountOptions.map((amount) {
                  return DropdownMenuItem(
                    value: amount,
                    child: Text(_formatLabel(amount)),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedAmount = value!),
              ),
              const SizedBox(height: 24),

              // Motivation
              const Text('Primary Motivation', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedMotivation,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select your motivation',
                ),
                items: _motivationOptions.map((motivation) {
                  return DropdownMenuItem(
                    value: motivation,
                    child: Text(_formatLabel(motivation)),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedMotivation = value!),
              ),
              const SizedBox(height: 24),

              // Favorite Drinks
              const Text('Favorite Drinks', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _drinkOptions.map((drink) {
                      final isSelected = _selectedDrinks.contains(drink);
                      return FilterChip(
                        label: Text(drink),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedDrinks.add(drink);
                            } else {
                              _selectedDrinks.remove(drink);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Required fields warning (only show when fields are missing)
              if (!_isFormValid()) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_outlined, color: Colors.orange[700], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Required Information Missing:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Only show missing fields
                      if (_nameController.text.trim().isEmpty || _nameController.text.trim().length < 2)
                        const Text('• Name: Required (at least 2 characters)'),
                      if (_selectedSchedule == null)
                        const Text('• Schedule: Select your drinking schedule'),
                      if (_selectedLimit == null)
                        const Text('• Daily Limit: Select your daily drink limit'),
                      if (_selectedSchedule == OnboardingConstants.scheduleCustomWeekly && _customWeeklyPattern.isEmpty)
                        const Text('• Custom Days: Select at least 1 day for your drinking schedule'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isFormValid() ? _saveAndContinue : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: _isFormValid() 
                      ? Theme.of(context).colorScheme.primary 
                      : null, // Use default disabled color
                    foregroundColor: _isFormValid() 
                      ? Theme.of(context).colorScheme.onPrimary 
                      : null, // Use default disabled color
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isFormValid()) 
                        const Icon(Icons.check_circle_outline, size: 20)
                      else 
                        const Icon(Icons.lock_outline, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _isFormValid() ? 'Complete Setup' : 'Complete Required Fields First',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
