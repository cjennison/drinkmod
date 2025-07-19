import 'package:flutter/material.dart';
import '../../../core/utils/date_utils.dart' as date_utils;
import '../shared/components/adaptive_goal_card.dart';
import '../shared/components/goal_card_components.dart';
import '../shared/types/goal_display_types.dart';
import '../shared/utils/goal_type_utils.dart';

/// Goal progress card with adaptive sizing and shared UI components
class GoalProgressCard extends AdaptiveGoalCard {
  final VoidCallback? onGoalCompleted;
  
  const GoalProgressCard({
    super.key,
    required super.goalData,
    super.onTap,
    super.variant = GoalCardSize.expanded,
    this.onGoalCompleted,
  });

  @override
  State<GoalProgressCard> createState() => _GoalProgressCardState();
}

class _GoalProgressCardState extends AdaptiveGoalCardState<GoalProgressCard> {
  
  @override
  Widget build(BuildContext context) {
    switch (loadingState) {
      case DataLoadingState.loading:
        return buildLoadingState();
      case DataLoadingState.error:
        return buildErrorState();
      case DataLoadingState.empty:
      case DataLoadingState.loaded:
        return _buildLoadedCard();
    }
  }

  Widget _buildLoadedCard() {
    final data = progressData!;
    final goalTypeInfo = _getGoalTypeInfo();
    
    return GoalCardComponents.buildCardContainer(
      color: goalTypeInfo['color'],
      margin: _getCardMargin(),
      onTap: widget.onTap,
      child: _buildContent(data, goalTypeInfo),
    );
  }

  Widget _buildContent(Map<String, dynamic> data, Map<String, dynamic> goalTypeInfo) {
    switch (widget.variant) {
      case GoalCardSize.compact:
        return _buildCompactContent(data, goalTypeInfo);
      case GoalCardSize.standard:
        return _buildStandardContent(data, goalTypeInfo);
      case GoalCardSize.expanded:
        return _buildExpandedContent(data, goalTypeInfo);
    }
  }

