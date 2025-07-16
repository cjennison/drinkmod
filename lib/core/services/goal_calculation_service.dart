import '../models/user_goal.dart';
import '../services/hive_database_service.dart';

/// Service for calculating goal progress and metrics
class GoalCalculationService {
  
  /// Calculate progress for a given goal based on current data
  static GoalMetrics calculateProgress(UserGoal goal, HiveDatabaseService databaseService) {
    switch (goal.goalType) {
      case GoalType.weeklyReduction:
        return _calculateWeeklyReductionProgress(goal, databaseService);
      case GoalType.dailyLimit:
        return _calculateDailyLimitProgress(goal, databaseService);
      case GoalType.alcoholFreeDays:
        return _calculateAlcoholFreeDaysProgress(goal, databaseService);
      case GoalType.interventionWins:
        return _calculateInterventionWinsProgress(goal, databaseService);
      case GoalType.moodImprovement:
        return _calculateMoodImprovementProgress(goal, databaseService);
      case GoalType.streakMaintenance:
        return _calculateStreakMaintenanceProgress(goal, databaseService);
      case GoalType.costSavings:
        return _calculateCostSavingsProgress(goal, databaseService);
      case GoalType.customGoal:
        return _calculateCustomGoalProgress(goal, databaseService);
    }
  }

  /// Check and update milestones for a goal
  static List<Milestone> checkMilestones(UserGoal goal, GoalMetrics metrics) {
    final updatedMilestones = <Milestone>[];
    
    for (final milestone in metrics.milestones) {
      if (!milestone.isAchieved && metrics.currentProgress >= milestone.threshold) {
        // Milestone achieved
        updatedMilestones.add(milestone.copyWith(
          isAchieved: true,
          achievedDate: DateTime.now(),
        ));
      } else {
        updatedMilestones.add(milestone);
      }
    }
    
    return updatedMilestones;
  }

  /// Create default milestones for a goal type
  static List<Milestone> createDefaultMilestones(GoalType goalType) {
    switch (goalType) {
      case GoalType.weeklyReduction:
      case GoalType.dailyLimit:
      case GoalType.alcoholFreeDays:
        return [
          Milestone(
            id: 'milestone_25',
            title: 'First Quarter',
            description: '25% progress toward your goal',
            threshold: 0.25,
          ),
          Milestone(
            id: 'milestone_50',
            title: 'Halfway There',
            description: '50% progress toward your goal',
            threshold: 0.50,
          ),
          Milestone(
            id: 'milestone_75',
            title: 'Three Quarters',
            description: '75% progress toward your goal',
            threshold: 0.75,
          ),
          Milestone(
            id: 'milestone_100',
            title: 'Goal Achieved!',
            description: 'You completed your goal',
            threshold: 1.0,
          ),
        ];
      case GoalType.interventionWins:
        return [
          Milestone(
            id: 'milestone_5',
            title: 'First Wins',
            description: '5 successful interventions',
            threshold: 0.33,
          ),
          Milestone(
            id: 'milestone_10',
            title: 'Building Strength',
            description: '10 successful interventions',
            threshold: 0.66,
          ),
          Milestone(
            id: 'milestone_complete',
            title: 'Intervention Master',
            description: 'Reached your intervention goal',
            threshold: 1.0,
          ),
        ];
      case GoalType.moodImprovement:
      case GoalType.streakMaintenance:
      case GoalType.costSavings:
      case GoalType.customGoal:
        return [
          Milestone(
            id: 'milestone_50',
            title: 'Halfway There',
            description: '50% progress toward your goal',
            threshold: 0.50,
          ),
          Milestone(
            id: 'milestone_100',
            title: 'Goal Achieved!',
            description: 'You completed your goal',
            threshold: 1.0,
          ),
        ];
    }
  }

  // Private calculation methods for each goal type

  static GoalMetrics _calculateWeeklyReductionProgress(UserGoal goal, HiveDatabaseService databaseService) {
    final targetWeeklyDrinks = goal.parameters['targetWeeklyDrinks'] as int;
    final durationMonths = goal.parameters['durationMonths'] as int;
    final currentBaseline = goal.parameters['currentBaseline'] as double;
    
    final now = DateTime.now();
    final weeksElapsed = now.difference(goal.startDate).inDays / 7;
    final totalWeeks = durationMonths * 4.33; // Average weeks per month
    
    // Calculate recent weekly average (last 4 weeks)
    final recentWeeks = <double>[];
    for (int i = 0; i < 4; i++) {
      final weekStart = now.subtract(Duration(days: (i + 1) * 7));
      final weekEnd = now.subtract(Duration(days: i * 7));
      final weeklyTotal = _getWeeklyDrinks(weekStart, weekEnd, databaseService);
      recentWeeks.add(weeklyTotal);
    }
    
    final currentWeeklyAverage = recentWeeks.isNotEmpty 
        ? recentWeeks.reduce((a, b) => a + b) / recentWeeks.length 
        : 0.0;
    
    // Calculate weeks within target
    final successfulWeeks = _getSuccessfulWeeks(goal.startDate, now, targetWeeklyDrinks, databaseService);
    final progress = (successfulWeeks / totalWeeks).clamp(0.0, 1.0);
    
    return goal.metrics.copyWith(
      currentProgress: progress,
      targetValue: targetWeeklyDrinks.toDouble(),
      currentValue: currentWeeklyAverage,
      lastUpdated: DateTime.now(),
      metadata: {
        'weeksElapsed': weeksElapsed,
        'totalWeeks': totalWeeks,
        'successfulWeeks': successfulWeeks,
        'currentBaseline': currentBaseline,
      },
    );
  }

