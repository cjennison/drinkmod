import '../models/drink_entry.dart';
import '../services/drink_tracking_service.dart';

/// Service that integrates real data for goal progress calculations
class GoalProgressService {
  static GoalProgressService? _instance;
  static GoalProgressService get instance => _instance ??= GoalProgressService._();
  
  GoalProgressService._();
  
  final _drinkService = DrinkTrackingService.instance;

  /// Get real progress data for a goal using actual drink entries
  Future<Map<String, dynamic>> calculateGoalProgress(Map<String, dynamic> goalData) async {
    final goalStartDate = DateTime.parse(goalData['startDate']);
    final goalType = goalData['goalType'] as String;
    final parameters = goalData['parameters'] as Map<String, dynamic>;
    
    // Get all drink entries since goal started
    final allEntries = _drinkService.getAllDrinkEntries();
    final relevantEntries = allEntries.where((entry) {
      final entryDate = DateTime.parse(entry['drinkDate'] as String);
      return entryDate.isAfter(goalStartDate) || entryDate.isAtSameMomentAs(goalStartDate);
    }).toList();
    
    // Convert to DrinkEntry objects for calculation
    final drinkEntries = relevantEntries.map((data) => _mapToDrinkEntry(data)).toList();
    
    // Calculate based on goal type
    switch (goalType) {
      case 'GoalType.weeklyReduction':
        return _calculateWeeklyReductionProgress(goalData, drinkEntries, parameters);
      case 'GoalType.dailyLimit':
        return _calculateDailyLimitProgress(goalData, drinkEntries, parameters);
      case 'GoalType.alcoholFreeDays':
        return _calculateAlcoholFreeDaysProgress(goalData, drinkEntries, parameters);
      case 'GoalType.costSavings':
        return _calculateCostSavingsProgress(goalData, drinkEntries, parameters);
      default:
        return _getDefaultProgress(goalData);
    }
  }

  /// Calculate real progress for weekly reduction goals
  Map<String, dynamic> _calculateWeeklyReductionProgress(
    Map<String, dynamic> goalData,
    List<DrinkEntry> entries,
    Map<String, dynamic> parameters,
  ) {
    final startDate = DateTime.parse(goalData['startDate']);
    final targetWeekly = parameters['targetWeeklyDrinks'] as int;
    final durationMonths = parameters['durationMonths'] as int;
    
    final now = DateTime.now();
    final weeksElapsed = now.difference(startDate).inDays ~/ 7;
    final totalWeeks = (durationMonths * 4.33).round(); // Approximate weeks per month
    
    int successfulWeeks = 0;
    List<Map<String, dynamic>> recentActions = [];
    
    // Check each week since goal started
    for (int week = 0; week < weeksElapsed; week++) {
      final weekStart = startDate.add(Duration(days: week * 7));
      final weekEnd = weekStart.add(const Duration(days: 7));
      
      final weeklyDrinks = entries.where((entry) => 
        entry.timestamp.isAfter(weekStart) && entry.timestamp.isBefore(weekEnd)
      ).length;
      
      if (weeklyDrinks <= targetWeekly) {
        successfulWeeks++;
        if (week >= weeksElapsed - 2) { // Recent weeks
          recentActions.add({
            'icon': 'Icons.check_circle',
            'color': 'Colors.green',
            'text': 'Week ${week + 1}: $weeklyDrinks/$targetWeekly drinks ✓',
          });
        }
      } else if (week >= weeksElapsed - 2) {
        recentActions.add({
          'icon': 'Icons.info',
          'color': 'Colors.orange',
          'text': 'Week ${week + 1}: $weeklyDrinks/$targetWeekly drinks',
        });
      }
    }
    
    final baseProgress = totalWeeks > 0 ? successfulWeeks / totalWeeks : 0.0;
    final timeProgress = totalWeeks > 0 ? weeksElapsed / totalWeeks : 0.0;
    final isOnTrack = baseProgress >= (timeProgress * 0.8); // 80% success rate to be "on track"
    
    return {
      'percentage': baseProgress.clamp(0.0, 1.0),
      'isOnTrack': isOnTrack,
      'statusText': '$successfulWeeks/$totalWeeks weeks successful',
      'currentMetric': '$successfulWeeks weeks',
      'targetMetric': '$totalWeeks weeks',
      'bonusMetric': successfulWeeks > weeksElapsed * 0.9 ? 'Excellent pace!' : null,
      'recentActions': recentActions.take(3).toList(),
      'daysRemaining': _calculateDaysRemaining(goalData),
      'timeProgress': timeProgress.clamp(0.0, 1.0),
    };
  }

