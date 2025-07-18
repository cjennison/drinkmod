import 'package:uuid/uuid.dart';

/// Types of events that can be tracked in the app
enum AppEventType {
  drinkLogged,          // User logged a drink
  interventionWin,      // User declined to drink when prompted by intervention
  interventionLoss,     // User proceeded to drink despite intervention
  goalCreated,          // User created a new goal
  goalCompleted,        // User completed a goal
  accountCreated,       // User account was created
  mindfulnessSessionStarted,    // User started a mindfulness session
  mindfulnessSessionCompleted,  // User completed a mindfulness session
  urgeSurfingUsed,             // User used urge surfing feature
  reflectionEntryAdded,        // User added a reflection entry
  dailyCheckInCompleted,       // User completed daily check-in
  sosSessionCompleted,         // User completed an SOS session after taking action
}

/// Represents an event that occurred in the app for tracking achievements
class AppEvent {
  final String id;
  final DateTime timestamp;
  final AppEventType type;
  final Map<String, dynamic> metadata;

  AppEvent({
    String? id,
    required this.timestamp,
    required this.type,
    required this.metadata,
  }) : id = id ?? const Uuid().v4();

  /// Create from Hive data
  factory AppEvent.fromHive(Map<String, dynamic> data) {
    return AppEvent(
      id: data['id'] as String,
      timestamp: DateTime.parse(data['timestamp'] as String),
      type: AppEventType.values.firstWhere((e) => e.name == data['type']),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  /// Convert to Hive data
  Map<String, dynamic> toHive() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'metadata': metadata,
    };
  }

  /// Factory methods for common event types

  /// Create a drink logged event
  static AppEvent drinkLogged({
    required DateTime timestamp,
    required String drinkId,
    required String drinkName,
    required double standardDrinks,
    required bool isScheduleCompliant,
    required bool isWithinLimit,
    required bool wasIntervention,
    String? interventionType,
    Map<String, dynamic>? additionalData,
  }) {
    return AppEvent(
      timestamp: timestamp,
      type: AppEventType.drinkLogged,
      metadata: {
        'drinkId': drinkId,
        'drinkName': drinkName,
        'standardDrinks': standardDrinks,
        'isScheduleCompliant': isScheduleCompliant,
        'isWithinLimit': isWithinLimit,
        'wasIntervention': wasIntervention,
        'interventionType': interventionType,
        ...?additionalData,
      },
    );
  }

  /// Create an intervention win event
  static AppEvent interventionWin({
    required DateTime timestamp,
    required String interventionType,
    String? reason,
    Map<String, dynamic>? additionalData,
  }) {
    return AppEvent(
      timestamp: timestamp,
      type: AppEventType.interventionWin,
      metadata: {
        'interventionType': interventionType,
        'reason': reason,
        ...?additionalData,
      },
    );
  }

  /// Create an intervention loss event
  static AppEvent interventionLoss({
    required DateTime timestamp,
    required String interventionType,
    required String drinkId,
    String? reason,
    Map<String, dynamic>? additionalData,
  }) {
    return AppEvent(
      timestamp: timestamp,
      type: AppEventType.interventionLoss,
      metadata: {
        'interventionType': interventionType,
        'drinkId': drinkId,
        'reason': reason,
        ...?additionalData,
      },
    );
  }

  /// Create a goal created event
  static AppEvent goalCreated({
    required DateTime timestamp,
    required String goalId,
    required String goalType,
    Map<String, dynamic>? additionalData,
  }) {
    return AppEvent(
      timestamp: timestamp,
      type: AppEventType.goalCreated,
      metadata: {
        'goalId': goalId,
        'goalType': goalType,
        ...?additionalData,
      },
    );
  }

