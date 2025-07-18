import 'package:flutter/material.dart';
import 'smart_reminder.dart';

/// Extension to provide UI-friendly properties for reminder types
extension SmartReminderTypeExtension on SmartReminderType {
  /// Display name for the reminder type
  String get displayName {
    switch (this) {
      case SmartReminderType.friendlyCheckin:
        return 'Friendly Check-in';
      case SmartReminderType.scheduleReminder:
        return 'Schedule Reminder';
    }
  }

  /// Description of what this reminder type does
  String get description {
    switch (this) {
      case SmartReminderType.friendlyCheckin:
        return 'A gentle nudge asking how you\'re feeling and if you need mindful time';
      case SmartReminderType.scheduleReminder:
        return 'Reminds you of your daily drinking schedule and remaining drinks';
    }
  }

  /// Icon to represent this reminder type
  IconData get icon {
    switch (this) {
      case SmartReminderType.friendlyCheckin:
        return Icons.favorite_outline;
      case SmartReminderType.scheduleReminder:
        return Icons.schedule;
    }
  }

  /// Color theme for this reminder type
  Color get color {
    switch (this) {
      case SmartReminderType.friendlyCheckin:
        return Colors.pink;
      case SmartReminderType.scheduleReminder:
        return Colors.blue;
    }
  }

  /// Default title for notifications of this type
  String get defaultTitle {
    switch (this) {
      case SmartReminderType.friendlyCheckin:
        return 'How are you feeling?';
      case SmartReminderType.scheduleReminder:
        return 'Your drinking schedule';
    }
  }

  /// Example notification message
  String get exampleMessage {
    switch (this) {
      case SmartReminderType.friendlyCheckin:
        return 'Take a moment for mindful reflection. How are you feeling today?';
      case SmartReminderType.scheduleReminder:
        return 'Today is a drinking day - you have 2 drinks available. Stay mindful!';
    }
  }
}
