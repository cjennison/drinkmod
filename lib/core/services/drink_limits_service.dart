import 'dart:developer' as developer;
import '../constants/onboarding_constants.dart';
import 'user_data_service.dart';
import 'drink_tracking_service.dart';
import 'schedule_service.dart';

/// Service for schedule checking and drink limit validation
class DrinkLimitsService {
  static DrinkLimitsService? _instance;
  static DrinkLimitsService get instance => _instance ??= DrinkLimitsService._();
  
  DrinkLimitsService._();
  
  final UserDataService _userDataService = UserDataService.instance;
  final DrinkTrackingService _drinkTrackingService = DrinkTrackingService.instance;
  
  /// Check if today is a drinking day based on user's schedule
  bool isDrinkingDay({DateTime? date}) {
    final checkDate = date ?? DateTime.now();
    final userData = _userDataService.getUserData();
    if (userData == null) {
      developer.log('No user data found, defaulting to allow drinking', name: 'DrinkLimitsService');
      return true; // Default to allow if no data
    }
    
    return ScheduleService.isDrinkingDay(userData, date: checkDate);
  }
  
  /// Check if user can add another drink today (handles both strict and open schedules)
  bool canAddDrinkToday({DateTime? date}) {
    final checkDate = date ?? DateTime.now();
    final userData = _userDataService.getUserData();
    if (userData == null) return true;
    
    final schedule = userData['schedule'] as String?;
    if (schedule == null) return true;
    
    final scheduleType = OnboardingConstants.scheduleTypeMap[schedule];
    
    switch (scheduleType) {
      case OnboardingConstants.scheduleTypeStrict:
        return _canAddDrinkStrictSchedule(checkDate, userData, schedule);
      case OnboardingConstants.scheduleTypeOpen:
        return _canAddDrinkOpenSchedule(checkDate, userData, schedule);
      default:
        return true;
    }
  }
  
  /// Get remaining drinks allowed for today
  int getRemainingDrinksToday({DateTime? date}) {
    final checkDate = date ?? DateTime.now();
    final userData = _userDataService.getUserData();
    if (userData == null) return 2;
    
    final schedule = userData['schedule'] as String?;
    if (schedule == null) return 2;
    
    final scheduleType = OnboardingConstants.scheduleTypeMap[schedule];
    
    switch (scheduleType) {
      case OnboardingConstants.scheduleTypeStrict:
        return _getRemainingDrinksStrictSchedule(checkDate, userData);
      case OnboardingConstants.scheduleTypeOpen:
        return _getRemainingDrinksOpenSchedule(checkDate, userData, schedule);
      default:
        return 2;
    }
  }

  /// Check if user can add drink for strict schedule
  bool _canAddDrinkStrictSchedule(DateTime date, Map<String, dynamic> userData, String schedule) {
    // First check if today is a drinking day
    if (!ScheduleService.isDrinkingDay(userData, date: date)) {
      return false;
    }
    
    final dailyLimit = userData['drinkLimit'] as int? ?? 2;
    final todaysDrinks = _drinkTrackingService.getTotalDrinksForDate(date);
    
    return todaysDrinks < dailyLimit;
  }
  
  /// Get remaining drinks for strict schedule
  int _getRemainingDrinksStrictSchedule(DateTime date, Map<String, dynamic> userData) {
    if (!ScheduleService.isDrinkingDay(userData, date: date)) {
      return 0;
    }
    
    final dailyLimit = userData['drinkLimit'] as int? ?? 2;
    final todaysDrinks = _drinkTrackingService.getTotalDrinksForDate(date);
    
    return (dailyLimit - todaysDrinks.round()).clamp(0, dailyLimit);
  }

  /// Check if user can add drink for open schedule (weekly + daily limits)
  bool _canAddDrinkOpenSchedule(DateTime date, Map<String, dynamic> userData, String schedule) {
    // Check daily limit first
    final todaysDrinks = _drinkTrackingService.getTotalDrinksForDate(date);
    if (todaysDrinks >= OnboardingConstants.maxDrinksPerDayOpen) {
      developer.log('Open schedule: Daily limit reached ($todaysDrinks >= ${OnboardingConstants.maxDrinksPerDayOpen})', name: 'DrinkLimitsService');
      return false;
    }
    
    // Check weekly limit
    final weeklyLimit = userData['weeklyLimit'] as int? ?? OnboardingConstants.defaultWeeklyLimits[schedule] ?? 4;
    final weeklyDrinks = _drinkTrackingService.getWeeklyDrinks(date);
    
    if (weeklyDrinks >= weeklyLimit) {
      developer.log('Open schedule: Weekly limit reached ($weeklyDrinks >= $weeklyLimit)', name: 'DrinkLimitsService');
      return false;
    }
    
    developer.log('Open schedule: Can add drink (daily: $todaysDrinks/${OnboardingConstants.maxDrinksPerDayOpen}, weekly: $weeklyDrinks/$weeklyLimit)', name: 'DrinkLimitsService');
    return true;
  }
  
  /// Get remaining drinks for open schedule (limited by both daily and weekly)
  int _getRemainingDrinksOpenSchedule(DateTime date, Map<String, dynamic> userData, String schedule) {
    // Calculate remaining based on daily limit
    final todaysDrinks = _drinkTrackingService.getTotalDrinksForDate(date);
    final remainingDaily = (OnboardingConstants.maxDrinksPerDayOpen - todaysDrinks.round()).clamp(0, OnboardingConstants.maxDrinksPerDayOpen);
    
    // Calculate remaining based on weekly limit
    final weeklyLimit = userData['weeklyLimit'] as int? ?? OnboardingConstants.defaultWeeklyLimits[schedule] ?? 4;
    final weeklyDrinks = _drinkTrackingService.getWeeklyDrinks(date);
    final remainingWeekly = (weeklyLimit - weeklyDrinks.round()).clamp(0, weeklyLimit);
    
    // Return the more restrictive limit
    final remaining = [remainingDaily, remainingWeekly].reduce((a, b) => a < b ? a : b);
    developer.log('Open schedule remaining: daily=$remainingDaily, weekly=$remainingWeekly, final=$remaining', name: 'DrinkLimitsService');
    return remaining;
  }
  
  /// Get limit check status with detailed information
  Map<String, dynamic> getLimitStatus({DateTime? date}) {
    final checkDate = date ?? DateTime.now();
    final userData = _userDataService.getUserData();
    
    if (userData == null) {
      return {
        'canLog': true,
        'message': 'No user data found.',
        'status': 'no_data',
      };
    }
    
    if (!isDrinkingDay(date: checkDate)) {
      return {
        'canLog': false,
        'message': 'Today is not a drinking day according to your schedule.',
        'status': 'non_drinking_day',
      };
    }
    
    final dailyLimit = userData['drinkLimit'] as int? ?? 2;
    final todaysDrinks = _drinkTrackingService.getTotalDrinksForDate(checkDate);
    
    if (todaysDrinks >= dailyLimit) {
      return {
        'canLog': false,
        'message': 'You have reached your daily limit of $dailyLimit drinks.',
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
