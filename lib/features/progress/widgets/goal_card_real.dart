import 'package:flutter/material.dart';
import '../../../core/services/real_progress_service.dart';

/// Motivational goal progress card that shows achievement and recent actions
/// Designed to maximize dopamine and positive reinforcement
class GoalCard extends StatefulWidget {
  final Map<String, dynamic> goalData;
  final VoidCallback? onTap;
  
  const GoalCard({
    super.key,
    required this.goalData,
    this.onTap,
  });

  @override
  State<GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard> {
  Map<String, dynamic>? _progressData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRealProgressData();
  }

  Future<void> _loadRealProgressData() async {
    try {
      final progressService = RealProgressService.instance;
      final progressData = await progressService.calculateRealGoalProgress(widget.goalData);
      setState(() {
        _progressData = progressData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _progressData = _getEmptyProgressData();
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _getEmptyProgressData() {
    return {
      'percentage': 0.0,
      'isOnTrack': true,
      'statusText': 'Goal started today',
      'currentMetric': '0',
      'targetMetric': 'Loading...',
      'bonusMetric': null,
      'recentActions': [
        {
          'icon': 'Icons.flag',
          'color': 'Colors.blue',
          'text': 'Goal created - ready to start!',
        }
      ],
      'daysRemaining': 0,
      'timeProgress': 0.0,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 200,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final goalTypeInfo = _getGoalTypeInfo();
    final progressData = _progressData ?? _getEmptyProgressData();
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                goalTypeInfo['color'].withOpacity(0.05),
                goalTypeInfo['color'].withOpacity(0.1),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(goalTypeInfo, progressData),
              const SizedBox(height: 16),
              _buildProgressSection(goalTypeInfo, progressData),
              const SizedBox(height: 16),
              _buildTimeRemaining(progressData),
              const SizedBox(height: 12),
              _buildRecentActions(progressData),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> goalTypeInfo, Map<String, dynamic> progressData) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: goalTypeInfo['color'].withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            goalTypeInfo['icon'],
            size: 24,
            color: goalTypeInfo['color'],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.goalData['title'] ?? 'My Goal',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                goalTypeInfo['name'],
                style: TextStyle(
                  fontSize: 14,
                  color: goalTypeInfo['color'],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        _buildProgressBadge(progressData),
      ],
    );
  }

  Widget _buildProgressBadge(Map<String, dynamic> progressData) {
    final percentage = ((progressData['percentage'] as double) * 100).round();
    final isOnTrack = progressData['isOnTrack'] ?? true;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOnTrack ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isOnTrack ? Colors.green : Colors.orange).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnTrack ? Icons.trending_up : Icons.schedule,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            '$percentage%',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(Map<String, dynamic> goalTypeInfo, Map<String, dynamic> progressData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              progressData['statusText'] ?? '',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: goalTypeInfo['color'],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildProgressBar(goalTypeInfo, progressData),
        const SizedBox(height: 8),
        _buildProgressMetrics(progressData),
      ],
    );
  }

  Widget _buildProgressBar(Map<String, dynamic> goalTypeInfo, Map<String, dynamic> progressData) {
    final progress = progressData['percentage'] ?? 0.0;
    
    return Container(
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.grey.shade200,
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (progress as double).clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              colors: [
                goalTypeInfo['color'].withOpacity(0.8),
                goalTypeInfo['color'],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressMetrics(Map<String, dynamic> progressData) {
    return Row(
      children: [
        _buildMetricChip(
          icon: Icons.check_circle_outline,
          label: progressData['currentMetric'] ?? '0',
          color: Colors.green,
        ),
        const SizedBox(width: 8),
        _buildMetricChip(
          icon: Icons.flag_outlined,
          label: progressData['targetMetric'] ?? '0',
          color: Colors.blue,
        ),
        if (progressData['bonusMetric'] != null) ...[
          const SizedBox(width: 8),
          _buildMetricChip(
            icon: Icons.star_outline,
            label: progressData['bonusMetric'],
            color: Colors.amber,
          ),
        ],
      ],
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRemaining(Map<String, dynamic> progressData) {
    final daysRemaining = progressData['daysRemaining'] ?? 0;
    final timeProgress = progressData['timeProgress'] ?? 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Time Remaining',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              '$daysRemaining days',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: Colors.grey.shade300,
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (timeProgress as double).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActions(Map<String, dynamic> progressData) {
    final recentActions = progressData['recentActions'] as List<Map<String, dynamic>>? ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Achievements',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        ...recentActions.take(3).map((action) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Icon(
                _getIconFromString(action['icon']),
                size: 16,
                color: _getColorFromString(action['color']),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  action['text'],
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Map<String, dynamic> _getGoalTypeInfo() {
    final goalTypeString = widget.goalData['goalType'] ?? '';
    
    switch (goalTypeString) {
      case 'GoalType.weeklyReduction':
        return {
          'name': 'Weekly Reduction',
          'icon': Icons.trending_down,
          'color': Colors.orange,
        };
      case 'GoalType.dailyLimit':
        return {
          'name': 'Daily Limit',
          'icon': Icons.timer,
          'color': Colors.blue,
        };
      case 'GoalType.alcoholFreeDays':
        return {
          'name': 'Alcohol-Free Days',
          'icon': Icons.calendar_today,
          'color': Colors.green,
        };
      case 'GoalType.interventionWins':
        return {
          'name': 'Intervention Success',
          'icon': Icons.psychology,
          'color': Colors.purple,
        };
      case 'GoalType.moodImprovement':
        return {
          'name': 'Mood & Wellbeing',
          'icon': Icons.sentiment_satisfied,
          'color': Colors.pink,
        };
      case 'GoalType.costSavings':
        return {
          'name': 'Cost Savings',
          'icon': Icons.savings,
          'color': Colors.teal,
        };
      case 'GoalType.streakMaintenance':
        return {
          'name': 'Streak Maintenance',
          'icon': Icons.whatshot,
          'color': Colors.deepOrange,
        };
      default:
        return {
          'name': 'Custom Goal',
          'icon': Icons.star,
          'color': Colors.indigo,
        };
    }
  }

  IconData _getIconFromString(String iconString) {
    switch (iconString) {
      case 'Icons.check_circle':
        return Icons.check_circle;
      case 'Icons.info':
        return Icons.info;
      case 'Icons.flag':
        return Icons.flag;
      case 'Icons.attach_money':
        return Icons.attach_money;
      case 'Icons.trending_down':
        return Icons.trending_down;
      default:
        return Icons.info;
    }
  }

  Color _getColorFromString(String colorString) {
    switch (colorString) {
      case 'Colors.green':
        return Colors.green;
      case 'Colors.orange':
        return Colors.orange;
      case 'Colors.blue':
        return Colors.blue;
      case 'Colors.purple':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
