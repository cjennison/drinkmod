import 'package:flutter/material.dart';
import '../services/hive_database_service.dart';

/// Utility class for determining when therapeutic intervention is required for drink logging
class DrinkInterventionUtils {
  
  /// Result of intervention check
  static const String interventionRequired = 'intervention_required';
  static const String quickLogAllowed = 'quick_log_allowed';
  static const String cannotLog = 'cannot_log';

  /// Check if a drink logging action requires therapeutic intervention
  /// Returns a [DrinkInterventionResult] with the decision and reasoning
  static DrinkInterventionResult checkInterventionRequired({
    required DateTime date,
    required double proposedStandardDrinks,
    required HiveDatabaseService databaseService,
    bool isRetroactive = false,
  }) {
    // Check for future dates first (strict blocking)
    if (date.isAfter(DateTime.now())) {
      return DrinkInterventionResult(
        decision: cannotLog,
        reason: 'Cannot log drinks for future dates',
        requiresIntervention: false,
      );
    }

    // Check if today is a scheduled drinking day (priority intervention)
    final isDrinkingDay = databaseService.isDrinkingDay(date: date);
    if (!isDrinkingDay) {
      return DrinkInterventionResult(
        decision: interventionRequired,
        reason: 'This is a scheduled alcohol-free day.',
        requiresIntervention: true,
        isScheduleViolation: true,
      );
    }

    // Check if we can log for this date (after checking drinking day status)
    if (!databaseService.canAddDrinkToday(date: date)) {
      return DrinkInterventionResult(
        decision: cannotLog,
        reason: 'Cannot log drinks for this date',
        requiresIntervention: false,
      );
    }

    // For retroactive entries, show informational warning but don't require intervention
    if (isRetroactive) {
      return DrinkInterventionResult(
        decision: quickLogAllowed,
        reason: 'Retroactive entry - try to log drinks before consuming for better tracking.',
        requiresIntervention: false,
        isRetroactive: true,
      );
    }

    // Check current consumption and limits
    final currentDrinks = databaseService.getTotalDrinksForDate(date);
    final userData = databaseService.getUserData();
    final dailyLimit = userData?['drinkLimit'] ?? 2;
    final proposedTotal = currentDrinks + proposedStandardDrinks;

    // If they would exceed their limit, require intervention
    if (proposedTotal > dailyLimit) {
      return DrinkInterventionResult(
        decision: interventionRequired,
        reason: 'Daily limit would be exceeded (${proposedTotal.toStringAsFixed(1)}/${dailyLimit}).',
        requiresIntervention: true,
        isLimitExceeded: true,
        currentDrinks: currentDrinks,
        dailyLimit: dailyLimit,
        proposedTotal: proposedTotal,
      );
    }

    // If approaching limit (70% threshold), require intervention
    final warningThreshold = dailyLimit * 0.7;
    if (currentDrinks >= warningThreshold) {
      return DrinkInterventionResult(
        decision: interventionRequired,
        reason: 'Approaching daily limit (${currentDrinks.toStringAsFixed(1)}/${dailyLimit}).',
        requiresIntervention: true,
        isApproachingLimit: true,
        currentDrinks: currentDrinks,
        dailyLimit: dailyLimit,
        proposedTotal: proposedTotal,
      );
    }

    // Quick log is allowed
    return DrinkInterventionResult(
      decision: quickLogAllowed,
      reason: 'Safe to quick log on drinking day within limits.',
      requiresIntervention: false,
      currentDrinks: currentDrinks,
      dailyLimit: dailyLimit,
      proposedTotal: proposedTotal,
    );
  }

  /// Check if quick log should be available for the UI
  static bool shouldShowQuickLog({
    required DateTime date,
    required HiveDatabaseService databaseService,
    bool isRetroactive = false,
  }) {
    // Never show quick log for retroactive dates
    if (isRetroactive) return false;

    // Never show quick log for future dates
    if (date.isAfter(DateTime.now())) return false;

    // Never show quick log for dates before account creation
    if (databaseService.isDateBeforeAccountCreation(date)) return false;

    // Never show quick log for non-drinking days
    final isDrinkingDay = databaseService.isDrinkingDay(date: date);
    if (!isDrinkingDay) return false;

    // Check if we can log for this date
    if (!databaseService.canAddDrinkToday(date: date)) return false;

    // Check if approaching limit
    final currentDrinks = databaseService.getTotalDrinksForDate(date);
    final userData = databaseService.getUserData();
    final dailyLimit = userData?['drinkLimit'] ?? 2;
    final warningThreshold = dailyLimit * 0.7;

    // Don't show quick log if approaching limit
    if (currentDrinks >= warningThreshold) return false;

    return true;
  }

  /// Generate appropriate button text for quick log button
  static String getQuickLogButtonText({
    required DateTime date,
    required HiveDatabaseService databaseService,
    bool isRetroactive = false,
  }) {
    if (isRetroactive) {
      return 'Full Log Only';
    }

    final isDrinkingDay = databaseService.isDrinkingDay(date: date);
    if (!isDrinkingDay) {
      return 'Alcohol-Free Day';
    }

    return 'Quick Log';
  }