  static GoalMetrics _calculateDailyLimitProgress(UserGoal goal, HiveDatabaseService databaseService) {
    final dailyLimit = goal.parameters['dailyLimit'] as int;
    final durationWeeks = goal.parameters['durationWeeks'] as int;
    final allowedViolations = goal.parameters['allowedViolations'] as int? ?? 0;
    
    final now = DateTime.now();
    final daysElapsed = now.difference(goal.startDate).inDays;
    final totalDays = durationWeeks * 7;
    
    // Count adherent days
    int adherentDays = 0;
    for (int i = 0; i < daysElapsed && i < totalDays; i++) {
      final checkDate = goal.startDate.add(Duration(days: i));
      final dailyDrinks = databaseService.getTotalDrinksForDate(checkDate);
      if (dailyDrinks <= dailyLimit) {
        adherentDays++;
      }
    }
    
    final progress = (adherentDays / totalDays).clamp(0.0, 1.0);
    
    return goal.metrics.copyWith(
      currentProgress: progress,
      targetValue: totalDays.toDouble(),
      currentValue: adherentDays.toDouble(),
      lastUpdated: DateTime.now(),
      metadata: {
        'daysElapsed': daysElapsed,
        'totalDays': totalDays,
        'adherentDays': adherentDays,
        'dailyLimit': dailyLimit,
        'allowedViolations': allowedViolations,
      },
    );
  }

  static GoalMetrics _calculateAlcoholFreeDaysProgress(UserGoal goal, HiveDatabaseService databaseService) {
    final alcoholFreeDaysPerWeek = goal.parameters['alcoholFreeDaysPerWeek'] as int;
    final durationMonths = goal.parameters['durationMonths'] as int;
    
    final now = DateTime.now();
    final weeksElapsed = now.difference(goal.startDate).inDays / 7;
    final totalWeeks = durationMonths * 4.33;
    
    // Count successful weeks
    int successfulWeeks = 0;
    final weekStart = goal.startDate;
    
    for (int week = 0; week < weeksElapsed && week < totalWeeks; week++) {
      final currentWeekStart = weekStart.add(Duration(days: week * 7));
      final alcoholFreeDays = _getAlcoholFreeDaysInWeek(currentWeekStart, databaseService);
      
      if (alcoholFreeDays >= alcoholFreeDaysPerWeek) {
        successfulWeeks++;
      }
    }
    
    final progress = (successfulWeeks / totalWeeks).clamp(0.0, 1.0);
    
    return goal.metrics.copyWith(
      currentProgress: progress,
      targetValue: totalWeeks,
      currentValue: successfulWeeks.toDouble(),
      lastUpdated: DateTime.now(),
      metadata: {
        'weeksElapsed': weeksElapsed,
        'totalWeeks': totalWeeks,
        'successfulWeeks': successfulWeeks,
        'alcoholFreeDaysPerWeek': alcoholFreeDaysPerWeek,
      },
    );
  }

  static GoalMetrics _calculateInterventionWinsProgress(UserGoal goal, HiveDatabaseService databaseService) {
    final targetInterventionWins = goal.parameters['targetInterventionWins'] as int;
    final durationWeeks = goal.parameters['durationWeeks'] as int;
    
    // This would require intervention events to be tracked in the database
    // For now, return placeholder calculation
    final currentWins = 0; // TODO: Get from intervention events
    final progress = (currentWins / targetInterventionWins).clamp(0.0, 1.0);
    
    return goal.metrics.copyWith(
      currentProgress: progress,
      targetValue: targetInterventionWins.toDouble(),
      currentValue: currentWins.toDouble(),
      lastUpdated: DateTime.now(),
      metadata: {
        'targetWins': targetInterventionWins,
        'currentWins': currentWins,
        'durationWeeks': durationWeeks,
      },
    );
  }

