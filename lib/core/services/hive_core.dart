import 'dart:developer' as developer;
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/smart_reminders/models/smart_reminder.dart';

/// Core Hive database initialization and management service
/// Handles only the initialization, connection, and cleanup of Hive boxes
class HiveCore {
  static HiveCore? _instance;
  static HiveCore get instance => _instance ??= HiveCore._();
  
  HiveCore._();
  
  // Box names - centralized for all services
  static const String userDataBoxName = 'user_data';
  static const String drinkEntriesBoxName = 'drink_entries';
  static const String favoriteDrinksBoxName = 'favorite_drinks';
  static const String appSettingsBoxName = 'app_settings';
  static const String goalsBoxName = 'user_goals';
  static const String interventionEventsBoxName = 'intervention_events';
  static const String achievementsBoxName = 'achievements';
  static const String appEventsBoxName = 'app_events';
  static const String smartRemindersBoxName = 'smart_reminders';
  
  // Hive boxes - accessible to other services
  late Box<Map> userBox;
  late Box<Map> drinkEntriesBox;
  late Box<Map> favoriteDrinksBox;
  late Box<Map> settingsBox;
  late Box<Map> goalsBox;
  late Box<Map> interventionEventsBox;
  late Box<Map> achievementsBox;
  late Box<Map> appEventsBox;
  late Box<SmartReminder> smartRemindersBox;
  
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  
  /// Initialize Hive and open all boxes
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      developer.log('Initializing HiveCore...', name: 'HiveCore');
      
      // Initialize Hive path (only for non-web platforms)
      if (!kIsWeb) {
        final appDocumentDir = await getApplicationDocumentsDirectory();
        Hive.init(appDocumentDir.path);
      }
      
      // Register adapters for Smart Reminders
      Hive.registerAdapter(TimeOfDayAdapter());
      Hive.registerAdapter(SmartReminderTypeAdapter());
      Hive.registerAdapter(SmartReminderAdapter());
      
      // Open all boxes
      userBox = await Hive.openBox<Map>(userDataBoxName);
      drinkEntriesBox = await Hive.openBox<Map>(drinkEntriesBoxName);
      favoriteDrinksBox = await Hive.openBox<Map>(favoriteDrinksBoxName);
      settingsBox = await Hive.openBox<Map>(appSettingsBoxName);
      goalsBox = await Hive.openBox<Map>(goalsBoxName);
      interventionEventsBox = await Hive.openBox<Map>(interventionEventsBoxName);
      achievementsBox = await Hive.openBox<Map>(achievementsBoxName);
      appEventsBox = await Hive.openBox<Map>(appEventsBoxName);
      smartRemindersBox = await Hive.openBox<SmartReminder>(smartRemindersBoxName);
      
      _isInitialized = true;
      developer.log('HiveCore initialized successfully', name: 'HiveCore');
    } catch (e) {
      developer.log('Error initializing HiveCore: $e', name: 'HiveCore');
      rethrow;
    }
  }
  
  /// Close all Hive boxes
  Future<void> close() async {
    if (!_isInitialized) return;
    
    await userBox.close();
    await drinkEntriesBox.close();
    await favoriteDrinksBox.close();
    await settingsBox.close();
    await goalsBox.close();
    await interventionEventsBox.close();
    await achievementsBox.close();
    await appEventsBox.close();
    await smartRemindersBox.close();
    
    _isInitialized = false;
    developer.log('HiveCore closed', name: 'HiveCore');
  }
  
  /// Clear all data (for testing/reset purposes)
  Future<void> clearAllData() async {
    if (!_isInitialized) await initialize();
    
    await userBox.clear();
    await drinkEntriesBox.clear();
    await favoriteDrinksBox.clear();
    await settingsBox.clear();
    await goalsBox.clear();
    await interventionEventsBox.clear();
    await achievementsBox.clear();
    await appEventsBox.clear();
    await smartRemindersBox.clear();
    
    developer.log('All Hive data cleared', name: 'HiveCore');
  }
  
  /// Ensure initialization before operations
  Future<void> ensureInitialized() async {
    if (!_isInitialized) await initialize();
  }
}
