import 'dart:developer' as developer;
import '../services/hive_database_service.dart';
import 'drink_intervention_utils.dart';

/// Service for calculating user progress metrics, streaks, and patterns
class ProgressMetricsService {
  static const int _maxDaysToAnalyze = 90; // Analyze up to 90 days for patterns
  
  final HiveDatabaseService _databaseService;
  
  ProgressMetricsService(this._databaseService);
  
  // =============================================================================
  // STREAK CALCULATION
  // =============================================================================
  
  /// Calculate current adherence streak (consecutive days following goals)
  int calculateCurrentStreak({DateTime? endDate}) {
    final userData = _databaseService.getUserData();
    if (userData == null) return 0;
    
    final end = endDate ?? DateTime.now();
    final accountCreatedDate = _databaseService.getAccountCreatedDate();
    
    if (accountCreatedDate == null) return 0;
    
    int streak = 0;
    DateTime currentDate = end;
    
    // Go backwards day by day until we find a non-adherent day or reach account creation
    for (int i = 0; i < _maxDaysToAnalyze; i++) {
      // Stop if we've reached before the account was created
      if (currentDate.isBefore(accountCreatedDate)) {
        break;
      }
      
      final dayResult = _evaluateDayAdherence(currentDate, userData);
      
      if (dayResult == DayAdherence.adherent) {
        streak++;
      } else if (dayResult == DayAdherence.violation) {
        // Stop counting on first violation
        break;
      }
      // Skip non-drinking days (they don't break or extend streak)
      
      currentDate = currentDate.subtract(const Duration(days: 1));
    }
    
    developer.log('Current streak calculated: $streak days (account created: $accountCreatedDate)', name: 'ProgressMetricsService');
    return streak;
  }
  
