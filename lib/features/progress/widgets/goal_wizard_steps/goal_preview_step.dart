import 'package:flutter/material.dart';
import '../../../../core/models/user_goal.dart';

/// Goal preview step showing configured goal details and visual representation
class GoalPreviewStep extends StatelessWidget {
  final UserGoal goal;
  final Function() onConfirm;
  final Function() onEdit;
  
  const GoalPreviewStep({
    super.key,
    required this.goal,
    required this.onConfirm,
    required this.onEdit,
  });

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(),
                  
                  const SizedBox(height: 20),
                  
                  // Goal preview card
                  _buildGoalPreviewCard(),
                  
                  const SizedBox(height: 20),
                  
                  // Visual representation
                  _buildVisualPreview(),
                  
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
            child: _buildActionButtons(context),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review Your Goal',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Make sure everything looks right before creating your goal.',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade600,
            height: 1.2,
          ),
        ),
      ],
    );
  }
  
  Widget _buildGoalPreviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Goal type badge
          _buildGoalTypeBadge(),
          
          const SizedBox(height: 16),
          
          // Goal title
          Text(
            goal.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Goal description
          if (goal.description.isNotEmpty) ...[
            Text(
              goal.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Goal parameters
          _buildParametersSection(),
          
          const SizedBox(height: 16),
          
          // Goal timeline
          _buildTimelineSection(),
        ],
      ),
    );
  }
  
  Widget _buildGoalTypeBadge() {
    final goalTypeInfo = _getGoalTypeInfo();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: goalTypeInfo['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: goalTypeInfo['color'].withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            goalTypeInfo['icon'],
            size: 16,
            color: goalTypeInfo['color'],
          ),
          const SizedBox(width: 6),
          Text(
            goalTypeInfo['name'],
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: goalTypeInfo['color'],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildParametersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Goal Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ..._buildParameterItems(),
      ],
    );
  }
  
  List<Widget> _buildParameterItems() {
    final items = <Widget>[];
    
    switch (goal.goalType) {
      case GoalType.weeklyReduction:
        final targetWeekly = goal.parameters['targetWeeklyDrinks'] as int? ?? 0;
        final currentBaseline = goal.parameters['currentBaseline'] as double? ?? 0.0;
        final reduction = currentBaseline - targetWeekly;
        
        items.addAll([
          _buildParameterItem('Target', '$targetWeekly drinks per week'),
          _buildParameterItem('Reduction', '-${reduction.toStringAsFixed(1)} drinks per week'),
        ]);
        break;
        
      case GoalType.dailyLimit:
        final dailyLimit = goal.parameters['dailyLimit'] as int? ?? 0;
        items.add(_buildParameterItem('Daily Limit', '$dailyLimit drinks maximum'));
        break;
        
      case GoalType.alcoholFreeDays:
        final afDays = goal.parameters['alcoholFreeDaysPerWeek'] as int? ?? 0;
        items.add(_buildParameterItem('Alcohol-Free Days', '$afDays days per week'));
        break;
        
      case GoalType.interventionWins:
        final targetWins = goal.parameters['targetInterventionWins'] as int? ?? 0;
        items.add(_buildParameterItem('Target Wins', '$targetWins successful interventions'));
        break;
        
      case GoalType.moodImprovement:
        final targetMood = goal.parameters['targetAverageMood'] as double? ?? 0.0;
        items.add(_buildParameterItem('Target Mood', '${targetMood.toStringAsFixed(1)}/10 average'));
        break;
        
      case GoalType.costSavings:
        final targetSavings = goal.parameters['targetSavings'] as double? ?? 0.0;
        items.add(_buildParameterItem('Target Savings', '\$${targetSavings.toStringAsFixed(0)}'));
        break;
        
      case GoalType.streakMaintenance:
      case GoalType.customGoal:
        items.add(_buildParameterItem('Type', 'Custom goal'));
        break;
    }
    
    return items;
  }
  
  Widget _buildParameterItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimelineSection() {
    final duration = _getDurationText();
    final endDate = goal.endDate;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Timeline',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              duration,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.event, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              endDate != null ? 'Ends on ${_formatDate(endDate)}' : 'No end date set',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildVisualPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.trending_up,
            size: 40,
            color: Colors.blue.shade600,
          ),
          const SizedBox(height: 10),
          const Text(
            'Your Progress Journey',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Track your progress with daily check-ins, milestone celebrations, and personalized insights.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          _buildProgressPreview(),
        ],
      ),
    );
  }
  
  Widget _buildProgressPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Progress circle
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.blue.shade200,
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                '0%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade600,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Progress info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ready to Start',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your goal begins today',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Confirm button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
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
                Icon(Icons.check_circle, size: 20),
                SizedBox(width: 8),
                Text(
                  'Create Goal',
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
        
        // Edit button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onEdit,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue.shade600,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.blue.shade600),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit, size: 20),
                SizedBox(width: 8),
                Text(
                  'Edit Parameters',
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
    switch (goal.goalType) {
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
  
  String _getDurationText() {
    final startDate = goal.startDate;
    final endDate = goal.endDate;
    
    if (endDate == null) {
      return 'Ongoing';
    }
    
    final duration = endDate.difference(startDate).inDays;
    
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
  
  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
