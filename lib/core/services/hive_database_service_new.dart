import 'dart:developer' as developer;
import '../constants/onboarding_constants.dart';
import 'hive_core.dart';
import 'user_data_service.dart';
import 'drink_tracking_service.dart';
import 'goal_management_service.dart';
import 'intervention_service.dart';
import 'drink_limits_service.dart';
import 'analytics_service.dart';
import 'settings_service.dart';
import 'schedule_service.dart';

/// Unified service facade that provides access to all database operations
/// This maintains backward compatibility while delegating to focused services
class HiveDatabaseService {
  static HiveDatabaseService? _instance;
  static HiveDatabaseService get instance => _instance ??= HiveDatabaseService._();
  
  HiveDatabaseService._();
  
  // Service instances
  final HiveCore _hiveCore = HiveCore.instance;
  final UserDataService _userDataService = UserDataService.instance;
  final DrinkTrackingService _drinkTrackingService = DrinkTrackingService.instance;
  final GoalManagementService _goalManagementService = GoalManagementService.instance;
  final InterventionService _interventionService = InterventionService.instance;
  final DrinkLimitsService _drinkLimitsService = DrinkLimitsService.instance;
  final AnalyticsService _analyticsService = AnalyticsService.instance;
  final SettingsService _settingsService = SettingsService.instance;
  
  /// Initialize the database service
  Future<void> initialize() async {
    await _hiveCore.initialize();
    await _migrateScheduleData();
  }
  
  /// Close the database service
  Future<void> close() async {
    await _hiveCore.close();
  }
  
  /// Clear all data
  Future<void> clearAllData() async {
    await _hiveCore.clearAllData();
  }
  
  // =============================================================================
  // USER DATA OPERATIONS (Delegate to UserDataService)
  // =============================================================================
  
  Future<void> saveUserData(Map<String, dynamic> userData) => 
      _userDataService.saveUserData(userData);
  
  Map<String, dynamic>? getUserData() => 
      _userDataService.getUserData();
  
  Future<void> updateUserData(Map<String, dynamic> updates) => 
      _userDataService.updateUserData(updates);
  
  bool isOnboardingCompleted() => 
      _userDataService.isOnboardingCompleted();
  
  Future<void> completeOnboarding(Map<String, dynamic> userData) => 
      _userDataService.completeOnboarding(userData);
  
  DateTime? getAccountCreatedDate() => 
      _userDataService.getAccountCreatedDate();
  
  bool isDateBeforeAccountCreation(DateTime date) => 
      _userDataService.isDateBeforeAccountCreation(date);
  
  String getFormattedAccountCreationDate() => 
      _userDataService.getFormattedAccountCreationDate();
  
  // =============================================================================
  // DRINK TRACKING OPERATIONS (Delegate to DrinkTrackingService)
  // =============================================================================
  
  Future<String> createDrinkEntry({
    required DateTime drinkDate,
    required String drinkName,
    required double standardDrinks,
    required String drinkType,
    String? timeOfDay,
    String? reason,
    String? notes,
    String? location,
    String? socialContext,
    int? moodBefore,
    List<String>? triggers,
    String? triggerDescription,
    String? intention,
    int? urgeIntensity,
    bool? consideredAlternatives,
    String? alternatives,
    int? energyLevel,
    int? hungerLevel,
    int? stressLevel,
    String? sleepQuality,
    Map<String, dynamic>? interventionData,
  }) => _drinkTrackingService.createDrinkEntry(
    drinkDate: drinkDate,
    drinkName: drinkName,
    standardDrinks: standardDrinks,
    drinkType: drinkType,
    timeOfDay: timeOfDay,
    reason: reason,
    notes: notes,
    location: location,
    socialContext: socialContext,
    moodBefore: moodBefore,
    triggers: triggers,
    triggerDescription: triggerDescription,
    intention: intention,
    urgeIntensity: urgeIntensity,
    consideredAlternatives: consideredAlternatives,
    alternatives: alternatives,
    energyLevel: energyLevel,
    hungerLevel: hungerLevel,
    stressLevel: stressLevel,
    sleepQuality: sleepQuality,
    interventionData: interventionData,
  );
  
  List<Map<String, dynamic>> getAllDrinkEntries() => 
      _drinkTrackingService.getAllDrinkEntries();
  
  List<Map<String, dynamic>> getDrinkEntriesForDate(DateTime date) => 
      _drinkTrackingService.getDrinkEntriesForDate(date);
  
  double getTotalDrinksForDate(DateTime date) => 
      _drinkTrackingService.getTotalDrinksForDate(date);
  
  Future<void> deleteDrinkEntry(String entryId) => 
      _drinkTrackingService.deleteDrinkEntry(entryId);
  
  Future<void> logDrink({
    required String drinkName,
    required double standardDrinks,
    required DateTime timestamp,
    String? notes,
  }) => _drinkTrackingService.logDrink(
    drinkName: drinkName,
    standardDrinks: standardDrinks,
    timestamp: timestamp,
    notes: notes,
  );
  
  Future<List<Map<String, dynamic>>> getDrinkLogsForDate(DateTime date) => 
      _drinkTrackingService.getDrinkLogsForDate(date);
  
  // =============================================================================
  // SCHEDULE & LIMITS OPERATIONS (Delegate to DrinkLimitsService)
  // =============================================================================
  
  bool isDrinkingDay({DateTime? date}) => 
      _drinkLimitsService.isDrinkingDay(date: date);
  
  bool canAddDrinkToday({DateTime? date}) => 
      _drinkLimitsService.canAddDrinkToday(date: date);
  
