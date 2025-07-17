import 'package:flutter/material.dart';
import '../../../../core/models/user_goal.dart';
import '../../../../core/utils/date_utils.dart' as date_utils;

/// Shared components for goal preview displays
class GoalPreviewComponents {
  /// Creates a goal preview card with all details
  static Widget buildGoalPreviewCard({
    required UserGoal goal,
  }) {
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (goal.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        goal.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              buildGoalTypeBadge(goal.goalType),
            ],
          ),
          const SizedBox(height: 16),
          buildParametersSection(goal),
          const SizedBox(height: 16),
          buildTimelineSection(goal),
        ],
      ),
    );
  }

  /// Creates a goal type badge
  static Widget buildGoalTypeBadge(GoalType goalType) {
    final typeInfo = _getGoalTypeInfo(goalType);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: typeInfo['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: typeInfo['color'].withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            typeInfo['icon'],
            size: 14,
            color: typeInfo['color'],
          ),
          const SizedBox(width: 4),
          Text(
            typeInfo['label'],
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: typeInfo['color'],
            ),
          ),
        ],
      ),
    );
  }

  /// Creates the parameters section
  static Widget buildParametersSection(UserGoal goal) {
    final parameters = _getParameterDisplayItems(goal);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Goal Parameters',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          ...parameters.map((param) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: buildParameterItem(param['label']!, param['value']!),
              )),
        ],
      ),
    );
  }

  /// Creates a single parameter item
  static Widget buildParameterItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  /// Creates the timeline section
  static Widget buildTimelineSection(UserGoal goal) {
    final targetDate = _calculateTargetDate(goal);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: Colors.blue[700]),
              const SizedBox(width: 6),
              Text(
                'Timeline',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.play_arrow, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                'Start: ${_formatDate(goal.startDate)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.flag, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                'Target: ${_formatDate(targetDate)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Creates a visual progress preview
  static Widget buildProgressPreview({
    required UserGoal goal,
    double mockProgress = 0.0,
  }) {
    return Container(
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
          Row(
            children: [
              Icon(Icons.insights, color: Colors.blue[600]),
              const SizedBox(width: 8),
              const Text(
                'Progress Preview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: mockProgress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
          ),
          const SizedBox(height: 8),
          Text(
            '${(mockProgress * 100).toStringAsFixed(0)}% Complete',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This is how your progress will look as you work towards your goal.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Creates action buttons for the preview
  static Widget buildActionButtons({
    required VoidCallback onEdit,
    required VoidCallback onConfirm,
    required BuildContext context,
  }) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Create Goal',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: onEdit,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Edit Goal',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods
  static Map<String, dynamic> _getGoalTypeInfo(GoalType goalType) {
    switch (goalType) {
      case GoalType.weeklyReduction:
        return {
          'label': 'Weekly Reduction',
          'icon': Icons.trending_down,
          'color': Colors.orange,
        };
      case GoalType.dailyLimit:
        return {
          'label': 'Daily Limit',
          'icon': Icons.schedule,
          'color': Colors.blue,
        };
      case GoalType.alcoholFreeDays:
        return {
          'label': 'Alcohol-Free Days',
          'icon': Icons.calendar_today,
          'color': Colors.green,
        };
      case GoalType.interventionWins:
        return {
          'label': 'Intervention Success',
          'icon': Icons.psychology,
          'color': Colors.purple,
        };
      case GoalType.moodImprovement:
        return {
          'label': 'Mood Improvement',
          'icon': Icons.mood,
          'color': Colors.amber,
        };
      case GoalType.streakMaintenance:
        return {
          'label': 'Streak Maintenance',
          'icon': Icons.local_fire_department,
          'color': Colors.red,
        };
      case GoalType.costSavings:
        return {
          'label': 'Cost Savings',
          'icon': Icons.savings,
          'color': Colors.teal,
        };
      case GoalType.customGoal:
        return {
          'label': 'Custom Goal',
          'icon': Icons.star,
          'color': Colors.indigo,
        };
    }
  }

  static List<Map<String, String>> _getParameterDisplayItems(UserGoal goal) {
    final items = <Map<String, String>>[];
    final params = goal.parameters;

    switch (goal.goalType) {
      case GoalType.weeklyReduction:
        items.add({'label': 'Target Weekly Drinks', 'value': '${params['targetWeeklyDrinks'] ?? 'N/A'}'});
        items.add({'label': 'Duration', 'value': '${params['durationMonths'] ?? 'N/A'} months'});
        break;
      case GoalType.dailyLimit:
        items.add({'label': 'Daily Limit', 'value': '${params['dailyLimit'] ?? 'N/A'} drinks'});
        items.add({'label': 'Duration', 'value': '${params['durationWeeks'] ?? 'N/A'} weeks'});
        break;
      case GoalType.alcoholFreeDays:
        items.add({'label': 'Alcohol-Free Days', 'value': '${params['alcoholFreeDaysPerWeek'] ?? 'N/A'} per week'});
        items.add({'label': 'Duration', 'value': '${params['durationMonths'] ?? 'N/A'} months'});
        break;
      case GoalType.interventionWins:
        items.add({'label': 'Target Success Rate', 'value': '${params['targetSuccessRate'] ?? 'N/A'}%'});
        items.add({'label': 'Duration', 'value': '${params['durationWeeks'] ?? 'N/A'} weeks'});
        break;
      case GoalType.moodImprovement:
        items.add({'label': 'Target Mood', 'value': '${params['targetAverageMood'] ?? 'N/A'}/10'});
        items.add({'label': 'Duration', 'value': '${params['durationWeeks'] ?? 'N/A'} weeks'});
        break;
      case GoalType.costSavings:
        items.add({'label': 'Target Savings', 'value': '\$${params['targetSavings'] ?? 'N/A'}'});
        items.add({'label': 'Duration', 'value': '${params['durationMonths'] ?? 'N/A'} months'});
        break;
      case GoalType.streakMaintenance:
        items.add({'label': 'Streak Days', 'value': '${params['streakDays'] ?? 'N/A'}'});
        break;
      case GoalType.customGoal:
        items.add({'label': 'Custom Value', 'value': '${params['customValue'] ?? 'N/A'}'});
        break;
    }

    return items;
  }

  static String _formatDate(DateTime date) {
    return date_utils.DateUtils.formatTimelineDate(date);
  }

  static DateTime _calculateTargetDate(UserGoal goal) {
    final params = goal.parameters;
    int durationDays = 30; // default
    
    switch (goal.goalType) {
      case GoalType.weeklyReduction:
      case GoalType.alcoholFreeDays:
      case GoalType.costSavings:
        final months = params['durationMonths'] as int? ?? 1;
        durationDays = months * 30;
        break;
      case GoalType.dailyLimit:
      case GoalType.interventionWins:
      case GoalType.moodImprovement:
        final weeks = params['durationWeeks'] as int? ?? 1;
        durationDays = weeks * 7;
        break;
      case GoalType.streakMaintenance:
        durationDays = params['streakDays'] as int? ?? 30;
        break;
      case GoalType.customGoal:
        durationDays = params['duration'] as int? ?? 30;
        break;
    }
    
    return goal.startDate.add(Duration(days: durationDays));
  }
}