  /// Get appropriate warning message for quick log sheet
  static QuickLogSheetWarning? getQuickLogSheetWarning({
    required DateTime date,
    required HiveDatabaseService databaseService,
  }) {
    final isDrinkingDay = databaseService.isDrinkingDay(date: date);
    
    if (!isDrinkingDay) {
      return QuickLogSheetWarning(
        type: QuickLogWarningType.alcoholFreeDay,
        title: 'Alcohol-Free Day',
        message: 'Today is scheduled as alcohol-free. Please use "Log Drink" for therapeutic support if you need to log a drink.',
        severity: QuickLogWarningSeverity.error,
      );
    }

    final currentDrinks = databaseService.getTotalDrinksForDate(date);
    final userData = databaseService.getUserData();
    final dailyLimit = userData?['drinkLimit'] ?? 2;
    final warningThreshold = dailyLimit * 0.7;

    if (currentDrinks >= warningThreshold) {
      return QuickLogSheetWarning(
        type: QuickLogWarningType.approachingLimit,
        title: 'Approaching Daily Limit',
        message: 'You\'re approaching your daily limit (${currentDrinks.toStringAsFixed(1)}/${dailyLimit}). Consider using "Log Drink" for mindful tracking.',
        severity: QuickLogWarningSeverity.warning,
      );
    }

    return null;
  }

  /// Determine the adherence status for a day
  static DayAdherenceStatus getDayAdherenceStatus({
    required DateTime date,
    required HiveDatabaseService databaseService,
  }) {
    // Don't evaluate future dates
    if (date.isAfter(DateTime.now())) {
      return DayAdherenceStatus.future;
    }

    final isDrinkingDay = databaseService.isDrinkingDay(date: date);
    final totalDrinks = databaseService.getTotalDrinksForDate(date);
    final userData = databaseService.getUserData();
    final dailyLimit = userData?['drinkLimit'] ?? 2;

    if (!isDrinkingDay) {
      if (totalDrinks == 0) {
        return DayAdherenceStatus.alcoholFreeDaySuccess;
      } else {
        return DayAdherenceStatus.alcoholFreeDayViolation;
      }
    } else {
      if (totalDrinks == 0) {
        return DayAdherenceStatus.drinkingDayUnused;
      } else if (totalDrinks <= dailyLimit) {
        return DayAdherenceStatus.drinkingDayWithinLimit;
      } else {
        return DayAdherenceStatus.drinkingDayExceeded;
      }
    }
  }

  /// Determine if a day was adherent to the user's drinking plan
  /// Returns true if the day was "good" (followed the plan), false if "bad" (deviated)
  static bool isDayAdherent({
    required DateTime date,
    required HiveDatabaseService databaseService,
  }) {
    final status = getDayAdherenceStatus(date: date, databaseService: databaseService);
    return status == DayAdherenceStatus.alcoholFreeDaySuccess ||
           status == DayAdherenceStatus.drinkingDayWithinLimit ||
           status == DayAdherenceStatus.drinkingDayUnused ||
           status == DayAdherenceStatus.future;
  }

  /// Get appropriate color for a day based on adherence status
  static Color getDayAdherenceColor(DayAdherenceStatus status) {
    switch (status) {
      case DayAdherenceStatus.alcoholFreeDaySuccess:
        return Colors.green.shade400;
      case DayAdherenceStatus.alcoholFreeDayViolation:
        return Colors.red.shade400;
      case DayAdherenceStatus.drinkingDayWithinLimit:
        return Colors.green.shade400;
      case DayAdherenceStatus.drinkingDayExceeded:
        return Colors.red.shade400;
      case DayAdherenceStatus.drinkingDayUnused:
        return Colors.grey.shade300;
      case DayAdherenceStatus.future:
        return Colors.grey.shade200;
    }
  }

}

/// Result of intervention check
class DrinkInterventionResult {
  final String decision;
  final String reason;
  final bool requiresIntervention;
  final bool isScheduleViolation;
  final bool isLimitExceeded;
  final bool isApproachingLimit;
  final bool isRetroactive;
  final double? currentDrinks;
  final int? dailyLimit;
  final double? proposedTotal;

  const DrinkInterventionResult({
    required this.decision,
    required this.reason,
    required this.requiresIntervention,
    this.isScheduleViolation = false,
    this.isLimitExceeded = false,
    this.isApproachingLimit = false,
    this.isRetroactive = false,
    this.currentDrinks,
    this.dailyLimit,
    this.proposedTotal,
  });

  /// Get user-friendly message for snackbar
  String get userMessage => reason;

  /// Get severity level for UI styling
  DrinkInterventionSeverity get severity {
    if (isScheduleViolation || isLimitExceeded) {
      return DrinkInterventionSeverity.error;
    }
    if (isApproachingLimit || isRetroactive) {
      return DrinkInterventionSeverity.warning;
    }
    return DrinkInterventionSeverity.info;
  }
}

/// Warning information for quick log sheet
class QuickLogSheetWarning {
  final QuickLogWarningType type;
  final String title;
  final String message;
  final QuickLogWarningSeverity severity;

  const QuickLogSheetWarning({
    required this.type,
    required this.title,
    required this.message,
    required this.severity,
  });
}

/// Types of quick log warnings
enum QuickLogWarningType {
  alcoholFreeDay,
  approachingLimit,
}

/// Severity levels for warnings
enum QuickLogWarningSeverity {
  error,
  warning,
  info,
}

/// Severity levels for interventions
enum DrinkInterventionSeverity {
  error,
  warning,
  info,
}

/// Day adherence status options
enum DayAdherenceStatus {
  alcoholFreeDaySuccess,    // Alcohol-free day with no drinks
  alcoholFreeDayViolation,  // Alcohol-free day with drinks logged
  drinkingDayWithinLimit,   // Drinking day within daily limit
  drinkingDayExceeded,      // Drinking day over daily limit
  drinkingDayUnused,        // Drinking day with no drinks logged
  future,                   // Future date (not yet evaluated)
}
