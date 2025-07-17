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
  
  Map<String, dynamic> _baseline = {};
  bool _isLoading = true;
  String? _selectedDurationUnit = 'Weeks';
  
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
    super.dispose();
  }
  
  Future<void> _loadBaseline() async {
    try {
      final analytics = DrinkTrackingService.instance;
      setState(() {
        _baseline = {
          'weeklyAverage': _calculateWeeklyAverage(analytics),
          'dailyAverage': analytics.calculateAverageDrinksPerDay(),
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _baseline = {'weeklyAverage': 7.0, 'dailyAverage': 1.0};
        _isLoading = false;
      });
    }
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
}
