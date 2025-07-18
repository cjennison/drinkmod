import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/smart_reminder.dart';

/// Service for scheduling and managing local notifications for Smart Reminders
class NotificationSchedulingService {
  // Private constructor for singleton pattern
  NotificationSchedulingService._();
  
  static final NotificationSchedulingService _instance = NotificationSchedulingService._();
  
  /// Get the singleton instance
  static NotificationSchedulingService get instance => _instance;
  
  /// Local notifications plugin instance
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  /// Initialize the notification service
  Future<void> initialize() async {
    try {
      // Initialize timezone data
      tz.initializeTimeZones();
      
      // Set the local timezone based on device timezone
      try {
        final deviceTimeZone = DateTime.now().timeZoneName;
        final location = tz.getLocation(deviceTimeZone);
        tz.setLocalLocation(location);
      } catch (e) {
        // Fallback to UTC if device timezone can't be determined
        developer.log('Could not set device timezone, using UTC: $e', name: 'NotificationSchedulingService');
        tz.setLocalLocation(tz.UTC);
      }
      
      // Android initialization settings
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS initialization settings
      const iosInit = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );
      
      // Linux initialization settings
      const linuxInit = LinuxInitializationSettings(
        defaultActionName: 'Open notification',
      );
      
      // Combined initialization settings with desktop support
      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
        linux: linuxInit,
      );
      
