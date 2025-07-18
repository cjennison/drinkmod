import 'dart:math';
import '../models/smart_reminder.dart';
import '../../../core/services/hive_database_service.dart';

/// Enhanced service for generating dynamic, personalized notification content
class ReminderContentGenerator {
  static final Random _random = Random();
  
  /// Cache for user context to avoid repeated database queries
  static Map<String, dynamic>? _userContextCache;
  static DateTime? _cacheTimestamp;
  
  /// Generate personalized notification content for a reminder
  static Future<Map<String, String>> generateContent(SmartReminder reminder) async {
    await _refreshUserContextIfNeeded();
    
    switch (reminder.type) {
      case SmartReminderType.friendlyCheckin:
        return _generateFriendlyCheckinContent(reminder);
      case SmartReminderType.scheduleReminder:
        return await _generateScheduleReminderContent(reminder);
    }
  }
  
  /// Refresh user context cache if needed (every 30 minutes)
  static Future<void> _refreshUserContextIfNeeded() async {
    final now = DateTime.now();
    
    if (_userContextCache == null || 
        _cacheTimestamp == null ||
        now.difference(_cacheTimestamp!).inMinutes > 30) {
      
      _userContextCache = await _getUserContext();
      _cacheTimestamp = now;
    }
  }
  
  /// Get current user context for personalization
  static Future<Map<String, dynamic>> _getUserContext() async {
    try {
      final databaseService = HiveDatabaseService.instance;
      final today = DateTime.now();
      
      // Get recent drinking data
      final todaysDrinks = databaseService.getDrinkEntriesForDate(today);
      final yesterdaysDrinks = databaseService.getDrinkEntriesForDate(
          today.subtract(const Duration(days: 1)));
      
      // Calculate streak information
      final streakDays = _calculateStreakDays();
      
      return {
        'todaysDrinkCount': todaysDrinks.length,
        'yesterdaysDrinkCount': yesterdaysDrinks.length,
        'streakDays': streakDays,
        'timeOfDay': _getTimeOfDay(),
        'dayOfWeek': today.weekday,
        'isWeekend': today.weekday > 5,
        'lastActiveTime': today,
      };
    } catch (e) {
      // Return default context if database access fails
      return {
        'todaysDrinkCount': 0,
        'yesterdaysDrinkCount': 0,
        'streakDays': 0,
        'timeOfDay': _getTimeOfDay(),
        'dayOfWeek': DateTime.now().weekday,
        'isWeekend': DateTime.now().weekday > 5,
        'lastActiveTime': DateTime.now(),
      };
    }
  }
  
  /// Calculate current streak days (simplified)
  static int _calculateStreakDays() {
    // TODO: Implement proper streak calculation when user goal system is available
    return _random.nextInt(30); // Placeholder
  }
  
  /// Generate content for friendly check-in reminders with personalization
  static Map<String, String> _generateFriendlyCheckinContent(SmartReminder reminder) {
    // Use custom message if provided
    if (reminder.message != null && reminder.message!.isNotEmpty) {
      return {
        'title': reminder.title,
        'body': reminder.message!,
      };
    }
    
    final context = _userContextCache!;
    final timeOfDay = context['timeOfDay'] as String;
    final isWeekend = context['isWeekend'] as bool;
    final streakDays = context['streakDays'] as int;
    
    // Generate contextual title
    String title = _generateContextualTitle(timeOfDay, isWeekend);
    
    // Generate personalized body message
    String body = _generatePersonalizedCheckinMessage(context, streakDays);
    
    return {
      'title': title,
      'body': body,
    };
  }
  
  /// Generate contextual titles based on time and day
  static String _generateContextualTitle(String timeOfDay, bool isWeekend) {
    final titleTemplates = {
      'morning': [
        'Good Morning Check-in',
        'Morning Mindfulness',
        'Start Your Day Mindfully',
        'Morning Reflection',
      ],
      'afternoon': [
        'Afternoon Check-in',
        'Midday Mindfulness',
        'How\'s Your Day?',
        'Afternoon Reflection',
      ],
      'evening': [
        'Evening Check-in',
        'End of Day Reflection',
        'Evening Mindfulness',
        'Daily Wrap-up',
      ],
    };
    
    final templates = titleTemplates[timeOfDay] ?? titleTemplates['morning']!;
    return templates[_random.nextInt(templates.length)];
  }
  
