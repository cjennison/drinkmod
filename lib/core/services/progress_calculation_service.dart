import 'package:flutter/material.dart';
import '../models/user_goal.dart';
import '../models/drink_entry.dart';
import '../models/intervention_event.dart';
import 'dart:math';

/// Temporary mood entry class until the real one is created
class MoodEntry {
  final DateTime timestamp;
  final double mood;
  
  MoodEntry({required this.timestamp, required this.mood});
}

/// Service for calculating motivational progress percentages for goals
/// Implements dopamine-driven algorithms that "always go up and feel good"
class ProgressCalculationService {
  
  /// Calculate progress for any goal type with motivational algorithms
  Map<String, dynamic> calculateGoalProgress(
    UserGoal goal,
    List<DrinkEntry> drinkEntries,
    List<MoodEntry>? moodEntries,
    List<InterventionEvent>? interventionEvents,
  ) {
    switch (goal.goalType) {
      case GoalType.weeklyReduction:
        return _calculateWeeklyReductionProgress(goal, drinkEntries);
      case GoalType.dailyLimit:
        return _calculateDailyLimitProgress(goal, drinkEntries);
      case GoalType.alcoholFreeDays:
        return _calculateAlcoholFreeDaysProgress(goal, drinkEntries);
      case GoalType.interventionWins:
        return _calculateInterventionWinsProgress(goal, interventionEvents ?? []);
      case GoalType.moodImprovement:
        return _calculateMoodImprovementProgress(goal, moodEntries ?? []);
      case GoalType.costSavings:
        return _calculateCostSavingsProgress(goal, drinkEntries);
      case GoalType.streakMaintenance:
        return _calculateStreakMaintenanceProgress(goal, drinkEntries);
      default:
        return _getDefaultProgress();
    }
  }

  /// Weekly Reduction: Success-based accumulation + trend bonus
  Map<String, dynamic> _calculateWeeklyReductionProgress(UserGoal goal, List<DrinkEntry> entries) {
    final durationWeeks = (goal.parameters['durationMonths'] as num).toDouble() * 4.33;
    final targetWeekly = goal.parameters['targetWeeklyDrinks'] as num;
    
    int successfulWeeks = 0;
    final totalWeeksElapsed = min(
      DateTime.now().difference(goal.startDate).inDays ~/ 7, 
      durationWeeks.round()
    );
    
    List<double> weeklyDrinks = [];
    
    // Count successful weeks (at or under target)
    for (int week = 0; week < totalWeeksElapsed; week++) {
      final weekStart = goal.startDate.add(Duration(days: week * 7));
      final weeklyCount = _getWeeklyDrinks(entries, weekStart);
      weeklyDrinks.add(weeklyCount.toDouble());
      
      if (weeklyCount <= targetWeekly) successfulWeeks++;
    }
    
    // Base progress: successful weeks / total weeks
    final baseProgress = durationWeeks > 0 ? successfulWeeks / durationWeeks : 0.0;
    
    // Bonus: Recent improvement trend (last 2 weeks vs previous 2 weeks)
    final trendBonus = _calculateRecentTrend(weeklyDrinks, 2) > 0 ? 0.05 : 0.0;
    
    final finalProgress = (baseProgress + trendBonus).clamp(0.0, 1.0);
    
    return {
      'percentage': finalProgress,
      'isOnTrack': finalProgress >= _getExpectedProgress(goal),
      'statusText': '$successfulWeeks/${durationWeeks.round()} weeks successful',
      'currentMetric': '$successfulWeeks weeks',
      'targetMetric': '${durationWeeks.round()} weeks',
      'bonusMetric': trendBonus > 0 ? '+5% trend bonus' : null,
      'recentActions': _getWeeklyReductionActions(weeklyDrinks, targetWeekly.toDouble()),
    };
  }

