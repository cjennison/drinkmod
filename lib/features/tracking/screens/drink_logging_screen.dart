import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/models/drink_entry.dart';
import '../../../core/services/hive_database_service.dart';
import '../../../core/services/drink_database_service.dart';
import '../../../core/utils/drink_intervention_utils.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../widgets/drink_selection_log_widget.dart';
import '../widgets/context_log_widget.dart';
import '../widgets/emotional_checkin_log_widget.dart';
import '../widgets/therapeutic_reflection_log_widget.dart';
import 'drink_logging_cubit.dart';
import 'therapeutic_intervention_screen.dart';

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
  DrinkInfo? _selectedDrink;
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
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
    
    // Check if the selected date is before account creation
    final databaseService = HiveDatabaseService.instance;
    if (databaseService.isDateBeforeAccountCreation(_selectedDate!)) {
      // If trying to log for a date before account creation, close the screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot add drinks before your journey started on ${databaseService.getFormattedAccountCreationDate()}'),
              backgroundColor: Colors.orange,
            ),
          );
          Navigator.of(context).pop();
        }
      });
      return;
    }
    _selectedTimeOfDay = 'Afternoon'; // Default time of day
    
    // If editing, populate form with existing data
    if (widget.editingEntry != null) {
      _isInitializing = true;
      _populateFromExistingEntry();
    }
  }

  void _populateFromExistingEntry() async {
    final entry = widget.editingEntry!;
    
    setState(() {
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
    });
    
    // Find matching drink from new database
    final drinkService = DrinkDatabaseService.instance;
    final allDrinks = await drinkService.getAllDrinks();
    
    final matchedDrink = allDrinks.firstWhere(
      (d) => d.name == entry.drinkName,
      orElse: () => DrinkInfo(
        id: 'fallback',
        name: entry.drinkName,
        description: 'Previously logged drink',
        ingredients: [entry.drinkName],
        standardDrinks: entry.standardDrinks,
        category: 'other',
        isBasic: false,
      ),
    );
    
    setState(() {
      _selectedDrink = matchedDrink;
      _isInitializing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DrinkLoggingCubit(HiveDatabaseService.instance),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getAppBarTitle()),
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
                      DrinkSelectionLogWidget(
                        selectedDate: _selectedDate,
                        selectedTimeOfDay: _selectedTimeOfDay,
                        selectedDrink: _selectedDrink,
                        isInitializing: _isInitializing,
                        onTimeOfDaySelected: (timeOfDay) {
                          setState(() {
                            _selectedTimeOfDay = timeOfDay;
                          });
                        },
                        onDrinkSelected: (drink) {
                          setState(() {
                            _selectedDrink = drink;
                          });
                        },
                        onShowDatePicker: _showDatePicker,
                      ),
                      ContextLogWidget(
                        location: _location,
                        socialContext: _socialContext,
                        onLocationSelected: (location) {
                          setState(() {
                            _location = location;
                          });
                        },
                        onSocialContextSelected: (context) {
                          setState(() {
                            _socialContext = context;
                          });
                        },
                      ),
                      EmotionalCheckinLogWidget(
                        moodBefore: _moodBefore,
                        triggers: _triggers,
                        triggerDescription: _triggerDescription,
                        onMoodSelected: (mood) {
                          setState(() {
                            _moodBefore = mood;
                          });
                        },
                        onTriggersChanged: (triggers) {
                          setState(() {
                            _triggers = triggers;
                          });
                        },
                        onTriggerDescriptionChanged: (description) {
                          setState(() {
                            _triggerDescription = description;
                          });
                        },
                      ),
                      TherapeuticReflectionLogWidget(
                        intention: _intention,
                        urgeIntensity: _urgeIntensity,
                        consideredAlternatives: _consideredAlternatives,
                        alternatives: _alternatives,
                        onIntentionChanged: (intention) {
                          setState(() {
                            _intention = intention;
                          });
                        },
                        onUrgeIntensityChanged: (intensity) {
                          setState(() {
                            _urgeIntensity = intensity;
                          });
                        },
                        onConsideredAlternativesChanged: (considered) {
                          setState(() {
                            _consideredAlternatives = considered;
                          });
                        },
                        onAlternativesChanged: (alternatives) {
                          setState(() {
                            _alternatives = alternatives;
                          });
                        },
                      ),
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

  String _getAppBarTitle() {
    final selectedDate = _selectedDate ?? DateTime.now();
    final isToday = _isSameDay(selectedDate, DateTime.now());
    
    if (widget.editingEntry != null) {
      return 'Edit Drink';
    }
    
    if (isToday) {
      return 'Log a Drink';
    } else {
      final formatter = DateFormat('MMM d');
      return 'Add Drink for ${formatter.format(selectedDate)}';
    }
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
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

  void _showDatePicker() async {
    final selectedDate = _selectedDate ?? DateTime.now();
    final databaseService = HiveDatabaseService.instance;
    final accountCreatedDate = databaseService.getAccountCreatedDate();
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: accountCreatedDate ?? DateTime.now().subtract(const Duration(days: 365)), // Account creation date or last year
      lastDate: DateTime.now(), // No future dates
      helpText: 'Select date for drink entry',
    );
    
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
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
                      ? (_selectedDrink != null ? _nextStep : null)
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
      AppSnackBar.showWarning(context, 'Please select a drink and time of day');
      return;
    }

    // For new entries, check intervention requirements using the utility
    if (widget.editingEntry == null) {
      final databaseService = HiveDatabaseService.instance;
      final selectedDate = _selectedDate ?? DateTime.now();
      final isRetroactive = !_isSameDay(selectedDate, DateTime.now());
      
      // Check intervention requirements
      final interventionResult = DrinkInterventionUtils.checkInterventionRequired(
        date: selectedDate,
        proposedStandardDrinks: _selectedDrink!.standardDrinks,
        databaseService: databaseService,
        isRetroactive: isRetroactive,
      );
      
      // Handle intervention requirements
      if (interventionResult.decision == DrinkInterventionUtils.cannotLog) {
        AppSnackBar.showError(context, interventionResult.userMessage);
        return;
      }
      
      // For any intervention (alcohol-free day, limit exceeded, approaching limit, etc)
      if (interventionResult.requiresIntervention) {
        final shouldProceed = await _showTherapeuticIntervention(interventionResult);
        if (shouldProceed) {
          await _proceedWithSave();
        }
        return;
      }
      
      // For approaching limit, show informational message but continue
      if (interventionResult.isApproachingLimit) {
        AppSnackBar.showWarning(context, interventionResult.userMessage);
      }
      
      // For retroactive entries, show informational message but continue
      if (interventionResult.isRetroactive) {
        AppSnackBar.showWarning(context, interventionResult.userMessage);
      }
    }
    
    // Proceed with save
    await _proceedWithSave();
  }

  /// Show the unified therapeutic intervention screen
  Future<bool> _showTherapeuticIntervention(DrinkInterventionResult interventionResult) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => TherapeuticInterventionScreen(
          interventionResult: interventionResult,
          onProceed: () {
            Navigator.of(context).pop(true);
          },
          onCancel: () {
            // User chose to stick to their goal - clear state and go back
            _clearFormState();
            Navigator.of(context).pop(false);
            // Navigate back to home, clearing the drink logging screen
            if (mounted) {
              Navigator.of(context).popUntil((route) => route.isFirst);
              // Show positive reinforcement based on intervention type
              final message = _getPositiveReinforcementMessage(interventionResult);
              AppSnackBar.showSuccess(context, message);
            }
          },
        ),
      ),
    );
    
    return result ?? false;
  }

  /// Get appropriate positive reinforcement message based on intervention type
  String _getPositiveReinforcementMessage(DrinkInterventionResult interventionResult) {
    if (interventionResult.isScheduleViolation) {
      return 'Great choice! You\'re honoring your alcohol-free day commitment.';
    } else if (interventionResult.isLimitExceeded) {
      return 'Excellent decision! You\'re staying within your daily limits.';
    } else if (interventionResult.isApproachingLimit) {
      return 'Wise choice! You\'re staying in control of your drinking.';
    } else {
      return 'Great choice! You\'re staying on track with your goals.';
    }
  }

  /// Actually save the drink entry
  Future<void> _proceedWithSave() async {

    final standardDrinks = _selectedDrink!.standardDrinks;

    final entry = DrinkEntry(
      id: widget.editingEntry?.id,
      timestamp: _selectedDate ?? DateTime.now(),
      timeOfDay: _selectedTimeOfDay!,
      drinkId: _selectedDrink!.id,
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
        AppSnackBar.showError(context, 'Failed to save drink: $e');
      }
    }
  }

  /// Clear all form state when user decides to stick to their goal
  void _clearFormState() {
    setState(() {
      _selectedDrink = null;
      _selectedTimeOfDay = 'Afternoon'; // Reset to default
      _location = null;
      _socialContext = null;
      _moodBefore = null;
      _triggers.clear();
      _triggerDescription = null;
      _intention = null;
      _urgeIntensity = null;
      _consideredAlternatives = null;
      _alternatives = null;
      _energyLevel = null;
      _hungerLevel = null;
      _stressLevel = null;
      _sleepQuality = null;
      _currentStep = 0; // Reset to first step
    });
    
    // Reset page controller to first page
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
