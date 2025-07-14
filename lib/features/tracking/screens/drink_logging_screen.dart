import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/drink_entry.dart';
import '../../../core/utils/drink_calculator.dart';
import '../../../core/services/hive_database_service.dart';
import 'drink_logging_cubit.dart';

/// Progressive disclosure drink logging screen with therapeutic features
class DrinkLoggingScreen extends StatefulWidget {
  final DateTime? selectedDate;
  final DrinkEntry? editingEntry;

  const DrinkLoggingScreen({
    super.key, 
    this.selectedDate,
    this.editingEntry,
  });

  @override
  State<DrinkLoggingScreen> createState() => _DrinkLoggingScreenState();
}

class _DrinkLoggingScreenState extends State<DrinkLoggingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Form data
  DrinkSuggestion? _selectedDrink;
  double? _customStandardDrinks;
  DateTime? _selectedDate;
  String? _selectedTimeOfDay;
  String? _location;
  String? _socialContext;
  int? _moodBefore;
  List<String> _triggers = [];
  String? _triggerDescription;
  String? _intention;
  int? _urgeIntensity;
  bool? _consideredAlternatives;
  String? _alternatives;
  int? _energyLevel;
  int? _hungerLevel;
  int? _stressLevel;
  String? _sleepQuality;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
    _selectedTimeOfDay = 'Afternoon'; // Default time of day
    
    // If editing, populate form with existing data
    if (widget.editingEntry != null) {
      _populateFromExistingEntry();
    }
  }

  void _populateFromExistingEntry() {
    final entry = widget.editingEntry!;
    _selectedDate = DateTime(entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
    _selectedTimeOfDay = entry.timeOfDay; // Use the stored time of day directly
    _location = entry.location;
    _socialContext = entry.socialContext;
    _moodBefore = entry.moodBefore;
    _triggers = entry.triggers ?? [];
    _triggerDescription = entry.triggerDescription;
    _intention = entry.intention;
    _urgeIntensity = entry.urgeIntensity;
    _consideredAlternatives = entry.consideredAlternatives;
    _alternatives = entry.alternatives;
    _energyLevel = entry.energyLevel;
    _hungerLevel = entry.hungerLevel;
    _stressLevel = entry.stressLevel;
    _sleepQuality = entry.sleepQuality;
    
    // Find matching drink
    final drinks = DrinkCalculator.getCommonDrinks();
    _selectedDrink = drinks.firstWhere(
      (d) => d.name == entry.drinkName,
      orElse: () => DrinkSuggestion('Custom', 'custom', entry.standardDrinks),
    );
    
    if (_selectedDrink!.name == 'Custom') {
      _customStandardDrinks = entry.standardDrinks;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DrinkLoggingCubit(HiveDatabaseService.instance),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.editingEntry != null ? 'Edit Drink' : 'Log a Drink'),
          actions: [
            if (_currentStep > 0)
              TextButton(
                onPressed: _canSkipToSave() ? _saveEntry : null,
                child: const Text('Save'),
              ),
          ],
        ),
        body: BlocBuilder<DrinkLoggingCubit, DrinkLoggingState>(
          builder: (context, state) {
            print('DrinkLoggingScreen - Builder called with state: ${state.runtimeType}');
            return Column(
              children: [
                // Progress indicator
                _buildProgressIndicator(),
                
                // Page content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentStep = index;
                      });
                    },
                    children: [
                      _buildDrinkSelectionStep(),
                      _buildContextStep(),
                      _buildEmotionalCheckInStep(),
                      _buildTherapeuticReflectionStep(),
                    ],
                  ),
                ),
                
                // Navigation buttons
                _buildNavigationButtons(state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 4,
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green
                    : isActive
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDrinkSelectionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What did you drink?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Select from common drinks or enter a custom amount',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          
          // Time selection
          _buildTimeSelector(),
          const SizedBox(height: 24),
          
          // Drink selection
          _buildDrinkSelector(),
          
          if (_selectedDrink?.name == 'Custom') ...[
            const SizedBox(height: 16),
            _buildCustomDrinkInput(),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time of day:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TriggerConstants.timeOfDayOptions.map((timeOfDay) {
                final isSelected = _selectedTimeOfDay == timeOfDay;
                return FilterChip(
                  label: Text(timeOfDay),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedTimeOfDay = selected ? timeOfDay : null;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrinkSelector() {
    final drinks = DrinkCalculator.getCommonDrinks();
    drinks.add(DrinkSuggestion('Custom', 'custom', 1.0));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select drink type:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: drinks.length,
          itemBuilder: (context, index) {
            final drink = drinks[index];
            final isSelected = _selectedDrink?.name == drink.name;
            
            return Card(
              elevation: isSelected ? 4 : 1,
              color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedDrink = drink;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        drink.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${drink.standardDrinks.toStringAsFixed(1)} ${drink.standardDrinks == 1 ? 'drink' : 'drinks'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCustomDrinkInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Custom drink amount:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _customStandardDrinks?.toString(),
              decoration: const InputDecoration(
                labelText: 'Standard drinks',
                hintText: 'e.g., 1.5',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                setState(() {
                  _customStandardDrinks = double.tryParse(value);
                });
              },
            ),
            const SizedBox(height: 8),
            Text(
              'One standard drink = 14g of pure alcohol\n(12oz beer, 5oz wine, 1.5oz spirits)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Context & Setting',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Help us understand the situation (optional)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          
          _buildLocationSelector(),
          const SizedBox(height: 16),
          _buildSocialContextSelector(),
        ],
      ),
    );
  }

  Widget _buildLocationSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Where are you?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TriggerConstants.locations.map((location) {
                final isSelected = _location == location;
                return FilterChip(
                  label: Text(location),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _location = selected ? location : null;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialContextSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Who are you with?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TriggerConstants.socialContexts.map((context) {
                final isSelected = _socialContext == context;
                return FilterChip(
                  label: Text(context),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _socialContext = selected ? context : null;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionalCheckInStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Check in with yourself (optional but helpful)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          
          _buildMoodSelector(),
          const SizedBox(height: 16),
          _buildTriggerSelector(),
          const SizedBox(height: 16),
          _buildTriggerDescription(),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood (1-10)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(10, (index) {
                final mood = index + 1;
                final isSelected = _moodBefore == mood;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _moodBefore = mood;
                    });
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey.shade200,
                    ),
                    child: Center(
                      child: Text(
                        mood.toString(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('😢 Low', style: Theme.of(context).textTheme.bodySmall),
                Text('😊 High', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTriggerSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What led to this drink?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...TriggerConstants.triggersByCategory.entries.map((category) {
              return ExpansionTile(
                title: Text(category.key),
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: category.value.map((trigger) {
                      final isSelected = _triggers.contains(trigger);
                      return FilterChip(
                        label: Text(trigger),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _triggers.add(trigger);
                            } else {
                              _triggers.remove(trigger);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTriggerDescription() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tell us more (optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _triggerDescription,
              decoration: const InputDecoration(
                hintText: 'What led to this moment? How are you feeling?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                setState(() {
                  _triggerDescription = value.isNotEmpty ? value : null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTherapeuticReflectionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reflection & Intention',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Mindful questions for deeper awareness',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          
          _buildIntentionInput(),
          const SizedBox(height: 16),
          _buildUrgeIntensitySelector(),
          const SizedBox(height: 16),
          _buildAlternativesSection(),
        ],
      ),
    );
  }

  Widget _buildIntentionInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What\'s your plan for this session?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _intention,
              decoration: const InputDecoration(
                hintText: 'e.g., "Just this one drink with dinner"',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _intention = value.isNotEmpty ? value : null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrgeIntensitySelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How strong was the urge? (1-10)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Slider(
              value: (_urgeIntensity ?? 5).toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: _urgeIntensity?.toString() ?? '5',
              onChanged: (value) {
                setState(() {
                  _urgeIntensity = value.round();
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mild', style: Theme.of(context).textTheme.bodySmall),
                Text('Intense', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlternativesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Did you consider alternatives?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Yes'),
                    value: true,
                    groupValue: _consideredAlternatives,
                    onChanged: (value) {
                      setState(() {
                        _consideredAlternatives = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('No'),
                    value: false,
                    groupValue: _consideredAlternatives,
                    onChanged: (value) {
                      setState(() {
                        _consideredAlternatives = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            
            if (_consideredAlternatives == true) ...[
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _alternatives,
                decoration: const InputDecoration(
                  hintText: 'What alternatives did you consider?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onChanged: (value) {
                  setState(() {
                    _alternatives = value.isNotEmpty ? value : null;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(DrinkLoggingState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Back'),
              ),
            ),
          
          if (_currentStep > 0) const SizedBox(width: 16),
          
          Expanded(
            child: ElevatedButton(
              onPressed: state is DrinkLoggingLoading 
                  ? null 
                  : _currentStep < _totalSteps - 1 
                      ? _nextStep 
                      : _saveEntry,
              child: state is DrinkLoggingLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_currentStep < _totalSteps - 1 ? 'Next' : 'Save'),
            ),
          ),
        ],
      ),
    );
  }

  bool _canSkipToSave() {
    return _selectedDrink != null && _selectedTimeOfDay != null;
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _saveEntry() async {
    if (_selectedDrink == null || _selectedTimeOfDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a drink and time of day'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final standardDrinks = _selectedDrink!.name == 'Custom' 
        ? (_customStandardDrinks ?? 1.0)
        : _selectedDrink!.standardDrinks;

    final entry = DrinkEntry(
      id: widget.editingEntry?.id,
      timestamp: _selectedDate ?? DateTime.now(),
      timeOfDay: _selectedTimeOfDay!,
      drinkId: _selectedDrink!.name,
      drinkName: _selectedDrink!.name,
      standardDrinks: standardDrinks,
      location: _location,
      socialContext: _socialContext,
      moodBefore: _moodBefore,
      triggers: _triggers.isNotEmpty ? _triggers : null,
      triggerDescription: _triggerDescription,
      intention: _intention,
      urgeIntensity: _urgeIntensity,
      consideredAlternatives: _consideredAlternatives,
      alternatives: _alternatives,
      energyLevel: _energyLevel,
      hungerLevel: _hungerLevel,
      stressLevel: _stressLevel,
      sleepQuality: _sleepQuality,
      isWithinLimit: true, // Will be calculated by service
      isScheduleCompliant: true, // Will be calculated by service
    );

    final cubit = context.read<DrinkLoggingCubit>();
    print('DrinkLoggingScreen - About to call cubit methods');
    
    try {
      if (widget.editingEntry != null) {
        print('DrinkLoggingScreen - Calling updateDrinkEntry');
        await cubit.updateDrinkEntry(entry);
      } else {
        print('DrinkLoggingScreen - Calling logDrinkEntry');
        await cubit.logDrinkEntry(entry);
      }
      print('DrinkLoggingScreen - Cubit method completed successfully');
      
      // Just navigate back manually - fuck the BlocListener
      if (mounted) {
        Navigator.of(context).pop(true);
        print('DrinkLoggingScreen - Manually navigated back');
      }
    } catch (e) {
      print('DrinkLoggingScreen - Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save drink: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