  /// Generate personalized check-in messages
  static String _generatePersonalizedCheckinMessage(Map<String, dynamic> context, int streakDays) {
    final timeOfDay = context['timeOfDay'] as String;
    final todaysDrinks = context['todaysDrinkCount'] as int;
    final isWeekend = context['isWeekend'] as bool;
    
    List<String> messages = [];
    
    // Add time-specific messages
    switch (timeOfDay) {
      case 'morning':
        messages.addAll([
          'How are you feeling as you start your day?',
          'Take a moment to set your intentions for today.',
          'What emotions are you experiencing this morning?',
          'How did you sleep? How\'s your energy level?',
        ]);
        break;
      case 'afternoon':
        messages.addAll([
          'How\'s your energy holding up this afternoon?',
          'Take a mindful pause - how are you feeling?',
          'How has your day been treating you so far?',
          'What\'s your mood and stress level right now?',
        ]);
        break;
      case 'evening':
        messages.addAll([
          'How are you feeling as the day winds down?',
          'Take a moment to reflect on your day.',
          'How did today go with your wellness goals?',
          'What emotions are you carrying from today?',
        ]);
        break;
    }
    
    // Add context-specific messages
    if (streakDays > 7) {
      messages.add('You\'ve been doing great with your goals. How are you feeling about your progress?');
    }
    
    if (isWeekend) {
      messages.addAll([
        'Weekend check-in: How are you taking care of yourself?',
        'How are you balancing relaxation and mindfulness this weekend?',
      ]);
    }
    
    if (todaysDrinks == 0 && timeOfDay == 'evening') {
      messages.add('You\'ve had an alcohol-free day so far. How does that feel?');
    }
    
    return messages[_random.nextInt(messages.length)];
  }
  
  /// Generate content for schedule reminder notifications
  static Future<Map<String, String>> _generateScheduleReminderContent(SmartReminder reminder) async {
    // Use custom message if provided
    if (reminder.message != null && reminder.message!.isNotEmpty) {
      return {
        'title': reminder.title,
        'body': reminder.message!,
      };
    }
    
    final context = _userContextCache!;
    final scheduleInfo = await _getTodaysScheduleInfo(context);
    
    String title = _generateScheduleTitle(context, scheduleInfo);
    String body = _buildPersonalizedScheduleMessage(context, scheduleInfo);
    
    return {
      'title': title,
      'body': body,
    };
  }
  
  /// Generate dynamic schedule titles
  static String _generateScheduleTitle(Map<String, dynamic> context, Map<String, dynamic> scheduleInfo) {
    final timeOfDay = context['timeOfDay'] as String;
    final currentDrinks = scheduleInfo['currentDrinks'] as int;
    final dailyLimit = scheduleInfo['dailyLimit'] as int;
    
    if (currentDrinks >= dailyLimit) {
      return 'Daily Limit Reached';
    } else if (timeOfDay == 'morning') {
      return 'Daily Plan Reminder';
    } else if (timeOfDay == 'afternoon') {
      return 'Midday Check-in';
    } else {
      return 'Evening Plan Review';
    }
  }
  
  /// Get today's schedule information with enhanced context
  static Future<Map<String, dynamic>> _getTodaysScheduleInfo(Map<String, dynamic> userContext) async {
    final todaysDrinks = userContext['todaysDrinkCount'] as int;
    
    // TODO: Get actual user goals from database when available
    final dailyLimit = 2; // Default limit
    final isDrinkingDay = !userContext['isWeekend'] || _random.nextBool();
    
    return {
      'currentDrinks': todaysDrinks,
      'dailyLimit': dailyLimit,
      'remainingDrinks': (dailyLimit - todaysDrinks).clamp(0, dailyLimit),
      'isDrinkingDay': isDrinkingDay,
      'timeOfDay': userContext['timeOfDay'],
      'streakDays': userContext['streakDays'],
    };
  }
  
  /// Build personalized schedule messages with better variety
  static String _buildPersonalizedScheduleMessage(Map<String, dynamic> context, Map<String, dynamic> scheduleInfo) {
    final isDrinkingDay = scheduleInfo['isDrinkingDay'] as bool;
    final currentDrinks = scheduleInfo['currentDrinks'] as int;
    final dailyLimit = scheduleInfo['dailyLimit'] as int;
    final remainingDrinks = scheduleInfo['remainingDrinks'] as int;
    final timeOfDay = context['timeOfDay'] as String;
    final streakDays = context['streakDays'] as int;
    
    if (!isDrinkingDay) {
      if (currentDrinks > 0) {
        return _getAlcoholFreeDayMessage(currentDrinks, true);
      } else {
        return _getAlcoholFreeDayMessage(0, false);
      }
    }
    
    // Drinking day messages with personalization
    if (currentDrinks == 0) {
      return _getStartOfDayMessage(dailyLimit, timeOfDay, streakDays);
    } else if (currentDrinks < dailyLimit) {
      return _getProgressMessage(currentDrinks, dailyLimit, remainingDrinks, timeOfDay);
    } else if (currentDrinks == dailyLimit) {
      return _getLimitReachedMessage(dailyLimit, timeOfDay, streakDays);
    } else {
      return _getOverLimitMessage(currentDrinks, dailyLimit, timeOfDay);
    }
  }
  
