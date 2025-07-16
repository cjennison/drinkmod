import 'dart:developer' as developer;
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/onboarding_constants.dart';
import '../models/user_goal.dart';
import '../models/intervention_event.dart';
import 'schedule_service.dart';

/// Central Hive-based storage service for all app data
class HiveDatabaseService {
  static HiveDatabaseService? _instance;
  static HiveDatabaseService get instance => _instance ??= HiveDatabaseService._();
  
  HiveDatabaseService._();
  
  // Box names
  static const String _userDataBoxName = 'user_data';
  static const String _drinkEntriesBoxName = 'drink_entries';
  static const String _favoriteDrinksBoxName = 'favorite_drinks';
  static const String _appSettingsBoxName = 'app_settings';
  static const String _goalsBoxName = 'user_goals';
  static const String _interventionEventsBoxName = 'intervention_events';
  
  // Hive boxes
  late Box<Map> _userBox;
  late Box<Map> _drinkEntriesBox;
  late Box<Map> _favoriteDrinksBox;
  late Box<Map> _settingsBox;
  late Box<Map> _goalsBox;
  late Box<Map> _interventionEventsBox;
  
  bool _isInitialized = false;
  
  /// Initialize Hive and open all boxes
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      developer.log('Initializing HiveDatabaseService...', name: 'HiveDatabaseService');
      
      // Initialize Hive path (only for non-web platforms)
      if (!kIsWeb) {
        final appDocumentDir = await getApplicationDocumentsDirectory();
        Hive.init(appDocumentDir.path);
      }
      
      // Open all boxes
      _userBox = await Hive.openBox<Map>(_userDataBoxName);
      _drinkEntriesBox = await Hive.openBox<Map>(_drinkEntriesBoxName);
      _favoriteDrinksBox = await Hive.openBox<Map>(_favoriteDrinksBoxName);
      _settingsBox = await Hive.openBox<Map>(_appSettingsBoxName);
      _goalsBox = await Hive.openBox<Map>(_goalsBoxName);
      _interventionEventsBox = await Hive.openBox<Map>(_interventionEventsBoxName);
      
      _isInitialized = true;
      developer.log('HiveDatabaseService initialized successfully', name: 'HiveDatabaseService');
      