  /// Create a goal completed event
  static AppEvent goalCompleted({
    required DateTime timestamp,
    required String goalId,
    required String goalType,
    required double finalProgress,
    Map<String, dynamic>? additionalData,
  }) {
    return AppEvent(
      timestamp: timestamp,
      type: AppEventType.goalCompleted,
      metadata: {
        'goalId': goalId,
        'goalType': goalType,
        'finalProgress': finalProgress,
        ...?additionalData,
      },
    );
  }

  /// Create an account created event
  static AppEvent accountCreated({
    required DateTime timestamp,
    Map<String, dynamic>? additionalData,
  }) {
    return AppEvent(
      timestamp: timestamp,
      type: AppEventType.accountCreated,
      metadata: {
        ...?additionalData,
      },
    );
  }

  /// Create a mindfulness session started event
  static AppEvent mindfulnessSessionStarted({
    required DateTime timestamp,
    required String sessionId,
    required String exerciseType,
    String? metaphor,
    int? plannedDurationSeconds,
    Map<String, dynamic>? additionalData,
  }) {
    return AppEvent(
      timestamp: timestamp,
      type: AppEventType.mindfulnessSessionStarted,
      metadata: {
        'sessionId': sessionId,
        'exerciseType': exerciseType,
        'metaphor': metaphor,
        'plannedDurationSeconds': plannedDurationSeconds,
        ...?additionalData,
      },
    );
  }

  /// Create a mindfulness session completed event
  static AppEvent mindfulnessSessionCompleted({
    required DateTime timestamp,
    required String sessionId,
    required String exerciseType,
    required int actualDurationSeconds,
    int? moodImprovement,
    int? urgeReduction,
    Map<String, dynamic>? additionalData,
  }) {
    return AppEvent(
      timestamp: timestamp,
      type: AppEventType.mindfulnessSessionCompleted,
      metadata: {
        'sessionId': sessionId,
        'exerciseType': exerciseType,
        'actualDurationSeconds': actualDurationSeconds,
        'moodImprovement': moodImprovement,
        'urgeReduction': urgeReduction,
        ...?additionalData,
      },
    );
  }

  /// Create an urge surfing used event
  static AppEvent urgeSurfingUsed({
    required DateTime timestamp,
    required String sessionId,
    required String metaphor,
    required int urgeIntensityBefore,
    int? urgeIntensityAfter,
    Map<String, dynamic>? additionalData,
  }) {
    return AppEvent(
      timestamp: timestamp,
      type: AppEventType.urgeSurfingUsed,
      metadata: {
        'sessionId': sessionId,
        'metaphor': metaphor,
        'urgeIntensityBefore': urgeIntensityBefore,
        'urgeIntensityAfter': urgeIntensityAfter,
        ...?additionalData,
      },
    );
  }

  /// Create a reflection entry added event
  static AppEvent reflectionEntryAdded({
    required DateTime timestamp,
    required String entryId,
    required String category,
    required int contentLength,
    Map<String, dynamic>? additionalData,
  }) {
    return AppEvent(
      timestamp: timestamp,
      type: AppEventType.reflectionEntryAdded,
      metadata: {
        'entryId': entryId,
        'category': category,
        'contentLength': contentLength,
        ...?additionalData,
      },
    );
  }

  /// Create a daily check-in completed event
  static AppEvent dailyCheckInCompleted({
    required DateTime timestamp,
    required int checkInLength,
    Map<String, dynamic>? additionalData,
  }) {
    return AppEvent(
      timestamp: timestamp,
      type: AppEventType.dailyCheckInCompleted,
      metadata: {
        'checkInLength': checkInLength,
        ...?additionalData,
      },
    );
  }

  /// Create an SOS session completed event
  static AppEvent sosSessionCompleted({
    required DateTime timestamp,
    required String actionType,
    required int sessionDurationSeconds,
    Map<String, dynamic>? additionalData,
  }) {
    return AppEvent(
      timestamp: timestamp,
      type: AppEventType.sosSessionCompleted,
      metadata: {
        'actionType': actionType,
        'sessionDurationSeconds': sessionDurationSeconds,
        ...?additionalData,
      },
    );
  }
}