  /// Daily Limit: Daily success accumulation with streak multipliers
  Map<String, dynamic> _calculateDailyLimitProgress(UserGoal goal, List<DrinkEntry> entries) {
    final durationDays = (goal.parameters['durationWeeks'] as num) * 7;
    final dailyLimit = goal.parameters['dailyLimit'] as num;
    
    int successfulDays = 0;
    int currentStreak = 0;
    int longestStreak = 0;
    
    final totalDaysElapsed = min(
      DateTime.now().difference(goal.startDate).inDays, 
      durationDays.round()
    );
    
    for (int day = 0; day < totalDaysElapsed; day++) {
      final date = goal.startDate.add(Duration(days: day));
      final dailyDrinks = _getDailyDrinks(entries, date);
      
      if (dailyDrinks <= dailyLimit) {
        successfulDays++;
        currentStreak++;
        longestStreak = max(longestStreak, currentStreak);
      } else {
        currentStreak = 0;
      }
    }
    
    // Base progress
    final baseProgress = durationDays > 0 ? successfulDays / durationDays : 0.0;
    
    // Streak bonus: +10% for 7+ day streaks, +20% for 14+ day streaks
    final streakBonus = longestStreak >= 14 ? 0.20 : 
                       longestStreak >= 7 ? 0.10 : 0.0;
    
    final finalProgress = (baseProgress + streakBonus).clamp(0.0, 1.0);
    
    return {
      'percentage': finalProgress,
      'isOnTrack': finalProgress >= _getExpectedProgress(goal),
      'statusText': '$successfulDays/${durationDays.round()} days under limit',
      'currentMetric': '$successfulDays days',
      'targetMetric': '${durationDays.round()} days',
      'bonusMetric': longestStreak >= 7 ? '${longestStreak}-day streak' : null,
      'recentActions': _getDailyLimitActions(entries, goal.startDate, dailyLimit.toDouble(), currentStreak),
    };
  }

  /// Alcohol-Free Days: AF day accumulation with pattern recognition
  Map<String, dynamic> _calculateAlcoholFreeDaysProgress(UserGoal goal, List<DrinkEntry> entries) {
    final durationWeeks = (goal.parameters['durationMonths'] as num).toDouble() * 4.33;
    final targetAFDays = goal.parameters['alcoholFreeDaysPerWeek'] as num;
    
    int totalSuccessfulAFDays = 0;
    int successfulWeeks = 0;
    final weeksElapsed = _getWeeksElapsed(goal.startDate);
    
    for (int week = 0; week < min(weeksElapsed, durationWeeks.round()); week++) {
      final weekStart = goal.startDate.add(Duration(days: week * 7));
      final weekAFDays = _getAlcoholFreeDaysInWeek(entries, weekStart);
      totalSuccessfulAFDays += weekAFDays;
      
      if (weekAFDays >= targetAFDays) successfulWeeks++;
    }
    
    // Dual progress calculation - show the higher one for motivation
    final dayBasedProgress = (durationWeeks * targetAFDays) > 0 ? 
      totalSuccessfulAFDays / (durationWeeks * targetAFDays) : 0.0;
    final weekBasedProgress = durationWeeks > 0 ? successfulWeeks / durationWeeks : 0.0;
    
    // Consistency bonus for meeting weekly targets
    final consistencyBonus = weeksElapsed > 0 ? (successfulWeeks / weeksElapsed) * 0.1 : 0.0;
    
    final finalProgress = (max(dayBasedProgress, weekBasedProgress) + consistencyBonus).clamp(0.0, 1.0);
    
    return {
      'percentage': finalProgress,
      'isOnTrack': finalProgress >= _getExpectedProgress(goal),
      'statusText': '$totalSuccessfulAFDays/${(durationWeeks * targetAFDays).round()} AF days achieved',
      'currentMetric': '$totalSuccessfulAFDays days',
      'targetMetric': '${(durationWeeks * targetAFDays).round()} days',
      'bonusMetric': successfulWeeks > weeksElapsed * 0.8 ? 'Exceeded weekly!' : null,
      'recentActions': _getAlcoholFreeDaysActions(entries, goal.startDate, targetAFDays.toInt()),
    };
  }

