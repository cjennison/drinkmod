import 'dart:developer' as developer;
import '../models/user_goal.dart';
import '../utils/map_utils.dart';
import 'hive_core.dart';

/// Service for managing user goals and progress tracking
class GoalManagementService {
  static GoalManagementService? _instance;
  static GoalManagementService get instance => _instance ??= GoalManagementService._();
  
  GoalManagementService._();
  
  final HiveCore _hiveCore = HiveCore.instance;
  
  /// Create a new goal
  Future<String> createGoal({
    required String title,
    required String description,
    required GoalType goalType,
    required Map<String, dynamic> parameters,
    required ChartType associatedChart,
    int priorityLevel = 1,
    DateTime? customStartDate,
    DateTime? customCreatedAt,
  }) async {
    await _hiveCore.ensureInitialized();
    
    final now = DateTime.now();
    final startDate = customStartDate ?? now;
    final createdAt = customCreatedAt ?? now;
    
    final goalId = 'goal_${createdAt.millisecondsSinceEpoch}';
    
    final goal = {
      'id': goalId,
      'title': title,
      'description': description,
      'goalType': goalType.toString(),
      'status': GoalStatus.active.toString(),
      'startDate': startDate.toIso8601String(),
      'endDate': null,
      'parameters': parameters,
      'associatedChart': associatedChart.toString(),
      'priorityLevel': priorityLevel,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': createdAt.toIso8601String(),
      'metrics': {
        'currentProgress': 0.0,
        'targetValue': parameters['targetValue'] ?? 0.0,
        'currentValue': 0.0,
        'lastUpdated': createdAt.toIso8601String(),
        'milestones': [],
        'metadata': <String, dynamic>{},
      },
    };
    
    await _hiveCore.goalsBox.put(goalId, goal);
    developer.log('Created goal: $goalId - $title', name: 'GoalManagementService');
    return goalId;
  }

  /// Get all goals with optional status filter
  List<Map<String, dynamic>> getAllGoals({GoalStatus? status}) {
    if (!_hiveCore.isInitialized) {
      developer.log('HiveCore not initialized when getting all goals', name: 'GoalManagementService');
      return [];
    }
    
    final goals = _hiveCore.goalsBox.values
        .map((goal) => MapUtils.deepConvertMap(goal))
        .toList();
    developer.log('getAllGoals found ${goals.length} total goals', name: 'GoalManagementService');
    
    if (status != null) {
      final filtered = goals.where((goal) => goal['status'] == status.toString()).toList();
      developer.log('getAllGoals filtered to ${filtered.length} goals with status $status', name: 'GoalManagementService');
      return filtered;
    }
    
    return goals;
  }

  /// Get active goals only (should return max 1 goal)
  List<Map<String, dynamic>> getActiveGoals() {
    return getAllGoals(status: GoalStatus.active);
  }

  /// Get the single active goal (new primary method)
  Future<Map<String, dynamic>?> getActiveGoal() async {
    await _hiveCore.ensureInitialized();
    
    final activeGoals = getActiveGoals();
    final result = activeGoals.isNotEmpty ? activeGoals.first : null;
    developer.log('getActiveGoal result: $result', name: 'GoalManagementService');
    return result;
  }

  /// Check if user has an active goal
  Future<bool> hasActiveGoal() async {
    final activeGoal = await getActiveGoal();
    return activeGoal != null;
  }

  /// Set a goal as the single active goal (archives current active goal if exists)
  Future<String> setActiveGoal({
    required String title,
    required String description,
    required GoalType goalType,
    required Map<String, dynamic> parameters,
    required ChartType associatedChart,
    int priorityLevel = 1,
  }) async {
    await _hiveCore.ensureInitialized();
    
    // Archive current active goal if it exists
    final currentActive = await getActiveGoal();
    if (currentActive != null) {
      await _archiveGoal(currentActive['id']);
    }
    
    // Create new goal
    return await createGoal(
      title: title,
      description: description,
      goalType: goalType,
      parameters: parameters,
      associatedChart: associatedChart,
      priorityLevel: priorityLevel,
    );
  }

  /// Archive a goal (move from active to completed)
  Future<void> _archiveGoal(String goalId) async {
    await updateGoalStatus(goalId, GoalStatus.completed);
    developer.log('Goal archived: $goalId', name: 'GoalManagementService');
  }

  /// Complete the current active goal
  Future<void> completeActiveGoal() async {
    final activeGoal = await getActiveGoal();
    if (activeGoal != null) {
      await _archiveGoal(activeGoal['id']);
    }
  }

  /// Get completed goals (goal history)
  List<Map<String, dynamic>> getGoalHistory() {
    return getAllGoals(status: GoalStatus.completed);
  }