  static GoalMetrics _calculateMoodImprovementProgress(UserGoal goal, HiveDatabaseService databaseService) {
    final targetAverageMood = goal.parameters['targetAverageMood'] as double;
    final durationWeeks = goal.parameters['durationWeeks'] as int;
    
    // Calculate current mood average from drink entries
    final entries = databaseService.getAllDrinkEntries();
    final moodEntries = entries
        .where((e) => e['moodBefore'] != null)
        .where((e) {
          final entryDate = DateTime.parse(e['drinkDate']);
          return entryDate.isAfter(goal.startDate);
        })
        .toList();
    
    double currentMoodAverage = 0.0;
    if (moodEntries.isNotEmpty) {
      final totalMood = moodEntries.fold<double>(
        0.0, 
        (sum, entry) => sum + (entry['moodBefore'] as int).toDouble()
      );
      currentMoodAverage = totalMood / moodEntries.length;
    }
    
    final progress = currentMoodAverage >= targetAverageMood ? 1.0 : currentMoodAverage / targetAverageMood;
    
    return goal.metrics.copyWith(
      currentProgress: progress.clamp(0.0, 1.0),
      targetValue: targetAverageMood,
      currentValue: currentMoodAverage,
      lastUpdated: DateTime.now(),
      metadata: {
        'targetMood': targetAverageMood,
        'currentMood': currentMoodAverage,
        'moodEntriesCount': moodEntries.length,
        'durationWeeks': durationWeeks,
      },
    );
  }

  static GoalMetrics _calculateStreakMaintenanceProgress(UserGoal goal, HiveDatabaseService databaseService) {
    // This would use existing streak calculation logic
    final stats = databaseService.getDashboardStats();
    final currentStreak = stats['streak'] as int;
    final targetStreak = goal.parameters['targetStreak'] as int;
    
    final progress = (currentStreak / targetStreak).clamp(0.0, 1.0);
    
    return goal.metrics.copyWith(
      currentProgress: progress,
      targetValue: targetStreak.toDouble(),
      currentValue: currentStreak.toDouble(),
      lastUpdated: DateTime.now(),
      metadata: {
        'targetStreak': targetStreak,
        'currentStreak': currentStreak,
      },
    );
  }

  static GoalMetrics _calculateCostSavingsProgress(UserGoal goal, HiveDatabaseService databaseService) {
    final targetSavings = goal.parameters['targetSavings'] as double;
    final durationMonths = goal.parameters['durationMonths'] as int;
    final baselineMonthlyCost = goal.parameters['baselineMonthlyCost'] as double;
    
    // This would calculate actual cost savings based on reduced consumption
    // For now, return placeholder calculation
    final currentSavings = 0.0; // TODO: Calculate based on drink reduction
    final progress = (currentSavings / targetSavings).clamp(0.0, 1.0);
    
    return goal.metrics.copyWith(
      currentProgress: progress,
      targetValue: targetSavings,
      currentValue: currentSavings,
      lastUpdated: DateTime.now(),
      metadata: {
        'targetSavings': targetSavings,
        'currentSavings': currentSavings,
        'baselineMonthlyCost': baselineMonthlyCost,
        'durationMonths': durationMonths,
      },
    );
  }

  static GoalMetrics _calculateCustomGoalProgress(UserGoal goal, HiveDatabaseService databaseService) {
    // Custom goals would have their own calculation logic
    // For now, return the existing metrics
    return goal.metrics.copyWith(lastUpdated: DateTime.now());
  }

  // Helper methods

  static double _getWeeklyDrinks(DateTime weekStart, DateTime weekEnd, HiveDatabaseService databaseService) {
    double total = 0.0;
    for (int day = 0; day < 7; day++) {
      final checkDate = weekStart.add(Duration(days: day));
      if (checkDate.isBefore(weekEnd)) {
        total += databaseService.getTotalDrinksForDate(checkDate);
      }
    }
    return total;
  }

  static int _getSuccessfulWeeks(DateTime startDate, DateTime endDate, int targetWeeklyDrinks, HiveDatabaseService databaseService) {
    int successfulWeeks = 0;
    final weeks = endDate.difference(startDate).inDays ~/ 7;
    
    for (int week = 0; week < weeks; week++) {
      final weekStart = startDate.add(Duration(days: week * 7));
      final weekEnd = weekStart.add(const Duration(days: 7));
      final weeklyTotal = _getWeeklyDrinks(weekStart, weekEnd, databaseService);
      
      if (weeklyTotal <= targetWeeklyDrinks) {
        successfulWeeks++;
      }
    }
    
    return successfulWeeks;
  }

  static int _getAlcoholFreeDaysInWeek(DateTime weekStart, HiveDatabaseService databaseService) {
    int alcoholFreeDays = 0;
    for (int day = 0; day < 7; day++) {
      final checkDate = weekStart.add(Duration(days: day));
      final dailyDrinks = databaseService.getTotalDrinksForDate(checkDate);
      if (dailyDrinks == 0) {
        alcoholFreeDays++;
      }
    }
    return alcoholFreeDays;
  }
}
