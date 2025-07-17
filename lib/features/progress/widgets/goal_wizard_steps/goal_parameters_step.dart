import 'package:flutter/material.dart';
import '../../../../core/models/user_goal.dart';
import '../../../../core/services/drink_tracking_service.dart';
import '../../shared/components/goal_form_components.dart';

/// Goal parameters configuration step with smart defaults and validation
class GoalParametersStep extends StatefulWidget {
  final GoalType goalType;
  final Function(Map<String, dynamic>, String, String) onParametersSet;
  
  const GoalParametersStep({
    super.key,
    required this.goalType,
    required this.onParametersSet,
  });

  @override
  State<GoalParametersStep> createState() => _GoalParametersStepState();
}

class _GoalParametersStepState extends State<GoalParametersStep> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _primaryController = TextEditingController();
  final _durationController = TextEditingController();
  
  // Cost savings baseline drinking pattern
  final _weeklyDrinksController = TextEditingController();
  final _drinksPerOccasionController = TextEditingController();
  final _costPerDrinkController = TextEditingController();
  
  Map<String, dynamic> _baseline = {};
  bool _isLoading = true;
  String? _selectedDurationUnit = 'Weeks';
  String? _drinkingFrequency = 'once_week'; // Default frequency
  
  @override
  void initState() {
    super.initState();
    _loadBaseline();
    _setDefaults();
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _primaryController.dispose();
    _durationController.dispose();
    _weeklyDrinksController.dispose();
    _drinksPerOccasionController.dispose();
    _costPerDrinkController.dispose();
    super.dispose();
  }
  
  Future<void> _loadBaseline() async {
    try {
      final analytics = DrinkTrackingService.instance;
      
      // Calculate baseline drinking data from last 3 months
      if (widget.goalType == GoalType.costSavings) {
        await _loadCostSavingsBaseline(analytics);
      } else {
        // For other goal types, use existing logic
        setState(() {
          _baseline = {
            'weeklyAverage': _calculateWeeklyAverage(analytics),
            'dailyAverage': analytics.calculateAverageDrinksPerDay(),
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _baseline = {'weeklyAverage': 7.0, 'dailyAverage': 1.0};
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCostSavingsBaseline(DrinkTrackingService analytics) async {
    // For now, use existing analytics methods and set reasonable defaults
    // This can be enhanced later with more sophisticated period-based calculations
    
    final weeklyAverage = _calculateWeeklyAverage(analytics);
    final dailyAverage = analytics.calculateAverageDrinksPerDay();
    
    // Round up to whole numbers for better user experience
    final roundedWeeklyDrinks = weeklyAverage.ceil();
    final roundedDrinksPerOccasion = (dailyAverage * 1.5).ceil();
    
    // Set default values in controllers with rounded values
    _weeklyDrinksController.text = roundedWeeklyDrinks.toString();
    _drinksPerOccasionController.text = roundedDrinksPerOccasion.toString();
    _costPerDrinkController.text = '8.00'; // Default cost per drink estimate
    
    // Determine drinking frequency based on weekly average
    if (weeklyAverage >= 28) {
      _drinkingFrequency = 'daily';
    } else if (weeklyAverage >= 14) {
      _drinkingFrequency = 'few_times_week';
    } else if (weeklyAverage >= 7) {
      _drinkingFrequency = 'twice_week';
    } else if (weeklyAverage >= 3) {
      _drinkingFrequency = 'once_week';
    } else {
      _drinkingFrequency = 'few_times_month';
    }
    
    setState(() {
      _baseline = {
        'weeklyAverage': roundedWeeklyDrinks.toDouble(),
        'dailyAverage': roundedDrinksPerOccasion.toDouble() / 1.5, // Back-calculate daily from occasion
        'drinksPerOccasion': roundedDrinksPerOccasion.toDouble(),
        'estimatedFromData': true,
        'baselinePeriod': 'available_data',
        'roundedUp': true,
      };
      _isLoading = false;
    });
  }

  double _calculateWeeklyAverage(DrinkTrackingService analytics) {
    final entries = analytics.getAllDrinkEntries();
    if (entries.isEmpty) return 0.0;
    
    final weeklyTotals = <String, double>{};
    for (final entry in entries) {
      final date = DateTime.parse(entry['drinkDate']);
      final monday = date.subtract(Duration(days: date.weekday - 1));
      final weekKey = '${monday.year}-${monday.month}-${monday.day}';
      weeklyTotals[weekKey] = (weeklyTotals[weekKey] ?? 0.0) + (entry['standardDrinks'] as double);
    }
    
    if (weeklyTotals.isEmpty) return 0.0;
    return weeklyTotals.values.fold<double>(0.0, (sum, drinks) => sum + drinks) / weeklyTotals.length;
  }
  
  void _setDefaults() {
    final defaults = _getGoalDefaults(widget.goalType);
    _titleController.text = defaults['title']!;
    _descriptionController.text = defaults['description']!;
    _primaryController.text = defaults['primaryValue']!;
    _durationController.text = defaults['duration']!;
    _selectedDurationUnit = defaults['durationUnit']!;
  }

  Map<String, String> _getGoalDefaults(GoalType type) {
    switch (type) {
      case GoalType.weeklyReduction:
        return {
          'title': 'Reduce Weekly Drinking',
          'description': 'Gradually reduce my weekly alcohol consumption',
          'primaryValue': '5',
          'duration': '3',
          'durationUnit': 'Months',
        };
      case GoalType.dailyLimit:
        return {
          'title': 'Daily Drink Limit',
          'description': 'Stay within my daily drink limit',
          'primaryValue': '2',
          'duration': '4',
          'durationUnit': 'Weeks',
        };
      case GoalType.alcoholFreeDays:
        return {
          'title': 'Alcohol-Free Days',
          'description': 'Maintain regular alcohol-free days',
          'primaryValue': '3',
          'duration': '2',
          'durationUnit': 'Months',
        };
      case GoalType.interventionWins:
        return {
          'title': 'Intervention Success Rate',
          'description': 'Succeed in X% of intervention moments when they occur',
          'primaryValue': '70',
          'duration': '8',
          'durationUnit': 'Weeks',
        };
      case GoalType.moodImprovement:
        return {
          'title': 'Mood & Wellbeing',
          'description': 'Improve mood through mindful drinking',
          'primaryValue': '7',
          'duration': '8',
          'durationUnit': 'Weeks',
        };
      case GoalType.costSavings:
        return {
          'title': 'Cost Savings',
          'description': 'Save money by reducing alcohol spending',
          'primaryValue': '200',
          'duration': '3',
          'durationUnit': 'Months',
        };
      case GoalType.streakMaintenance:
        return {
          'title': 'Streak Maintenance',
          'description': 'Maintain a consistent streak',
          'primaryValue': '30',
          'duration': '3',
          'durationUnit': 'Months',
        };
      case GoalType.customGoal:
        return {
          'title': 'Custom Goal',
          'description': 'My personalized drinking goal',
          'primaryValue': '1',
          'duration': '1',
          'durationUnit': 'Weeks',
        };
    }
  }

  String _getPrimaryFieldLabel() {
    switch (widget.goalType) {
      case GoalType.weeklyReduction:
        return 'Target Drinks Per Week';
      case GoalType.dailyLimit:
        return 'Daily Limit';
      case GoalType.alcoholFreeDays:
        return 'Alcohol-Free Days Per Week';
      case GoalType.interventionWins:
        return 'Target Success Rate (%)';
      case GoalType.moodImprovement:
        return 'Target Mood Rating (1-10)';
      case GoalType.costSavings:
        return 'Target Savings';
      case GoalType.streakMaintenance:
        return 'Streak Days';
      case GoalType.customGoal:
        return 'Target Value';
    }
  }

  Map<String, dynamic> _buildParameters() {
    final primaryValue = double.parse(_primaryController.text);
    final duration = int.parse(_durationController.text);
    
    final params = <String, dynamic>{
      'targetValue': primaryValue,
      'duration': duration,
      'durationUnit': _selectedDurationUnit?.toLowerCase(),
      'currentBaseline': _baseline,
    };

    switch (widget.goalType) {
      case GoalType.weeklyReduction:
        params['targetWeeklyDrinks'] = primaryValue.toInt();
        params['durationMonths'] = duration;
        break;
      case GoalType.dailyLimit:
        params['dailyLimit'] = primaryValue.toInt();
        params['durationWeeks'] = duration;
        break;
      case GoalType.alcoholFreeDays:
        params['alcoholFreeDaysPerWeek'] = primaryValue.toInt();
        params['durationMonths'] = duration;
        break;
      case GoalType.interventionWins:
        params['targetSuccessRate'] = primaryValue.toInt(); // Store as percentage (70 = 70%)
        params['durationWeeks'] = duration;
        break;
      case GoalType.moodImprovement:
        params['targetAverageMood'] = primaryValue;
        params['durationWeeks'] = duration;
        break;
      case GoalType.costSavings:
        params['targetSavings'] = primaryValue;
        params['durationMonths'] = duration;
        
        // Add drinking pattern parameters for cost savings calculation
        if (_weeklyDrinksController.text.isNotEmpty) {
          params['baselineWeeklyDrinks'] = double.tryParse(_weeklyDrinksController.text) ?? 0.0;
        }
        if (_drinksPerOccasionController.text.isNotEmpty) {
          params['baselineDrinksPerOccasion'] = double.tryParse(_drinksPerOccasionController.text) ?? 0.0;
        }
        if (_costPerDrinkController.text.isNotEmpty) {
          params['avgCostPerDrink'] = double.tryParse(_costPerDrinkController.text) ?? 0.0; // Match service parameter name
        }
        params['baselineDrinkingFrequency'] = _drinkingFrequency;
        break;
      case GoalType.streakMaintenance:
        params['streakDays'] = primaryValue.toInt();
        break;
      case GoalType.customGoal:
        params['customValue'] = primaryValue;
        break;
    }
    
    return params;
  }

  void _onContinue() {
    if (_formKey.currentState!.validate()) {
      final parameters = _buildParameters();
      widget.onParametersSet(
        parameters,
        _titleController.text.trim(),
        _descriptionController.text.trim(),
      );
    }
  }

  Widget _buildBaselineInfo() {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Loading your drinking baseline...'),
            ],
          ),
        ),
      );
    }

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Your Current Baseline',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Weekly Average: ${_baseline['weeklyAverage']?.toStringAsFixed(1) ?? '0'} drinks'),
            Text('Daily Average: ${_baseline['dailyAverage']?.toStringAsFixed(1) ?? '0'} drinks'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Parameters'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBaselineInfo(),
            const SizedBox(height: 16),
            
            GoalFormComponents.buildFormSection(
              title: 'Goal Details',
              subtitle: 'Give your goal a name and description',
              children: [
                GoalFormComponents.buildTextInput(
                  controller: _titleController,
                  label: 'Goal Title',
                  hint: 'Enter a motivating title for your goal',
                  isRequired: true,
                  maxLength: 50,
                ),
                GoalFormComponents.buildTextInput(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Describe what this goal means to you',
                  maxLength: 200,
                  maxLines: 3,
                ),
              ],
            ),
            
            GoalFormComponents.buildFormSection(
              title: 'Target & Duration',
              subtitle: 'Set your target and timeframe',
              children: [
                if (widget.goalType == GoalType.costSavings)
                  GoalFormComponents.buildMoneyField(
                    controller: _primaryController,
                    label: _getPrimaryFieldLabel(),
                    isRequired: true,
                  )
                else
                  GoalFormComponents.buildGoalTypeField(
                    goalType: widget.goalType,
                    label: _getPrimaryFieldLabel(),
                    controller: _primaryController,
                    isRequired: true,
                  ),
                GoalFormComponents.buildDurationField(
                  controller: _durationController,
                  selectedUnit: _selectedDurationUnit,
                  onUnitChanged: (unit) {
                    setState(() {
                      _selectedDurationUnit = unit;
                    });
                  },
                  isRequired: true,
                ),
              ],
            ),
            
            // Drinking Pattern section (only for cost savings goals)
            if (widget.goalType == GoalType.costSavings)
              _buildDrinkingPatternSection(),
            
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _onContinue,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('Continue'),
        ),
      ),
    );
  }

  Widget _buildDrinkingPatternSection() {
    return GoalFormComponents.buildFormSection(
      title: 'Your Current Drinking Pattern',
      subtitle: 'Help us calculate your potential savings by telling us about your current habits',
      children: [
        // Info card showing baseline data
        if (!_isLoading && _baseline.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Based on your drinking history:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Weekly average: ${(_baseline['weeklyAverage'] as double?)?.ceil() ?? 0} drinks',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Daily average: ${(_baseline['dailyAverage'] as double?)?.ceil() ?? 0} drinks',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Values have been rounded up to whole numbers. You can adjust these values below to match your typical drinking pattern.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        
        // Drinking frequency dropdown
        DropdownButtonFormField<String>(
          value: _drinkingFrequency,
          decoration: const InputDecoration(
            labelText: 'How often do you typically drink?',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'daily', child: Text('Daily')),
            DropdownMenuItem(value: 'few_times_week', child: Text('A few times a week')),
            DropdownMenuItem(value: 'twice_week', child: Text('Twice a week')),
            DropdownMenuItem(value: 'once_week', child: Text('Once a week')),
            DropdownMenuItem(value: 'few_times_month', child: Text('A few times a month')),
          ],
          onChanged: (value) {
            setState(() {
              _drinkingFrequency = value;
            });
          },
        ),
        
        const SizedBox(height: 16),
        
        // Weekly drinks input
        TextFormField(
          controller: _weeklyDrinksController,
          decoration: const InputDecoration(
            labelText: 'Drinks per week',
            hintText: 'e.g., 10',
            border: OutlineInputBorder(),
            suffixText: 'drinks',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter drinks per week';
            }
            final parsed = double.tryParse(value);
            if (parsed == null || parsed < 0) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Drinks per occasion input
        TextFormField(
          controller: _drinksPerOccasionController,
          decoration: const InputDecoration(
            labelText: 'Drinks per drinking occasion',
            hintText: 'e.g., 3',
            border: OutlineInputBorder(),
            suffixText: 'drinks',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter drinks per occasion';
            }
            final parsed = double.tryParse(value);
            if (parsed == null || parsed < 0) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Cost per drink input
        GoalFormComponents.buildMoneyField(
          controller: _costPerDrinkController,
          label: 'Average cost per drink',
          isRequired: true,
        ),
        
        const SizedBox(height: 12),
        
        // Helper text
        const Text(
          'Tip: Include the cost of drinks at bars, restaurants, and retail. Consider tips and taxes for a realistic estimate.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
