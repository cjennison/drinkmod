import 'package:flutter/material.dart';
import '../../../../core/models/user_goal.dart';

/// Goal confirmation step with celebration animation and next steps
class GoalConfirmationStep extends StatefulWidget {
  final UserGoal goal;
  final Function() onViewGoal;
  final Function() onViewHistory;
  
  const GoalConfirmationStep({
    super.key,
    required this.goal,
    required this.onViewGoal,
    required this.onViewHistory,
  });

  @override
  State<GoalConfirmationStep> createState() => _GoalConfirmationStepState();
}

class _GoalConfirmationStepState extends State<GoalConfirmationStep>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    
    // Start animations with delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  
                  // Success animation
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildSuccessHeader(),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Goal summary card
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildGoalSummaryCard(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Motivation message
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildMotivationMessage(),
                  ),
                  
                  const SizedBox(height: 20), // Bottom padding for scroll
                ],
              ),
            ),
          ),
          
          // Action buttons - always visible at bottom
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildActionButtons(),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuccessHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.green.shade400,
                Colors.green.shade600,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.check_circle,
            size: 50,
            color: Colors.white,
          ),
        ),
        
        const SizedBox(height: 20),
        
        const Text(
          'Goal Created Successfully!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Your journey to healthier drinking habits starts now',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade600,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildGoalSummaryCard() {
    final goalTypeInfo = _getGoalTypeInfo();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            goalTypeInfo['color'].withOpacity(0.05),
            goalTypeInfo['color'].withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: goalTypeInfo['color'].withOpacity(0.2),
        ),
      ),        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: goalTypeInfo['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    goalTypeInfo['icon'],
                    size: 20,
                    color: goalTypeInfo['color'],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.goal.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        goalTypeInfo['name'],
                        style: TextStyle(
                          fontSize: 13,
                          color: goalTypeInfo['color'],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMetricItem(
                      'Target Value',
                      _getTargetValueText(),
                      Icons.flag,
                    ),
                ),
                
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.shade300,
                ),
                
                Expanded(
                  child: _buildMetricItem(
                    'Duration',
                    _getDurationText(),
                    Icons.schedule,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey.shade600,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildMotivationMessage() {
    final messages = [
      'Every step you take matters. You\'ve got this!',
      'Small changes lead to big transformations.',
      'Your commitment to change is inspiring.',
      'Focus on progress, not perfection.',
      'Each day is a new opportunity to succeed.',
    ];
    
    final randomMessage = messages[DateTime.now().millisecond % messages.length];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          Icon(
            Icons.psychology,
            size: 24,
            color: Colors.blue.shade600,
          ),
          const SizedBox(height: 10),
          Text(
            randomMessage,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.blue.shade800,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary action - View Goal
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.onViewGoal,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.visibility, size: 20),
                SizedBox(width: 8),
                Text(
                  'View My Goal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Secondary action - View Goal History
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: widget.onViewHistory,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey.shade400),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 20),
                SizedBox(width: 8),
                Text(
                  'View Goal History',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Map<String, dynamic> _getGoalTypeInfo() {
    switch (widget.goal.goalType) {
      case GoalType.weeklyReduction:
        return {
          'name': 'Weekly Reduction',
          'icon': Icons.trending_down,
          'color': Colors.orange,
        };
      case GoalType.dailyLimit:
        return {
          'name': 'Daily Limit',
          'icon': Icons.timer,
          'color': Colors.blue,
        };
      case GoalType.alcoholFreeDays:
        return {
          'name': 'Alcohol-Free Days',
          'icon': Icons.calendar_today,
          'color': Colors.green,
        };
      case GoalType.interventionWins:
        return {
          'name': 'Intervention Success',
          'icon': Icons.psychology,
          'color': Colors.purple,
        };
      case GoalType.moodImprovement:
        return {
          'name': 'Mood & Wellbeing',
          'icon': Icons.sentiment_satisfied,
          'color': Colors.pink,
        };
      case GoalType.costSavings:
        return {
          'name': 'Cost Savings',
          'icon': Icons.savings,
          'color': Colors.teal,
        };
      case GoalType.streakMaintenance:
        return {
          'name': 'Streak Maintenance',
          'icon': Icons.whatshot,
          'color': Colors.deepOrange,
        };
      case GoalType.customGoal:
        return {
          'name': 'Custom Goal',
          'icon': Icons.star,
          'color': Colors.indigo,
        };
    }
  }
  
  String _getTargetValueText() {
    switch (widget.goal.goalType) {
      case GoalType.weeklyReduction:
        final target = widget.goal.parameters['targetWeeklyDrinks'] as int? ?? 0;
        return '$target drinks/week';
      case GoalType.dailyLimit:
        final limit = widget.goal.parameters['dailyLimit'] as int? ?? 0;
        return '$limit drinks/day max';
      case GoalType.alcoholFreeDays:
        final days = widget.goal.parameters['alcoholFreeDaysPerWeek'] as int? ?? 0;
        return '$days AF days/week';
      case GoalType.interventionWins:
        final wins = widget.goal.parameters['targetInterventionWins'] as int? ?? 0;
        return '$wins successful wins';
      case GoalType.moodImprovement:
        final mood = widget.goal.parameters['targetAverageMood'] as double? ?? 0.0;
        return '${mood.toStringAsFixed(1)}/10 mood';
      case GoalType.costSavings:
        final savings = widget.goal.parameters['targetSavings'] as double? ?? 0.0;
        return '\$${savings.toStringAsFixed(0)} saved';
      case GoalType.streakMaintenance:
      case GoalType.customGoal:
        return 'Custom target';
    }
  }
  
  String _getDurationText() {
    final endDate = widget.goal.endDate;
    if (endDate == null) return 'Ongoing';
    
    final duration = endDate.difference(widget.goal.startDate).inDays;
    
    if (duration < 7) {
      return '$duration days';
    } else if (duration < 30) {
      final weeks = (duration / 7).round();
      return '$weeks week${weeks == 1 ? '' : 's'}';
    } else {
      final months = (duration / 30).round();
      return '$months month${months == 1 ? '' : 's'}';
    }
  }
}
