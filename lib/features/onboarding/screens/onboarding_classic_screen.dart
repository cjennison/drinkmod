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
  String _selectedMotivation = OnboardingConstants.motivationHealth;
  String _selectedFrequency = OnboardingConstants.frequencyOnceOrTwiceWeek;
  String _selectedAmount = OnboardingConstants.amount1To2;
  final List<String> _selectedDrinks = [OnboardingConstants.drinkBeer, OnboardingConstants.drinkWine];

  final List<String> _genderOptions = OnboardingConstants.genderOptions;
  final List<String> _scheduleOptions = OnboardingConstants.scheduleOptions;
  final List<int> _limitOptions = OnboardingConstants.drinkLimitOptions;
  final List<String> _motivationOptions = OnboardingConstants.motivationOptions;
  final List<String> _frequencyOptions = OnboardingConstants.frequencyOptions;
  final List<String> _amountOptions = OnboardingConstants.amountOptions;
  final List<String> _drinkOptions = OnboardingConstants.drinkOptions;

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
        'scheduleType': _selectedSchedule,
        'drinkLimit': _selectedLimit,
        'drinkingFrequency': _selectedFrequency,
        'drinkingAmount': _selectedAmount,
        'motivation': _selectedMotivation,
        'favoriteDrinks': _selectedDrinks,
        'onboardingCompleted': true,
      };

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
                onChanged: (value) => setState(() => _selectedSchedule = value!),
              ),
              const SizedBox(height: 24),

              // Daily Limit
              const Text('Daily Drink Limit', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _selectedLimit,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: _limitOptions.map((limit) {
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
