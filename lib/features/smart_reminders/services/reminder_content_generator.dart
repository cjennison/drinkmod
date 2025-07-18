import '../models/smart_reminder.dart';
import '../../../core/services/hive_database_service.dart';

/// Service for generating dynamic notification content for smart reminders
class ReminderContentGenerator {
  /// Generate personalized notification content for a reminder
  static Future<Map<String, String>> generateContent(SmartReminder reminder) async {
    switch (reminder.type) {
      case SmartReminderType.friendlyCheckin:
        return _generateFriendlyCheckinContent(reminder);
      case SmartReminderType.scheduleReminder:
        return _generateScheduleReminderContent(reminder);
    }
  }

  /// Generate content for friendly check-in reminders
  static Future<Map<String, String>> _generateFriendlyCheckinContent(SmartReminder reminder) async {
    final title = reminder.title.isNotEmpty ? reminder.title : 'How are you feeling?';
    
    String body;
    if (reminder.message != null && reminder.message!.isNotEmpty) {
      body = reminder.message!;
    } else {
      // Use variety of friendly messages
      final messages = [
        'Take a moment for mindful reflection. How are you feeling today?',
        'Checking in on you - how\'s your mood and energy level?',
        'Time for a mindful pause. What emotions are you experiencing?',
        'How are you doing with your wellness goals today?',
        'Take a deep breath and check in with yourself. How do you feel?',
      ];
      
      final now = DateTime.now();
      final index = now.day % messages.length;
      body = messages[index];
    }

    return {
      'title': title,
      'body': body,
    };
  }

  /// Generate content for schedule reminder notifications
  static Future<Map<String, String>> _generateScheduleReminderContent(SmartReminder reminder) async {
    final title = reminder.title.isNotEmpty ? reminder.title : 'Your drinking schedule';
    
    try {
      final scheduleInfo = await _getTodaysScheduleInfo();
      final body = _buildScheduleMessage(scheduleInfo);
      
      return {
        'title': title,
        'body': body,
      };
    } catch (e) {
      print('Error generating schedule content: $e');
      return {
        'title': title,
        'body': 'Check your drinking schedule for today',
      };
    }
  }

  /// Get today's schedule information
  static Future<Map<String, dynamic>> _getTodaysScheduleInfo() async {
    final databaseService = HiveDatabaseService.instance;
    
    final today = DateTime.now();
    final todaysDrinks = databaseService.getDrinkEntriesForDate(today);
    final totalDrinks = todaysDrinks.length;
    
    // For now, use basic logic since we don't have user schedule data easily accessible
    final dailyLimit = 2; // Default limit
    
    return {
      'totalDrinks': totalDrinks,
      'dailyLimit': dailyLimit,
      'isDrinkingDay': true,
      'timeOfDay': _getTimeOfDay(),
    };
  }

  /// Build the schedule message based on current status
  static String _buildScheduleMessage(Map<String, dynamic> scheduleInfo) {
    final isDrinkingDay = scheduleInfo['isDrinkingDay'] as bool;
    final currentDrinks = scheduleInfo['currentDrinks'] as int;
    final dailyLimit = scheduleInfo['dailyLimit'] as int;
    final remainingDrinks = scheduleInfo['remainingDrinks'] as int;
    
    if (!isDrinkingDay) {
      if (currentDrinks > 0) {
        return 'Today was planned as alcohol-free, but you\'ve logged $currentDrinks drink${currentDrinks == 1 ? '' : 's'}. Stay mindful!';
      } else {
        return 'Today is an alcohol-free day. You\'re doing great - keep it up!';
      }
    }
    
    // Drinking day messages
    if (currentDrinks == 0) {
      return 'Today is a drinking day - you have $dailyLimit drink${dailyLimit == 1 ? '' : 's'} available. Stay mindful!';
    } else if (currentDrinks < dailyLimit) {
      return 'You\'ve had $currentDrinks of $dailyLimit drinks today. $remainingDrinks remaining - pace yourself!';
    } else if (currentDrinks == dailyLimit) {
      return 'You\'ve reached your daily limit of $dailyLimit drink${dailyLimit == 1 ? '' : 's'}. Great job staying on track!';
    } else {
      final over = currentDrinks - dailyLimit;
      return 'You\'ve exceeded your daily limit by $over drink${over == 1 ? '' : 's'}. Consider slowing down.';
    }
  }

  /// Generate content for different times of day
  static Map<String, String> generateTimeBasedContent(SmartReminder reminder, DateTime scheduledTime) {
    final hour = scheduledTime.hour;
    String timeContext = '';
    
    if (hour < 12) {
      timeContext = 'morning';
    } else if (hour < 17) {
      timeContext = 'afternoon';
    } else {
      timeContext = 'evening';
    }
    
    if (reminder.type == SmartReminderType.friendlyCheckin) {
      final contextualMessages = {
        'morning': 'Good morning! How are you starting your day?',
        'afternoon': 'Afternoon check-in - how\'s your energy and mood?',
        'evening': 'Evening reflection - how did your day go?',
      };
      
      return {
        'title': 'Mindful Check-in',
        'body': contextualMessages[timeContext] ?? reminder.notificationMessage,
      };
    }
    
    // For schedule reminders, time context can influence urgency
    return {
      'title': reminder.title,
      'body': reminder.notificationMessage,
    };
  }

  /// Get motivational quotes for friendly check-ins
  static List<String> getFriendlyCheckinQuotes() {
    return [
      'Every moment is a fresh beginning.',
      'You are stronger than you think.',
      'Progress, not perfection.',
      'One day at a time.',
      'You\'ve got this!',
      'Mindfulness is a gift you give yourself.',
      'Small steps lead to big changes.',
      'Be kind to yourself today.',
    ];
  }

  /// Get random motivational quote
  static String getRandomQuote() {
    final quotes = getFriendlyCheckinQuotes();
    final now = DateTime.now();
    final index = now.millisecond % quotes.length;
    return quotes[index];
  }

  /// Get current time of day
  static String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      return 'morning';
    } else if (hour < 17) {
      return 'afternoon';
    } else {
      return 'evening';
    }
  }
}
