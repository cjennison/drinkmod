import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'smart_reminder.g.dart';

/// Custom TimeOfDay adapter for Hive storage
class TimeOfDayAdapter extends TypeAdapter<TimeOfDay> {
  @override
  final int typeId = 8;

  @override
  TimeOfDay read(BinaryReader reader) {
    final hour = reader.readByte();
    final minute = reader.readByte();
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  void write(BinaryWriter writer, TimeOfDay obj) {
    writer.writeByte(obj.hour);
    writer.writeByte(obj.minute);
  }
}

/// Types of smart reminders available in the system
@HiveType(typeId: 7)
enum SmartReminderType {
  @HiveField(0)
  friendlyCheckin,
  @HiveField(1)
  scheduleReminder;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case SmartReminderType.friendlyCheckin:
        return 'Friendly Check-in';
      case SmartReminderType.scheduleReminder:
        return 'Schedule Reminder';
    }
  }

  /// Description for UI
  String get description {
    switch (this) {
      case SmartReminderType.friendlyCheckin:
        return 'Gentle nudges to check in with yourself and reflect on your goals';
      case SmartReminderType.scheduleReminder:
        return 'Reminders to help you stay aware of your daily drinking plan';
    }
  }

  /// Icon for UI
  IconData get icon {
    switch (this) {
      case SmartReminderType.friendlyCheckin:
        return Icons.favorite_outline;
      case SmartReminderType.scheduleReminder:
        return Icons.schedule;
    }
  }

  /// Color for UI
  Color get color {
    switch (this) {
      case SmartReminderType.friendlyCheckin:
        return Colors.purple;
      case SmartReminderType.scheduleReminder:
        return Colors.blue;
    }
  }

  /// Default title for this type
  String get defaultTitle {
    switch (this) {
      case SmartReminderType.friendlyCheckin:
        return 'Evening Check-in';
      case SmartReminderType.scheduleReminder:
        return 'Daily Drinking Plan';
    }
  }
}

/// Smart reminder configuration model
/// Stores all information needed to schedule and display reminders
@HiveType(typeId: 6) // Use next available typeId
class SmartReminder extends HiveObject {
  /// Unique identifier for the reminder
  @HiveField(0)
  String id;

  /// Type of reminder (friendly check-in or schedule reminder)
  @HiveField(1)
  SmartReminderType type;

  /// Title for the notification
  @HiveField(2)
  String title;

  /// Custom message (optional, null means use smart generated content)
  @HiveField(3)
  String? message;

  /// Time of day to send the notification
  @HiveField(4)
  TimeOfDay timeOfDay;

  /// Days of week to send notifications (1=Monday, 7=Sunday)
  @HiveField(5)
  List<int> weekDays;

  /// Whether this reminder is active
  @HiveField(6)
  bool isActive;

  /// When this reminder was created
  @HiveField(7)
  DateTime createdAt;

  /// Last time this reminder was triggered
  @HiveField(8)
  DateTime? lastTriggered;

  SmartReminder({
    required this.id,
    required this.type,
    required this.title,
    this.message,
    required this.timeOfDay,
    required this.weekDays,
    this.isActive = true,
    required this.createdAt,
    this.lastTriggered,
  });

  /// Create a new SmartReminder with generated ID
  factory SmartReminder.create({
    required SmartReminderType type,
    required String title,
    String? message,
    required TimeOfDay timeOfDay,
    required List<int> weekDays,
    bool isActive = true,
  }) {
    return SmartReminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      title: title,
      message: message,
      timeOfDay: timeOfDay,
      weekDays: weekDays,
      isActive: isActive,
      createdAt: DateTime.now(),
    );
  }

  /// Create a copy with modified fields
  SmartReminder copyWith({
    String? id,
    SmartReminderType? type,
    String? title,
    String? message,
    TimeOfDay? timeOfDay,
    List<int>? weekDays,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastTriggered,
  }) {
    return SmartReminder(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      weekDays: weekDays ?? this.weekDays,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastTriggered: lastTriggered ?? this.lastTriggered,
    );
  }

  /// Get the notification message to display
  String get notificationMessage {
    if (type == SmartReminderType.friendlyCheckin && message != null) {
      return message!;
    }
    return _getDefaultMessage();
  }

  String _getDefaultMessage() {
    switch (type) {
      case SmartReminderType.friendlyCheckin:
        return 'How are you feeling today? Take a moment for mindful reflection.';
      case SmartReminderType.scheduleReminder:
        return 'Check your drinking schedule for today';
    }
  }

  /// Get a summary of when this reminder is scheduled
  String get scheduleSummary {
    if (weekDays.isEmpty) return 'Never';
    
    final now = DateTime.now();
    final time = DateTime(now.year, now.month, now.day, 
        timeOfDay.hour, timeOfDay.minute);
    final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    
    if (weekDays.length == 7) {
      return 'Daily at $timeStr';
    } else if (weekDays.length == 5 && 
               weekDays.every((day) => day >= 1 && day <= 5)) {
      return 'Weekdays at $timeStr';
    } else if (weekDays.length == 2 && 
               weekDays.contains(0) && weekDays.contains(6)) {
      return 'Weekends at $timeStr';
    } else {
      final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      final days = weekDays.map((day) => dayNames[day]).join(', ');
      return '$days at $timeStr';
    }
  }

  /// Check if this reminder should trigger today
  bool shouldTriggerToday() {
    if (!isActive) return false;
    final today = DateTime.now().weekday % 7; // Convert to Sunday=0 format
    return weekDays.contains(today);
  }

  @override
  String toString() {
    return 'SmartReminder(id: $id, type: $type, title: $title, scheduleSummary: $scheduleSummary, isActive: $isActive)';
  }
}