  /// Calculate real progress for daily limit goals
  Map<String, dynamic> _calculateDailyLimitProgress(
    Map<String, dynamic> goalData,
    List<DrinkEntry> entries,
    Map<String, dynamic> parameters,
  ) {
    final startDate = DateTime.parse(goalData['startDate']);
    final dailyLimit = parameters['dailyLimit'] as int;
    final durationWeeks = parameters['durationWeeks'] as int;
    
    final now = DateTime.now();
    final daysElapsed = now.difference(startDate).inDays;
    final totalDays = durationWeeks * 7;
    
    int successfulDays = 0;
    int currentStreak = 0;
    List<Map<String, dynamic>> recentActions = [];
    
    // Check each day since goal started
    for (int day = 0; day < daysElapsed && day < totalDays; day++) {
      final date = startDate.add(Duration(days: day));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      
      final dailyDrinks = entries.where((entry) => 
        entry.timestamp.isAfter(dayStart) && entry.timestamp.isBefore(dayEnd)
      ).length;
      
      if (dailyDrinks <= dailyLimit) {
        successfulDays++;
        currentStreak++;
        if (day >= daysElapsed - 3) { // Recent days
          recentActions.add({
            'icon': 'Icons.check_circle',
            'color': 'Colors.green',
            'text': 'Day ${day + 1}: $dailyDrinks/$dailyLimit drinks ✓',
          });
        }
      } else {
        currentStreak = 0;
        if (day >= daysElapsed - 3) {
          recentActions.add({
            'icon': 'Icons.info',
            'color': 'Colors.orange',
            'text': 'Day ${day + 1}: $dailyDrinks/$dailyLimit drinks',
          });
        }
      }
    }
    
    final baseProgress = totalDays > 0 ? successfulDays / totalDays : 0.0;
    final timeProgress = totalDays > 0 ? daysElapsed / totalDays : 0.0;
    final isOnTrack = baseProgress >= (timeProgress * 0.8);
    
    return {
      'percentage': baseProgress.clamp(0.0, 1.0),
      'isOnTrack': isOnTrack,
      'statusText': '$successfulDays/$totalDays days under limit',
      'currentMetric': '$successfulDays days',
      'targetMetric': '$totalDays days',
      'bonusMetric': currentStreak >= 7 ? '$currentStreak-day streak!' : null,
      'recentActions': recentActions.take(3).toList(),
      'daysRemaining': _calculateDaysRemaining(goalData),
      'timeProgress': timeProgress.clamp(0.0, 1.0),
    };
  }

