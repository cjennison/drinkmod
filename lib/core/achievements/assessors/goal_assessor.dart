import '../models/achievement_model.dart';
import 'base_assessor.dart';
import '../../services/goal_management_service.dart';

/// Assessor for goal-related achievements
class GoalAssessor extends BaseAssessor {
  final GoalManagementService _goalService = GoalManagementService.instance;
  @override
  Future<AssessmentResult> assess(String achievementId, {Map<String, dynamic>? context}) async {
    switch (achievementId) {
      case 'first_goal':
        return await _assessFirstGoal();
      case 'first_goal_completed':
        return await _assessFirstGoalCompleted();
      case 'first_goal_finished':
        return await _assessFirstGoalFinished();
      default:
        return const AssessmentResult.skip(reason: 'Unknown goal achievement');
    }
  }

  /// Check if user has created their first goal
  Future<AssessmentResult> _assessFirstGoal() async {
    final hasGoals = await hasAnyGoals();
    
    if (hasGoals) {
      // Check both all goals and active goal for completeness
      final allGoals = _goalService.getAllGoals();
      final activeGoal = await _goalService.getActiveGoal();
      
      // Use active goal as first goal if available, otherwise first from all goals
      final firstGoal = activeGoal ?? (allGoals.isNotEmpty ? allGoals.first : null);
      final totalGoalCount = allGoals.length + (activeGoal != null ? 1 : 0);
      
      if (firstGoal != null) {
        return AssessmentResult.grant(
          context: {
            'goalCount': totalGoalCount,
            'firstGoalTitle': firstGoal['title'],
            'firstGoalType': firstGoal['goalType'],
          },
          reason: 'User has created their first goal: ${firstGoal['title']}',
        );
      }
    }
    
    return const AssessmentResult.skip(
      reason: 'User has not created any goals yet',
    );
  }

  /// Check if user has completed their first goal at 100%
  Future<AssessmentResult> _assessFirstGoalCompleted() async {
    final firstCompletedGoal = await getFirstCompletedGoal();
    
    if (firstCompletedGoal != null && wasGoalCompletedAt100Percent(firstCompletedGoal)) {
      return AssessmentResult.grant(
        context: {
          'goalTitle': firstCompletedGoal['title'],
          'goalType': firstCompletedGoal['goalType'],
          'completedAt': firstCompletedGoal['completedAt'],
          'finalProgress': firstCompletedGoal['finalProgress'],
        },
        reason: 'First goal completed at 100%',
      );
    }
    
    return const AssessmentResult.skip(
      reason: 'No goals completed at 100% yet',
    );
  }

  /// Check if user has finished their first goal (any completion percentage)
  Future<AssessmentResult> _assessFirstGoalFinished() async {
    final firstCompletedGoal = await getFirstCompletedGoal();
    
    if (firstCompletedGoal != null) {
      final finalProgress = firstCompletedGoal['finalProgress'] as double? ?? 0.0;
      
      return AssessmentResult.grant(
        context: {
          'goalTitle': firstCompletedGoal['title'],
          'goalType': firstCompletedGoal['goalType'],
          'completedAt': firstCompletedGoal['completedAt'],
          'finalProgress': finalProgress,
        },
        reason: 'First goal finished with ${(finalProgress * 100).round()}% progress',
      );
    }
    
    return const AssessmentResult.skip(
      reason: 'No goals finished yet',
    );
  }
}
