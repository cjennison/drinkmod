import 'dart:developer' as developer;
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

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
  
  // Hive boxes
  late Box<Map> _userBox;
  late Box<Map> _drinkEntriesBox;
  late Box<Map> _favoriteDrinksBox;
  late Box<Map> _settingsBox;
  
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
      
      _isInitialized = true;
      developer.log('HiveDatabaseService initialized successfully', name: 'HiveDatabaseService');
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
    final requiredFields = ['name', 'gender', 'scheduleType', 'drinkLimit', 'motivation'];
    
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
    await saveUserData(userData);
    developer.log('Onboarding completed', name: 'HiveDatabaseService');
  }
  
  // =============================================================================
  // DRINK ENTRIES OPERATIONS
  // =============================================================================
  
  /// Create a new drink entry
  Future<String> createDrinkEntry({
    required DateTime drinkDate,
    required String drinkName,
    required double standardDrinks,
    required String drinkType,
    String? reason,
    String? notes,
  }) async {
    if (!_isInitialized) await initialize();
    
    final entryId = DateTime.now().millisecondsSinceEpoch.toString();
    final entry = {
      'id': entryId,
      'drinkDate': drinkDate.toIso8601String(),
      'drinkName': drinkName,
      'standardDrinks': standardDrinks,
      'drinkType': drinkType,
      'reason': reason,
      'notes': notes,
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    await _drinkEntriesBox.put(entryId, entry);
    developer.log('Drink entry created: $entry', name: 'HiveDatabaseService');
    
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
  // DASHBOARD & ANALYTICS
  // =============================================================================
  
  /// Get dashboard statistics
  Map<String, dynamic> getDashboardStats() {
    final userData = getUserData();
    if (userData == null) {
      return {
        'todaysDrinks': 0.0,
        'dailyLimit': 0,
        'streak': 0,
        'weeklyAdherence': 0.0,
        'isAllowedDay': false,
        'remainingDrinks': 0,
      };
    }
    
    final today = DateTime.now();
    final todaysDrinks = getTotalDrinksForDate(today);
    final dailyLimit = userData['drinkLimit'] ?? 0;
    final scheduleType = userData['scheduleType'] ?? '';
    
    // Calculate streak
    final streak = _calculateStreak(dailyLimit);
    
    // Calculate weekly adherence
    final weeklyAdherence = _calculateWeeklyAdherence(dailyLimit);
    
    // Check if today is allowed drinking day
    final isAllowedDay = _isAllowedDrinkingDay(today, scheduleType);
    
    return {
      'todaysDrinks': todaysDrinks,
      'dailyLimit': dailyLimit,
      'streak': streak,
      'weeklyAdherence': weeklyAdherence,
      'isAllowedDay': isAllowedDay,
      'remainingDrinks': isAllowedDay ? (dailyLimit - todaysDrinks).clamp(0, dailyLimit) : 0,
    };
  }
  
  /// Calculate current streak
  int _calculateStreak(int dailyLimit) {
    final today = DateTime.now();
    int streak = 0;
    
    for (int i = 0; i < 365; i++) {
      final checkDate = today.subtract(Duration(days: i));
      final totalDrinks = getTotalDrinksForDate(checkDate);
      
      if (totalDrinks <= dailyLimit) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }
  
  /// Calculate weekly adherence percentage
  double _calculateWeeklyAdherence(int dailyLimit) {
    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    
    int adherentDays = 0;
    for (int i = 0; i < 7; i++) {
      final checkDate = weekStart.add(Duration(days: i));
      final totalDrinks = getTotalDrinksForDate(checkDate);
      
      if (totalDrinks <= dailyLimit) {
        adherentDays++;
      }
    }
    
    return adherentDays / 7.0;
  }
  
  /// Check if today is an allowed drinking day based on schedule
  bool _isAllowedDrinkingDay(DateTime date, String scheduleType) {
    switch (scheduleType) {
      case 'weekends_only':
        return date.weekday == DateTime.friday || 
               date.weekday == DateTime.saturday || 
               date.weekday == DateTime.sunday;
      case 'friday_only':
        return date.weekday == DateTime.friday;
      case 'social_occasions':
      case 'custom_weekly':
      case 'reduced_current':
      default:
        return true; // Allow all days for these schedule types
    }
  }
  
  // =============================================================================
  // DRINK LOGGING & LIMITS
  // =============================================================================
  
  /// Check if user can log a drink today
  Map<String, dynamic> checkDailyLimit() {
    final stats = getDashboardStats();
    final todaysDrinks = stats['todaysDrinks'] as double;
    final dailyLimit = stats['dailyLimit'] as int;
    final isAllowedDay = stats['isAllowedDay'] as bool;
    
    if (!isAllowedDay) {
      return {
        'canLog': false,
        'message': "Today isn't a planned drinking day. Would you like to adjust your schedule?",
        'status': 'not_allowed_day',
      };
    }
    
    if (todaysDrinks >= dailyLimit) {
      return {
        'canLog': false,
        'message': "You've reached your daily limit of $dailyLimit drinks. How are you feeling?",
        'status': 'limit_reached',
      };
    }
    
    final remaining = dailyLimit - todaysDrinks;
    return {
      'canLog': true,
      'message': "You have ${remaining.round()} drink${remaining != 1 ? 's' : ''} remaining today.",
      'status': 'within_limit',
      'remaining': remaining,
    };
  }
}
