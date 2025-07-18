import 'package:uuid/uuid.dart';

/// Types of mindfulness exercises available
enum MindfulnessExerciseType {
  urgeSurfing,           // Core urge surfing exercises
  bodyScan,              // Body scan meditation
  lovingKindness,        // Self-compassion practice
  quickCheckIn,          // Brief mood check-in
  rainTechnique,         // RAIN emotional processing
  breathingExercise,     // General breathing meditation
}

/// Visual metaphors for urge surfing
enum UrgeSurfingMetaphor {
  wave,                  // Ocean wave visualization
  candle,                // Candle flame visualization
  bubble,                // Soap bubble visualization
}

/// Session completion status
enum SessionStatus {
  started,               // Session began but not completed
  completed,             // Session completed successfully
  interrupted,           // Session interrupted/abandoned
  skipped,               // Session skipped after starting
}

/// Mood rating scale (1-10)
enum MoodRating {
  veryLow(1),
  low(2),
  somewhatLow(3),
  belowAverage(4),
  neutral(5),
  aboveAverage(6),
  good(7),
  veryGood(8),
  excellent(9),
  euphoric(10);

  const MoodRating(this.value);
  final int value;

  static MoodRating fromValue(int value) {
    return MoodRating.values.firstWhere((mood) => mood.value == value);
  }
}

/// Represents a single mindfulness session
class MindfulnessSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final MindfulnessExerciseType exerciseType;
  final UrgeSurfingMetaphor? metaphor; // Only for urge surfing
  final SessionStatus status;
  final int? plannedDurationSeconds;
  final int? actualDurationSeconds;
  final MoodRating? preMood;           // Mood before session
  final MoodRating? postMood;          // Mood after session
  final int? urgeIntensityBefore;      // 1-10 scale for urge surfing
  final int? urgeIntensityAfter;       // 1-10 scale for urge surfing
  final String? notes;                 // User notes about the session
  final Map<String, dynamic> metadata; // Additional session data
  final DateTime createdAt;
  final DateTime updatedAt;

  MindfulnessSession({
    String? id,
    required this.startTime,
    this.endTime,
    required this.exerciseType,
    this.metaphor,
    required this.status,
    this.plannedDurationSeconds,
    this.actualDurationSeconds,
    this.preMood,
    this.postMood,
    this.urgeIntensityBefore,
    this.urgeIntensityAfter,
    this.notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        metadata = metadata ?? {},
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create from Hive data
  factory MindfulnessSession.fromHive(Map<String, dynamic> data) {
    return MindfulnessSession(
      id: data['id'] as String,
      startTime: DateTime.parse(data['startTime'] as String),
      endTime: data['endTime'] != null 
          ? DateTime.parse(data['endTime'] as String) 
          : null,
      exerciseType: MindfulnessExerciseType.values
          .firstWhere((e) => e.name == data['exerciseType']),
      metaphor: data['metaphor'] != null
          ? UrgeSurfingMetaphor.values
              .firstWhere((m) => m.name == data['metaphor'])
          : null,
      status: SessionStatus.values
          .firstWhere((s) => s.name == data['status']),
      plannedDurationSeconds: data['plannedDurationSeconds'] as int?,
      actualDurationSeconds: data['actualDurationSeconds'] as int?,
      preMood: data['preMood'] != null
          ? MoodRating.fromValue(data['preMood'] as int)
          : null,
      postMood: data['postMood'] != null
          ? MoodRating.fromValue(data['postMood'] as int)
          : null,
      urgeIntensityBefore: data['urgeIntensityBefore'] as int?,
      urgeIntensityAfter: data['urgeIntensityAfter'] as int?,
      notes: data['notes'] as String?,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
    );
  }

  /// Convert to Hive data
  Map<String, dynamic> toHive() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'exerciseType': exerciseType.name,
      'metaphor': metaphor?.name,
      'status': status.name,
      'plannedDurationSeconds': plannedDurationSeconds,
      'actualDurationSeconds': actualDurationSeconds,
      'preMood': preMood?.value,
      'postMood': postMood?.value,
      'urgeIntensityBefore': urgeIntensityBefore,
      'urgeIntensityAfter': urgeIntensityAfter,
      'notes': notes,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  MindfulnessSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    MindfulnessExerciseType? exerciseType,
    UrgeSurfingMetaphor? metaphor,
    SessionStatus? status,
    int? plannedDurationSeconds,
    int? actualDurationSeconds,
    MoodRating? preMood,
    MoodRating? postMood,
    int? urgeIntensityBefore,
    int? urgeIntensityAfter,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MindfulnessSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      exerciseType: exerciseType ?? this.exerciseType,
      metaphor: metaphor ?? this.metaphor,
      status: status ?? this.status,
      plannedDurationSeconds: plannedDurationSeconds ?? this.plannedDurationSeconds,
      actualDurationSeconds: actualDurationSeconds ?? this.actualDurationSeconds,
      preMood: preMood ?? this.preMood,
      postMood: postMood ?? this.postMood,
      urgeIntensityBefore: urgeIntensityBefore ?? this.urgeIntensityBefore,
      urgeIntensityAfter: urgeIntensityAfter ?? this.urgeIntensityAfter,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Get actual duration if session is completed
  Duration? get actualDuration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return null;
  }

  /// Get planned duration if set
  Duration? get plannedDuration {
    if (plannedDurationSeconds != null) {
      return Duration(seconds: plannedDurationSeconds!);
    }
    return null;
  }

  /// Check if this was an urge surfing session
  bool get isUrgeSurfing => exerciseType == MindfulnessExerciseType.urgeSurfing;

  /// Calculate mood improvement (post - pre)
  int? get moodImprovement {
    if (preMood != null && postMood != null) {
      return postMood!.value - preMood!.value;
    }
    return null;
  }

  /// Calculate urge intensity reduction
  int? get urgeReduction {
    if (urgeIntensityBefore != null && urgeIntensityAfter != null) {
      return urgeIntensityBefore! - urgeIntensityAfter!;
    }
    return null;
  }

  /// Check if session was completed successfully
  bool get wasCompleted => status == SessionStatus.completed;

  /// Factory methods for creating specific session types

  /// Create an urge surfing session
  static MindfulnessSession createUrgeSurfing({
    required UrgeSurfingMetaphor metaphor,
    required int plannedDurationSeconds,
    int? urgeIntensityBefore,
    MoodRating? preMood,
  }) {
    return MindfulnessSession(
      startTime: DateTime.now(),
      exerciseType: MindfulnessExerciseType.urgeSurfing,
      metaphor: metaphor,
      status: SessionStatus.started,
      plannedDurationSeconds: plannedDurationSeconds,
      urgeIntensityBefore: urgeIntensityBefore,
      preMood: preMood,
    );
  }

  /// Create a general mindfulness session
  static MindfulnessSession createMindfulness({
    required MindfulnessExerciseType exerciseType,
    int? plannedDurationSeconds,
    MoodRating? preMood,
  }) {
    return MindfulnessSession(
      startTime: DateTime.now(),
      exerciseType: exerciseType,
      status: SessionStatus.started,
      plannedDurationSeconds: plannedDurationSeconds,
      preMood: preMood,
    );
  }

  @override
  String toString() {
    return 'MindfulnessSession(id: $id, type: $exerciseType, status: $status, duration: ${actualDuration?.inSeconds ?? 0}s)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MindfulnessSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