  Widget _buildCompactContent(Map<String, dynamic> data, Map<String, dynamic> goalTypeInfo) {
    final percentage = ((data['percentage'] as num).toDouble() * 100).clamp(0.0, 100.0);
    final endDate = _calculateEndDate();
    final daysRemaining = _calculateDaysRemaining(endDate);
    final isFinished = daysRemaining <= 0 || percentage >= 100.0;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                goalTypeInfo['icon'],
                color: goalTypeInfo['color'],
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  goalTypeInfo['title'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage / 100.0,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(goalTypeInfo['color']),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${percentage.toStringAsFixed(0)}% Complete',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              if (isFinished)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: percentage >= 100.0 ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    percentage >= 100.0 ? 'Complete' : 'Finished',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          if (isFinished) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: goalTypeInfo['color'],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 1,
                ),
                child: const Text(
                  'View Details',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStandardContent(Map<String, dynamic> data, Map<String, dynamic> goalTypeInfo) {
    final percentage = ((data['percentage'] as num).toDouble() * 100).clamp(0.0, 100.0);
    final isOnTrack = data['isOnTrack'] ?? true;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GoalCardComponents.buildCardHeader(
            goalData: widget.goalData,
            icon: goalTypeInfo['icon'],
            color: goalTypeInfo['color'],
            title: goalTypeInfo['title'],
            subtitle: goalTypeInfo['subtitle'],
          ),
          const SizedBox(height: 12),
          GoalCardComponents.buildProgressIndicator(
            percentage: percentage,
            color: goalTypeInfo['color'],
            isOnTrack: isOnTrack,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${percentage.toStringAsFixed(1)}% Complete',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _getTimelineText(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          Text(
            data['statusText'] ?? 'No status available',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(Map<String, dynamic> data, Map<String, dynamic> goalTypeInfo) {
    final percentage = ((data['percentage'] as num).toDouble() * 100).clamp(0.0, 100.0);
    final isOnTrack = data['isOnTrack'] ?? true;
    final actions = data['recentActions'] as List<dynamic>? ?? [];
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEnhancedHeader(goalTypeInfo),
          const SizedBox(height: 16),
          GoalCardComponents.buildProgressIndicator(
            percentage: percentage,
            color: goalTypeInfo['color'],
            isOnTrack: isOnTrack,
          ),
          const SizedBox(height: 16),
          // Show completion CTA when goal time is up OR when 100% complete
          Builder(
            builder: (context) {
              final endDate = _calculateEndDate();
              final daysRemaining = _calculateDaysRemaining(endDate);
              final isTimeUp = daysRemaining <= 0;
              final isPercentComplete = percentage >= 100.0;
              
              if (isTimeUp || isPercentComplete) {
                return Column(
                  children: [
                    _buildGoalCompleteSection(
                      isActuallyComplete: isPercentComplete,
                      isTimeUp: isTimeUp,
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          _buildSimplifiedMetrics(data),
          const SizedBox(height: 16),
          GoalCardComponents.buildActionsList(
            actions: actions,
            title: 'Recent Activity',
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getGoalTypeInfo() {
    final goalTypeString = widget.goalData['goalType']?.toString();
    final displayName = GoalTypeHelper.getDisplayNameFromString(goalTypeString);
    
    // Default values
    IconData icon = Icons.flag;
    Color color = Colors.blue;
    String subtitle = 'Track your progress';

    // Customize based on goal type with clear explanations
    if (goalTypeString != null) {
      if (goalTypeString.contains('daily')) {
        icon = Icons.today;
        color = Colors.green;
        subtitle = 'Keep your daily drinks under your target';
      } else if (goalTypeString.contains('weekly')) {
        icon = Icons.calendar_view_week;
        color = Colors.orange;
        subtitle = 'Stay within your weekly drink limit';
      } else if (goalTypeString.contains('alcoholFree') || goalTypeString.contains('dry')) {
        icon = Icons.flag;
        color = Colors.blue;
        subtitle = 'Complete alcohol-free days in your timeline';
      } else if (goalTypeString.contains('streak')) {
        icon = Icons.local_fire_department;
        color = Colors.red;
        subtitle = 'Maintain consecutive alcohol-free days';
      } else if (goalTypeString.contains('intervention')) {
        icon = Icons.psychology;
        color = Colors.purple;
        subtitle = 'Resist urges when the app offers interventions';
      } else if (goalTypeString.contains('mood')) {
        icon = Icons.sentiment_satisfied;
        color = Colors.teal;
        subtitle = 'Improve your mood through reduced drinking';
      } else if (goalTypeString.contains('cost')) {
        icon = Icons.savings;
        color = Colors.amber;
        subtitle = 'Save money by reducing alcohol spending';
      }
    }

    return {
      'title': displayName,
      'subtitle': subtitle,
      'icon': icon,
      'color': color,
    };
  }

  EdgeInsets _getCardMargin() {
    // Use zero margin - let parent handle spacing
    return EdgeInsets.zero;
  }

  DateTime? _calculateEndDate() {
    final startDate = DateTime.tryParse(widget.goalData['startDate'] ?? '');
    if (startDate == null) return null;
    
    final parameters = widget.goalData['parameters'] as Map<String, dynamic>? ?? {};
    final goalType = widget.goalData['goalType']?.toString();
    
    // Calculate end date based on goal type and duration
    if (goalType?.contains('daily') == true) {
      final weeks = parameters['durationWeeks'] as int? ?? 4;
      return startDate.add(Duration(days: weeks * 7));
    } else if (goalType?.contains('weekly') == true || goalType?.contains('cost') == true) {
      final months = parameters['durationMonths'] as int? ?? 3;
      return DateTime(startDate.year, startDate.month + months, startDate.day);
    } else if (goalType?.contains('intervention') == true) {
      final weeks = parameters['durationWeeks'] as int? ?? 4;
      return startDate.add(Duration(days: weeks * 7));
    }
    
    // Default to 30 days
    return startDate.add(const Duration(days: 30));
  }
  
  int _calculateDaysRemaining(DateTime? endDate) {
    if (endDate == null) return 0;
    final now = DateTime.now();
    final difference = endDate.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }
  
  int _calculateDaysSinceStart(DateTime? startDate) {
    if (startDate == null) return 0;
    final now = DateTime.now();
    return now.difference(startDate).inDays + 1; // +1 to include start day
  }
  
  String _getTimelineText() {
    final endDate = _calculateEndDate();
    final daysRemaining = _calculateDaysRemaining(endDate);
    final startDate = DateTime.tryParse(widget.goalData['startDate'] ?? '');
    final daysSinceStart = _calculateDaysSinceStart(startDate);
    
    if (daysRemaining <= 0) {
      return 'Goal period ended';
    } else if (daysRemaining == 1) {
      return '1 day remaining';
    } else if (daysRemaining <= 7) {
      return '$daysRemaining days remaining';
    } else if (daysSinceStart == 1) {
      return 'Started today';
    } else {
      return 'Day $daysSinceStart of goal';
    }
  }

  Widget _buildEnhancedHeader(Map<String, dynamic> goalTypeInfo) {
    final startDate = DateTime.tryParse(widget.goalData['startDate'] ?? '');
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: goalTypeInfo['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            goalTypeInfo['icon'],
            color: goalTypeInfo['color'],
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goalTypeInfo['title'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                goalTypeInfo['subtitle'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        if (startDate != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'Timeline',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Builder(
                  builder: (context) {
                    final endDate = _calculateEndDate();
                    final endDateText = endDate != null ? date_utils.DateUtils.formatShortDate(endDate) : 'Ongoing';
                    return Text(
                      '${date_utils.DateUtils.formatShortDate(startDate)} - $endDateText',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildGoalCompleteSection({
    required bool isActuallyComplete,
    required bool isTimeUp,
  }) {
    // Determine messaging based on completion state
    String title;
    String subtitle;
    Color backgroundColor;
    Color borderColor;
    Color iconColor;
    Color textColor;
    IconData icon;
    
    if (isActuallyComplete) {
      // Goal was actually completed (100%)
      title = 'Goal Complete!';
      subtitle = 'Ready to set your next challenge?';
      backgroundColor = Colors.green[50]!;
      borderColor = Colors.green[200]!;
      iconColor = Colors.green[600]!;
      textColor = Colors.green[700]!;
      icon = Icons.celebration;
    } else {
      // Time is up but goal not fully completed
      title = 'Goal Period Ended';
      subtitle = 'Ready to start fresh with a new goal?';
      backgroundColor = Colors.blue[50]!;
      borderColor = Colors.blue[200]!;
      iconColor = Colors.blue[600]!;
      textColor = Colors.blue[700]!;
      icon = Icons.schedule;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigate to goal setup or call callback
              widget.onGoalCompleted?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: iconColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Set New Goal'),
          ),
        ],
      ),
    );
  }

  Widget _buildSimplifiedMetrics(Map<String, dynamic> data) {
    final endDate = _calculateEndDate();
    final daysRemaining = _calculateDaysRemaining(endDate);
    final goalType = widget.goalData['goalType']?.toString();
    
    // For intervention goals, check if target success rate is achieved
    bool isInterventionGoalComplete = false;
    if (goalType?.contains('intervention') == true) {
      // Check if interventionStats data exists for percentage-based goals
      final interventionStats = data['interventionStats'] as Map<String, dynamic>?;
      if (interventionStats != null) {
        final currentRate = interventionStats['currentSuccessRate'] as double? ?? 0.0;
        final targetRate = interventionStats['targetSuccessRate'] as double? ?? 0.7;
        final totalInterventions = interventionStats['totalInterventions'] as int? ?? 0;
        // Goal is complete if they have at least 3 interventions and met the target rate
        isInterventionGoalComplete = totalInterventions >= 3 && currentRate >= targetRate;
      } else {
        // Fallback for old win-count based goals
        final currentWins = int.tryParse(data['currentMetric']?.toString().replaceAll(RegExp(r'[^\d]'), '') ?? '0') ?? 0;
        final targetWins = int.tryParse(data['targetMetric']?.toString().replaceAll(RegExp(r'[^\d]'), '') ?? '0') ?? 0;
        isInterventionGoalComplete = currentWins >= targetWins;
      }
    }
    
    // Max 3 boxes: Current, Target, Status/Days Left
    return Row(
      children: [
        Expanded(
          child: GoalCardComponents.buildMetricChip(
            label: 'Current',
            value: data['currentMetric']?.toString() ?? '0',
            color: Colors.blue,
            icon: Icons.check_circle_outline,
          ),
        ),
        Expanded(
          child: GoalCardComponents.buildMetricChip(
            label: 'Target',
            value: data['targetMetric']?.toString() ?? 'N/A',
            color: Colors.green,
            icon: Icons.flag_outlined,
          ),
        ),
        Expanded(
          child: GoalCardComponents.buildMetricChip(
            label: _getThirdMetricLabel(daysRemaining, isInterventionGoalComplete),
            value: _getThirdMetricValue(daysRemaining, isInterventionGoalComplete),
            color: _getThirdMetricColor(daysRemaining, isInterventionGoalComplete),
            icon: _getThirdMetricIcon(daysRemaining, isInterventionGoalComplete),
          ),
        ),
      ],
    );
  }
  
  String _getThirdMetricLabel(int daysRemaining, bool isInterventionGoalComplete) {
    if (isInterventionGoalComplete) {
      return 'Status';
    } else if (daysRemaining > 0) {
      return 'Days Left';
    } else {
      return 'Status';
    }
  }
  
  String _getThirdMetricValue(int daysRemaining, bool isInterventionGoalComplete) {
    if (isInterventionGoalComplete) {
      return 'Complete';
    } else if (daysRemaining > 0) {
      return daysRemaining.toString();
    } else {
      return 'Finished';
    }
  }
  
  Color _getThirdMetricColor(int daysRemaining, bool isInterventionGoalComplete) {
    if (isInterventionGoalComplete) {
      return Colors.green;
    } else if (daysRemaining > 7) {
      return Colors.teal;
    } else if (daysRemaining > 0) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }
  
  IconData _getThirdMetricIcon(int daysRemaining, bool isInterventionGoalComplete) {
    if (isInterventionGoalComplete) {
      return Icons.check_circle;
    } else if (daysRemaining > 0) {
      return Icons.timer;
    } else {
      return Icons.schedule;
    }
  }
}