  int getRemainingDrinksToday({DateTime? date}) => 
      _drinkLimitsService.getRemainingDrinksToday(date: date);
  
  Map<String, dynamic> getLimitStatus({DateTime? date}) => 
      _drinkLimitsService.getLimitStatus(date: date);
  
  // =============================================================================
  // ANALYTICS OPERATIONS (Delegate to AnalyticsService)
  // =============================================================================
  
  Map<String, dynamic> getDashboardStats() => 
      _analyticsService.getDashboardStats();
  
  Map<String, dynamic> getAnalytics({DateTime? startDate, DateTime? endDate}) => 
      _analyticsService.getAnalytics(startDate: startDate, endDate: endDate);
  
  Map<String, dynamic> getWeeklyTrends({int numberOfWeeks = 4}) => 
      _analyticsService.getWeeklyTrends(numberOfWeeks: numberOfWeeks);
  
  // =============================================================================
  // SETTINGS OPERATIONS (Delegate to SettingsService)
  // =============================================================================
  
  Future<void> setSetting(String key, dynamic value) => 
      _settingsService.setSetting(key, value);
  
  T? getSetting<T>(String key, [T? defaultValue]) => 
      _settingsService.getSetting<T>(key, defaultValue);
  
  Future<void> removeSetting(String key) => 
      _settingsService.removeSetting(key);
  
  Future<void> saveFavoriteDrinks(List<String> drinks) => 
      _settingsService.saveFavoriteDrinks(drinks);
  
  List<String> getFavoriteDrinks() => 
      _settingsService.getFavoriteDrinks();
  
  // =============================================================================
  // GOAL OPERATIONS (Delegate to GoalManagementService)
  // =============================================================================
  
  // Legacy goal operations for backward compatibility
  Future<void> saveGoals(Map<String, dynamic> goals) => 
      _goalManagementService.saveGoals(goals);
  
  Map<String, dynamic>? getGoals() => 
      _goalManagementService.getGoals();
  
  Future<void> updateGoals(Map<String, dynamic> updates) => 
      _goalManagementService.updateGoals(updates);
  
  // New goal management operations
  Future<String> createGoal({
    required String title,
    required String description,
    required goalType,
    required Map<String, dynamic> parameters,
    required associatedChart,
    int priorityLevel = 1,
  }) => _goalManagementService.createGoal(
    title: title,
    description: description,
    goalType: goalType,
    parameters: parameters,
    associatedChart: associatedChart,
    priorityLevel: priorityLevel,
  );
  
  List<Map<String, dynamic>> getAllGoals({status}) => 
      _goalManagementService.getAllGoals(status: status);
  
  List<Map<String, dynamic>> getActiveGoals() => 
      _goalManagementService.getActiveGoals();
  
  Map<String, dynamic>? getGoal(String goalId) => 
      _goalManagementService.getGoal(goalId);
  
  Future<void> updateGoalProgress(String goalId, double progress, double currentValue) => 
      _goalManagementService.updateGoalProgress(goalId, progress, currentValue);
  
  Future<void> updateGoalStatus(String goalId, status) => 
      _goalManagementService.updateGoalStatus(goalId, status);
  
  Future<void> updateGoalMilestones(String goalId, List<Map<String, dynamic>> milestones) => 
      _goalManagementService.updateGoalMilestones(goalId, milestones);
  
  Future<void> deleteGoal(String goalId) => 
      _goalManagementService.deleteGoal(goalId);
  
  List<Map<String, dynamic>> getGoalsByType(goalType) => 
      _goalManagementService.getGoalsByType(goalType);
  
  bool hasActiveGoals() => 
      _goalManagementService.hasActiveGoals();
  
  // =============================================================================
  // INTERVENTION OPERATIONS (Delegate to InterventionService)
  // =============================================================================
  
  Future<String> recordInterventionEvent({
    required interventionType,
    required decision,
    String? drinkEntryId,
    Map<String, dynamic>? context,
  }) => _interventionService.recordInterventionEvent(
    interventionType: interventionType,
    decision: decision,
    drinkEntryId: drinkEntryId,
    context: context,
  );
  
  List<Map<String, dynamic>> getInterventionEvents({
    type,
    decision,
    DateTime? startDate,
    DateTime? endDate,
  }) => _interventionService.getInterventionEvents(
    type: type,
    decision: decision,
    startDate: startDate,
    endDate: endDate,
  );
  
  Map<String, dynamic> getInterventionStats({
    type,
    DateTime? startDate,
    DateTime? endDate,
  }) => _interventionService.getInterventionStats(
    type: type,
    startDate: startDate,
    endDate: endDate,
  );
  
  List<Map<String, dynamic>> getRecentInterventionEvents({int limit = 10}) => 
      _interventionService.getRecentInterventionEvents(limit: limit);
  
  // =============================================================================
  // DATA MIGRATION
  // =============================================================================
  
  /// Migrate existing schedule data to include weekly patterns
  Future<void> _migrateScheduleData() async {
    final userData = getUserData();
    if (userData == null) return;
    
    final schedule = userData['schedule'] as String?;
    if (schedule == null) return;
    
    // Check if weeklyPattern already exists
    if (userData.containsKey('weeklyPattern')) return;
    
    // Add weekly pattern for strict schedules that don't have it
    final scheduleType = OnboardingConstants.scheduleTypeMap[schedule];
    if (scheduleType == OnboardingConstants.scheduleTypeStrict) {
      final pattern = ScheduleService.getPatternForSchedule(schedule);
      if (pattern != null) {
        await updateUserData({'weeklyPattern': pattern});
        developer.log('Migrated schedule $schedule to weekly pattern: $pattern', name: 'HiveDatabaseService');
      }
    }
  }
}
