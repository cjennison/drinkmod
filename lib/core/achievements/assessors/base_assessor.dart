import '../models/achievement_model.dart';
import '../../services/user_data_service.dart';
import '../../services/goal_management_service.dart';

/// Base class for achievement assessors with common functionality
abstract class BaseAssessor {
  /// Service dependencies
  final UserDataService _userService = UserDataService.instance;
  final GoalManagementService _goalService = GoalManagementService.instance;

  /// Assess if achievement should be granted
  Future<AssessmentResult> assess(String achievementId, {Map<String, dynamic>? context});

  /// Helper: Get account creation date
  Future<DateTime?> getAccountCreationDate() async {
    return _userService.getAccountCreatedDate();
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
    
    print('🎯 BaseAssessor: Found ${completedGoals.length} completed goals');
    
    if (completedGoals.isEmpty) return null;
    
    // Debug: Print details of completed goals
    for (int i = 0; i < completedGoals.length; i++) {
      final goal = completedGoals[i];
      print('🎯 BaseAssessor: Completed goal $i: ${goal['title']}');
      print('🎯 BaseAssessor: - Status: ${goal['status']}');
      print('🎯 BaseAssessor: - CompletedAt: ${goal['completedAt']}');
      print('🎯 BaseAssessor: - FinalProgress: ${goal['finalProgress']}');
      print('🎯 BaseAssessor: - EndDate: ${goal['endDate']}');
    }
    
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
