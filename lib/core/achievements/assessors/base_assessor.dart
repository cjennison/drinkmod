import '../models/achievement_model.dart';
import '../../services/hive_database_service.dart';
import '../../services/goal_management_service.dart';

/// Base class for achievement assessors with common functionality
abstract class BaseAssessor {
  /// Service dependencies
  final HiveDatabaseService _databaseService = HiveDatabaseService.instance;
  final GoalManagementService _goalService = GoalManagementService.instance;

  /// Assess if achievement should be granted
  Future<AssessmentResult> assess(String achievementId, {Map<String, dynamic>? context});

  /// Helper: Get account creation date
  Future<DateTime?> getAccountCreationDate() async {
    return _databaseService.getAccountCreatedDate();
  }

  /// Helper: Get days since account creation
  Future<int> getDaysSinceAccountCreation() async {
    final creationDate = await getAccountCreationDate();
    if (creationDate == null) return 0;
    
    return DateTime.now().difference(creationDate).inDays;
  }

  /// Helper: Check if user has completed any goals
  Future<bool> hasCompletedAnyGoal() async {
    final completedGoals = _goalService.getGoalHistory()
        .where((goal) => goal['status'] == 'GoalStatus.completed')
        .toList();
    return completedGoals.isNotEmpty;
  }

  /// Helper: Get goal completion count
  Future<int> getGoalCompletionCount() async {
    final completedGoals = _goalService.getGoalHistory()
        .where((goal) => goal['status'] == 'GoalStatus.completed')
        .toList();
    return completedGoals.length;
  }

  /// Helper: Check if user has any goals
  Future<bool> hasAnyGoals() async {
    // Check both active and completed goals
    final allGoals = _goalService.getAllGoals();
    final activeGoal = await _goalService.getActiveGoal();
    
    return allGoals.isNotEmpty || activeGoal != null;
  }

  /// Helper: Get first goal completion data
  Future<Map<String, dynamic>?> getFirstCompletedGoal() async {
    final completedGoals = _goalService.getGoalHistory()
        .where((goal) => goal['status'] == 'GoalStatus.completed')
        .toList();
    
    if (completedGoals.isEmpty) return null;
    
    // Sort by completion date
    completedGoals.sort((a, b) {
      final aDate = DateTime.tryParse(a['completedAt'] ?? '') ?? DateTime.now();
      final bDate = DateTime.tryParse(b['completedAt'] ?? '') ?? DateTime.now();
      return aDate.compareTo(bDate);
    });
    
    final firstCompleted = completedGoals.first;
    print('🎯 BaseAssessor: First completed goal: ${firstCompleted['title']} with ${firstCompleted['finalProgress']} progress');
    
    return firstCompleted;
  }

  /// Helper: Check if goal was completed at 100%
  bool wasGoalCompletedAt100Percent(Map<String, dynamic> goalData) {
    final finalProgress = goalData['finalProgress'] as double? ?? 0.0;
    return finalProgress >= 1.0;
  }
}
