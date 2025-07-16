import 'package:uuid/uuid.dart';
import 'intervention_data.dart';

/// Enhanced drink entry model with therapeutic data capture
class DrinkEntry {
  // Core data
  final String id;
  final DateTime timestamp; // When the entry was created (for daily tracking)
  final String timeOfDay; // Morning, Noon, Afternoon, Evening, Night (when the drink was consumed)
  final String drinkId; // References FavoriteDrink or common drink
  final String drinkName;
  final double standardDrinks; // Calculated amount (beer=1, cocktail=2)
  
  // Context data
  final String? location; // Home, Work, Bar, Restaurant, Social Event, Other
  final String? socialContext; // Alone, Partner, Close Friends, Family, Acquaintances, Strangers
  
  // Emotional & psychological data
  final int? moodBefore; // 1-10 scale
  final int? moodAfter; // 1-10 scale (post-drink reflection)
  final List<String>? triggers; // Stress, Anxiety, Boredom, Celebration, Social Pressure, Habit
  final int? urgeIntensity; // 1-10 scale: How strong was the urge?
  
  // Therapeutic reflection
  final String? intention; // What's your plan for this session?
  final String? triggerDescription; // Free text: What led to this drink?
  final bool? consideredAlternatives; // Did you consider alternatives?
  final String? alternatives; // What alternatives did you consider?
  
  // Physical state
  final int? energyLevel; // 1-10 scale
  final int? hungerLevel; // 1-10 scale
  final int? stressLevel; // 1-10 scale
  final String? sleepQuality; // Poor, Fair, Good, Excellent (previous night)
  
  // Post-drink reflection (optional)
  final int? satisfactionLevel; // 1-10: How satisfied do you feel?
  final int? regretPrideScale; // 1-10: How do you feel about this choice? (1=regret, 10=pride)
  final String? physicalEffects; // How does your body feel?
  final String? nextIntention; // What's your plan for the rest of the session?
  
  // System calculated
  final bool isWithinLimit; // Calculated field
  final bool isScheduleCompliant; // Was this a scheduled drinking day?
  final InterventionData? interventionData; // Intervention tracking data
  final Map<String, dynamic>? metadata; // Extensible therapeutic data