  /// Calculate real progress for alcohol-free days goals
  Map<String, dynamic> _calculateAlcoholFreeDaysProgress(
    Map<String, dynamic> goalData,
    List<DrinkEntry> entries,
    Map<String, dynamic> parameters,
  ) {
    final startDate = DateTime.parse(goalData['startDate']);
    final targetAFDaysPerWeek = parameters['alcoholFreeDaysPerWeek'] as int;
    final durationMonths = parameters['durationMonths'] as int;
    
    final now = DateTime.now();
    final weeksElapsed = now.difference(startDate).inDays ~/ 7;
    final totalWeeks = (durationMonths * 4.33).round();
    
    int totalAFDays = 0;
    int successfulWeeks = 0;
    List<Map<String, dynamic>> recentActions = [];
    
    // Check each week
    for (int week = 0; week < weeksElapsed && week < totalWeeks; week++) {
      final weekStart = startDate.add(Duration(days: week * 7));
      int weeklyAFDays = 0;
      
      // Check each day in the week
      for (int day = 0; day < 7; day++) {
        final date = weekStart.add(Duration(days: day));
        final dayStart = DateTime(date.year, date.month, date.day);
        final dayEnd = dayStart.add(const Duration(days: 1));
        
        final dailyDrinks = entries.where((entry) => 
          entry.timestamp.isAfter(dayStart) && entry.timestamp.isBefore(dayEnd)
        ).length;
        
        if (dailyDrinks == 0) {
          weeklyAFDays++;
          totalAFDays++;
        }
      }
      
      if (weeklyAFDays >= targetAFDaysPerWeek) {
        successfulWeeks++;
      }
      
      if (week >= weeksElapsed - 2) { // Recent weeks
        recentActions.add({
          'icon': weeklyAFDays >= targetAFDaysPerWeek ? 'Icons.celebration' : 'Icons.info',
          'color': weeklyAFDays >= targetAFDaysPerWeek ? 'Colors.green' : 'Colors.orange',
          'text': 'Week ${week + 1}: $weeklyAFDays/$targetAFDaysPerWeek AF days',
        });
      }
    }
    
    final targetTotalAFDays = totalWeeks * targetAFDaysPerWeek;
    final baseProgress = targetTotalAFDays > 0 ? totalAFDays / targetTotalAFDays : 0.0;
    final timeProgress = totalWeeks > 0 ? weeksElapsed / totalWeeks : 0.0;
    final isOnTrack = baseProgress >= (timeProgress * 0.8);
    
    return {
      'percentage': baseProgress.clamp(0.0, 1.0),
      'isOnTrack': isOnTrack,
      'statusText': '$totalAFDays/$targetTotalAFDays AF days achieved',
      'currentMetric': '$totalAFDays days',
      'targetMetric': '$targetTotalAFDays days',
      'bonusMetric': successfulWeeks > weeksElapsed * 0.8 ? 'Consistent weekly goals!' : null,
      'recentActions': recentActions.take(3).toList(),
      'daysRemaining': _calculateDaysRemaining(goalData),
      'timeProgress': timeProgress.clamp(0.0, 1.0),
    };
  }

  /// Calculate real progress for cost savings goals
  Map<String, dynamic> _calculateCostSavingsProgress(
    Map<String, dynamic> goalData,
    List<DrinkEntry> entries,
    Map<String, dynamic> parameters,
  ) {
    final startDate = DateTime.parse(goalData['startDate']);
    final targetSavings = parameters['targetSavings'] as num;
    final avgCostPerDrink = parameters['avgCostPerDrink'] as num? ?? 8.0;
    final baselineWeeklyDrinks = parameters['baselineWeeklyDrinks'] as num? ?? 10.0;
    final durationMonths = parameters['durationMonths'] as int;
    
    final now = DateTime.now();
    final weeksElapsed = now.difference(startDate).inDays / 7;
    final totalWeeks = durationMonths * 4.33;
    
    // Calculate actual drinks since goal started
    final actualDrinks = entries.length;
    final expectedDrinks = (weeksElapsed * baselineWeeklyDrinks).round();
    final drinksSaved = (expectedDrinks - actualDrinks).clamp(0, double.infinity);
    final currentSavings = drinksSaved * avgCostPerDrink;
    
    final baseProgress = targetSavings > 0 ? (currentSavings / targetSavings).clamp(0.0, 1.0) : 0.0;
    final timeProgress = totalWeeks > 0 ? weeksElapsed / totalWeeks : 0.0;
    final isOnTrack = baseProgress >= (timeProgress * 0.8);
    
    final weeklyDrinks = weeksElapsed > 0 ? actualDrinks / weeksElapsed : 0.0;
    final weeklySavings = (baselineWeeklyDrinks - weeklyDrinks) * avgCostPerDrink;
    
    return {
      'percentage': baseProgress,
      'isOnTrack': isOnTrack,
      'statusText': '\$${currentSavings.round()}/\$${targetSavings.round()} saved',
      'currentMetric': '\$${currentSavings.round()}',
      'targetMetric': '\$${targetSavings.round()}',
      'bonusMetric': weeklySavings > 0 ? '\$${weeklySavings.round()}/week saved' : null,
      'recentActions': [
        {
          'icon': 'Icons.attach_money',
          'color': 'Colors.green',
          'text': 'Total saved: \$${currentSavings.round()}',
        },
        {
          'icon': 'Icons.trending_down',
          'color': 'Colors.blue',
          'text': '${drinksSaved.round()} fewer drinks',
        },
      ],
      'daysRemaining': _calculateDaysRemaining(goalData),
      'timeProgress': timeProgress.clamp(0.0, 1.0),
    };
  }

