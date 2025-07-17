import 'package:flutter/material.dart';
import 'goal_progress_card.dart';
import '../shared/types/goal_display_types.dart';

/// Legacy goal card wrapper - now uses GoalProgressCard
/// Maintained for backwards compatibility
class GoalCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GoalProgressCard(
      goalData: goalData,
      variant: GoalCardSize.expanded,
      onTap: onTap,
      onGoalCompleted: onGoalCompleted,
    );
  }
}