  /// Calculate longest streak in the analyzed period
  int calculateLongestStreak({DateTime? endDate}) {
    final userData = _databaseService.getUserData();
    if (userData == null) return 0;
    
    final end = endDate ?? DateTime.now();
    final accountCreatedDate = _databaseService.getAccountCreatedDate();
    
    if (accountCreatedDate == null) return 0;
    
    int longestStreak = 0;
    int currentStreak = 0;
    
    // Start from account creation date or max analysis period, whichever is more recent
    final analysisStartDate = accountCreatedDate.isAfter(end.subtract(Duration(days: _maxDaysToAnalyze))) 
        ? accountCreatedDate 
        : end.subtract(Duration(days: _maxDaysToAnalyze));
    
    DateTime currentDate = analysisStartDate;
    final daysDifference = end.difference(analysisStartDate).inDays;
    
    // Go forward through all days since account creation
    for (int i = 0; i <= daysDifference; i++) {
      final dayResult = _evaluateDayAdherence(currentDate, userData);
      
      if (dayResult == DayAdherence.adherent) {
        currentStreak++;
        longestStreak = currentStreak > longestStreak ? currentStreak : longestStreak;
      } else if (dayResult == DayAdherence.violation) {
        currentStreak = 0;
      }
      // Skip non-drinking days (don't affect current streak count)
      
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    developer.log('Longest streak calculated: $longestStreak days (since account creation: $accountCreatedDate)', name: 'ProgressMetricsService');
    return longestStreak;
  }
  
  // =============================================================================
  // WEEKLY ADHERENCE CALCULATION
  // =============================================================================
  
  /// Calculate weekly adherence percentage for current week
  double calculateWeeklyAdherence({DateTime? date}) {
    final targetDate = date ?? DateTime.now();
    final weekStart = _getWeekStart(targetDate);
    
    return _calculateAdherenceForWeek(weekStart);
  }
  
  /// Calculate adherence for a specific week starting from Monday
  double _calculateAdherenceForWeek(DateTime weekStart) {
    final userData = _databaseService.getUserData();
    if (userData == null) return 0.0;
    
    int adherentDays = 0;
    int totalDrinkingDays = 0;
    
    for (int i = 0; i < 7; i++) {
      final currentDay = weekStart.add(Duration(days: i));
      final dayResult = _evaluateDayAdherence(currentDay, userData);
      
      if (dayResult == DayAdherence.adherent) {
        adherentDays++;
        totalDrinkingDays++;
      } else if (dayResult == DayAdherence.violation) {
        totalDrinkingDays++;
      }
      // Skip non-drinking days from calculation
    }
    
    if (totalDrinkingDays == 0) return 1.0; // Perfect if no drinking days scheduled
    return adherentDays / totalDrinkingDays;
  }
  
  /// Calculate average weekly adherence over multiple weeks
  double calculateAverageWeeklyAdherence({DateTime? endDate, int weeksToAnalyze = 4}) {
    final end = endDate ?? DateTime.now();
    double totalAdherence = 0.0;
    int weeksAnalyzed = 0;
    
    for (int week = 0; week < weeksToAnalyze; week++) {
      final weekDate = end.subtract(Duration(days: week * 7));
      final weekStart = _getWeekStart(weekDate);
      
      // Only count weeks that are not in the future
      if (weekStart.isBefore(DateTime.now()) || weekStart.isAtSameMomentAs(DateTime.now())) {
        totalAdherence += _calculateAdherenceForWeek(weekStart);
        weeksAnalyzed++;
      }
    }
    
    return weeksAnalyzed > 0 ? totalAdherence / weeksAnalyzed : 0.0;
  }
  
  // =============================================================================
  // PATTERN ANALYSIS
  // =============================================================================
  
  /// Analyze weekly drinking pattern and return descriptive assessment
  PatternAssessment analyzeWeeklyPattern({DateTime? date}) {
    final weeklyAdherence = calculateWeeklyAdherence(date: date);
    final monthlyAdherence = calculateAverageWeeklyAdherence(endDate: date, weeksToAnalyze: 4);
    
    // Trend analysis
    final trend = _calculateTrend(date: date);
    
    return PatternAssessment(
      weeklyAdherence: weeklyAdherence,
      monthlyAdherence: monthlyAdherence,
      trend: trend,
      description: _getPatternDescription(weeklyAdherence, trend),
      recommendation: _getPatternRecommendation(weeklyAdherence, trend),
    );
  }
  
  /// Analyze drinking pattern trends (improving, declining, stable)
  TrendDirection _calculateTrend({DateTime? date}) {
    final end = date ?? DateTime.now();
    
    // Compare last 2 weeks vs previous 2 weeks
    final recentWeeks = calculateAverageWeeklyAdherence(endDate: end, weeksToAnalyze: 2);
    final previousWeeks = calculateAverageWeeklyAdherence(
      endDate: end.subtract(const Duration(days: 14)), 
      weeksToAnalyze: 2
    );
    
    const threshold = 0.1; // 10% change threshold
    
    if (recentWeeks - previousWeeks > threshold) {
      return TrendDirection.improving;
    } else if (previousWeeks - recentWeeks > threshold) {
      return TrendDirection.declining;
    } else {
      return TrendDirection.stable;
    }
  }
  
  /// Get descriptive text for pattern assessment
  String _getPatternDescription(double adherence, TrendDirection trend) {
    String baseDescription;
    
    if (adherence >= 0.9) {
      baseDescription = 'Excellent';
    } else if (adherence >= 0.75) {
      baseDescription = 'Good';
    } else if (adherence >= 0.5) {
      baseDescription = 'Fair';
    } else {
      baseDescription = 'Challenging';
    }
    
    switch (trend) {
      case TrendDirection.improving:
        return '$baseDescription & Improving';
      case TrendDirection.declining:
        return '$baseDescription & Declining';
      case TrendDirection.stable:
        return baseDescription;
    }
  }
  
  /// Get recommendation based on pattern
  String _getPatternRecommendation(double adherence, TrendDirection trend) {
    final accountAge = getDaysSinceAccountCreation();
    final isNewAccount = accountAge <= 14; // First 2 weeks
    
    if (adherence >= 0.9) {
      if (isNewAccount) {
        return 'Amazing start - keep up the excellent work!';
      }
      return 'Keep up the excellent work!';
    } else if (adherence >= 0.75) {
      if (trend == TrendDirection.improving) {
        return isNewAccount 
            ? 'Great progress for your first weeks!'
            : 'Great progress - you\'re on the right track!';
      } else {
        return 'Good progress - stay focused on your goals.';
      }
    } else if (adherence >= 0.5) {
      if (trend == TrendDirection.improving) {
        return isNewAccount
            ? 'Building momentum - every day counts!'
            : 'Nice improvement - keep building momentum!';
      } else {
        return isNewAccount
            ? 'Take it one day at a time - you\'re learning!'
            : 'Consider reviewing your goals and strategies.';
      }
    } else {
      return isNewAccount
          ? 'Starting is the hardest part - be patient with yourself.'
          : 'Small steps forward count - be kind to yourself.';
    }
  }
  
  // =============================================================================
  // HELPER METHODS
  // =============================================================================
  
  /// Evaluate adherence for a specific day
  DayAdherence _evaluateDayAdherence(DateTime date, Map<String, dynamic> userData) {
    // Use the centralized adherence logic that considers tolerance
    final isAdherent = DrinkInterventionUtils.isDayAdherent(
      date: date, 
      databaseService: _databaseService
    );
    
    return isAdherent ? DayAdherence.adherent : DayAdherence.violation;
  }
  
  /// Get the start of the week (Monday) for a given date
  DateTime _getWeekStart(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysFromMonday));
  }
  
  /// Get number of days since account was created
  int getDaysSinceAccountCreation() {
    final accountCreatedDate = _databaseService.getAccountCreatedDate();
    if (accountCreatedDate == null) return 0;
    
    final now = DateTime.now();
    final difference = now.difference(accountCreatedDate).inDays;
    
    // Add 1 to include the creation day itself
    return difference + 1;
  }

  /// Get account age in a human-readable format
  String getAccountAgeString() {
    final days = getDaysSinceAccountCreation();
    
    if (days == 0) return 'Today';
    if (days == 1) return '1 day';
    if (days < 7) return '$days days';
    if (days < 30) {
      final weeks = days ~/ 7;
      final remainingDays = days % 7;
      String result = '$weeks week${weeks > 1 ? 's' : ''}';
      if (remainingDays > 0) {
        result += ', $remainingDays day${remainingDays > 1 ? 's' : ''}';
      }
      return result;
    }
    
    final months = days ~/ 30;
    final remainingDays = days % 30;
    String result = '$months month${months > 1 ? 's' : ''}';
    if (remainingDays > 0) {
      result += ', $remainingDays day${remainingDays > 1 ? 's' : ''}';
    }
    return result;
  }

}

// =============================================================================
// DATA MODELS
// =============================================================================

enum DayAdherence {
  adherent,    // Followed goals perfectly
  violation,   // Exceeded limits or drank on non-drinking day
  skip,        // Non-drinking day with no consumption (neutral)
}

enum TrendDirection {
  improving,
  stable,
  declining,
}

class PatternAssessment {
  final double weeklyAdherence;
  final double monthlyAdherence;
  final TrendDirection trend;
  final String description;
  final String recommendation;
  
  const PatternAssessment({
    required this.weeklyAdherence,
    required this.monthlyAdherence,
    required this.trend,
    required this.description,
    required this.recommendation,
  });
  
  @override
  String toString() {
    return 'PatternAssessment(weekly: ${(weeklyAdherence * 100).round()}%, '
           'monthly: ${(monthlyAdherence * 100).round()}%, '
           'trend: $trend, description: $description)';
  }
}