      await _notificationsPlugin.initialize(initSettings);
      developer.log('NotificationSchedulingService initialized with timezone: ${tz.local.name}', name: 'NotificationSchedulingService');
    } catch (e) {
      developer.log('Error initializing notifications: $e', name: 'NotificationSchedulingService', level: 900);
      rethrow;
    }
  }
  
  /// Check if notification permissions are granted
  Future<bool> areNotificationsEnabled() async {
    try {
      final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidImplementation != null) {
        final granted = await androidImplementation.areNotificationsEnabled();
        return granted ?? false;
      }
      
      // For desktop platforms, notifications are typically available by default
      // For iOS, assume permissions are granted if we reach here
      return true;
    } catch (e) {
      developer.log('Error checking notification permissions: $e', name: 'NotificationSchedulingService', level: 900);
      return false;
    }
  }
  
  /// Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidImplementation != null) {
        final granted = await androidImplementation.requestNotificationsPermission();
        return granted ?? false;
      }
      
      return true;
    } catch (e) {
      developer.log('Error requesting notification permissions: $e', name: 'NotificationSchedulingService', level: 900);
      return false;
    }
  }
  
  /// Schedule a reminder notification
  Future<void> scheduleReminder(SmartReminder reminder) async {
    try {
      // Cancel existing notifications for this reminder first
      await cancelReminder(reminder.id);
      
      if (!reminder.isActive) {
        developer.log('Reminder ${reminder.title} is inactive, not scheduling', name: 'NotificationSchedulingService');
        return;
      }
      
      // Schedule for each enabled day of the week
      for (final weekDay in reminder.weekDays) {
        final notificationId = _getNotificationId(reminder.id, weekDay);
        
        // Calculate next occurrence of this weekday at the specified time
        final scheduledDate = _getNextWeekday(weekDay, reminder.timeOfDay);
        
        const androidDetails = AndroidNotificationDetails(
          'smart_reminders',
          'Smart Reminders',
          channelDescription: 'Notifications for your drinking goals and check-ins',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        );
        
        const iosDetails = DarwinNotificationDetails();
        
        // Linux notification details for desktop testing
        const linuxDetails = LinuxNotificationDetails();
        
        const notificationDetails = NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
          linux: linuxDetails,
        );
        
        await _notificationsPlugin.zonedSchedule(
          notificationId,
          reminder.title,
          reminder.message ?? _generateSmartMessage(reminder),
          tz.TZDateTime.from(scheduledDate, tz.local),
          notificationDetails,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
      
      developer.log('Scheduled notifications for reminder: ${reminder.title}', name: 'NotificationSchedulingService');
    } catch (e) {
      developer.log('Error scheduling reminder: $e', name: 'NotificationSchedulingService', level: 900);
      rethrow;
    }
  }
  
  /// Cancel notifications for a specific reminder
  Future<void> cancelReminder(String reminderId) async {
    try {
      // Cancel all weekday notifications for this reminder
      for (int weekDay = 1; weekDay <= 7; weekDay++) {
        final notificationId = _getNotificationId(reminderId, weekDay);
        await _notificationsPlugin.cancel(notificationId);
      }
      
      developer.log('Cancelled notifications for reminder: $reminderId', name: 'NotificationSchedulingService');
    } catch (e) {
      developer.log('Error cancelling reminder: $e', name: 'NotificationSchedulingService', level: 900);
    }
  }
  
  /// Reschedule all reminders (useful after app updates or permission changes)
  Future<void> rescheduleAllReminders() async {
    try {
      // This would typically get all reminders from the service and reschedule them
      // For now, just log that the method was called
      developer.log('Rescheduling all reminders', name: 'NotificationSchedulingService');
    } catch (e) {
      developer.log('Error rescheduling all reminders: $e', name: 'NotificationSchedulingService', level: 900);
    }
  }
  
  /// Show a test notification for a reminder
  Future<void> showTestNotification(SmartReminder reminder) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'smart_reminders_test',
        'Smart Reminders Test',
        channelDescription: 'Test notifications for Smart Reminders',
        importance: Importance.high,
        priority: Priority.high,
      );
      
      const iosDetails = DarwinNotificationDetails();
      
      // Linux notification details for desktop testing
      const linuxDetails = LinuxNotificationDetails();
      
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        linux: linuxDetails,
      );
      
      await _notificationsPlugin.show(
        99999, // Use a high ID for test notifications
        '${reminder.title} (Test)',
        reminder.message ?? _generateSmartMessage(reminder),
        notificationDetails,
      );
      
      developer.log('Showed test notification for: ${reminder.title}', name: 'NotificationSchedulingService');
    } catch (e) {
      developer.log('Error showing test notification: $e', name: 'NotificationSchedulingService', level: 900);
      rethrow;
    }
  }
  
  /// Show a simple test notification to verify the system works on any platform
  Future<void> showSimpleTestNotification() async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'test_channel',
        'Test Channel',
        channelDescription: 'Channel for testing notifications',
        importance: Importance.high,
        priority: Priority.high,
      );
      
      const iosDetails = DarwinNotificationDetails();
      const linuxDetails = LinuxNotificationDetails();
      
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        linux: linuxDetails,
      );
      
      await _notificationsPlugin.show(
        98888, // Fixed ID for simple test
        'Smart Reminders Test',
        'This is a test notification from Drinkmod. If you see this, notifications are working!',
        notificationDetails,
      );
      
      developer.log('Simple test notification shown', name: 'NotificationSchedulingService');
    } catch (e) {
      developer.log('Error showing simple test notification: $e', name: 'NotificationSchedulingService', level: 900);
      rethrow;
    }
  }
  
  /// Generate a unique notification ID for a reminder and weekday combination
  int _getNotificationId(String reminderId, int weekDay) {
    return (reminderId.hashCode + weekDay).abs() % 2147483647;
  }
  
  /// Get the next occurrence of a specific weekday at a specific time
  DateTime _getNextWeekday(int weekday, TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final today = now.weekday;
    
    // Calculate days until the target weekday
    int daysUntilTarget = (weekday - today) % 7;
    if (daysUntilTarget == 0) {
      // If it's today, check if the time has already passed
      final targetTime = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
      if (targetTime.isBefore(now)) {
        daysUntilTarget = 7; // Schedule for next week
      }
    }
    
    final targetDate = now.add(Duration(days: daysUntilTarget));
    return DateTime(targetDate.year, targetDate.month, targetDate.day, timeOfDay.hour, timeOfDay.minute);
  }
  
  /// Generate smart message content based on reminder type
  String _generateSmartMessage(SmartReminder reminder) {
    switch (reminder.type) {
      case SmartReminderType.friendlyCheckin:
        return 'How are you feeling today? Take a moment to check in with yourself.';
      case SmartReminderType.scheduleReminder:
        return 'Remember your drinking plan for today. Stay mindful of your goals.';
    }
  }
}