      // Run data migrations
      await _migrateScheduleData();
    } catch (e) {
      developer.log('Error initializing HiveDatabaseService: $e', name: 'HiveDatabaseService');
      rethrow;
    }
  }
  
  /// Close all Hive boxes
  Future<void> close() async {
    if (!_isInitialized) return;
    
    await _userBox.close();
    await _drinkEntriesBox.close();
    await _favoriteDrinksBox.close();
    await _settingsBox.close();
    await _goalsBox.close();
    await _interventionEventsBox.close();
    
    _isInitialized = false;
    developer.log('HiveDatabaseService closed', name: 'HiveDatabaseService');
  }
  
  /// Clear all data (for testing/reset purposes)
  Future<void> clearAllData() async {
    if (!_isInitialized) await initialize();
    
    await _userBox.clear();
    await _drinkEntriesBox.clear();
    await _favoriteDrinksBox.clear();
    await _settingsBox.clear();
    await _goalsBox.clear();
    await _interventionEventsBox.clear();
    
    developer.log('All Hive data cleared', name: 'HiveDatabaseService');
  }
  
  // =============================================================================
  // USER DATA OPERATIONS
  // =============================================================================
  
  /// Save user profile data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    if (!_isInitialized) await initialize();
    
    await _userBox.put('profile', userData);
    developer.log('User data saved: $userData', name: 'HiveDatabaseService');
  }
  
  /// Get user profile data
  Map<String, dynamic>? getUserData() {
    if (!_isInitialized) return null;
    
    final data = _userBox.get('profile');
    return data?.cast<String, dynamic>();
  }
  
  /// Update specific user data fields
  Future<void> updateUserData(Map<String, dynamic> updates) async {
    if (!_isInitialized) await initialize();
    
    final currentData = getUserData() ?? <String, dynamic>{};
    currentData.addAll(updates);
    
    await saveUserData(currentData);
    developer.log('User data updated: $updates', name: 'HiveDatabaseService');
  }
  
  /// Check if onboarding is completed
  bool isOnboardingCompleted() {
    final userData = getUserData();
    if (userData == null) return false;
    
    // Check for required fields
    final requiredFields = ['name', 'gender', 'schedule', 'drinkLimit', 'motivation'];
    
    for (final field in requiredFields) {
      if (!userData.containsKey(field) || 
          userData[field] == null || 
          (userData[field] is String && (userData[field] as String).isEmpty)) {
        return false;
      }
    }
    
    return userData['onboardingCompleted'] == true;
  }
  
  /// Mark onboarding as completed
  Future<void> completeOnboarding(Map<String, dynamic> userData) async {
    userData['onboardingCompleted'] = true;
    
    // Add account creation date if not already present (Remove after 7/16)
    if (!userData.containsKey('accountCreatedDate')) {
      userData['accountCreatedDate'] = DateTime.now().millisecondsSinceEpoch;
      developer.log('Account created date set: ${DateTime.now()}', name: 'HiveDatabaseService');
    }
    
    await saveUserData(userData);
    developer.log('Onboarding completed', name: 'HiveDatabaseService');
  }
  
  /// Get account creation date
  DateTime? getAccountCreatedDate() {
    final userData = getUserData();
    if (userData == null) return null;
    
    final timestamp = userData['accountCreatedDate'];
    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    
    // Fallback: if no creation date stored, assume account is new (today)
    return DateTime.now();
  }

  /// Check if a date is before account creation (prevents logging drinks in the past)
  bool isDateBeforeAccountCreation(DateTime date) {
    final accountCreatedDate = getAccountCreatedDate();
    if (accountCreatedDate == null) return false;
    
    // Compare only the date parts (ignore time)
    final checkDate = DateTime(date.year, date.month, date.day);
    final creationDate = DateTime(accountCreatedDate.year, accountCreatedDate.month, accountCreatedDate.day);
    
    return checkDate.isBefore(creationDate);
  }

  /// Get formatted account creation date for display
  String getFormattedAccountCreationDate() {
    final accountCreatedDate = getAccountCreatedDate();
    if (accountCreatedDate == null) return 'recently';
    
    // Format as "July 15, 2025"
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${months[accountCreatedDate.month - 1]} ${accountCreatedDate.day}, ${accountCreatedDate.year}';
  }

  // =============================================================================
  // DRINK ENTRIES OPERATIONS
  // =============================================================================
  
  /// Create a new drink entry with enhanced therapeutic data
  Future<String> createDrinkEntry({
    required DateTime drinkDate,
    required String drinkName,
    required double standardDrinks,
    required String drinkType,
    String? timeOfDay,
    String? reason,
    String? notes,
    // Enhanced therapeutic fields
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
  }) async {
    if (!_isInitialized) await initialize();
    
    final entryId = DateTime.now().millisecondsSinceEpoch.toString();
    final entry = {
      'id': entryId,
      'drinkDate': drinkDate.toIso8601String(),
      'drinkName': drinkName,
      'standardDrinks': standardDrinks,
      'drinkType': drinkType,
      'timeOfDay': timeOfDay,
      'reason': reason,
      'notes': notes,
      'createdAt': DateTime.now().toIso8601String(),
      // Enhanced therapeutic data
      'location': location,
      'socialContext': socialContext,
      'moodBefore': moodBefore,
      'triggers': triggers,
      'triggerDescription': triggerDescription,
      'intention': intention,
      'urgeIntensity': urgeIntensity,
      'consideredAlternatives': consideredAlternatives,
      'alternatives': alternatives,
      'energyLevel': energyLevel,
      'hungerLevel': hungerLevel,
      'stressLevel': stressLevel,
      'sleepQuality': sleepQuality,
      'interventionData': interventionData,
    };
    
    await _drinkEntriesBox.put(entryId, entry);
    developer.log('Drink entry created with enhanced data: $entry', name: 'HiveDatabaseService');
    
    return entryId;
  }
  
  /// Get all drink entries
  List<Map<String, dynamic>> getAllDrinkEntries() {
    if (!_isInitialized) return [];
    
    return _drinkEntriesBox.values
        .map((e) => e.cast<String, dynamic>())
        .toList();
  }
  
  /// Get drink entries for a specific date
  List<Map<String, dynamic>> getDrinkEntriesForDate(DateTime date) {
    final allEntries = getAllDrinkEntries();
    final targetDate = DateTime(date.year, date.month, date.day);
    
    return allEntries.where((entry) {
      final entryDate = DateTime.parse(entry['drinkDate']);
      final entryDateOnly = DateTime(entryDate.year, entryDate.month, entryDate.day);
      return entryDateOnly.isAtSameMomentAs(targetDate);
    }).toList();
  }
  
  /// Get total drinks for a specific date
  double getTotalDrinksForDate(DateTime date) {
    final entries = getDrinkEntriesForDate(date);
    return entries.fold<double>(0.0, (sum, entry) => sum + (entry['standardDrinks'] as double));
  }
  
  /// Delete a drink entry
  Future<void> deleteDrinkEntry(String entryId) async {
    if (!_isInitialized) await initialize();
    
    await _drinkEntriesBox.delete(entryId);
    developer.log('Drink entry deleted: $entryId', name: 'HiveDatabaseService');
  }
  
  /// Log a drink entry (simple interface)
  Future<void> logDrink({
    required String drinkName,
    required double standardDrinks,
    required DateTime timestamp,
    String? notes,
  }) async {
    await createDrinkEntry(
      drinkDate: timestamp,
      drinkName: drinkName,
      standardDrinks: standardDrinks,
      drinkType: 'other',
      notes: notes,
    );
  }

  /// Get drink logs for a specific date
  Future<List<Map<String, dynamic>>> getDrinkLogsForDate(DateTime date) async {
    if (!_isInitialized) await initialize();
    
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final allEntries = _drinkEntriesBox.values.toList();
    final entriesForDate = <Map<String, dynamic>>[];
    
    for (final entry in allEntries) {
      final entryData = Map<String, dynamic>.from(entry);
      final drinkDateStr = entryData['drinkDate'] as String?;
      if (drinkDateStr != null) {
        final drinkDate = DateTime.parse(drinkDateStr);
        if (drinkDate.isAfter(startOfDay.subtract(const Duration(milliseconds: 1))) && 
            drinkDate.isBefore(endOfDay)) {
          entriesForDate.add(entryData);
        }
      }
    }
    
    return entriesForDate;
  }

  // =============================================================================
  // SCHEDULE CHECKING OPERATIONS
  // =============================================================================
  
  /// Check if today is a drinking day based on user's schedule
  bool isDrinkingDay({DateTime? date}) {
    final checkDate = date ?? DateTime.now();
    final userData = getUserData();
    if (userData == null) {
      developer.log('No user data found, defaulting to allow drinking', name: 'HiveDatabaseService');
      return true; // Default to allow if no data
    }
    
    return ScheduleService.isDrinkingDay(userData, date: checkDate);
  }
  
  /// Check if user can add another drink today (handles both strict and open schedules)
  bool canAddDrinkToday({DateTime? date}) {
    final checkDate = date ?? DateTime.now();
    final userData = getUserData();
    if (userData == null) return true;
    
    final schedule = userData['schedule'] as String?;
    if (schedule == null) return true;
    
    final scheduleType = OnboardingConstants.scheduleTypeMap[schedule];
    
    switch (scheduleType) {
      case OnboardingConstants.scheduleTypeStrict:
        return _canAddDrinkStrictSchedule(checkDate, userData, schedule);
      case OnboardingConstants.scheduleTypeOpen:
        return _canAddDrinkOpenSchedule(checkDate, userData, schedule);
      default:
        return true;
    }
  }
  
  /// Get remaining drinks allowed for today
  int getRemainingDrinksToday({DateTime? date}) {
    final checkDate = date ?? DateTime.now();
    final userData = getUserData();
    if (userData == null) return 2;
    
    final schedule = userData['schedule'] as String?;
    if (schedule == null) return 2;
    
    final scheduleType = OnboardingConstants.scheduleTypeMap[schedule];
    
    switch (scheduleType) {
      case OnboardingConstants.scheduleTypeStrict:
        return _getRemainingDrinksStrictSchedule(checkDate, userData);
      case OnboardingConstants.scheduleTypeOpen:
        return _getRemainingDrinksOpenSchedule(checkDate, userData, schedule);
      default:
        return 2;
    }
  }

  // =============================================================================
  // STRICT SCHEDULE LOGIC
  // =============================================================================
  /// Check if user can add drink for strict schedule
  bool _canAddDrinkStrictSchedule(DateTime date, Map<String, dynamic> userData, String schedule) {
    // First check if today is a drinking day
    if (!ScheduleService.isDrinkingDay(userData, date: date)) {
      return false;
    }
    
    final dailyLimit = userData['drinkLimit'] as int? ?? 2;
    final todaysDrinks = getTotalDrinksForDate(date);
    
    return todaysDrinks < dailyLimit;
  }
  
  /// Get remaining drinks for strict schedule
  int _getRemainingDrinksStrictSchedule(DateTime date, Map<String, dynamic> userData) {
    if (!ScheduleService.isDrinkingDay(userData, date: date)) {
      return 0;
    }
    
    final dailyLimit = userData['drinkLimit'] as int? ?? 2;
    final todaysDrinks = getTotalDrinksForDate(date);
    
    return (dailyLimit - todaysDrinks.round()).clamp(0, dailyLimit);
  }

  // =============================================================================
  // OPEN SCHEDULE LOGIC
  // =============================================================================
  
  /// Check if user can add drink for open schedule (weekly + daily limits)
  bool _canAddDrinkOpenSchedule(DateTime date, Map<String, dynamic> userData, String schedule) {
    // Check daily limit first
    final todaysDrinks = getTotalDrinksForDate(date);
    if (todaysDrinks >= OnboardingConstants.maxDrinksPerDayOpen) {
      developer.log('Open schedule: Daily limit reached ($todaysDrinks >= ${OnboardingConstants.maxDrinksPerDayOpen})', name: 'HiveDatabaseService');
      return false;
    }
    
    // Check weekly limit
    final weeklyLimit = userData['weeklyLimit'] as int? ?? OnboardingConstants.defaultWeeklyLimits[schedule] ?? 4;
    final weeklyDrinks = _getWeeklyDrinks(date);
    
    if (weeklyDrinks >= weeklyLimit) {
      developer.log('Open schedule: Weekly limit reached ($weeklyDrinks >= $weeklyLimit)', name: 'HiveDatabaseService');
      return false;
    }
    
    developer.log('Open schedule: Can add drink (daily: $todaysDrinks/${OnboardingConstants.maxDrinksPerDayOpen}, weekly: $weeklyDrinks/$weeklyLimit)', name: 'HiveDatabaseService');
    return true;
  }
  
  /// Get remaining drinks for open schedule (limited by both daily and weekly)
  int _getRemainingDrinksOpenSchedule(DateTime date, Map<String, dynamic> userData, String schedule) {
    // Calculate remaining based on daily limit
    final todaysDrinks = getTotalDrinksForDate(date);
    final remainingDaily = (OnboardingConstants.maxDrinksPerDayOpen - todaysDrinks.round()).clamp(0, OnboardingConstants.maxDrinksPerDayOpen);
    
    // Calculate remaining based on weekly limit
    final weeklyLimit = userData['weeklyLimit'] as int? ?? OnboardingConstants.defaultWeeklyLimits[schedule] ?? 4;
    final weeklyDrinks = _getWeeklyDrinks(date);
    final remainingWeekly = (weeklyLimit - weeklyDrinks.round()).clamp(0, weeklyLimit);
    
    // Return the more restrictive limit
    final remaining = [remainingDaily, remainingWeekly].reduce((a, b) => a < b ? a : b);
    developer.log('Open schedule remaining: daily=$remainingDaily, weekly=$remainingWeekly, final=$remaining', name: 'HiveDatabaseService');
    return remaining;
  }
  
  /// Get total drinks for the current week
  double _getWeeklyDrinks(DateTime date) {
    // Get Monday of the current week
    final monday = date.subtract(Duration(days: date.weekday - 1));
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    
    final allEntries = getAllDrinkEntries();
    double weeklyTotal = 0.0;
    
    for (final entry in allEntries) {
      final drinkDate = DateTime.parse(entry['drinkDate']);
      if (drinkDate.isAfter(startOfWeek.subtract(const Duration(milliseconds: 1))) && 
          drinkDate.isBefore(endOfWeek)) {
        weeklyTotal += entry['standardDrinks'] as double;
      }
    }
    
    developer.log('Weekly drinks for week starting ${startOfWeek.toString().split(' ')[0]}: $weeklyTotal', name: 'HiveDatabaseService');
    return weeklyTotal;
  }
  
  // =============================================================================
  // FAVORITE DRINKS OPERATIONS
  // =============================================================================
  
  /// Save favorite drinks list
  Future<void> saveFavoriteDrinks(List<String> drinks) async {
    if (!_isInitialized) await initialize();
    
    final favoriteDrinksData = {
      'drinks': drinks,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    
    await _favoriteDrinksBox.put('favorites', favoriteDrinksData);
    developer.log('Favorite drinks saved: $drinks', name: 'HiveDatabaseService');
  }
  
  /// Get favorite drinks list
  List<String> getFavoriteDrinks() {
    if (!_isInitialized) return [];
    
    final data = _favoriteDrinksBox.get('favorites');
    if (data == null) return [];
    
    final drinks = data['drinks'];
    return drinks is List ? drinks.cast<String>() : [];
  }
  
  // =============================================================================
  // APP SETTINGS OPERATIONS
  // =============================================================================
  
  /// Set a setting value
  Future<void> setSetting(String key, dynamic value) async {
    if (!_isInitialized) await initialize();
    
    await _settingsBox.put(key, {'value': value});
    developer.log('Setting saved: $key = $value', name: 'HiveDatabaseService');
  }
  
  /// Get a setting value
  T? getSetting<T>(String key, [T? defaultValue]) {
    if (!_isInitialized) return defaultValue;
    
    final data = _settingsBox.get(key);
    if (data == null) return defaultValue;
    
    return data['value'] as T? ?? defaultValue;
  }
  
  /// Remove a setting
  Future<void> removeSetting(String key) async {
    if (!_isInitialized) await initialize();
    
    await _settingsBox.delete(key);
    developer.log('Setting removed: $key', name: 'HiveDatabaseService');
  }
  
  // =============================================================================
  // GOALS OPERATIONS
  // =============================================================================
  
  /// Save user goals
  Future<void> saveGoals(Map<String, dynamic> goals) async {
    if (!_isInitialized) await initialize();
    
    await _goalsBox.put('goals', goals);
    developer.log('Goals saved: $goals', name: 'HiveDatabaseService');
  }
  
  /// Get user goals
  Map<String, dynamic>? getGoals() {
    if (!_isInitialized) return null;
    
    final data = _goalsBox.get('goals');
    return data?.cast<String, dynamic>();
  }
  
  /// Update specific goal fields
  Future<void> updateGoals(Map<String, dynamic> updates) async {
    if (!_isInitialized) await initialize();
    
    final currentGoals = getGoals() ?? <String, dynamic>{};
    currentGoals.addAll(updates);
    
    await saveGoals(currentGoals);
    developer.log('Goals updated: $updates', name: 'HiveDatabaseService');
  }
  
  // =====================
  // GOAL MANAGEMENT METHODS
  // =====================

  /// Create a new goal
  Future<String> createGoal({
    required String title,
    required String description,
    required GoalType goalType,
    required Map<String, dynamic> parameters,
    required ChartType associatedChart,
    int priorityLevel = 1,
  }) async {
    final goalId = 'goal_${DateTime.now().millisecondsSinceEpoch}';
    
    final goal = {
      'id': goalId,
      'title': title,
      'description': description,
      'goalType': goalType.toString(),
      'status': GoalStatus.active.toString(),
      'startDate': DateTime.now().toIso8601String(),
      'endDate': null,
      'parameters': parameters,
      'associatedChart': associatedChart.toString(),
      'priorityLevel': priorityLevel,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'metrics': {
        'currentProgress': 0.0,
        'targetValue': parameters['targetValue'] ?? 0.0,
        'currentValue': 0.0,
        'lastUpdated': DateTime.now().toIso8601String(),
        'milestones': [],
        'metadata': <String, dynamic>{},
      },
    };
    
    await _goalsBox.put(goalId, goal);
    developer.log('Created goal: $goalId - $title', name: 'HiveDatabaseService');
    return goalId;
  }

  /// Get all goals with optional status filter
  List<Map<String, dynamic>> getAllGoals({GoalStatus? status}) {
    final goals = _goalsBox.values.map((goal) => Map<String, dynamic>.from(goal)).toList();
    
    if (status != null) {
      return goals.where((goal) => goal['status'] == status.toString()).toList();
    }
    
    return goals;
  }

  /// Get active goals only
  List<Map<String, dynamic>> getActiveGoals() {
    return getAllGoals(status: GoalStatus.active);
  }

  /// Get a specific goal by ID
  Map<String, dynamic>? getGoal(String goalId) {
    final goal = _goalsBox.get(goalId);
    return goal != null ? Map<String, dynamic>.from(goal) : null;
  }

  /// Update goal progress
  Future<void> updateGoalProgress(String goalId, double progress, double currentValue) async {
    final goal = _goalsBox.get(goalId);
    if (goal == null) return;
    
    final metrics = Map<String, dynamic>.from(goal['metrics']);
    metrics['currentProgress'] = progress.clamp(0.0, 1.0);
    metrics['currentValue'] = currentValue;
    metrics['lastUpdated'] = DateTime.now().toIso8601String();
    
    goal['metrics'] = metrics;
    goal['updatedAt'] = DateTime.now().toIso8601String();
    
    await _goalsBox.put(goalId, goal);
    developer.log('Updated goal progress: $goalId - ${progress * 100}%', name: 'HiveDatabaseService');
  }

  /// Update goal status
  Future<void> updateGoalStatus(String goalId, GoalStatus status) async {
    final goal = _goalsBox.get(goalId);
    if (goal == null) return;
    
    goal['status'] = status.toString();
    goal['updatedAt'] = DateTime.now().toIso8601String();
    
    if (status == GoalStatus.completed || status == GoalStatus.discontinued) {
      goal['endDate'] = DateTime.now().toIso8601String();
    }
    
    await _goalsBox.put(goalId, goal);
    developer.log('Updated goal status: $goalId - $status', name: 'HiveDatabaseService');
  }

  /// Update goal milestones
  Future<void> updateGoalMilestones(String goalId, List<Map<String, dynamic>> milestones) async {
    final goal = _goalsBox.get(goalId);
    if (goal == null) return;
    
    final metrics = Map<String, dynamic>.from(goal['metrics']);
    metrics['milestones'] = milestones;
    metrics['lastUpdated'] = DateTime.now().toIso8601String();
    
    goal['metrics'] = metrics;
    goal['updatedAt'] = DateTime.now().toIso8601String();
    
    await _goalsBox.put(goalId, goal);
    developer.log('Updated goal milestones: $goalId', name: 'HiveDatabaseService');
  }

  /// Delete a goal
  Future<void> deleteGoal(String goalId) async {
    await _goalsBox.delete(goalId);
    developer.log('Deleted goal: $goalId', name: 'HiveDatabaseService');
  }

  /// Get goals by type
  List<Map<String, dynamic>> getGoalsByType(GoalType goalType) {
    return _goalsBox.values
        .where((goal) => goal['goalType'] == goalType.toString())
        .map((goal) => Map<String, dynamic>.from(goal))
        .toList();
  }

  /// Check if user has any active goals
  bool hasActiveGoals() {
    return getActiveGoals().isNotEmpty;
  }

  // =====================
  // INTERVENTION EVENT METHODS
  // =====================

  /// Record an intervention event
  Future<String> recordInterventionEvent({
    required InterventionType interventionType,
    required InterventionDecision decision,
    String? drinkEntryId,
    Map<String, dynamic>? context,
  }) async {
    final eventId = 'intervention_${DateTime.now().millisecondsSinceEpoch}';
    
    final event = {
      'id': eventId,
      'interventionType': interventionType.toString(),
      'decision': decision.toString(),
      'timestamp': DateTime.now().toIso8601String(),
      'drinkEntryId': drinkEntryId,
      'context': context ?? <String, dynamic>{},
    };
    
    await _interventionEventsBox.put(eventId, event);
    developer.log('Recorded intervention event: $eventId - $decision', name: 'HiveDatabaseService');
    return eventId;
  }

  /// Get intervention events with optional filters
  List<Map<String, dynamic>> getInterventionEvents({
    InterventionType? type,
    InterventionDecision? decision,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    var events = _interventionEventsBox.values.map((event) => Map<String, dynamic>.from(event)).toList();
    
    if (type != null) {
      events = events.where((event) => event['interventionType'] == type.toString()).toList();
    }
    
    if (decision != null) {
      events = events.where((event) => event['decision'] == decision.toString()).toList();
    }
    
    if (startDate != null || endDate != null) {
      events = events.where((event) {
        final timestamp = DateTime.parse(event['timestamp']);
        if (startDate != null && timestamp.isBefore(startDate)) return false;
        if (endDate != null && timestamp.isAfter(endDate)) return false;
        return true;
      }).toList();
    }
    
    // Sort by timestamp descending
    events.sort((a, b) => DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])));
    
    return events;
  }

  /// Get intervention success rate
  Map<String, dynamic> getInterventionStats({
    InterventionType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final events = getInterventionEvents(
      type: type,
      startDate: startDate,
      endDate: endDate,
    );
    
    if (events.isEmpty) {
      return {
        'totalEvents': 0,
        'successfulEvents': 0,
        'successRate': 0.0,
        'breakdownByType': <String, dynamic>{},
      };
    }
    
    final successfulEvents = events.where((event) => 
        event['decision'] == InterventionDecision.declined.toString()).length;
    
    final successRate = successfulEvents / events.length;
    
    // Breakdown by intervention type
    final breakdownByType = <String, dynamic>{};
    for (final type in InterventionType.values) {
      final typeEvents = events.where((event) => 
          event['interventionType'] == type.toString()).toList();
      final typeSuccesses = typeEvents.where((event) => 
          event['decision'] == InterventionDecision.declined.toString()).length;
      
      breakdownByType[type.toString()] = {
        'total': typeEvents.length,
        'successful': typeSuccesses,
        'successRate': typeEvents.isNotEmpty ? typeSuccesses / typeEvents.length : 0.0,
      };
    }
    
    return {
      'totalEvents': events.length,
      'successfulEvents': successfulEvents,
      'successRate': successRate,
      'breakdownByType': breakdownByType,
    };
  }

  /// Get recent intervention events
  List<Map<String, dynamic>> getRecentInterventionEvents({int limit = 10}) {
    final events = getInterventionEvents();
    return events.take(limit).toList();
  }

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

  // =============================================================================
  // DASHBOARD STATS OPERATIONS
  // =============================================================================
  
  /// Get dashboard statistics
  Map<String, dynamic> getDashboardStats() {
    if (!_isInitialized) return {'streak': 0};
    
    final userData = getUserData();
    if (userData == null) return {'streak': 0};
    
    // Calculate current streak (placeholder implementation)
    // TODO: Implement proper streak calculation based on user's schedule
    final allEntries = getAllDrinkEntries();
    if (allEntries.isEmpty) return {'streak': 0};
    
    // Simple streak calculation - days without drinks
    final now = DateTime.now();
    int streak = 0;
    
    for (int i = 0; i < 365; i++) { // Check up to a year
      final checkDate = now.subtract(Duration(days: i));
      final dailyDrinks = getTotalDrinksForDate(checkDate);
      
      if (dailyDrinks > 0) {
        break; // Streak broken
      }
      streak++;
    }
    
    return {
      'streak': streak,
      'totalDays': allEntries.length,
      'averageDrinksPerDay': _calculateAverageDrinksPerDay(),
    };
  }
  
  /// Calculate average drinks per day
  double _calculateAverageDrinksPerDay() {
    final allEntries = getAllDrinkEntries();
    if (allEntries.isEmpty) return 0.0;
    
    final totalDrinks = allEntries.fold<double>(0.0, (sum, entry) => sum + (entry['standardDrinks'] as double));
    
    // Get unique days with entries
    final uniqueDays = <String>{};
    for (final entry in allEntries) {
      final date = DateTime.parse(entry['drinkDate']);
      final dateKey = '${date.year}-${date.month}-${date.day}';
      uniqueDays.add(dateKey);
    }
    
    return uniqueDays.isNotEmpty ? totalDrinks / uniqueDays.length : 0.0;
  }
}