  /// Get default progress for unsupported goal types
  Map<String, dynamic> _getDefaultProgress(Map<String, dynamic> goalData) {
    return {
      'percentage': 0.0, // Real user just started today
      'isOnTrack': true,
      'statusText': 'Goal started today',
      'currentMetric': '0 days',
      'targetMetric': 'Goal duration',
      'bonusMetric': null,
      'recentActions': [
        {
          'icon': 'Icons.flag',
          'color': 'Colors.blue',
          'text': 'Goal created today - let\'s get started!',
        }
      ],
      'daysRemaining': _calculateDaysRemaining(goalData),
      'timeProgress': 0.0,
    };
  }

  /// Calculate days remaining for goal
  int _calculateDaysRemaining(Map<String, dynamic> goalData) {
    final startDate = DateTime.parse(goalData['startDate']);
    final parameters = goalData['parameters'] as Map<String, dynamic>;
    
    // Calculate end date based on goal type
    DateTime endDate;
    if (parameters.containsKey('durationMonths')) {
      final months = parameters['durationMonths'] as int;
      endDate = DateTime(startDate.year, startDate.month + months, startDate.day);
    } else if (parameters.containsKey('durationWeeks')) {
      final weeks = parameters['durationWeeks'] as int;
      endDate = startDate.add(Duration(days: weeks * 7));
    } else {
      // Default to 3 months
      endDate = DateTime(startDate.year, startDate.month + 3, startDate.day);
    }
    
    final now = DateTime.now();
    return endDate.difference(now).inDays.clamp(0, 999);
  }

  /// Convert Map data to DrinkEntry object for calculations
  DrinkEntry _mapToDrinkEntry(Map<String, dynamic> data) {
    return DrinkEntry(
      id: data['id'] as String,
      timestamp: DateTime.parse(data['drinkDate'] as String),
      timeOfDay: data['timeOfDay'] as String? ?? 'Unknown',
      drinkId: data['id'] as String,
      drinkName: data['drinkName'] as String,
      standardDrinks: (data['standardDrinks'] as num).toDouble(),
      location: data['location'] as String?,
      socialContext: data['socialContext'] as String?,
      moodBefore: data['moodBefore'] as int?,
      moodAfter: data['moodAfter'] as int?,
      triggers: (data['triggers'] as List?)?.cast<String>(),
      urgeIntensity: data['urgeIntensity'] as int?,
      intention: data['intention'] as String?,
      triggerDescription: data['triggerDescription'] as String?,
      consideredAlternatives: data['consideredAlternatives'] as bool?,
      alternatives: data['alternatives'] as String?,
      energyLevel: data['energyLevel'] as int?,
      hungerLevel: data['hungerLevel'] as int?,
      stressLevel: data['stressLevel'] as int?,
      sleepQuality: data['sleepQuality'] as String?,
      satisfactionLevel: data['satisfactionLevel'] as int?,
      regretPrideScale: data['regretPrideScale'] as int?,
      physicalEffects: data['physicalEffects'] as String?,
      nextIntention: data['nextIntention'] as String?,
      isWithinLimit: data['isWithinLimit'] as bool? ?? true,
      isScheduleCompliant: data['isScheduleCompliant'] as bool? ?? true,
      interventionData: null, // TODO: Map intervention data if available
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }
}