  DrinkEntry({
    String? id,
    DateTime? timestamp,
    required this.timeOfDay,
    required this.drinkId,
    required this.drinkName,
    required this.standardDrinks,
    this.location,
    this.socialContext,
    this.moodBefore,
    this.moodAfter,
    this.triggers,
    this.urgeIntensity,
    this.intention,
    this.triggerDescription,
    this.consideredAlternatives,
    this.alternatives,
    this.energyLevel,
    this.hungerLevel,
    this.stressLevel,
    this.sleepQuality,
    this.satisfactionLevel,
    this.regretPrideScale,
    this.physicalEffects,
    this.nextIntention,
    required this.isWithinLimit,
    required this.isScheduleCompliant,
    this.interventionData,
    this.metadata,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();

  /// Create from existing Hive data
  factory DrinkEntry.fromHive(Map<String, dynamic> data) {
    return DrinkEntry(
      id: data['id'] as String,
      timestamp: data['drinkDate'] != null 
          ? DateTime.parse(data['drinkDate'] as String)
          : DateTime.now(),
      timeOfDay: data['timeOfDay'] as String? ?? 'Afternoon', // Default fallback
      drinkId: data['drinkId'] as String? ?? data['drinkName'] as String,
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
      interventionData: data['interventionData'] != null 
          ? InterventionData.fromHive(data['interventionData'] as Map<String, dynamic>)
          : null,
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to Hive-compatible map
  Map<String, dynamic> toHive() {
    return {
      'id': id,
      'drinkDate': timestamp.toIso8601String(),
      'timeOfDay': timeOfDay,
      'drinkId': drinkId,
      'drinkName': drinkName,
      'standardDrinks': standardDrinks,
      'drinkType': 'logged', // For compatibility with existing system
      'location': location,
      'socialContext': socialContext,
      'moodBefore': moodBefore,
      'moodAfter': moodAfter,
      'triggers': triggers,
      'urgeIntensity': urgeIntensity,
      'intention': intention,
      'triggerDescription': triggerDescription,
      'consideredAlternatives': consideredAlternatives,
      'alternatives': alternatives,
      'energyLevel': energyLevel,
      'hungerLevel': hungerLevel,
      'stressLevel': stressLevel,
      'sleepQuality': sleepQuality,
      'satisfactionLevel': satisfactionLevel,
      'regretPrideScale': regretPrideScale,
      'physicalEffects': physicalEffects,
      'nextIntention': nextIntention,
      'isWithinLimit': isWithinLimit,
      'isScheduleCompliant': isScheduleCompliant,
      'interventionData': interventionData?.toHive(),
      'metadata': metadata,
      // Legacy fields for backward compatibility
      'reason': triggerDescription,
      'notes': intention,
    };
  }

  /// Create copy with updated fields
  DrinkEntry copyWith({
    String? id,
    DateTime? timestamp,
    String? timeOfDay,
    String? drinkId,
    String? drinkName,
    double? standardDrinks,
    String? location,
    String? socialContext,
    int? moodBefore,
    int? moodAfter,
    List<String>? triggers,
    int? urgeIntensity,
    String? intention,
    String? triggerDescription,
    bool? consideredAlternatives,
    String? alternatives,
    int? energyLevel,
    int? hungerLevel,
    int? stressLevel,
    String? sleepQuality,
    int? satisfactionLevel,
    int? regretPrideScale,
    String? physicalEffects,
    String? nextIntention,
    bool? isWithinLimit,
    bool? isScheduleCompliant,
    InterventionData? interventionData,
    Map<String, dynamic>? metadata,
  }) {
    return DrinkEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      drinkId: drinkId ?? this.drinkId,
      drinkName: drinkName ?? this.drinkName,
      standardDrinks: standardDrinks ?? this.standardDrinks,
      location: location ?? this.location,
      socialContext: socialContext ?? this.socialContext,
      moodBefore: moodBefore ?? this.moodBefore,
      moodAfter: moodAfter ?? this.moodAfter,
      triggers: triggers ?? this.triggers,
      urgeIntensity: urgeIntensity ?? this.urgeIntensity,
      intention: intention ?? this.intention,
      triggerDescription: triggerDescription ?? this.triggerDescription,
      consideredAlternatives: consideredAlternatives ?? this.consideredAlternatives,
      alternatives: alternatives ?? this.alternatives,
      energyLevel: energyLevel ?? this.energyLevel,
      hungerLevel: hungerLevel ?? this.hungerLevel,
      stressLevel: stressLevel ?? this.stressLevel,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      satisfactionLevel: satisfactionLevel ?? this.satisfactionLevel,
      regretPrideScale: regretPrideScale ?? this.regretPrideScale,
      physicalEffects: physicalEffects ?? this.physicalEffects,
      nextIntention: nextIntention ?? this.nextIntention,
      isWithinLimit: isWithinLimit ?? this.isWithinLimit,
      isScheduleCompliant: isScheduleCompliant ?? this.isScheduleCompliant,
      interventionData: interventionData ?? this.interventionData,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'DrinkEntry(id: $id, drink: $drinkName, standardDrinks: $standardDrinks, timeOfDay: $timeOfDay, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DrinkEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Trigger pattern tracking for analytics
class TriggerPattern {
  final String triggerId;
  final String category; // Emotional, Social, Environmental, Physical, Temporal
  final String specificTrigger; // Stress, Boredom, Social pressure, Celebration, etc.
  final int frequency; // How often this trigger leads to drinking
  final double averageIntensity; // Average urge intensity for this trigger
  final List<String> effectiveStrategies; // What alternatives worked?
  final DateTime lastOccurrence;
  final bool isActive; // Is this currently a concerning pattern?

  TriggerPattern({
    required this.triggerId,
    required this.category,
    required this.specificTrigger,
    required this.frequency,
    required this.averageIntensity,
    required this.effectiveStrategies,
    required this.lastOccurrence,
    required this.isActive,
  });

  factory TriggerPattern.fromHive(Map<String, dynamic> data) {
    return TriggerPattern(
      triggerId: data['triggerId'] as String,
      category: data['category'] as String,
      specificTrigger: data['specificTrigger'] as String,
      frequency: data['frequency'] as int,
      averageIntensity: (data['averageIntensity'] as num).toDouble(),
      effectiveStrategies: (data['effectiveStrategies'] as List).cast<String>(),
      lastOccurrence: DateTime.parse(data['lastOccurrence'] as String),
      isActive: data['isActive'] as bool,
    );
  }

  Map<String, dynamic> toHive() {
    return {
      'triggerId': triggerId,
      'category': category,
      'specificTrigger': specificTrigger,
      'frequency': frequency,
      'averageIntensity': averageIntensity,
      'effectiveStrategies': effectiveStrategies,
      'lastOccurrence': lastOccurrence.toIso8601String(),
      'isActive': isActive,
    };
  }
}

/// Daily reflection summary
class DayReflection {
  final String id;
  final DateTime date;
  final int? overallMood; // End of day mood assessment
  final int? adherenceFeeling; // How do you feel about today's choices? (1-10)
  final String? dailyWin; // What went well today?
  final String? challengesFaced; // What was difficult?
  final String? tomorrowIntention; // What's your plan for tomorrow?
  final List<String>? gratitude; // 3 things you're grateful for
  final bool completedReflection; // Did user complete end-of-day reflection?

  DayReflection({
    String? id,
    required this.date,
    this.overallMood,
    this.adherenceFeeling,
    this.dailyWin,
    this.challengesFaced,
    this.tomorrowIntention,
    this.gratitude,
    required this.completedReflection,
  }) : id = id ?? const Uuid().v4();

  factory DayReflection.fromHive(Map<String, dynamic> data) {
    return DayReflection(
      id: data['id'] as String,
      date: DateTime.parse(data['date'] as String),
      overallMood: data['overallMood'] as int?,
      adherenceFeeling: data['adherenceFeeling'] as int?,
      dailyWin: data['dailyWin'] as String?,
      challengesFaced: data['challengesFaced'] as String?,
      tomorrowIntention: data['tomorrowIntention'] as String?,
      gratitude: (data['gratitude'] as List?)?.cast<String>(),
      completedReflection: data['completedReflection'] as bool,
    );
  }

  Map<String, dynamic> toHive() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'overallMood': overallMood,
      'adherenceFeeling': adherenceFeeling,
      'dailyWin': dailyWin,
      'challengesFaced': challengesFaced,
      'tomorrowIntention': tomorrowIntention,
      'gratitude': gratitude,
      'completedReflection': completedReflection,
    };
  }
}

/// Predefined trigger categories and options
class TriggerConstants {
  static const List<String> categories = [
    'Emotional',
    'Social', 
    'Environmental',
    'Physical',
    'Temporal',
  ];

  static const Map<String, List<String>> triggersByCategory = {
    'Emotional': [
      'Stress',
      'Anxiety',
      'Boredom',
      'Sadness',
      'Anger',
      'Loneliness',
      'Celebration',
      'Excitement',
      'Frustration',
    ],
    'Social': [
      'Peer pressure',
      'Social anxiety',
      'FOMO',
      'Social celebration',
      'Work events',
      'Dating',
      'Family stress',
      'Conflict',
    ],
    'Environmental': [
      'Bar/restaurant',
      'Home alone',
      'Party/event',
      'Work stress',
      'Travel',
      'Specific locations',
      'Weather',
      'Music/media',
    ],
    'Physical': [
      'Fatigue',
      'Hunger',
      'Pain',
      'Insomnia',
      'Hormonal changes',
      'Withdrawal',
      'Physical discomfort',
    ],
    'Temporal': [
      'End of workday',
      'Weekends',
      'Holidays',
      'Special occasions',
      'Time of day habit',
      'Seasonal patterns',
    ],
  };

  static const List<String> locations = [
    'Home',
    'Work',
    'Bar',
    'Restaurant',
    'Social Event',
    'Friend\'s place',
    'Travel',
    'Other',
  ];

  static const List<String> socialContexts = [
    'Alone',
    'Partner',
    'Close Friends',
    'Family',
    'Acquaintances',
    'Strangers',
    'Work colleagues',
  ];

  static const List<String> sleepQualityOptions = [
    'Poor',
    'Fair',
    'Good',
    'Excellent',
  ];

  static const List<String> commonAlternatives = [
    'Exercise',
    'Call someone',
    'Take a walk',
    'Deep breathing',
    'Listen to music',
    'Read a book',
    'Take a bath',
    'Meditation',
    'Hobby activity',
    'Watch something',
    'Cook/eat',
    'Go to bed early',
  ];

  static const List<String> timeOfDayOptions = [
    'Morning',
    'Noon', 
    'Afternoon',
    'Evening',
    'Night',
  ];

  /// Convert time of day string to approximate DateTime
  static DateTime convertTimeOfDayToDateTime(String timeOfDay, DateTime date) {
    final baseDate = DateTime(date.year, date.month, date.day);
    
    switch (timeOfDay) {
      case 'Morning':
        return baseDate.add(const Duration(hours: 8)); // 8 AM
      case 'Noon':
        return baseDate.add(const Duration(hours: 12)); // 12 PM
      case 'Afternoon':
        return baseDate.add(const Duration(hours: 15)); // 3 PM
      case 'Evening':
        return baseDate.add(const Duration(hours: 18)); // 6 PM
      case 'Night':
        return baseDate.add(const Duration(hours: 21)); // 9 PM
      default:
        return baseDate.add(const Duration(hours: 12)); // Default to noon
    }
  }

  /// Convert DateTime to time of day string
  static String convertDateTimeToTimeOfDay(DateTime dateTime) {
    final hour = dateTime.hour;
    
    if (hour >= 5 && hour < 11) {
      return 'Morning';
    } else if (hour >= 11 && hour < 13) {
      return 'Noon';
    } else if (hour >= 13 && hour < 17) {
      return 'Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Evening';
    } else {
      return 'Night';
    }
  }
}
