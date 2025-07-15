import 'package:flutter/material.dart';
import '../constants/onboarding_constants.dart';
import '../services/hive_database_service.dart';

/// Utility class for determining drink status based on limits and strictness levels
class DrinkStatusUtils {
  
  /// Calculate the drink status for a given date considering strictness levels
  static DrinkStatus calculateDrinkStatus({
    required DateTime date,
    required HiveDatabaseService databaseService,
  }) {
    final userData = databaseService.getUserData();
    if (userData == null) return DrinkStatus.withinLimit;
    
    final dailyLimit = userData['drinkLimit'] as int? ?? 2;
    final strictnessLevel = userData['strictnessLevel'] as String? ?? OnboardingConstants.defaultStrictnessLevel;
    final tolerance = OnboardingConstants.strictnessToleranceMap[strictnessLevel] ?? 0.5;
    
    final currentDrinks = databaseService.getTotalDrinksForDate(date);
    final toleranceLimit = dailyLimit * (1 + tolerance);
    
    // Check if it's a drinking day
    final isDrinkingDay = databaseService.isDrinkingDay(date: date);
    if (!isDrinkingDay) {
      if (currentDrinks == 0) {
        return DrinkStatus.alcoholFreeSuccess;
      } else {
        return DrinkStatus.alcoholFreeViolation;
      }
    }
    
    // For drinking days, check against limits with tolerance
    if (currentDrinks == 0) {
      return DrinkStatus.unused;
    } else if (currentDrinks <= dailyLimit) {
      return DrinkStatus.withinLimit;
    } else if (currentDrinks <= toleranceLimit) {
      return DrinkStatus.overButWithinTolerance;
    } else {
      return DrinkStatus.exceeded;
    }
  }
  
  /// Get appropriate color for drink status
  static Color getStatusColor(DrinkStatus status) {
    switch (status) {
      case DrinkStatus.withinLimit:
      case DrinkStatus.alcoholFreeSuccess:
        return Colors.green.shade400;
      case DrinkStatus.overButWithinTolerance:
        return Colors.orange.shade400; // NEW: Orange for over but within tolerance
      case DrinkStatus.exceeded:
      case DrinkStatus.alcoholFreeViolation:
        return Colors.red.shade400;
      case DrinkStatus.unused:
        return Colors.grey.shade300;
      case DrinkStatus.future:
        return Colors.grey.shade200;
    }
  }
  
  /// Get appropriate icon for drink status
  static IconData getStatusIcon(DrinkStatus status) {
    switch (status) {
      case DrinkStatus.withinLimit:
      case DrinkStatus.alcoholFreeSuccess:
        return Icons.check_circle;
      case DrinkStatus.overButWithinTolerance:
        return Icons.warning; // NEW: Warning icon for tolerance zone
      case DrinkStatus.exceeded:
      case DrinkStatus.alcoholFreeViolation:
        return Icons.cancel;
      case DrinkStatus.unused:
        return Icons.circle_outlined;
      case DrinkStatus.future:
        return Icons.schedule;
    }
  }
  
  /// Get user-friendly status message
  static String getStatusMessage(DrinkStatus status, {double? currentDrinks, int? dailyLimit}) {
    switch (status) {
      case DrinkStatus.withinLimit:
        return 'Within daily limit';
      case DrinkStatus.overButWithinTolerance:
        return 'Over limit but within tolerance';
      case DrinkStatus.exceeded:
        return 'Daily limit exceeded';
      case DrinkStatus.alcoholFreeSuccess:
        return 'Alcohol-free day success';
      case DrinkStatus.alcoholFreeViolation:
        return 'Alcohol-free day violation';
      case DrinkStatus.unused:
        return 'No drinks logged';
      case DrinkStatus.future:
        return 'Future date';
    }
  }
  
  /// Check if intervention is required based on status
  static bool requiresIntervention(DrinkStatus status) {
    return status == DrinkStatus.exceeded || 
           status == DrinkStatus.alcoholFreeViolation;
  }
  
  /// Check if warning should be shown based on status
  static bool requiresWarning(DrinkStatus status) {
    return status == DrinkStatus.overButWithinTolerance;
  }
}