  static String _getAlcoholFreeDayMessage(int currentDrinks, bool hasHadDrinks) {
    if (hasHadDrinks) {
      final encouragement = [
        'Today was planned as alcohol-free, but you\'ve logged $currentDrinks drink${currentDrinks == 1 ? '' : 's'}. That\'s okay - tomorrow is a fresh start!',
        'You\'ve had $currentDrinks drink${currentDrinks == 1 ? '' : 's'} on your alcohol-free day. Be kind to yourself and stay mindful.',
        'Plans changed today? You\'ve logged $currentDrinks drink${currentDrinks == 1 ? '' : 's'}. Remember your goals for tomorrow.',
      ];
      return encouragement[_random.nextInt(encouragement.length)];
    } else {
      final celebration = [
        'Today is an alcohol-free day and you\'re doing amazing - keep it up!',
        'Alcohol-free day success! Your commitment is inspiring.',
        'You\'re crushing your alcohol-free day goal! How does it feel?',
        'Another alcohol-free day in the books. You should be proud!',
      ];
      return celebration[_random.nextInt(celebration.length)];
    }
  }
  
  static String _getStartOfDayMessage(int dailyLimit, String timeOfDay, int streakDays) {
    final messages = [
      'Today you have $dailyLimit drink${dailyLimit == 1 ? '' : 's'} available. Stay mindful of your goals!',
      'Your daily plan allows $dailyLimit drink${dailyLimit == 1 ? '' : 's'} today. Make them count!',
      'Starting fresh today with $dailyLimit drink${dailyLimit == 1 ? '' : 's'} planned. You\'ve got this!',
    ];
    
    if (streakDays > 14) {
      messages.add('You\'ve been consistent for $streakDays days! Today\'s limit: $dailyLimit drink${dailyLimit == 1 ? '' : 's'}.');
    }
    
    return messages[_random.nextInt(messages.length)];
  }
  
  static String _getProgressMessage(int current, int limit, int remaining, String timeOfDay) {
    final encouragement = [
      'You\'ve had $current of $limit drinks today. $remaining remaining - pace yourself!',
      'Progress check: $current/$limit drinks today. You have $remaining left to enjoy mindfully.',
      'Halfway update: $current drinks down, $remaining to go. How are you feeling?',
    ];
    
    if (timeOfDay == 'evening' && remaining > 0) {
      encouragement.add('Evening check: $current drinks today, $remaining remaining. Consider your evening plans.');
    }
    
    return encouragement[_random.nextInt(encouragement.length)];
  }
  
  static String _getLimitReachedMessage(int limit, String timeOfDay, int streakDays) {
    final success = [
      'You\'ve reached your daily limit of $limit drink${limit == 1 ? '' : 's'}. Great job staying on track!',
      'Daily goal achieved: $limit drink${limit == 1 ? '' : 's'} as planned. How do you feel?',
      'Perfect! You\'ve hit your target of $limit drink${limit == 1 ? '' : 's'} for today.',
    ];
    
    if (streakDays > 7) {
      success.add('Another day of sticking to your $limit-drink limit! $streakDays days of great choices.');
    }
    
    return success[_random.nextInt(success.length)];
  }
  
  static String _getOverLimitMessage(int current, int limit, String timeOfDay) {
    final over = current - limit;
    final support = [
      'You\'ve exceeded your daily limit by $over drink${over == 1 ? '' : 's'}. Consider slowing down.',
      'Gentle reminder: you\'re $over drink${over == 1 ? '' : 's'} over your $limit-drink goal today.',
      'You\'ve had $current drinks today (goal was $limit). How are you feeling? Consider taking a break.',
    ];
    
    if (timeOfDay == 'evening') {
      support.add('Evening reflection: $over drink${over == 1 ? '' : 's'} over your goal today. Tomorrow is a fresh start.');
    }
    
    return support[_random.nextInt(support.length)];
  }
  
  /// Generate motivational quotes for special occasions
  static List<String> getMotivationalQuotes() {
    return [
      'Every moment is a fresh beginning.',
      'You are stronger than you think.',
      'Progress, not perfection.',
      'One day at a time.',
      'You\'ve got this!',
      'Mindfulness is a gift you give yourself.',
      'Small steps lead to big changes.',
      'Be kind to yourself today.',
      'Your goals matter, and so do you.',
      'Consistency creates transformation.',
      'Celebrate every small victory.',
      'Your future self will thank you.',
    ];
  }
  
  /// Get random motivational quote with time-based selection
  static String getRandomQuote([String? timeOfDay]) {
    final quotes = getMotivationalQuotes();
    
    // Use time-based seeding for consistent but varied selection
    final now = DateTime.now();
    final seed = timeOfDay != null 
        ? now.day * 24 + now.hour 
        : now.millisecondsSinceEpoch ~/ 1000;
    
    final random = Random(seed);
    return quotes[random.nextInt(quotes.length)];
  }
  
  /// Get current time of day context
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
  
  /// Clear cache (useful for testing or user data changes)
  static void clearCache() {
    _userContextCache = null;
    _cacheTimestamp = null;
  }
  
  /// Get cache statistics for debugging
  static Map<String, dynamic> getCacheStats() {
    return {
      'hasCachedData': _userContextCache != null,
      'cacheAge': _cacheTimestamp != null 
          ? DateTime.now().difference(_cacheTimestamp!).inMinutes 
          : null,
      'cacheSize': _userContextCache?.length ?? 0,
    };
  }
}
