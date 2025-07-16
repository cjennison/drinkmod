import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/user_goal.dart';
import '../../../../core/services/drink_tracking_service.dart';

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
  
  // Parameter controllers
  final _weeklyDrinksController = TextEditingController();
  final _dailyLimitController = TextEditingController();
  final _durationController = TextEditingController();
  final _alcoholFreeDaysController = TextEditingController();
  final _interventionWinsController = TextEditingController();
  final _targetMoodController = TextEditingController();
  final _costSavingsController = TextEditingController();
  
  Map<String, dynamic> _currentBaseline = {};
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadBaseline();
    _setDefaultValues();
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _weeklyDrinksController.dispose();
    _dailyLimitController.dispose();
    _durationController.dispose();
    _alcoholFreeDaysController.dispose();
    _interventionWinsController.dispose();
    _targetMoodController.dispose();
    _costSavingsController.dispose();
    super.dispose();
  }
  
  Future<void> _loadBaseline() async {
    try {
      // Get user's current drinking baseline
      final analytics = DrinkTrackingService.instance;
      final weeklyAverage = analytics.getWeeklyDrinks(DateTime.now());
      final averageDaily = analytics.calculateAverageDrinksPerDay();
      
      setState(() {
        _currentBaseline = {
          'weeklyAverage': weeklyAverage,
          'dailyAverage': averageDaily,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _currentBaseline = {
          'weeklyAverage': 7.0,
          'dailyAverage': 1.0,
        };
        _isLoading = false;
      });
    }
  }
  
  void _setDefaultValues() {
    switch (widget.goalType) {
      case GoalType.weeklyReduction:
        _titleController.text = 'Reduce Weekly Drinking';
        _descriptionController.text = 'Gradually reduce my weekly alcohol consumption to a healthier level';
        _durationController.text = '3';
        break;
      case GoalType.dailyLimit:
        _titleController.text = 'Daily Drink Limit';
        _descriptionController.text = 'Stay within my daily drink limit consistently';
        _dailyLimitController.text = '2';
        _durationController.text = '4';
        break;
      case GoalType.alcoholFreeDays:
        _titleController.text = 'Alcohol-Free Days';
        _descriptionController.text = 'Maintain regular alcohol-free days each week';
        _alcoholFreeDaysController.text = '3';
        _durationController.text = '2';
        break;
      case GoalType.interventionWins:
        _titleController.text = 'Intervention Success';
        _descriptionController.text = 'Build strength by choosing not to drink when prompted';
        _interventionWinsController.text = '10';
        _durationController.text = '6';
        break;
      case GoalType.moodImprovement:
        _titleController.text = 'Mood & Wellbeing';
        _descriptionController.text = 'Improve my overall mood and energy through mindful drinking';
        _targetMoodController.text = '7';
        _durationController.text = '8';
        break;
      case GoalType.costSavings:
        _titleController.text = 'Cost Savings';
        _descriptionController.text = 'Save money by reducing my alcohol spending';
        _costSavingsController.text = '200';
        _durationController.text = '3';
        break;
      case GoalType.streakMaintenance:
      case GoalType.customGoal:
        _titleController.text = 'Custom Goal';
        _descriptionController.text = 'My personalized drinking goal';
        break;
    }
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
  
  Map<String, dynamic> _buildParameters() {
    final params = <String, dynamic>{};
    
    switch (widget.goalType) {
      case GoalType.weeklyReduction:
        params['targetWeeklyDrinks'] = int.parse(_weeklyDrinksController.text);
        params['durationMonths'] = int.parse(_durationController.text);
        params['currentBaseline'] = _currentBaseline['weeklyAverage'] ?? 7.0;
        params['targetValue'] = int.parse(_weeklyDrinksController.text).toDouble();
        break;
      case GoalType.dailyLimit:
        params['dailyLimit'] = int.parse(_dailyLimitController.text);
        params['durationWeeks'] = int.parse(_durationController.text);
        params['allowedViolations'] = 0;
        params['targetValue'] = int.parse(_durationController.text) * 7.0;
        break;
      case GoalType.alcoholFreeDays:
        params['alcoholFreeDaysPerWeek'] = int.parse(_alcoholFreeDaysController.text);
        params['durationMonths'] = int.parse(_durationController.text);
        params['targetValue'] = int.parse(_durationController.text) * 4.33;
        break;
      case GoalType.interventionWins:
        params['targetInterventionWins'] = int.parse(_interventionWinsController.text);
        params['durationWeeks'] = int.parse(_durationController.text);
        params['targetValue'] = int.parse(_interventionWinsController.text).toDouble();
        break;
      case GoalType.moodImprovement:
        params['targetAverageMood'] = double.parse(_targetMoodController.text);
        params['durationWeeks'] = int.parse(_durationController.text);
        params['targetValue'] = double.parse(_targetMoodController.text);
        break;
      case GoalType.costSavings:
        params['targetSavings'] = double.parse(_costSavingsController.text);
        params['durationMonths'] = int.parse(_durationController.text);
        params['baselineMonthlyCost'] = _estimateMonthlyCost();
        params['targetValue'] = double.parse(_costSavingsController.text);
        break;
      case GoalType.streakMaintenance:
      case GoalType.customGoal:
        params['targetValue'] = 1.0;
        break;
    }
    
    return params;
  }
  
  double _estimateMonthlyCost() {
    // Rough estimate: $8 per drink, weekly average
    final weeklyAverage = _currentBaseline['weeklyAverage'] as double? ?? 7.0;
    return weeklyAverage * 4.33 * 8.0;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              
              const SizedBox(height: 20),
              
              // Current baseline info
              _buildBaselineInfo(),
              
              const SizedBox(height: 20),
              
              // Form fields - expandable scrollable area
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTitleField(),
                      const SizedBox(height: 16),
                      _buildDescriptionField(),
                      const SizedBox(height: 20),
                      ..._buildGoalSpecificFields(),
                      const SizedBox(height: 20), // Bottom padding for scroll
                    ],
                  ),
                ),
              ),
              
              // Continue button - always visible at bottom
              _buildContinueButton(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Configure Your Goal',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Set specific parameters for your ${_getGoalTypeName()} goal.',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade600,
            height: 1.2,
          ),
        ),
      ],
    );
  }
  
  Widget _buildBaselineInfo() {
    final weeklyAverage = _currentBaseline['weeklyAverage'] as double? ?? 0.0;
    final dailyAverage = _currentBaseline['dailyAverage'] as double? ?? 0.0;
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: Colors.blue.shade600, size: 18),
              const SizedBox(width: 6),
              const Text(
                'Your Current Pattern',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildBaselineItem(
                  'Weekly Average',
                  '${weeklyAverage.toStringAsFixed(1)} drinks',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildBaselineItem(
                  'Daily Average',
                  '${dailyAverage.toStringAsFixed(1)} drinks',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildBaselineItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Goal Title',
        hintText: 'Give your goal a motivating name',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a goal title';
        }
        if (value.trim().length < 3) {
          return 'Title must be at least 3 characters';
        }
        return null;
      },
    );
  }
  
  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Description (Optional)',
        hintText: 'Describe what this goal means to you',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  
  List<Widget> _buildGoalSpecificFields() {
    switch (widget.goalType) {
      case GoalType.weeklyReduction:
        return _buildWeeklyReductionFields();
      case GoalType.dailyLimit:
        return _buildDailyLimitFields();
      case GoalType.alcoholFreeDays:
        return _buildAlcoholFreeDaysFields();
      case GoalType.interventionWins:
        return _buildInterventionWinsFields();
      case GoalType.moodImprovement:
        return _buildMoodImprovementFields();
      case GoalType.costSavings:
        return _buildCostSavingsFields();
      case GoalType.streakMaintenance:
      case GoalType.customGoal:
        return [];
    }
  }
  
  List<Widget> _buildWeeklyReductionFields() {
    final currentWeekly = _currentBaseline['weeklyAverage'] as double? ?? 7.0;
    final recommendedTarget = (currentWeekly * 0.7).round(); // 30% reduction
    
    if (_weeklyDrinksController.text.isEmpty) {
      _weeklyDrinksController.text = recommendedTarget.toString();
    }
    
    return [
      TextFormField(
        controller: _weeklyDrinksController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: 'Target Weekly Drinks',
          hintText: 'Recommended: $recommendedTarget',
          helperText: 'Current average: ${currentWeekly.toStringAsFixed(1)} drinks/week',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter target weekly drinks';
          }
          final number = int.tryParse(value);
          if (number == null || number < 0) {
            return 'Please enter a valid number';
          }
          if (number >= currentWeekly) {
            return 'Target should be less than current average (${currentWeekly.toStringAsFixed(1)})';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),
      TextFormField(
        controller: _durationController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: 'Duration (Months)',
          hintText: 'How long to reach this goal',
          helperText: 'Recommended: 2-6 months for sustainable change',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter duration';
          }
          final number = int.tryParse(value);
          if (number == null || number < 1 || number > 12) {
            return 'Duration must be between 1-12 months';
          }
          return null;
        },
      ),
    ];
  }
  
  List<Widget> _buildDailyLimitFields() {
    return [
      TextFormField(
        controller: _dailyLimitController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: 'Daily Limit (Drinks)',
          hintText: 'Maximum drinks per day',
          helperText: 'Health guidelines suggest 1-2 drinks per day',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter daily limit';
          }
          final number = int.tryParse(value);
          if (number == null || number < 0 || number > 10) {
            return 'Daily limit must be between 0-10 drinks';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),
      TextFormField(
        controller: _durationController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: 'Duration (Weeks)',
          hintText: 'How many weeks to maintain this limit',
          helperText: 'Start with 2-4 weeks, then extend if successful',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter duration';
          }
          final number = int.tryParse(value);
          if (number == null || number < 1 || number > 52) {
            return 'Duration must be between 1-52 weeks';
          }
          return null;
        },
      ),
    ];
  }
  
  List<Widget> _buildAlcoholFreeDaysFields() {
    return [
      TextFormField(
        controller: _alcoholFreeDaysController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: 'Alcohol-Free Days Per Week',
          hintText: 'Number of AF days weekly',
          helperText: 'Start with 2-3 days, increase gradually',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter alcohol-free days';
          }
          final number = int.tryParse(value);
          if (number == null || number < 1 || number > 7) {
            return 'Must be between 1-7 days per week';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),
      TextFormField(
        controller: _durationController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: 'Duration (Months)',
          hintText: 'How long to maintain this pattern',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter duration';
          }
          final number = int.tryParse(value);
          if (number == null || number < 1 || number > 12) {
            return 'Duration must be between 1-12 months';
          }
          return null;
        },
      ),
    ];
  }
  
  List<Widget> _buildInterventionWinsFields() {
    return [
      TextFormField(
        controller: _interventionWinsController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: 'Target Intervention Wins',
          hintText: 'Number of successful "no" choices',
          helperText: 'Start with 5-10 wins to build confidence',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter target wins';
          }
          final number = int.tryParse(value);
          if (number == null || number < 1 || number > 100) {
            return 'Target must be between 1-100 wins';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),
      TextFormField(
        controller: _durationController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: 'Duration (Weeks)',
          hintText: 'Time frame to achieve wins',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter duration';
          }
          final number = int.tryParse(value);
          if (number == null || number < 1 || number > 52) {
            return 'Duration must be between 1-52 weeks';
          }
          return null;
        },
      ),
    ];
  }
  
  List<Widget> _buildMoodImprovementFields() {
    return [
      TextFormField(
        controller: _targetMoodController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: 'Target Average Mood (1-10)',
          hintText: 'Desired mood score',
          helperText: '7+ is considered good wellbeing',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter target mood';
          }
          final number = double.tryParse(value);
          if (number == null || number < 1 || number > 10) {
            return 'Mood must be between 1-10';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),
      TextFormField(
        controller: _durationController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: 'Duration (Weeks)',
          hintText: 'Time to achieve mood target',
          helperText: 'Allow 4-8 weeks to see mood changes',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter duration';
          }
          final number = int.tryParse(value);
          if (number == null || number < 2 || number > 52) {
            return 'Duration must be between 2-52 weeks';
          }
          return null;
        },
      ),
    ];
  }
  
  List<Widget> _buildCostSavingsFields() {
    final estimatedSavings = _estimateMonthlyCost() * 0.3; // 30% reduction
    
    if (_costSavingsController.text.isEmpty) {
      _costSavingsController.text = estimatedSavings.round().toString();
    }
    
    return [
      TextFormField(
        controller: _costSavingsController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: 'Target Savings (\$)',
          hintText: 'Amount to save',
          helperText: 'Estimated potential: \$${estimatedSavings.round()}/month',
          prefixText: '\$',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter target savings';
          }
          final number = double.tryParse(value);
          if (number == null || number < 1) {
            return 'Savings must be a positive amount';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),
      TextFormField(
        controller: _durationController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: 'Duration (Months)',
          hintText: 'Time frame to save money',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter duration';
          }
          final number = int.tryParse(value);
          if (number == null || number < 1 || number > 12) {
            return 'Duration must be between 1-12 months';
          }
          return null;
        },
      ),
    ];
  }
  
  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _onContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Continue',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
  
  String _getGoalTypeName() {
    switch (widget.goalType) {
      case GoalType.weeklyReduction:
        return 'Weekly Reduction';
      case GoalType.dailyLimit:
        return 'Daily Limit';
      case GoalType.alcoholFreeDays:
        return 'Alcohol-Free Days';
      case GoalType.interventionWins:
        return 'Intervention Success';
      case GoalType.moodImprovement:
        return 'Mood & Wellbeing';
      case GoalType.costSavings:
        return 'Cost Savings';
      case GoalType.streakMaintenance:
        return 'Streak Maintenance';
      case GoalType.customGoal:
        return 'Custom Goal';
    }
  }
}
