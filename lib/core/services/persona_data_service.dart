import 'dart:math';
import '../models/user_goal.dart';
import '../constants/onboarding_constants.dart';
import 'drink_tracking_service.dart';
import 'goal_management_service.dart';
import 'onboarding_service.dart';

/// Service for generating test persona data for development and testing
class PersonaDataService {
  static final DrinkTrackingService _drinkService = DrinkTrackingService.instance;
  static final GoalManagementService _goalService = GoalManagementService.instance;
  static final Random _random = Random();

  /// Available test personas
  static List<PersonaDefinition> get availablePersonas => [
    PersonaDefinition(
      name: "Mostly Sober Samuel",
      description: "90 days of data, Fridays only drinking, 0-1 drinks/week",
      days: 90,
      schedule: DrinkingSchedule.fridaysOnly,
      pattern: DrinkingPattern.minimal,
      goalType: GoalType.dailyLimit,
    ),
    PersonaDefinition(
      name: "Drunk Deirdre", 
      description: "15 days of data, Social occasions, 2-8 drinks/week",
      days: 15,
      schedule: DrinkingSchedule.socialOccasions,
      pattern: DrinkingPattern.moderate,
      goalType: GoalType.weeklyReduction,
    ),
    PersonaDefinition(
      name: "Mormon Molly",
      description: "30 days of data, Weekends only, 0 drinks whatsoever",
      days: 30, 
      schedule: DrinkingSchedule.weekendsOnly,
      pattern: DrinkingPattern.none,
      goalType: GoalType.alcoholFreeDays,
    ),
    PersonaDefinition(
      name: "Normal Norman",
      description: "60 days of data, Mon/Wed/Sat, 1-2 drinks/day, sometimes off-days",
      days: 60,
      schedule: DrinkingSchedule.custom,
      pattern: DrinkingPattern.regular,
      goalType: GoalType.interventionWins,
    ),
  ];

