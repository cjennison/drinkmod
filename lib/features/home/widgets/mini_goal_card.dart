import 'package:flutter/material.dart';
import '../../../core/services/goal_progress_service.dart';
import '../../../core/services/goal_management_service.dart';

/// Mini version of the goal card for home screen
/// Shows condensed goal progress and navigates to progress page when tapped
class MiniGoalCard extends StatefulWidget {
  final VoidCallback? onTap;
  
  const MiniGoalCard({
    super.key,
    this.onTap,
  });

  @override
  State<MiniGoalCard> createState() => _MiniGoalCardState();
}

class _MiniGoalCardState extends State<MiniGoalCard> {
  Map<String, dynamic>? _goalData;
  Map<String, dynamic>? _progressData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoalData();
  }

  Future<void> _loadGoalData() async {
    try {
      final goalService = GoalManagementService.instance;
      final activeGoal = await goalService.getActiveGoal();
      
      if (activeGoal != null) {
        final progressService = GoalProgressService.instance;
        final progressData = await progressService.calculateGoalProgress(activeGoal);
        
        setState(() {
          _goalData = activeGoal;
          _progressData = progressData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _goalData = null;
          _progressData = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _goalData = null;
        _progressData = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything if no goal exists
    if (_isLoading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_goalData == null) {
      return _buildGoalCTACard(context);
    }

    final goalTypeInfo = _getGoalTypeInfo();
    final progressData = _progressData ?? _getEmptyProgressData();
    
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
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
              _buildMiniHeader(goalTypeInfo, progressData),
              const SizedBox(height: 12),
              _buildMiniProgress(goalTypeInfo, progressData),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniHeader(Map<String, dynamic> goalTypeInfo, Map<String, dynamic> progressData) {
    final percentage = ((progressData['percentage'] as double) * 100).round();
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: goalTypeInfo['color'].withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
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
                _goalData!['title'] ?? 'My Goal',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                goalTypeInfo['name'],
                style: TextStyle(
                  fontSize: 12,
                  color: goalTypeInfo['color'],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: goalTypeInfo['color'],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$percentage%',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniProgress(Map<String, dynamic> goalTypeInfo, Map<String, dynamic> progressData) {
    final progress = progressData['percentage'] ?? 0.0;
    final statusText = progressData['statusText'] ?? '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: goalTypeInfo['color'],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: Colors.grey.shade200,
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (progress as double).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: goalTypeInfo['color'],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _getEmptyProgressData() {
    return {
      'percentage': 0.0,
      'isOnTrack': true,
      'statusText': 'Goal started today',
      'currentMetric': '0',
      'targetMetric': 'Loading...',
      'daysRemaining': 0,
      'timeProgress': 0.0,
    };
  }

  Map<String, dynamic> _getGoalTypeInfo() {
    final goalTypeString = _goalData?['goalType'] ?? '';
    
    switch (goalTypeString) {
      case 'GoalType.weeklyReduction':
        return {
          'name': 'Weekly Reduction',
          'icon': Icons.trending_down,
          'color': Colors.blue,
        };
      case 'GoalType.dailyLimit':
        return {
          'name': 'Daily Limit',
          'icon': Icons.today,
          'color': Colors.orange,
        };
      case 'GoalType.alcoholFreeDays':
        return {
          'name': 'Alcohol-Free Days',
          'icon': Icons.event_available,
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
          'icon': Icons.sentiment_very_satisfied,
          'color': Colors.amber,
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
          'icon': Icons.local_fire_department,
          'color': Colors.red,
        };
      default:
        return {
          'name': 'Custom Goal',
          'icon': Icons.flag,
          'color': Colors.grey,
        };
    }
  }
  
  /// Build the CTA card that encourages users to set their first goal
  Widget _buildGoalCTACard(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade50,
                Colors.blue.shade100,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.flag_outlined,
                      size: 24,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Your Progress Journey',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Set Your First Goal',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Start now',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Research shows that individuals who set clear, achievable goals are significantly more successful in creating lasting change. Your progress page will guide you through setting a personalized goal that aligns with your wellness journey.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Tap to explore your progress and goal options',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
