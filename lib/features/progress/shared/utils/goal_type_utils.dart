import '../../../../core/models/user_goal.dart';

/// Goal type display and conversion utilities
/// Handles goal type operations and display formatting
class GoalTypeHelper {
  /// Get display name for a goal type
  static String getDisplayName(GoalType goalType) {
    switch (goalType) {
      case GoalType.weeklyReduction:
        return 'Weekly Reduction';
      case GoalType.dailyLimit:
        return 'Daily Limit';
      case GoalType.alcoholFreeDays:
        return 'Alcohol-Free Days';
      case GoalType.interventionWins:
        return 'Intervention Wins';
      case GoalType.moodImprovement:
        return 'Mood Improvement';
      case GoalType.streakMaintenance:
        return 'Streak Maintenance';
      case GoalType.costSavings:
        return 'Cost Savings';
      case GoalType.customGoal:
        return 'Custom Goal';
    }
  }

  /// Get display name from string representation (for legacy data)
  static String getDisplayNameFromString(String? goalTypeString) {
    if (goalTypeString == null) return 'Unknown Goal Type';
    
    switch (goalTypeString) {
      case 'GoalType.dailyLimit':
        return 'Daily Limit';
      case 'GoalType.weeklyLimit':
      case 'GoalType.weeklyReduction':
        return 'Weekly Reduction';
      case 'GoalType.dryDays':
      case 'GoalType.alcoholFreeDays':
        return 'Alcohol-Free Days';
      case 'GoalType.streakDays':
      case 'GoalType.streakMaintenance':
        return 'Streak Maintenance';
      case 'GoalType.reductionPercent':
        return 'Reduction Percentage';
      case 'GoalType.customTarget':
      case 'GoalType.customGoal':
        return 'Custom Goal';
      case 'GoalType.interventionWins':
        return 'Intervention Wins';
      case 'GoalType.moodImprovement':
        return 'Mood Improvement';
      case 'GoalType.costSavings':
        return 'Cost Savings';
      default:
        return goalTypeString;
    }
  }

  /// Get goal type from string representation
  static GoalType? parseFromString(String? goalTypeString) {
    if (goalTypeString == null) return null;
    
    switch (goalTypeString) {
      case 'GoalType.dailyLimit':
        return GoalType.dailyLimit;
      case 'GoalType.weeklyLimit':
      case 'GoalType.weeklyReduction':
        return GoalType.weeklyReduction;
      case 'GoalType.dryDays':
      case 'GoalType.alcoholFreeDays':
        return GoalType.alcoholFreeDays;
      case 'GoalType.streakDays':
      case 'GoalType.streakMaintenance':
        return GoalType.streakMaintenance;
      case 'GoalType.interventionWins':
        return GoalType.interventionWins;
      case 'GoalType.moodImprovement':
        return GoalType.moodImprovement;
      case 'GoalType.costSavings':
        return GoalType.costSavings;
      case 'GoalType.customTarget':
      case 'GoalType.customGoal':
        return GoalType.customGoal;
      default:
        return null;
    }
  }

  /// Get appropriate chart type for a goal type
  static ChartType getDefaultChartType(GoalType goalType) {
    switch (goalType) {
      case GoalType.weeklyReduction:
        return ChartType.weeklyDrinksTrend;
      case GoalType.dailyLimit:
        return ChartType.adherenceOverTime;
      case GoalType.alcoholFreeDays:
        return ChartType.riskDayAnalysis;
      case GoalType.interventionWins:
        return ChartType.interventionStats;
      case GoalType.moodImprovement:
        return ChartType.moodCorrelation;
      case GoalType.streakMaintenance:
        return ChartType.streakVisualization;
      case GoalType.costSavings:
        return ChartType.costSavingsProgress;
      case GoalType.customGoal:
        return ChartType.adherenceOverTime;
    }
  }
}
