import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/onboarding_service.dart';
import '../../../core/constants/onboarding_constants.dart';

/// Classic single-page onboarding for rapid development testing
class OnboardingClassicScreen extends StatefulWidget {
  const OnboardingClassicScreen({super.key});

  @override
  State<OnboardingClassicScreen> createState() => _OnboardingClassicScreenState();
}

class _OnboardingClassicScreenState extends State<OnboardingClassicScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  String _selectedGender = OnboardingConstants.genderMale;
  String _selectedSchedule = OnboardingConstants.scheduleWeekendsOnly;
  int _selectedLimit = 2;
  int _selectedWeeklyLimit = 4; // For open schedules
  String _selectedMotivation = OnboardingConstants.motivationHealth;
  String _selectedFrequency = OnboardingConstants.frequencyOnceOrTwiceWeek;
  String _selectedAmount = OnboardingConstants.amount1To2;
  final List<String> _selectedDrinks = [OnboardingConstants.drinkBeer, OnboardingConstants.drinkWine];

  final List<String> _genderOptions = OnboardingConstants.genderOptions;
  final List<String> _scheduleOptions = OnboardingConstants.scheduleOptions;
  final List<String> _motivationOptions = OnboardingConstants.motivationOptions;
  final List<String> _frequencyOptions = OnboardingConstants.frequencyOptions;
  final List<String> _amountOptions = OnboardingConstants.amountOptions;
  final List<String> _drinkOptions = OnboardingConstants.drinkOptions;

  bool get _isOpenSchedule {
    return OnboardingConstants.scheduleTypeMap[_selectedSchedule] == OnboardingConstants.scheduleTypeOpen;
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
    if (_formKey.currentState!.validate()) {
      final userData = {
        'name': _nameController.text.trim(),
        'gender': _selectedGender,
        'schedule': _selectedSchedule,
        'drinkLimit': _selectedLimit,
        'drinkingFrequency': _selectedFrequency,
        'drinkingAmount': _selectedAmount,
        'motivation': _selectedMotivation,
        'favoriteDrinks': _selectedDrinks,
        'onboardingCompleted': true,
      };

      // Add weekly limit for open schedules
      if (_isOpenSchedule) {
        userData['weeklyLimit'] = _selectedWeeklyLimit;
      }

      await OnboardingService.completeOnboarding(userData);
      
      if (mounted) {
        context.go('/home');
      }
    }
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
              const SizedBox(height: 32),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
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
                decoration: const InputDecoration(border: OutlineInputBorder()),
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
              const Text('Drinking Schedule', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedSchedule,
                decoration: const InputDecoration(border: OutlineInputBorder()),
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
                      _selectedWeeklyLimit = OnboardingConstants.defaultWeeklyLimits[_selectedSchedule] ?? 4;
                      // Ensure daily limit doesn't exceed half of weekly limit
                      final maxDaily = (_selectedWeeklyLimit / 2).floor();
                      _selectedLimit = _selectedLimit <= maxDaily ? _selectedLimit : maxDaily.clamp(1, OnboardingConstants.drinkLimitOptions.last);
                    }
                  });
                },
              ),
              const SizedBox(height: 24),

              // Weekly Limit (for open schedules only)
              if (_isOpenSchedule) ...[
                const Text('Weekly Drink Limit', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
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
                      if (_selectedLimit > maxDaily) {
                        _selectedLimit = maxDaily.clamp(1, OnboardingConstants.drinkLimitOptions.last);
                      }
                    });
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Daily Limit
              Text(
                _isOpenSchedule ? 'Maximum Drinks Per Day' : 'Daily Drink Limit',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              if (_isOpenSchedule)
                Text(
                  'Cannot exceed half your weekly limit (max ${(_selectedWeeklyLimit / 2).floor()} drinks per day).',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              if (_isOpenSchedule) const SizedBox(height: 8),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _selectedLimit,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
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
                decoration: const InputDecoration(border: OutlineInputBorder()),
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
                decoration: const InputDecoration(border: OutlineInputBorder()),
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
                decoration: const InputDecoration(border: OutlineInputBorder()),
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

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAndContinue,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Complete Setup',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('Back to Mode Selection'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
