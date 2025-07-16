import 'package:flutter/material.dart';
import '../../../core/services/goal_progress_service.dart';
import '../../../core/services/goal_management_service.dart';
import '../../../core/services/achievements_service.dart';

/// Motivational goal progress card that shows achievement and recent actions
/// Designed to maximize dopamine and positive reinforcement
class GoalCard extends StatefulWidget {
  final Map<String, dynamic> goalData;
  final VoidCallback? onTap;
  final VoidCallback? onGoalCompleted;
  
  const GoalCard({
    super.key,
    required this.goalData,
    this.onTap,
    this.onGoalCompleted,
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

  @override
  void didUpdateWidget(GoalCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload progress data if goal data changed
    if (oldWidget.goalData != widget.goalData) {
      print('GoalCard: Goal data changed, reloading progress...');
      setState(() {
        _isLoading = true;
      });
      _loadRealProgressData();
    }
  }

  Future<void> _loadRealProgressData() async {
    try {
      print('GoalCard: Loading progress data for goal: ${widget.goalData}');
      final progressService = GoalProgressService.instance;
      final progressData = await progressService.calculateGoalProgress(widget.goalData);
      print('GoalCard: Progress data loaded: $progressData');
      setState(() {
        _progressData = progressData;
        _isLoading = false;
      });
    } catch (e) {
      print('GoalCard: Error loading progress data: $e');
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
              // Show completion button if goal period is over
              if (_shouldShowCompletionButton(progressData)) ...[
                _buildCompletionButton(context, goalTypeInfo, progressData),
                const SizedBox(height: 16),
              ] else ...[
                _buildTimeRemaining(progressData),
                const SizedBox(height: 12),
              ],
              _buildRecentActions(progressData),
            ],
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
      case 'Icons.celebration':
        return Icons.celebration;
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

  /// Check if goal should show completion button (when time period is over)
  bool _shouldShowCompletionButton(Map<String, dynamic> progressData) {
    final daysRemaining = progressData['daysRemaining'] ?? 1;
    return daysRemaining <= 0;
  }

  /// Build the goal completion button
  Widget _buildCompletionButton(BuildContext context, Map<String, dynamic> goalTypeInfo, Map<String, dynamic> progressData) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade400,
            Colors.green.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showGoalCompletionCelebration(context, goalTypeInfo, progressData),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.celebration,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Complete Goal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show the goal completion celebration modal
  Future<void> _showGoalCompletionCelebration(BuildContext context, Map<String, dynamic> goalTypeInfo, Map<String, dynamic> progressData) async {
    // Add the missing imports at the top
    // For now, we'll implement the modal structure
    
    final percentage = ((progressData['percentage'] as double) * 100).round();
    final goalTitle = widget.goalData['title'] ?? 'Your Goal';
    final goalType = widget.goalData['goalType'] ?? '';
    
    // Calculate goal duration
    final startDate = DateTime.parse(widget.goalData['startDate']);
    final durationDays = DateTime.now().difference(startDate).inDays;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                goalTypeInfo['color'].withOpacity(0.1),
                goalTypeInfo['color'].withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Celebration header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: goalTypeInfo['color'].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.celebration,
                  size: 48,
                  color: goalTypeInfo['color'],
                ),
              ),
              const SizedBox(height: 16),
              
              Text(
                '🎉 Congratulations! 🎉',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              Text(
                'You\'ve completed your goal!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Goal summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: goalTypeInfo['color'].withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(goalTypeInfo['icon'], color: goalTypeInfo['color']),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            goalTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryMetric('Duration', '$durationDays days'),
                    _buildSummaryMetric('Final Progress', '$percentage%'),
                    _buildSummaryMetric('Goal Type', _getGoalTypeName(goalType)),
                    if (progressData['currentMetric'] != null)
                      _buildSummaryMetric('Achievement', progressData['currentMetric']),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Celebration message based on goal type
              Text(
                _getCelebrationMessage(goalType, percentage),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: goalTypeInfo['color']),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(color: goalTypeInfo['color']),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => _completeGoalAndStartNew(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: goalTypeInfo['color'],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Set New Goal'),
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

  /// Build a summary metric row
  Widget _buildSummaryMetric(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Get celebration message based on goal type and progress
  String _getCelebrationMessage(String goalType, int percentage) {
    if (percentage >= 90) {
      return "Outstanding achievement! You've exceeded expectations and shown incredible dedication to your wellness journey.";
    } else if (percentage >= 70) {
      return "Great job! You've made significant progress and built healthy habits that will serve you well.";
    } else if (percentage >= 50) {
      return "Well done! Every step forward is progress, and you've shown commitment to positive change.";
    } else {
      return "You completed the time period! Even small steps are meaningful progress in your wellness journey.";
    }
  }

  /// Get user-friendly goal type name
  String _getGoalTypeName(String goalType) {
    switch (goalType) {
      case 'GoalType.weeklyReduction':
        return 'Weekly Reduction';
      case 'GoalType.dailyLimit':
        return 'Daily Limit';
      case 'GoalType.alcoholFreeDays':
        return 'Alcohol-Free Days';
      case 'GoalType.interventionWins':
        return 'Intervention Success';
      case 'GoalType.moodImprovement':
        return 'Mood & Wellbeing';
      case 'GoalType.costSavings':
        return 'Cost Savings';
      case 'GoalType.streakMaintenance':
        return 'Streak Maintenance';
      default:
        return 'Custom Goal';
    }
  }

  /// Complete current goal and navigate to create new goal
  Future<void> _completeGoalAndStartNew(BuildContext context) async {
    try {
      final goalTitle = widget.goalData['title'] ?? 'Goal';
      final goalType = widget.goalData['goalType'] ?? '';
      final progressData = _progressData ?? {};
      final finalProgress = (progressData['percentage'] as double?) ?? 0.0;
      
      // Calculate goal duration
      final startDate = DateTime.parse(widget.goalData['startDate']);
      final durationDays = DateTime.now().difference(startDate).inDays;
      
      // Award achievement for completing the goal
      await AchievementsService.instance.awardGoalCompletion(
        goalTitle: goalTitle,
        goalType: goalType,
        durationDays: durationDays,
        finalProgress: finalProgress,
      );
      
      // Complete the goal (move to completed status)
      await GoalManagementService.instance.completeActiveGoal();
      
      Navigator.of(context).pop(); // Close the celebration modal
      
      // Notify parent screen that goal was completed
      widget.onGoalCompleted?.call();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Goal completed! Achievement unlocked!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error completing goal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