  /// Generate and inject persona data into the database
  static Future<void> generatePersonaData(PersonaDefinition persona) async {
    try {
      print('🧪 Starting persona data generation for: ${persona.name}');
      
      // Clear existing data first
      await _clearAllData();
      print('✅ Cleared existing data');
      
      // Update account creation date to match persona timeline
      await _updateAccountCreationDate(persona);
      print('✅ Updated account creation date');
      
      // Generate drink entries using the service's createDrinkEntry method
      await _generateAndSaveDrinkEntries(persona);
      print('✅ Generated drink entries');
      
      // Generate and save goal using the service's createGoal method
      await _generateAndSaveGoal(persona);
      print('✅ Generated goal');
      
      // Verify data was saved
      await _verifyDataWasSaved(persona);
      
      print('🎉 Persona data generation complete!');
    } catch (e, stackTrace) {
      print('❌ Error generating persona data: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Clear all existing data from the database
  static Future<void> _clearAllData() async {
    // Clear goals
    await _goalService.clearAllGoals();
    
    // Clear all drink entries manually since there's no clearAll method
    await _clearAllDrinkEntries();
  }

  /// Clear all drink entries by deleting them individually
  static Future<void> _clearAllDrinkEntries() async {
    final allEntries = _drinkService.getAllDrinkEntries();
    print('🗑️ Clearing ${allEntries.length} existing drink entries');
    
    for (final entry in allEntries) {
      final entryId = entry['id'] as String;
      await _drinkService.deleteDrinkEntry(entryId);
    }
    
    print('✅ Cleared all drink entries');
  }

  /// Verify that data was actually saved
  static Future<void> _verifyDataWasSaved(PersonaDefinition persona) async {
    // Check drink entries
    final allEntries = _drinkService.getAllDrinkEntries();
    print('📊 Verification: Found ${allEntries.length} drink entries in database');
    
    if (allEntries.isEmpty && persona.pattern != DrinkingPattern.none) {
      throw Exception('No drink entries were saved! Expected some entries for ${persona.name}');
    }
    
    // Check goals (this would require a method to get all goals, for now just print)
    print('✅ Data verification passed');
  }

  /// Generate and save drink entries using the actual service
  static Future<void> _generateAndSaveDrinkEntries(PersonaDefinition persona) async {
    final startDate = DateTime.now().subtract(Duration(days: persona.days));
    int totalEntriesCreated = 0;
    
    print('🍺 Generating drink entries for ${persona.days} days (${startDate.toString().split(' ')[0]} to today)');
    
    for (int day = 0; day < persona.days; day++) {
      final date = startDate.add(Duration(days: day));
      final shouldDrink = _shouldDrinkOnDay(date, persona);
      
      if (shouldDrink) {
        final drinkCount = _getDrinkCountForDay(persona);
        
        for (int i = 0; i < drinkCount; i++) {
          final timeOfDay = _getRandomTimeOfDay();
          final drinkTime = _getRandomTimeOnDate(date);
          
          try {
            await _drinkService.createDrinkEntry(
              drinkDate: drinkTime,
              drinkName: _getRandomDrinkName(),
              standardDrinks: _getRandomStandardDrinks(),
              drinkType: _getRandomDrinkType(),
              timeOfDay: timeOfDay,
              reason: 'Generated test data for ${persona.name}',
              location: _getRandomLocation(),
              socialContext: _getRandomSocialContext(),
              moodBefore: _getRandomMood(),
            );
            totalEntriesCreated++;
            
            if (totalEntriesCreated <= 3) {
              print('✓ Created entry $totalEntriesCreated: ${_getRandomDrinkName()} on ${date.toString().split(' ')[0]}');
            }
          } catch (e) {
            print('❌ Failed to create drink entry for day $day: $e');
            rethrow;
          }
        }
      }
    }
    
    print('🍺 Created $totalEntriesCreated total drink entries for ${persona.name}');
  }

  /// Generate and save goal using the actual service
  static Future<void> _generateAndSaveGoal(PersonaDefinition persona) async {
    print('🎯 Generating ${persona.goalType.name} goal for ${persona.name}');
    
    // Calculate a random goal creation date within the persona's timeline
    final accountStartDate = DateTime.now().subtract(Duration(days: persona.days));
    // For personas with long timelines, create goals that are near completion for testing
    final goalCreationDaysAgo = persona.days > 30 
        ? _random.nextInt(10) + 3  // Goals created 3-13 days ago for testing completion
        : _random.nextInt(persona.days - 5) + 3; // Original logic for shorter timelines
    final goalCreationDate = accountStartDate.add(Duration(days: goalCreationDaysAgo));
    
    print('📅 Setting goal creation date to: ${goalCreationDate.toString().split(' ')[0]} (${DateTime.now().difference(goalCreationDate).inDays} days ago)');
    
    Map<String, dynamic> parameters = {};
    String title = '';
    String description = '';
    ChartType chartType = ChartType.weeklyDrinksTrend;
    
    switch (persona.goalType) {
      case GoalType.dailyLimit:
        parameters = {
          'dailyLimit': 2,
          'durationWeeks': 2, // Shorter duration for testing completion
          'targetValue': 2.0,
        };
        title = 'Daily Drink Limit';
        description = 'Stay under 2 drinks per day';
        chartType = ChartType.adherenceOverTime;
        break;
        
      case GoalType.weeklyReduction:
        parameters = {
          'targetWeeklyDrinks': 4,
          'durationMonths': 1, // Keep 1 month but goal created near end
          'targetValue': 4.0,
        };
        title = 'Weekly Reduction';
        description = 'Reduce to 4 drinks per week';
        chartType = ChartType.weeklyDrinksTrend;
        break;
        
      case GoalType.alcoholFreeDays:
        parameters = {
          'alcoholFreeDaysPerWeek': 5,
          'durationMonths': 1, // 1 month duration
          'targetValue': 5.0,
        };
        title = 'Alcohol-Free Days';
        description = '5 alcohol-free days per week';
        chartType = ChartType.adherenceOverTime;
        break;
        
      case GoalType.interventionWins:
        parameters = {
          'targetSuccessRate': 70,
          'targetValue': 70.0,
        };
        title = 'Intervention Success';
        description = 'Achieve a 70% success rate when interventions occur';
        chartType = ChartType.interventionStats;
        break;
        
      default:
        parameters = {'duration': 30, 'targetValue': 1.0};
        title = 'Test Goal';
        description = 'Generated test goal';
    }

    try {
      final goalId = await _goalService.createGoal(
        title: title,
        description: description,
        goalType: persona.goalType,
        parameters: parameters,
        associatedChart: chartType,
        priorityLevel: 1,
        customStartDate: goalCreationDate,
        customCreatedAt: goalCreationDate,
      );
      
      print('🎯 Created goal: $title (ID: $goalId) on ${goalCreationDate.toString().split(' ')[0]}');
    } catch (e) {
      print('❌ Failed to create goal: $e');
      rethrow;
    }
  }

  /// Update the user's account creation date to match persona timeline
  static Future<void> _updateAccountCreationDate(PersonaDefinition persona) async {
    // Calculate the account creation date based on persona timeline
    final accountCreationDate = DateTime.now().subtract(Duration(days: persona.days));
    final timestamp = accountCreationDate.millisecondsSinceEpoch;
    
    print('📅 Setting account creation date to: ${accountCreationDate.toString().split(' ')[0]} (${persona.days} days ago)');
    
    // Get the schedule data for this persona
    final scheduleData = _getPersonaScheduleData(persona);
    
    // Update the user data with the new account creation date, name, and drinking schedule
    await OnboardingService.updateUserData({
      'accountCreatedDate': timestamp,
      'name': persona.name,
      'schedule': scheduleData['schedule'],
      'weeklyPattern': scheduleData['weeklyPattern'],
      'drinkLimit': scheduleData['drinkLimit'],
      'weeklyLimit': scheduleData['weeklyLimit'],
      'motivation': _getPersonaMotivation(persona),
      'strictnessLevel': _getPersonaStrictnessLevel(persona),
      'gender': _getPersonaGender(persona),
    });
    
    print('👤 Updated user profile:');
    print('  - Name: ${persona.name}');
    print('  - Gender: ${_getPersonaGender(persona)}');
    print('  - Motivation: ${_getPersonaMotivation(persona)}');
    print('  - Strictness: ${_getPersonaStrictnessLevel(persona)}');
    print('  - Schedule: ${scheduleData['schedule']}');
    if (scheduleData['weeklyPattern'] != null) {
      print('  - Weekly Pattern: ${scheduleData['weeklyPattern']}');
    }
  }

  /// Get persona schedule data in the format expected by the profile system
  static Map<String, dynamic> _getPersonaScheduleData(PersonaDefinition persona) {
    switch (persona.schedule) {
      case DrinkingSchedule.fridaysOnly:
        return {
          'schedule': OnboardingConstants.scheduleFridayOnly,
          'weeklyPattern': null,
          'drinkLimit': 2,
          'weeklyLimit': 2,
        };
        
      case DrinkingSchedule.weekendsOnly:
        return {
          'schedule': OnboardingConstants.scheduleWeekendsOnly,
          'weeklyPattern': null,
          'drinkLimit': 2,
          'weeklyLimit': 4,
        };
        
      case DrinkingSchedule.socialOccasions:
        return {
          'schedule': OnboardingConstants.scheduleSocialOccasions,
          'weeklyPattern': null,
          'drinkLimit': 3,
          'weeklyLimit': 9,
        };
        
      case DrinkingSchedule.custom:
        // Norman: Monday (1), Wednesday (3), Saturday (6)
        return {
          'schedule': OnboardingConstants.scheduleCustomWeekly,
          'weeklyPattern': [1, 3, 6], // Days of week as numbers (1=Monday, 7=Sunday)
          'drinkLimit': 2,
          'weeklyLimit': 6,
        };
    }
  }

  /// Get persona-specific motivation
  static String _getPersonaMotivation(PersonaDefinition persona) {
    switch (persona.name) {
      case "Mostly Sober Samuel":
        return "health_wellbeing";
      case "Drunk Deirdre":
        return "social_relationships";
      case "Mormon Molly":
        return "personal_values";
      case "Normal Norman":
        return "balance_control";
      default:
        return "health_wellbeing";
    }
  }

  /// Get persona-specific strictness level
  static String _getPersonaStrictnessLevel(PersonaDefinition persona) {
    switch (persona.pattern) {
      case DrinkingPattern.none:
        return OnboardingConstants.strictnessHigh;
      case DrinkingPattern.minimal:
        return OnboardingConstants.strictnessHigh;
      case DrinkingPattern.moderate:
        return OnboardingConstants.strictnessMedium;
      case DrinkingPattern.regular:
        return OnboardingConstants.strictnessLow;
    }
  }

  /// Get persona gender from name
  static String _getPersonaGender(PersonaDefinition persona) {
    if (persona.name.contains("Samuel") || persona.name.contains("Norman")) {
      return "male";
    } else if (persona.name.contains("Deirdre") || persona.name.contains("Molly")) {
      return "female";
    }
    return "other";
  }

  /// Determine if persona should drink on a given day
  static bool _shouldDrinkOnDay(DateTime date, PersonaDefinition persona) {
    final weekday = date.weekday;
    
    switch (persona.schedule) {
      case DrinkingSchedule.fridaysOnly:
        return weekday == DateTime.friday;
        
      case DrinkingSchedule.weekendsOnly:
        return weekday == DateTime.saturday || weekday == DateTime.sunday;
        
      case DrinkingSchedule.socialOccasions:
        // Random social occasions, about 3-4 times per week
        return _random.nextDouble() < 0.5;
        
      case DrinkingSchedule.custom:
        // Monday, Wednesday, Saturday for Norman
        if (weekday == DateTime.monday || 
            weekday == DateTime.wednesday || 
            weekday == DateTime.saturday) {
          return true;
        }
        // Sometimes drinks on off-days
        return _random.nextDouble() < 0.2;
    }
  }

  /// Get number of drinks for a drinking day
  static int _getDrinkCountForDay(PersonaDefinition persona) {
    switch (persona.pattern) {
      case DrinkingPattern.none:
        return 0;
        
      case DrinkingPattern.minimal:
        // Samuel: 0-1 drinks
        return _random.nextBool() ? 0 : 1;
        
      case DrinkingPattern.moderate:
        // Deirdre: 2-8 drinks per week, distributed randomly
        return _random.nextInt(3) + 1; // 1-3 per drinking day
        
      case DrinkingPattern.regular:
        // Norman: 1-2 drinks per day
        return _random.nextInt(2) + 1;
    }
  }

  // Helper methods
  static String _getRandomDrinkName() {
    final drinks = ['Beer', 'Wine', 'Vodka Tonic', 'Whiskey', 'Gin & Tonic', 'Rum & Coke'];
    return drinks[_random.nextInt(drinks.length)];
  }

  static String _getRandomDrinkType() {
    final types = ['beer', 'wine', 'spirit', 'cocktail'];
    return types[_random.nextInt(types.length)];
  }

  static DateTime _getRandomTimeOnDate(DateTime date) {
    final hour = 17 + _random.nextInt(6); // 5 PM to 11 PM
    final minute = _random.nextInt(60);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
  
  // Helper methods for data generation
  
  static String _getRandomTimeOfDay() {
    final times = ['Evening', 'Night', 'Afternoon', 'Morning'];
    return times[_random.nextInt(times.length)];
  }
  
  static double _getRandomStandardDrinks() {
    return 0.5 + _random.nextDouble() * 2.5; // 0.5 to 3.0 standard drinks
  }
  
  static String _getRandomLocation() {
    final locations = ['Home', 'Bar', 'Restaurant', 'Social Event', 'Work'];
    return locations[_random.nextInt(locations.length)];
  }
  
  static String _getRandomSocialContext() {
    final contexts = ['Alone', 'Partner', 'Close Friends', 'Family', 'Acquaintances'];
    return contexts[_random.nextInt(contexts.length)];
  }
  
  static int _getRandomMood() {
    return 5 + _random.nextInt(4); // 5-8 mood range
  }
}

/// Persona definition for test data generation
class PersonaDefinition {
  final String name;
  final String description;
  final int days;
  final DrinkingSchedule schedule;
  final DrinkingPattern pattern;
  final GoalType goalType;

  PersonaDefinition({
    required this.name,
    required this.description,
    required this.days,
    required this.schedule,
    required this.pattern,
    required this.goalType,
  });
}

enum DrinkingSchedule {
  fridaysOnly,
  weekendsOnly,
  socialOccasions,
  custom,
}

enum DrinkingPattern {
  none,
  minimal,
  moderate,
  regular,
}
