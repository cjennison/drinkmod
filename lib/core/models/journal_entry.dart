import 'package:uuid/uuid.dart';

/// Represents a daily journal/reflection entry
class JournalEntry {
  final String id;
  final DateTime date; // Date only (no time component for daily entries)
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // Mood tracking
  final MoodLevel? overallMood;
  final int? anxietyLevel; // 1-10 scale
  final int? stressLevel; // 1-10 scale  
  final int? energyLevel; // 1-10 scale  // Reflection content
  final String? gratitudeEntry;
  final String? challengesEntry;
  final String? accomplishmentsEntry;
  final String? emotionsEntry;
  final String? triggersEntry;
  final String? copingStrategiesEntry;
  final String? tomorrowGoalsEntry;
  final String? freeformEntry;
  
  // Tags and categories
  final List<String> emotionTags;
  final List<String> activityTags;
  final List<String> triggerTags;
  
  // Drinking-related (optional)
  final bool? hadUrges;
  final int? urgeIntensity; // 1-10 scale
  final String? urgeNotes;
  final bool? usedCopingStrategies;
  final List<String> copingStrategiesUsed;
  
  // Completion tracking
  final bool isComplete;
  final double completionPercentage;
  final List<JournalSection> completedSections;

  JournalEntry({
    String? id,
    required this.date,
    DateTime? createdAt,
    this.updatedAt,
    this.overallMood,
    this.anxietyLevel,
    this.stressLevel,
    this.energyLevel,
    this.gratitudeEntry,
    this.challengesEntry,
    this.accomplishmentsEntry,
    this.emotionsEntry,
    this.triggersEntry,
    this.copingStrategiesEntry,
    this.tomorrowGoalsEntry,
    this.freeformEntry,
    this.emotionTags = const [],
    this.activityTags = const [],
    this.triggerTags = const [],
    this.hadUrges,
    this.urgeIntensity,
    this.urgeNotes,
    this.usedCopingStrategies,
    this.copingStrategiesUsed = const [],
    this.isComplete = false,
    this.completionPercentage = 0.0,
    this.completedSections = const [],
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  /// Create a copy with updated fields
  JournalEntry copyWith({
    DateTime? date,
    DateTime? updatedAt,
    MoodLevel? overallMood,
    int? anxietyLevel,
    int? stressLevel,
    int? energyLevel,
    String? gratitudeEntry,
    String? challengesEntry,
    String? accomplishmentsEntry,
    String? emotionsEntry,
    String? triggersEntry,
    String? copingStrategiesEntry,
    String? tomorrowGoalsEntry,
    String? freeformEntry,
    List<String>? emotionTags,
    List<String>? activityTags,
    List<String>? triggerTags,
    bool? hadUrges,
    int? urgeIntensity,
    String? urgeNotes,
    bool? usedCopingStrategies,
    List<String>? copingStrategiesUsed,
    bool? isComplete,
    double? completionPercentage,
    List<JournalSection>? completedSections,
  }) {
    return JournalEntry(
      id: id,
      date: date ?? this.date,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      overallMood: overallMood ?? this.overallMood,
      anxietyLevel: anxietyLevel ?? this.anxietyLevel,
      stressLevel: stressLevel ?? this.stressLevel,
      energyLevel: energyLevel ?? this.energyLevel,
      gratitudeEntry: gratitudeEntry ?? this.gratitudeEntry,
      challengesEntry: challengesEntry ?? this.challengesEntry,
      accomplishmentsEntry: accomplishmentsEntry ?? this.accomplishmentsEntry,
      emotionsEntry: emotionsEntry ?? this.emotionsEntry,
      triggersEntry: triggersEntry ?? this.triggersEntry,
      copingStrategiesEntry: copingStrategiesEntry ?? this.copingStrategiesEntry,
      tomorrowGoalsEntry: tomorrowGoalsEntry ?? this.tomorrowGoalsEntry,
      freeformEntry: freeformEntry ?? this.freeformEntry,
      emotionTags: emotionTags ?? this.emotionTags,
      activityTags: activityTags ?? this.activityTags,
      triggerTags: triggerTags ?? this.triggerTags,
      hadUrges: hadUrges ?? this.hadUrges,
      urgeIntensity: urgeIntensity ?? this.urgeIntensity,
      urgeNotes: urgeNotes ?? this.urgeNotes,
      usedCopingStrategies: usedCopingStrategies ?? this.usedCopingStrategies,
      copingStrategiesUsed: copingStrategiesUsed ?? this.copingStrategiesUsed,
      isComplete: isComplete ?? this.isComplete,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      completedSections: completedSections ?? this.completedSections,
    );
  }

  /// Convert to/from storage format
  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      overallMood: json['overallMood'] != null 
          ? MoodLevel.values.firstWhere((e) => e.name == json['overallMood'])
          : null,
      anxietyLevel: json['anxietyLevel'] as int?,
      stressLevel: json['stressLevel'] as int?,
      energyLevel: json['energyLevel'] as int?,
      gratitudeEntry: json['gratitudeEntry'] as String?,
      challengesEntry: json['challengesEntry'] as String?,
      accomplishmentsEntry: json['accomplishmentsEntry'] as String?,
      emotionsEntry: json['emotionsEntry'] as String?,
      triggersEntry: json['triggersEntry'] as String?,
      copingStrategiesEntry: json['copingStrategiesEntry'] as String?,
      tomorrowGoalsEntry: json['tomorrowGoalsEntry'] as String?,
      freeformEntry: json['freeformEntry'] as String?,
      emotionTags: List<String>.from(json['emotionTags'] ?? []),
      activityTags: List<String>.from(json['activityTags'] ?? []),
      triggerTags: List<String>.from(json['triggerTags'] ?? []),
      hadUrges: json['hadUrges'] as bool?,
      urgeIntensity: json['urgeIntensity'] as int?,
      urgeNotes: json['urgeNotes'] as String?,
      usedCopingStrategies: json['usedCopingStrategies'] as bool?,
      copingStrategiesUsed: List<String>.from(json['copingStrategiesUsed'] ?? []),
      isComplete: json['isComplete'] as bool? ?? false,
      completionPercentage: (json['completionPercentage'] as num?)?.toDouble() ?? 0.0,
      completedSections: (json['completedSections'] as List?)
          ?.map((e) => JournalSection.values.firstWhere((s) => s.name == e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'overallMood': overallMood?.name,
      'anxietyLevel': anxietyLevel,
      'stressLevel': stressLevel,
      'energyLevel': energyLevel,
      'gratitudeEntry': gratitudeEntry,
      'challengesEntry': challengesEntry,
      'accomplishmentsEntry': accomplishmentsEntry,
      'emotionsEntry': emotionsEntry,
      'triggersEntry': triggersEntry,
      'copingStrategiesEntry': copingStrategiesEntry,
      'tomorrowGoalsEntry': tomorrowGoalsEntry,
      'freeformEntry': freeformEntry,
      'emotionTags': emotionTags,
      'activityTags': activityTags,
      'triggerTags': triggerTags,
      'hadUrges': hadUrges,
      'urgeIntensity': urgeIntensity,
      'urgeNotes': urgeNotes,
      'usedCopingStrategies': usedCopingStrategies,
      'copingStrategiesUsed': copingStrategiesUsed,
      'isComplete': isComplete,
      'completionPercentage': completionPercentage,
      'completedSections': completedSections.map((e) => e.name).toList(),
    };
  }

  /// Calculate completion percentage based on filled sections
  static double calculateCompletionPercentage(JournalEntry entry) {
    int totalSections = JournalSection.values.length;
    int completedCount = 0;

    // Check mood tracking
    if (entry.overallMood != null) completedCount++;
    if (entry.anxietyLevel != null || entry.stressLevel != null || 
        entry.energyLevel != null) completedCount++;
    
    // Check text entries
    if (entry.gratitudeEntry?.isNotEmpty == true) completedCount++;
    if (entry.challengesEntry?.isNotEmpty == true) completedCount++;
    if (entry.accomplishmentsEntry?.isNotEmpty == true) completedCount++;
    if (entry.emotionsEntry?.isNotEmpty == true) completedCount++;
    if (entry.freeformEntry?.isNotEmpty == true) completedCount++;

    return completedCount / totalSections;
  }
}

/// Mood levels for tracking
enum MoodLevel {
  veryLow(1, 'Very Low', '😞'),
  low(2, 'Low', '😔'),
  neutral(3, 'Neutral', '😐'),
  good(4, 'Good', '🙂'),
  veryGood(5, 'Very Good', '😊');

  const MoodLevel(this.value, this.label, this.emoji);
  
  final int value;
  final String label;
  final String emoji;
}

/// Journal sections for completion tracking
enum JournalSection {
  mood('Overall Mood'),
  scales('Mood Scales'),
  gratitude('Gratitude'),
  challenges('Challenges'),
  accomplishments('Accomplishments'),
  emotions('Emotions'),
  freeform('Free Writing');

  const JournalSection(this.label);
  final String label;
}

/// Predefined emotion tags
class EmotionTags {
  static const List<String> positive = [
    'Happy', 'Grateful', 'Excited', 'Calm', 'Confident', 'Hopeful', 
    'Proud', 'Peaceful', 'Joyful', 'Content', 'Energized', 'Inspired'
  ];
  
  static const List<String> negative = [
    'Anxious', 'Sad', 'Frustrated', 'Angry', 'Overwhelmed', 'Lonely',
    'Disappointed', 'Worried', 'Stressed', 'Irritated', 'Confused', 'Tired'
  ];
  
  static const List<String> neutral = [
    'Reflective', 'Curious', 'Focused', 'Thoughtful', 'Determined', 'Aware'
  ];
  
  static List<String> get all => [...positive, ...negative, ...neutral];
}

/// Activity tags for tracking daily activities
class ActivityTags {
  static const List<String> wellness = [
    'Exercise', 'Meditation', 'Reading', 'Journaling', 'Therapy', 'Sleep',
    'Healthy Eating', 'Nature Walk', 'Yoga', 'Breathing Exercises'
  ];
  
  static const List<String> social = [
    'Family Time', 'Friends', 'Support Group', 'Volunteering', 'Dating',
    'Networking', 'Community Event'
  ];
  
  static const List<String> work = [
    'Work', 'Meeting', 'Project', 'Learning', 'Presentation', 'Planning'
  ];
  
  static const List<String> leisure = [
    'Hobbies', 'Gaming', 'Movies', 'Music', 'Art', 'Cooking', 'Travel'
  ];
  
  static List<String> get all => [...wellness, ...social, ...work, ...leisure];
}

/// Trigger tags for identifying challenging situations
class TriggerTags {
  static const List<String> emotional = [
    'Stress', 'Anxiety', 'Loneliness', 'Boredom', 'Sadness', 'Anger',
    'Fear', 'Rejection', 'Criticism', 'Guilt', 'Shame'
  ];
  
  static const List<String> social = [
    'Social Pressure', 'Conflict', 'Isolation', 'FOMO', 'Comparison',
    'Judgment', 'Peer Pressure'
  ];
  
  static const List<String> environmental = [
    'Work Stress', 'Financial Pressure', 'Health Issues', 'Weather',
    'Noise', 'Crowds', 'Technology'
  ];
  
  static List<String> get all => [...emotional, ...social, ...environmental];
}