/// Enum for different drink status levels
enum DrinkStatus {
  withinLimit,              // Within daily limit - GREEN
  overButWithinTolerance,   // Over limit but within tolerance - ORANGE (NEW)
  exceeded,                 // Over tolerance limit - RED  
  alcoholFreeSuccess,       // Alcohol-free day with no drinks - GREEN
  alcoholFreeViolation,     // Alcohol-free day with drinks - RED
  unused,                   // Drinking day with no drinks - GREY
  future,                   // Future date - LIGHT GREY
}

/// Enum for UI display states - simplified for UI components
enum DrinkDayResultState {
  readyForDay,              // Drinking day, no drinks yet - GREEN (ready)
  onTrack,                  // Drinking day, within limit - GREEN (on track)
  overLimit,                // Drinking day, over limit but in tolerance - ORANGE (over limit)
  limitExceeded,            // Drinking day, exceeded tolerance - RED (limit exceeded)
  nonDrinkingDay,           // Alcohol-free day, no drinks - BLUE (non-drinking day)
  planDeviation,            // Alcohol-free day, drinks logged - RED (plan deviation)
}

/// Utility class for calculating day result states for UI components
class DrinkDayResultUtils {
  
  /// Calculate the day result state for UI display purposes
  static DrinkDayResultState calculateDayResultState({
    required DateTime date,
    required HiveDatabaseService databaseService,
  }) {
    final isDrinkingDay = databaseService.isDrinkingDay(date: date);
    final totalDrinks = databaseService.getTotalDrinksForDate(date);
    
    if (!isDrinkingDay) {
      if (totalDrinks > 0) {
        return DrinkDayResultState.planDeviation;
      } else {
        return DrinkDayResultState.nonDrinkingDay;
      }
    } else {
      // It's a drinking day
      if (totalDrinks == 0) {
        return DrinkDayResultState.readyForDay;
      }
      
      // Get drink status for tolerance calculation
      final drinkStatus = DrinkStatusUtils.calculateDrinkStatus(
        date: date,
        databaseService: databaseService,
      );
      
      switch (drinkStatus) {
        case DrinkStatus.withinLimit:
          return DrinkDayResultState.onTrack;
        case DrinkStatus.overButWithinTolerance:
          return DrinkDayResultState.overLimit;
        case DrinkStatus.exceeded:
          return DrinkDayResultState.limitExceeded;
        case DrinkStatus.unused:
          return DrinkDayResultState.readyForDay;
        default:
          return DrinkDayResultState.onTrack;
      }
    }
  }
  
  /// Get appropriate color for day result state
  static Color getStateColor(DrinkDayResultState state) {
    switch (state) {
      case DrinkDayResultState.readyForDay:
      case DrinkDayResultState.onTrack:
        return Colors.green;
      case DrinkDayResultState.overLimit:
        return Colors.orange;
      case DrinkDayResultState.limitExceeded:
      case DrinkDayResultState.planDeviation:
        return Colors.red;
      case DrinkDayResultState.nonDrinkingDay:
        return Colors.blue;
    }
  }
  
  /// Get appropriate icon for day result state
  static IconData getStateIcon(DrinkDayResultState state) {
    switch (state) {
      case DrinkDayResultState.readyForDay:
        return Icons.check_circle;
      case DrinkDayResultState.onTrack:
        return Icons.trending_up;
      case DrinkDayResultState.overLimit:
        return Icons.warning;
      case DrinkDayResultState.limitExceeded:
        return Icons.cancel;
      case DrinkDayResultState.nonDrinkingDay:
        return Icons.schedule;
      case DrinkDayResultState.planDeviation:
        return Icons.error_outline;
    }
  }
  
  /// Get appropriate status text for day result state
  static String getStateText(DrinkDayResultState state) {
    switch (state) {
      case DrinkDayResultState.readyForDay:
        return 'Ready for the day';
      case DrinkDayResultState.onTrack:
        return 'On track';
      case DrinkDayResultState.overLimit:
        return 'Within tolerance';
      case DrinkDayResultState.limitExceeded:
        return 'Limit exceeded';
      case DrinkDayResultState.nonDrinkingDay:
        return 'Non-drinking day';
      case DrinkDayResultState.planDeviation:
        return 'Plan deviation';
    }
  }
}
