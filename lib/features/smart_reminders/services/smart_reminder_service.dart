import 'dart:developer' as developer;
import 'package:hive/hive.dart';

import '../models/smart_reminder.dart';
import '../../../core/services/hive_core.dart';

/// Service for managing Smart Reminders data operations
class SmartReminderService {
  // Private constructor for singleton pattern
  SmartReminderService._();
  
  static final SmartReminderService _instance = SmartReminderService._();
  
  /// Get the singleton instance
  static SmartReminderService get instance => _instance;
  
  /// Get the smart reminders box from HiveCore
  Box<SmartReminder> get _box {
    if (!HiveCore.instance.isInitialized) {
      throw StateError('HiveCore must be initialized before accessing Smart Reminders');
    }
    return HiveCore.instance.smartRemindersBox;
  }
  
  /// Initialize the service
  Future<void> initialize() async {
    developer.log('SmartReminderService initialized', name: 'SmartReminderService');
  }
  
  /// Create a new smart reminder
  Future<void> createSmartReminder(SmartReminder reminder) async {
    try {
      await _box.add(reminder);
      developer.log('Smart reminder created: ${reminder.title}', name: 'SmartReminderService');
    } catch (e) {
      developer.log('Error creating smart reminder: $e', name: 'SmartReminderService', level: 900);
      rethrow;
    }
  }
  
  /// Get all smart reminders
  List<SmartReminder> getAllSmartReminders() {
    try {
      final reminders = _box.values.toList();
      developer.log('Retrieved ${reminders.length} reminders from database', name: 'SmartReminderService');
      return reminders;
    } catch (e) {
      developer.log('Error getting all smart reminders: $e', name: 'SmartReminderService', level: 900);
      return [];
    }
  }
  
  /// Get a specific smart reminder by ID
  SmartReminder? getSmartReminderById(String id) {
    try {
      return _box.values.firstWhere(
        (reminder) => reminder.id == id,
        orElse: () => throw StateError('No reminder found'),
      );
    } catch (e) {
      developer.log('Smart reminder not found with ID: $id', name: 'SmartReminderService');
      return null;
    }
  }
  
  /// Update an existing smart reminder
  Future<void> updateSmartReminder(SmartReminder reminder) async {
    try {
      // Find the key for this reminder using a more efficient approach
      dynamic targetKey;
      for (final key in _box.keys) {
        final existingReminder = _box.get(key);
        if (existingReminder?.id == reminder.id) {
          targetKey = key; // Keep the original key type
          break;
        }
      }
      
      if (targetKey != null) {
        await _box.put(targetKey, reminder);
        developer.log('Smart reminder updated: ${reminder.title}', name: 'SmartReminderService');
      } else {
        throw Exception('Reminder not found for update: ${reminder.id}');
      }
    } catch (e) {
      developer.log('Error updating smart reminder: $e', name: 'SmartReminderService', level: 900);
      rethrow;
    }
  }
  
  /// Delete a smart reminder by ID
  Future<void> deleteSmartReminder(String id) async {
    try {
      developer.log('Attempting to delete reminder with ID: $id', name: 'SmartReminderService');
      
      // Find and delete the reminder using the actual key
      dynamic targetKey;
      for (final key in _box.keys) {
        final existingReminder = _box.get(key);
        if (existingReminder?.id == id) {
          targetKey = key; // Keep the original key type
          developer.log('Found reminder to delete at key: $key', name: 'SmartReminderService');
          break;
        }
      }
      
      if (targetKey != null) {
        await _box.delete(targetKey);
        developer.log('Smart reminder deleted successfully: $id', name: 'SmartReminderService');
      } else {
        developer.log('Reminder not found for deletion: $id', name: 'SmartReminderService', level: 900);
        throw Exception('Reminder not found for deletion: $id');
      }
    } catch (e) {
      developer.log('Error deleting smart reminder: $e', name: 'SmartReminderService', level: 900);
      rethrow;
    }
  }
  
  /// Get reminders that should be active today
  List<SmartReminder> getTodaysReminders() {
    try {
      final today = DateTime.now().weekday;
      final reminders = <SmartReminder>[];
      
      // Iterate through box efficiently without creating intermediate lists
      for (final reminder in _box.values) {
        if (reminder.isActive && reminder.weekDays.contains(today)) {
          reminders.add(reminder);
        }
      }
      
      return reminders;
    } catch (e) {
      developer.log('Error getting today\'s reminders: $e', name: 'SmartReminderService', level: 900);
      return [];
    }
  }
  
  /// Toggle the active state of a reminder
  Future<bool> toggleReminderActive(String id) async {
    try {
      final reminder = getSmartReminderById(id);
      if (reminder != null) {
        reminder.isActive = !reminder.isActive;
        await updateSmartReminder(reminder);
        developer.log('Reminder ${reminder.title} toggled to ${reminder.isActive}', name: 'SmartReminderService');
        return true;
      }
      return false;
    } catch (e) {
      developer.log('Error toggling reminder active state: $e', name: 'SmartReminderService', level: 900);
      return false;
    }
  }
  
  /// Delete a reminder (alias for deleteSmartReminder for compatibility)
  Future<bool> deleteReminder(String id) async {
    try {
      await deleteSmartReminder(id);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Save a reminder (alias for createSmartReminder for compatibility)
  Future<bool> saveReminder(SmartReminder reminder) async {
    try {
      await createSmartReminder(reminder);
      return true;
    } catch (e) {
      return false;
    }
  }
}
