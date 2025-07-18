import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/smart_reminder.dart';
import 'reminder_content_generator.dart';

/// Enhanced notification scheduling service with better error handling and content generation
class NotificationSchedulingService {
  // Private constructor for singleton pattern
  NotificationSchedulingService._();
  
  static final NotificationSchedulingService _instance = NotificationSchedulingService._();
  
  /// Get the singleton instance
  static NotificationSchedulingService get instance => _instance;
  
  /// Local notifications plugin instance
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  /// Cache for initialization status
  bool _isInitialized = false;
  bool _permissionsGranted = false;
  DateTime? _lastPermissionCheck;
  
  /// Notification channel configurations
  static const _reminderChannelId = 'smart_reminders';
  static const _testChannelId = 'smart_reminders_test';
  
  /// Initialize the notification service with enhanced error handling
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _initializeTimezone();
      await _initializeNotificationPlugin();
      await _checkAndCachePermissions();
      
      _isInitialized = true;
      developer.log('NotificationSchedulingService initialized successfully', 
          name: 'NotificationSchedulingService');
    } catch (e) {
      developer.log('Error initializing notifications: $e', 
          name: 'NotificationSchedulingService', level: 900);
      rethrow;
    }
  }
  
  /// Initialize timezone with multiple fallback strategies
  Future<void> _initializeTimezone() async {
    tz.initializeTimeZones();
    
    try {
      // Strategy 1: Try to get device timezone
      final deviceTimeZone = DateTime.now().timeZoneName;
      final location = tz.getLocation(deviceTimeZone);
      tz.setLocalLocation(location);
      developer.log('Set timezone to device timezone: $deviceTimeZone', 
          name: 'NotificationSchedulingService');
    } catch (e) {
      try {
        // Strategy 2: Try common timezone patterns
        final offset = DateTime.now().timeZoneOffset;
        final hourOffset = offset.inHours;
        
        String? fallbackTz;
        if (hourOffset == -8) fallbackTz = 'America/Los_Angeles';
        else if (hourOffset == -5) fallbackTz = 'America/New_York';
        else if (hourOffset == 0) fallbackTz = 'Europe/London';
        else if (hourOffset == 1) fallbackTz = 'Europe/Berlin';
        
        if (fallbackTz != null) {
          final location = tz.getLocation(fallbackTz);
          tz.setLocalLocation(location);
          developer.log('Set timezone to fallback: $fallbackTz', 
              name: 'NotificationSchedulingService');
        } else {
          throw Exception('No suitable timezone fallback found');
        }
      } catch (e2) {
        // Strategy 3: Final fallback to UTC
        tz.setLocalLocation(tz.UTC);
        developer.log('Using UTC timezone as final fallback', 
            name: 'NotificationSchedulingService');
      }
    }
  }
  
  /// Initialize notification plugin with comprehensive platform support
  Future<void> _initializeNotificationPlugin() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const iosInit = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      defaultPresentAlert: true,
      defaultPresentSound: true,
      defaultPresentBadge: true,
    );
    
    const linuxInit = LinuxInitializationSettings(
      defaultActionName: 'Open Drinkmod',
    );
    
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
      linux: linuxInit,
    );
    
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }
  
  /// Handle notification tap events
  void _onNotificationTapped(NotificationResponse response) {
    developer.log('Notification tapped: ${response.payload}', 
        name: 'NotificationSchedulingService');
    // TODO: Add navigation handling when app navigation is available
  }
  
  /// Check and cache notification permissions with expiry
  Future<void> _checkAndCachePermissions() async {
    final now = DateTime.now();
    
    // Check cache validity (refresh every 5 minutes)
    if (_lastPermissionCheck != null && 
        now.difference(_lastPermissionCheck!).inMinutes < 5) {
      return;
    }
    
    _permissionsGranted = await _checkPermissions();
    _lastPermissionCheck = now;
  }
  
  /// Internal permission checking
  Future<bool> _checkPermissions() async {
    try {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidImplementation != null) {
        final granted = await androidImplementation.areNotificationsEnabled();
        return granted ?? false;
      }
      
      return true; // Assume granted for other platforms
    } catch (e) {
      developer.log('Error checking permissions: $e', 
          name: 'NotificationSchedulingService', level: 900);
      return false;
    }
  }
  
  /// Check if notification permissions are granted (with caching)
  Future<bool> areNotificationsEnabled() async {
    await _checkAndCachePermissions();
    return _permissionsGranted;
  }
  
  /// Request notification permissions with better UX
  Future<bool> requestPermissions() async {
    try {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidImplementation != null) {
        final granted = await androidImplementation.requestNotificationsPermission();
        _permissionsGranted = granted ?? false;
        _lastPermissionCheck = DateTime.now();
        return _permissionsGranted;
      }
      
      _permissionsGranted = true;
      _lastPermissionCheck = DateTime.now();
      return true;
    } catch (e) {
      developer.log('Error requesting permissions: $e', 
          name: 'NotificationSchedulingService', level: 900);
      return false;
    }
  }
  
  /// Schedule a reminder notification with enhanced content generation
  Future<void> scheduleReminder(SmartReminder reminder) async {
    if (!_isInitialized) await initialize();
    
    try {
      // Cancel existing notifications first
      await cancelReminder(reminder.id);
      
      if (!reminder.isActive) {
        developer.log('Reminder ${reminder.title} is inactive, not scheduling', 
            name: 'NotificationSchedulingService');
        return;
      }
      
      // Check permissions before scheduling
      if (!await areNotificationsEnabled()) {
        throw Exception('Notifications not enabled');
      }
      
      // Schedule for each enabled day of the week
      final schedulingTasks = reminder.weekDays.map((weekDay) => 
          _scheduleForWeekday(reminder, weekDay));
      
      await Future.wait(schedulingTasks);
      
      developer.log('Scheduled notifications for reminder: ${reminder.title}', 
          name: 'NotificationSchedulingService');
    } catch (e) {
      developer.log('Error scheduling reminder: $e', 
          name: 'NotificationSchedulingService', level: 900);
      rethrow;
    }
  }
  
  /// Schedule notification for a specific weekday
  Future<void> _scheduleForWeekday(SmartReminder reminder, int weekDay) async {
    final notificationId = _getNotificationId(reminder.id, weekDay);
    final scheduledDate = _getNextWeekday(weekDay, reminder.timeOfDay);
    
    // Generate enhanced content using the dedicated service
    final content = await ReminderContentGenerator.generateContent(reminder);
    
    final androidDetails = AndroidNotificationDetails(
      _reminderChannelId,
      'Smart Reminders',
      channelDescription: 'Personalized reminders for your wellness journey',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      styleInformation: BigTextStyleInformation(
        content['body']!,
        contentTitle: content['title']!,
        summaryText: 'Drinkmod',
      ),
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const linuxDetails = LinuxNotificationDetails();
    
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      linux: linuxDetails,
    );
    
    await _notificationsPlugin.zonedSchedule(
      notificationId,
      content['title']!,
      content['body']!,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: reminder.id, // For handling taps
    );
  }
  
  /// Cancel notifications for a specific reminder with retry logic
  Future<void> cancelReminder(String reminderId) async {
    try {
      final cancellationTasks = List.generate(7, (index) => 
          _cancelNotificationWithRetry(_getNotificationId(reminderId, index + 1)));
      
      await Future.wait(cancellationTasks);
      
      developer.log('Cancelled notifications for reminder: $reminderId', 
          name: 'NotificationSchedulingService');
    } catch (e) {
      developer.log('Error cancelling reminder: $e', 
          name: 'NotificationSchedulingService', level: 900);
    }
  }
  
  /// Cancel a single notification with retry
  Future<void> _cancelNotificationWithRetry(int notificationId, [int retries = 2]) async {
    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        await _notificationsPlugin.cancel(notificationId);
        return;
      } catch (e) {
        if (attempt == retries) {
          developer.log('Failed to cancel notification $notificationId after $retries retries: $e',
              name: 'NotificationSchedulingService', level: 900);
        } else {
          await Future.delayed(Duration(milliseconds: 100 * (attempt + 1)));
        }
      }
    }
  }
  
  /// Show a test notification with enhanced content
  Future<void> showTestNotification(SmartReminder reminder) async {
    if (!_isInitialized) await initialize();
    
    try {
      if (!await areNotificationsEnabled()) {
        throw Exception('Notifications not enabled');
      }
      
      final content = await ReminderContentGenerator.generateContent(reminder);
      
      const androidDetails = AndroidNotificationDetails(
        _testChannelId,
        'Smart Reminders Test',
        channelDescription: 'Test notifications for Smart Reminders',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        styleInformation: BigTextStyleInformation(
          'This is a test notification. Tap to dismiss.',
        ),
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const linuxDetails = LinuxNotificationDetails();
      
      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        linux: linuxDetails,
      );
      
      await _notificationsPlugin.show(
        99999, // Fixed ID for test notifications
        '${content['title']!} (Test)',
        content['body']!,
        notificationDetails,
        payload: 'test_${reminder.id}',
      );
      
      developer.log('Showed test notification for: ${reminder.title}', 
          name: 'NotificationSchedulingService');
    } catch (e) {
      developer.log('Error showing test notification: $e', 
          name: 'NotificationSchedulingService', level: 900);
      rethrow;
    }
  }
  
  /// Get all pending notifications for debugging
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      developer.log('Error getting pending notifications: $e', 
          name: 'NotificationSchedulingService', level: 900);
      return [];
    }
  }
  
  /// Clear all notifications (for debugging/reset)
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      developer.log('Cancelled all notifications', 
          name: 'NotificationSchedulingService');
    } catch (e) {
      developer.log('Error cancelling all notifications: $e', 
          name: 'NotificationSchedulingService', level: 900);
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
      final targetTime = DateTime(now.year, now.month, now.day, 
          timeOfDay.hour, timeOfDay.minute);
      if (targetTime.isBefore(now.add(const Duration(minutes: 1)))) {
        daysUntilTarget = 7; // Schedule for next week
      }
    }
    
    final targetDate = now.add(Duration(days: daysUntilTarget));
    return DateTime(targetDate.year, targetDate.month, targetDate.day, 
        timeOfDay.hour, timeOfDay.minute);
  }
}