  /// Intervention Wins: Win accumulation with decision quality bonus
  Map<String, dynamic> _calculateInterventionWinsProgress(UserGoal goal, List<InterventionEvent> events) {
    final targetWins = goal.parameters['targetInterventionWins'] as num;
    
    final winsCount = events.where((e) => e.decision == InterventionDecision.declined).length;
    final totalInterventions = events.length;
    
    // Base progress from wins achieved
    final baseProgress = targetWins > 0 ? winsCount / targetWins : 0.0;
    
    // Quality bonus: Higher win rate = bonus progress
    final winRate = totalInterventions > 0 ? winsCount / totalInterventions : 0.0;
    final qualityBonus = winRate > 0.7 ? 0.15 : winRate > 0.5 ? 0.1 : 0.05;
    
    // Recent momentum bonus
    final recentWins = events.where((e) => 
      e.decision == InterventionDecision.declined && 
      e.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 7)))
    ).length;
    final momentumBonus = recentWins >= 3 ? 0.1 : recentWins >= 1 ? 0.05 : 0.0;
    
    final finalProgress = (baseProgress + qualityBonus + momentumBonus).clamp(0.0, 1.0);
    
    return {
      'percentage': finalProgress,
      'isOnTrack': finalProgress >= _getExpectedProgress(goal),
      'statusText': '$winsCount/${targetWins.round()} intervention wins',
      'currentMetric': '$winsCount wins',
      'targetMetric': '${targetWins.round()} wins',
      'bonusMetric': winRate > 0.7 ? '${(winRate * 100).round()}% win rate' : null,
      'recentActions': _getInterventionActions(events, recentWins),
    };
  }

  /// Mood Improvement: Mood trend with consistency rewards
  Map<String, dynamic> _calculateMoodImprovementProgress(UserGoal goal, List<MoodEntry> moodEntries) {
    final targetMood = goal.parameters['targetAverageMood'] as num;
    final durationWeeks = (goal.parameters['durationWeeks'] as num).toInt();
    
    final weeklyAverages = _calculateWeeklyMoodAverages(moodEntries, goal.startDate);
    final successfulWeeks = weeklyAverages.where((avg) => avg >= targetMood).length;
    
    // Base progress
    final baseProgress = durationWeeks > 0 ? successfulWeeks / durationWeeks : 0.0;
    
    // Trend bonus: Recent weeks trending upward
    final recentTrend = _calculateMoodTrend(weeklyAverages.take(4).toList());
    final trendBonus = recentTrend > 0 ? 0.1 : 0.0;
    
    // Consistency bonus: Less mood variance = more bonus
    final moodVariance = _calculateMoodVariance(weeklyAverages);
    final stabilityBonus = moodVariance < 1.0 ? 0.1 : moodVariance < 2.0 ? 0.05 : 0.0;
    
    final finalProgress = (baseProgress + trendBonus + stabilityBonus).clamp(0.0, 1.0);
    
    final currentAverage = weeklyAverages.isNotEmpty ? 
      weeklyAverages.reduce((a, b) => a + b) / weeklyAverages.length : 0.0;
    
    return {
      'percentage': finalProgress,
      'isOnTrack': finalProgress >= _getExpectedProgress(goal),
      'statusText': '$successfulWeeks/$durationWeeks weeks above target',
      'currentMetric': '${currentAverage.toStringAsFixed(1)}/10',
      'targetMetric': '${targetMood.toStringAsFixed(1)}/10',
      'bonusMetric': recentTrend > 0 ? 'Mood trending upward ↗️' : null,
      'recentActions': _getMoodActions(moodEntries, targetMood.toDouble()),
    };
  }

  /// Cost Savings: Cumulative savings with acceleration bonus
  Map<String, dynamic> _calculateCostSavingsProgress(UserGoal goal, List<DrinkEntry> entries) {
    final targetSavings = (goal.parameters['targetSavings'] as num).toDouble();
    final baselineMonthlyCost = (goal.parameters['baselineMonthlyCost'] as num).toDouble();
    
    // For now, calculate based on drink count reduction vs cost per drink
    final avgCostPerDrink = (goal.parameters['avgCostPerDrink'] as num? ?? 8.0).toDouble();
    final actualDrinkCount = entries.where((entry) => entry.timestamp.isAfter(goal.startDate)).length;
    final monthsElapsed = DateTime.now().difference(goal.startDate).inDays / 30.44;
    final expectedDrinkCount = (monthsElapsed * (baselineMonthlyCost / avgCostPerDrink)).round();
    
    final actualSpending = actualDrinkCount * avgCostPerDrink;
    final expectedSpending = expectedDrinkCount * avgCostPerDrink;
    final currentSavings = max(0.0, expectedSpending - actualSpending);
    
    // Base progress
    final baseProgress = targetSavings > 0 ? (currentSavings / targetSavings).clamp(0.0, 1.0) : 0.0;
    
    // Acceleration bonus: Saving faster than expected
    final expectedProgressByNow = _getExpectedProgress(goal);
    final accelerationBonus = baseProgress > expectedProgressByNow ? 
      (baseProgress - expectedProgressByNow) * 0.5 : 0.0;
    
    final finalProgress = (baseProgress + accelerationBonus).clamp(0.0, 1.0);
    
    return {
      'percentage': finalProgress,
      'isOnTrack': finalProgress >= expectedProgressByNow,
      'statusText': '\$${currentSavings.round()}/\$${targetSavings.round()} saved',
      'currentMetric': '\$${currentSavings.round()}',
      'targetMetric': '\$${targetSavings.round()}',
      'bonusMetric': accelerationBonus > 0 ? '\$${((baseProgress - expectedProgressByNow) * targetSavings).round()} ahead' : null,
      'recentActions': _getCostSavingsActions(currentSavings.toDouble(), expectedSpending.toDouble(), actualSpending.toDouble()),
    };
  }

  /// Streak Maintenance: Continuous streak tracking with milestone rewards
  Map<String, dynamic> _calculateStreakMaintenanceProgress(UserGoal goal, List<DrinkEntry> entries) {
    final targetStreakDays = goal.parameters['targetStreakDays'] as num;
    final streakType = goal.parameters['streakType'] as String;
    
    final currentStreak = _calculateCurrentStreak(entries, goal.startDate, streakType);
    final longestStreak = _calculateLongestStreak(entries, goal.startDate, streakType);
    
    // Progress based on current streak vs target
    final baseProgress = targetStreakDays > 0 ? 
      (currentStreak / targetStreakDays).clamp(0.0, 1.0) : 0.0;
    
    // Milestone bonus for significant achievements
    final milestoneBonus = _calculateStreakMilestoneBonus(currentStreak);
    
    final finalProgress = (baseProgress + milestoneBonus).clamp(0.0, 1.0);
    
    return {
      'percentage': finalProgress,
      'isOnTrack': currentStreak > 0,
      'statusText': '$currentStreak/${targetStreakDays.round()} day streak',
      'currentMetric': '$currentStreak days',
      'targetMetric': '${targetStreakDays.round()} days',
      'bonusMetric': longestStreak > currentStreak ? 'Best: $longestStreak days' : 'New record!',
      'recentActions': _getStreakActions(currentStreak, streakType),
    };
  }

  // Helper methods for calculations
  
  int _getWeeklyDrinks(List<DrinkEntry> entries, DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 7));
    return entries.where((entry) => 
      entry.timestamp.isAfter(weekStart) && entry.timestamp.isBefore(weekEnd)
    ).length;
  }
  
  int _getDailyDrinks(List<DrinkEntry> entries, DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    return entries.where((entry) => 
      entry.timestamp.isAfter(dayStart) && entry.timestamp.isBefore(dayEnd)
    ).length;
  }
  
  int _getAlcoholFreeDaysInWeek(List<DrinkEntry> entries, DateTime weekStart) {
    int afDays = 0;
    for (int day = 0; day < 7; day++) {
      final date = weekStart.add(Duration(days: day));
      if (_getDailyDrinks(entries, date) == 0) {
        afDays++;
      }
    }
    return afDays;
  }
  
  int _getWeeksElapsed(DateTime startDate) {
    return DateTime.now().difference(startDate).inDays ~/ 7;
  }
  
  double _calculateRecentTrend(List<double> values, int weeks) {
    if (values.length < weeks * 2) return 0.0;
    
    final recent = values.take(weeks).reduce((a, b) => a + b) / weeks;
    final previous = values.skip(weeks).take(weeks).reduce((a, b) => a + b) / weeks;
    
    return previous - recent; // Positive means recent is lower (better for drinking)
  }
  
  List<double> _calculateWeeklyMoodAverages(List<MoodEntry> entries, DateTime startDate) {
    final weeks = _getWeeksElapsed(startDate);
    List<double> averages = [];
    
    for (int week = 0; week < weeks; week++) {
      final weekStart = startDate.add(Duration(days: week * 7));
      final weekEnd = weekStart.add(const Duration(days: 7));
      
      final weekEntries = entries.where((entry) => 
        entry.timestamp.isAfter(weekStart) && entry.timestamp.isBefore(weekEnd)
      ).toList();
      
      if (weekEntries.isNotEmpty) {
        final average = weekEntries.map((e) => e.mood).reduce((a, b) => a + b) / weekEntries.length;
        averages.add(average);
      }
    }
    
    return averages;
  }
  
  double _calculateMoodTrend(List<double> weeklyAverages) {
    if (weeklyAverages.length < 2) return 0.0;
    
    double trend = 0.0;
    for (int i = 1; i < weeklyAverages.length; i++) {
      trend += weeklyAverages[i] - weeklyAverages[i - 1];
    }
    
    return trend / (weeklyAverages.length - 1);
  }
  
  double _calculateMoodVariance(List<double> weeklyAverages) {
    if (weeklyAverages.isEmpty) return 0.0;
    
    final mean = weeklyAverages.reduce((a, b) => a + b) / weeklyAverages.length;
    final squaredDiffs = weeklyAverages.map((avg) => pow(avg - mean, 2));
    
    return squaredDiffs.reduce((a, b) => a + b) / weeklyAverages.length;
  }
  
  int _calculateCurrentStreak(List<DrinkEntry> entries, DateTime startDate, String streakType) {
    // Simplified implementation - return mock value for now
    return 5;
  }
  
  int _calculateLongestStreak(List<DrinkEntry> entries, DateTime startDate, String streakType) {
    // Simplified implementation - return mock value for now
    return 12;
  }
  
  double _calculateStreakMilestoneBonus(int currentStreak) {
    if (currentStreak >= 30) return 0.2;
    if (currentStreak >= 14) return 0.15;
    if (currentStreak >= 7) return 0.1;
    if (currentStreak >= 3) return 0.05;
    return 0.0;
  }
  
  double _getExpectedProgress(UserGoal goal) {
    final endDate = goal.endDate;
    if (endDate == null) return 0.0;
    
    final totalDuration = endDate.difference(goal.startDate).inDays;
    final elapsed = DateTime.now().difference(goal.startDate).inDays;
    return totalDuration > 0 ? elapsed / totalDuration : 0.0;
  }
  
  Map<String, dynamic> _getDefaultProgress() {
    return {
      'percentage': 0.75,
      'isOnTrack': true,
      'statusText': 'Making progress',
      'currentMetric': '3/4',
      'targetMetric': '4/4',
      'bonusMetric': null,
      'recentActions': [
        {
          'icon': Icons.check_circle,
          'color': Colors.green,
          'text': 'Making great progress!',
        }
      ],
    };
  }
  
  // Mock action generators - these would be replaced with real implementations
  List<Map<String, dynamic>> _getWeeklyReductionActions(List<double> weeklyDrinks, double target) {
    return [
      {'icon': Icons.check_circle, 'color': Colors.green, 'text': 'Great week! Stayed under ${target.round()} drinks ✓'},
      {'icon': Icons.local_fire_department, 'color': Colors.orange, 'text': '3 successful weeks in a row! 🔥'},
      {'icon': Icons.trending_down, 'color': Colors.blue, 'text': 'Down 2 drinks from last week ↓'},
    ];
  }
  
  List<Map<String, dynamic>> _getDailyLimitActions(List<DrinkEntry> entries, DateTime startDate, double limit, int streak) {
    return [
      {'icon': Icons.check_circle, 'color': Colors.green, 'text': 'Today: 2/${limit.round()} drinks ✓ Day $streak streak!'},
      {'icon': Icons.calendar_today, 'color': Colors.blue, 'text': 'Yesterday: Under limit ✓'},
      {'icon': Icons.bar_chart, 'color': Colors.purple, 'text': 'This week: 5/7 successful days'},
    ];
  }
  
  List<Map<String, dynamic>> _getAlcoholFreeDaysActions(List<DrinkEntry> entries, DateTime startDate, int target) {
    return [
      {'icon': Icons.stars, 'color': Colors.amber, 'text': 'Today: Alcohol-free! ✨'},
      {'icon': Icons.celebration, 'color': Colors.green, 'text': 'This week: 3/$target AF days (exceeded goal!)'},
      {'icon': Icons.whatshot, 'color': Colors.orange, 'text': 'AF streak: 2 days and counting'},
    ];
  }
  
  List<Map<String, dynamic>> _getInterventionActions(List<InterventionEvent> events, int recentWins) {
    return [
      {'icon': Icons.psychology, 'color': Colors.purple, 'text': 'Yesterday: Chose not to drink! 💪'},
      {'icon': Icons.emoji_events, 'color': Colors.amber, 'text': 'This week: $recentWins intervention wins'},
      {'icon': Icons.whatshot, 'color': Colors.orange, 'text': 'Win streak: 3 in a row!'},
    ];
  }
  
  List<Map<String, dynamic>> _getMoodActions(List<MoodEntry> entries, double target) {
    return [
      {'icon': Icons.sentiment_satisfied, 'color': Colors.green, 'text': 'Today: 8/10 mood ✓ (Above target!)'},
      {'icon': Icons.trending_up, 'color': Colors.blue, 'text': 'This week: Average 7.5/10 mood'},
      {'icon': Icons.psychology, 'color': Colors.purple, 'text': 'Mood trending upward ↗️'},
    ];
  }
  
  List<Map<String, dynamic>> _getCostSavingsActions(double currentSavings, double expected, double actual) {
    return [
      {'icon': Icons.attach_money, 'color': Colors.green, 'text': 'This week: Saved \$47 💰'},
      {'icon': Icons.trending_up, 'color': Colors.blue, 'text': 'Total saved: \$${currentSavings.round()} of target'},
      {'icon': Icons.rocket_launch, 'color': Colors.purple, 'text': 'Ahead of schedule by \$23!'},
    ];
  }
  
  List<Map<String, dynamic>> _getStreakActions(int currentStreak, String streakType) {
    return [
      {'icon': Icons.whatshot, 'color': Colors.orange, 'text': 'Day $currentStreak streak! 🔥'},
      {'icon': Icons.check_circle, 'color': Colors.green, 'text': 'Streak maintained today ✓'},
      {'icon': Icons.emoji_events, 'color': Colors.amber, 'text': 'New milestone reached!'},
    ];
  }
}
