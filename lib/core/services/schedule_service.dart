import '../constants/onboarding_constants.dart';

/// Service for handling drinking schedule logic and validation
class ScheduleService {
  /// Check if a given date is a drinking day based on user's schedule
  static bool isDrinkingDay(Map<String, dynamic> userData, {DateTime? date}) {
    final checkDate = date ?? DateTime.now();
    final schedule = userData['schedule'] as String?;
    
    if (schedule == null) {
      return true; // Default to allow if no schedule
    }
    
    // Get schedule type
    final scheduleType = OnboardingConstants.scheduleTypeMap[schedule];
    
    switch (scheduleType) {
      case OnboardingConstants.scheduleTypeStrict:
        return _isStrictScheduleDrinkingDay(userData, checkDate, schedule);
      case OnboardingConstants.scheduleTypeOpen:
        return true; // Open schedules allow drinking any day
      default:
        return true;
    }
  }
  
  /// Check if date is a drinking day for strict schedules
  static bool _isStrictScheduleDrinkingDay(Map<String, dynamic> userData, DateTime date, String schedule) {
    // Check if custom weekly pattern exists
    final weeklyPattern = userData['weeklyPattern'] as List<dynamic>?;
    
    if (weeklyPattern != null) {
      // Use custom weekly pattern (0=Monday, 6=Sunday)
      final dayOfWeek = date.weekday - 1; // Convert to 0-based (DateTime.weekday is 1-based)
      return weeklyPattern.contains(dayOfWeek);
    }
    
    // Fall back to predefined schedule patterns
    return _getPredefinedSchedulePattern(schedule).contains(date.weekday - 1);
  }
  
  /// Get the weekly pattern for predefined schedules
  static List<int> _getPredefinedSchedulePattern(String schedule) {
    switch (schedule) {
      case OnboardingConstants.scheduleWeekendsOnly:
        return [4, 5, 6]; // Friday, Saturday, Sunday (0-based)
      case OnboardingConstants.scheduleFridayOnly:
        return [4]; // Friday only (0-based)
      case OnboardingConstants.scheduleCustomWeekly:
        return []; // Should use weeklyPattern instead
      default:
        return []; // No drinking days by default
    }
  }
  
  /// Get display text for weekly pattern
  static String getWeeklyPatternDisplayText(List<int> pattern) {
    if (pattern.isEmpty) return 'No days selected';
    
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sortedPattern = List<int>.from(pattern)..sort();
    
    return sortedPattern.map((day) => dayNames[day]).join(', ');
  }
  
  /// Create weekly pattern from predefined schedule
  static List<int>? getPatternForSchedule(String schedule) {
    switch (schedule) {
      case OnboardingConstants.scheduleWeekendsOnly:
        return [4, 5, 6]; // Friday, Saturday, Sunday
      case OnboardingConstants.scheduleFridayOnly:
        return [4]; // Friday only
      case OnboardingConstants.scheduleCustomWeekly:
        return null; // User will define custom pattern
      default:
        return null;
    }
  }
  
  /// Validate daily limit against weekly limit for open schedules
  static bool isDailyLimitValid(int dailyLimit, int weeklyLimit) {
    return dailyLimit <= (weeklyLimit / 2).floor();
  }
  
  /// Get maximum allowed daily limit for a weekly limit
  static int getMaxDailyLimit(int weeklyLimit) {
    return (weeklyLimit / 2).floor().clamp(1, 6);
  }
}