  /// Get a specific goal by ID
  Map<String, dynamic>? getGoal(String goalId) {
    if (!_hiveCore.isInitialized) return null;
    
    final goal = _hiveCore.goalsBox.get(goalId);
    return goal != null ? MapUtils.deepConvertMap(goal) : null;
  }

  /// Update goal progress
  Future<void> updateGoalProgress(String goalId, double progress, double currentValue) async {
    await _hiveCore.ensureInitialized();
    
    final goal = _hiveCore.goalsBox.get(goalId);
    if (goal == null) return;
    
    final metrics = Map<String, dynamic>.from(goal['metrics']);
    metrics['currentProgress'] = progress.clamp(0.0, 1.0);
    metrics['currentValue'] = currentValue;
    metrics['lastUpdated'] = DateTime.now().toIso8601String();
    
    goal['metrics'] = metrics;
    goal['updatedAt'] = DateTime.now().toIso8601String();
    
    await _hiveCore.goalsBox.put(goalId, goal);
    developer.log('Updated goal progress: $goalId - ${progress * 100}%', name: 'GoalManagementService');
  }

  /// Update goal status
  Future<void> updateGoalStatus(String goalId, GoalStatus status) async {
    await _hiveCore.ensureInitialized();
    
    final goal = _hiveCore.goalsBox.get(goalId);
    if (goal == null) return;
    
    goal['status'] = status.toString();
    goal['updatedAt'] = DateTime.now().toIso8601String();
    
    if (status == GoalStatus.completed || status == GoalStatus.discontinued) {
      goal['endDate'] = DateTime.now().toIso8601String();
    }
    
    await _hiveCore.goalsBox.put(goalId, goal);
    developer.log('Updated goal status: $goalId - $status', name: 'GoalManagementService');
  }

  /// Update goal milestones
  Future<void> updateGoalMilestones(String goalId, List<Map<String, dynamic>> milestones) async {
    await _hiveCore.ensureInitialized();
    
    final goal = _hiveCore.goalsBox.get(goalId);
    if (goal == null) return;
    
    final metrics = Map<String, dynamic>.from(goal['metrics']);
    metrics['milestones'] = milestones;
    metrics['lastUpdated'] = DateTime.now().toIso8601String();
    
    goal['metrics'] = metrics;
    goal['updatedAt'] = DateTime.now().toIso8601String();
    
    await _hiveCore.goalsBox.put(goalId, goal);
    developer.log('Updated goal milestones: $goalId', name: 'GoalManagementService');
  }

  /// Delete a goal
  Future<void> deleteGoal(String goalId) async {
    await _hiveCore.ensureInitialized();
    
    await _hiveCore.goalsBox.delete(goalId);
    developer.log('Deleted goal: $goalId', name: 'GoalManagementService');
  }

  /// Get goals by type
  List<Map<String, dynamic>> getGoalsByType(GoalType goalType) {
    return _hiveCore.goalsBox.values
        .where((goal) => goal['goalType'] == goalType.toString())
        .map((goal) => MapUtils.deepConvertMap(goal))
        .toList();
  }

  /// Check if user has any active goals (legacy - use hasActiveGoal instead)
  bool hasActiveGoals() {
    // Use synchronous version for backward compatibility
    if (!_hiveCore.isInitialized) return false;
    final activeGoals = getActiveGoals();
    return activeGoals.isNotEmpty;
  }
  
  /// Clear all goals (useful for development and user preference)
  Future<void> clearAllGoals() async {
    await _hiveCore.ensureInitialized();
    
    await _hiveCore.goalsBox.clear();
    developer.log('All goals cleared', name: 'GoalManagementService');
  }
  
  /// Save user goals (legacy method)
  Future<void> saveGoals(Map<String, dynamic> goals) async {
    await _hiveCore.ensureInitialized();
    
    await _hiveCore.goalsBox.put('goals', goals);
    developer.log('Goals saved: $goals', name: 'GoalManagementService');
  }
  
  /// Get user goals (legacy method)
  Map<String, dynamic>? getGoals() {
    if (!_hiveCore.isInitialized) return null;
    
    final data = _hiveCore.goalsBox.get('goals');
    return data != null ? MapUtils.deepConvertMap(data) : null;
  }
  
  /// Update specific goal fields (legacy method)
  Future<void> updateGoals(Map<String, dynamic> updates) async {
    await _hiveCore.ensureInitialized();
    
    final currentGoals = getGoals() ?? <String, dynamic>{};
    currentGoals.addAll(updates);
    
    await saveGoals(currentGoals);
    developer.log('Goals updated: $updates', name: 'GoalManagementService');
  }
}
