import '../../../../core/models/user_goal.dart';

/// Goal parameter validation utilities
/// Provides validation logic for goal setup and editing
class GoalValidation {
  /// Validate weekly drinks input
  static String? validateWeeklyDrinks(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter weekly drinks target';
    }
    final intValue = int.tryParse(value);
    if (intValue == null) {
      return 'Please enter a valid number';
    }
    if (intValue < 0) {
      return 'Please enter a positive number';
    }
    if (intValue > 100) {
      return 'Weekly target seems too high. Consider a more achievable goal.';
    }
    return null;
  }

  /// Validate daily drinks input
  static String? validateDailyDrinks(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter daily drinks limit';
    }
    final intValue = int.tryParse(value);
    if (intValue == null) {
      return 'Please enter a valid number';
    }
    if (intValue < 0) {
      return 'Please enter a positive number';
    }
    if (intValue > 20) {
      return 'Daily limit seems too high. Consider a safer goal.';
    }
    return null;
  }

  /// Validate duration input
  static String? validateDuration(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter duration';
    }
    final intValue = int.tryParse(value);
    if (intValue == null) {
      return 'Please enter a valid number';
    }
    if (intValue < 1) {
      return 'Duration must be at least 1';
    }
    if (intValue > 52) {
      return 'Duration cannot exceed 52 weeks';
    }
    return null;
  }

  /// Validate alcohol-free days input
  static String? validateAlcoholFreeDays(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter number of alcohol-free days';
    }
    final intValue = int.tryParse(value);
    if (intValue == null) {
      return 'Please enter a valid number';
    }
    if (intValue < 1) {
      return 'Must have at least 1 alcohol-free day';
    }
    if (intValue > 7) {
      return 'Cannot exceed 7 days per week';
    }
    return null;
  }

  /// Validate intervention wins input
  static String? validateInterventionWins(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter intervention wins target';
    }
    final intValue = int.tryParse(value);
    if (intValue == null) {
      return 'Please enter a valid number';
    }
    if (intValue < 1) {
      return 'Must have at least 1 intervention win';
    }
    if (intValue > 50) {
      return 'Target seems too high. Consider a more achievable goal.';
    }
    return null;
  }

  /// Validate mood target input
  static String? validateMoodTarget(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter target mood score';
    }
    final doubleValue = double.tryParse(value);
    if (doubleValue == null) {
      return 'Please enter a valid number';
    }
    if (doubleValue < 1.0 || doubleValue > 10.0) {
      return 'Mood score must be between 1.0 and 10.0';
    }
    return null;
  }

  /// Validate cost savings input
  static String? validateCostSavings(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter cost savings target';
    }
    final doubleValue = double.tryParse(value);
    if (doubleValue == null) {
      return 'Please enter a valid number';
    }
    if (doubleValue < 0) {
      return 'Please enter a positive amount';
    }
    if (doubleValue > 10000) {
      return 'Target seems too high. Consider a more realistic goal.';
    }
    return null;
  }

  /// Validate goal title
  static String? validateGoalTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a goal title';
    }
    if (value.length < 3) {
      return 'Title must be at least 3 characters';
    }
    if (value.length > 100) {
      return 'Title must be less than 100 characters';
    }
    return null;
  }

  /// Validate goal description
  static String? validateGoalDescription(String? value) {
    if (value != null && value.length > 500) {
      return 'Description must be less than 500 characters';
    }
    return null;
  }

  /// Get appropriate validator for goal type
  static String? Function(String?)? getValidatorForGoalType(GoalType goalType, String fieldType) {
    switch (goalType) {
      case GoalType.weeklyReduction:
        switch (fieldType) {
          case 'target':
            return validateWeeklyDrinks;
          case 'duration':
            return validateDuration;
          default:
            return (String? value) => null;
        }
      case GoalType.dailyLimit:
        switch (fieldType) {
          case 'target':
            return validateDailyDrinks;
          case 'duration':
            return validateDuration;
          default:
            return (String? value) => null;
        }
      case GoalType.alcoholFreeDays:
        switch (fieldType) {
          case 'target':
            return validateAlcoholFreeDays;
          case 'duration':
            return validateDuration;
          default:
            return (String? value) => null;
        }
      case GoalType.interventionWins:
        switch (fieldType) {
          case 'target':
            return validateInterventionWins;
          case 'duration':
            return validateDuration;
          default:
            return (String? value) => null;
        }
      case GoalType.moodImprovement:
        switch (fieldType) {
          case 'target':
            return validateMoodTarget;
          case 'duration':
            return validateDuration;
          default:
            return (String? value) => null;
        }
      case GoalType.costSavings:
        switch (fieldType) {
          case 'target':
            return validateCostSavings;
          case 'duration':
            return validateDuration;
          default:
            return (String? value) => null;
        }
      default:
        return (String? value) => null;
    }
  }
}
