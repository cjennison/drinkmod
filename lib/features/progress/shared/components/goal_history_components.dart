import 'package:flutter/material.dart';
import '../../../../core/models/user_goal.dart';

/// Shared components for goal history displays
class GoalHistoryComponents {
  /// Creates a goal list item tile
  static Widget buildGoalListItem({
    required Map<String, dynamic> goal,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final status = _parseGoalStatus(goal['status']);
    final startDate = DateTime.tryParse(goal['startDate'] ?? '');
    final endDate = goal['updatedAt'] != null 
        ? DateTime.tryParse(goal['updatedAt']) 
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isSelected ? Colors.blue.shade50 : null,
      child: ListTile(
        title: Text(
          goal['title'] ?? 'Untitled Goal',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getGoalTypeDisplayName(goal['goalType'])),
            if (startDate != null)
              Text(
                endDate != null
                    ? '${_formatDate(startDate)} - ${_formatDate(endDate)}'
                    : 'Started ${_formatDate(startDate)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        trailing: _buildStatusChip(status),
        onTap: onTap,
        selected: isSelected,
      ),
    );
  }

  /// Creates a goal summary header
  static Widget buildSummaryHeader({
    required Map<String, dynamic> goal,
    Map<String, dynamic>? summary,
  }) {
    final status = _parseGoalStatus(goal['status']);
    final startDate = DateTime.tryParse(goal['startDate'] ?? '');
    final endDate = goal['updatedAt'] != null 
        ? DateTime.tryParse(goal['updatedAt']) 
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    goal['title'] ?? 'Untitled Goal',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getGoalTypeDisplayName(goal['goalType']),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            if (goal['description'] != null) ...[
              const SizedBox(height: 8),
              Text(
                goal['description'],
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            if (startDate != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    endDate != null
                        ? '${_formatDate(startDate)} - ${_formatDate(endDate)}'
                        : 'Started ${_formatDate(startDate)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Creates progress overview cards
  static Widget buildProgressOverview({
    required Map<String, dynamic>? summary,
    required Map<String, dynamic> goal,
  }) {
    if (summary == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No progress data available'),
        ),
      );
    }

    final progressPercentage = summary['progressPercentage'] ?? 0.0;
    final currentValue = summary['currentValue'] ?? 0.0;
    final targetValue = summary['targetValue'] ?? 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progress Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (progressPercentage / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                progressPercentage >= 100 ? Colors.green : Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${progressPercentage.toStringAsFixed(1)}% Complete',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetricCard('Current', currentValue.toString()),
                _buildMetricCard('Target', targetValue.toString()),
                _buildMetricCard(
                  'Status', 
                  progressPercentage >= 100 ? 'Achieved' : 'In Progress',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Creates an empty state widget
  static Widget buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No Goal History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Complete some goals to see your history here',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Creates a loading indicator
  static Widget buildLoadingIndicator(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }

  // Helper methods
  static Widget _buildStatusChip(GoalStatus status) {
    Color color;
    IconData icon;
    
    switch (status) {
      case GoalStatus.completed:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case GoalStatus.discontinued:
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case GoalStatus.paused:
        color = Colors.orange;
        icon = Icons.pause_circle;
        break;
      case GoalStatus.active:
        color = Colors.blue;
        icon = Icons.play_circle;
        break;
    }

    return Chip(
      label: Text(
        status.name.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
      avatar: Icon(icon, color: Colors.white, size: 16),
    );
  }

  static Widget _buildMetricCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  static GoalStatus _parseGoalStatus(dynamic status) {
    if (status is String) {
      try {
        return GoalStatus.values.firstWhere(
          (e) => e.name.toLowerCase() == status.toLowerCase(),
        );
      } catch (e) {
        return GoalStatus.completed; // Default for historical goals
      }
    }
    return status as GoalStatus? ?? GoalStatus.completed;
  }

  static String _getGoalTypeDisplayName(dynamic goalType) {
    if (goalType is String) {
      try {
        final type = GoalType.values.firstWhere(
          (e) => e.name == goalType,
        );
        return _formatGoalTypeName(type);
      } catch (e) {
        return goalType.replaceAll('_', ' ').toUpperCase();
      }
    }
    if (goalType is GoalType) {
      return _formatGoalTypeName(goalType);
    }
    return 'Unknown Goal Type';
  }

  static String _formatGoalTypeName(GoalType type) {
    switch (type) {
      case GoalType.weeklyReduction:
        return 'Weekly Reduction';
      case GoalType.dailyLimit:
        return 'Daily Limit';
      case GoalType.alcoholFreeDays:
        return 'Alcohol-Free Days';
      case GoalType.interventionWins:
        return 'Intervention Success';
      case GoalType.moodImprovement:
        return 'Mood Improvement';
      case GoalType.streakMaintenance:
        return 'Streak Maintenance';
      case GoalType.costSavings:
        return 'Cost Savings';
      case GoalType.customGoal:
        return 'Custom Goal';
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
