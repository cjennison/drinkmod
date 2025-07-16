import 'package:uuid/uuid.dart';

/// Type of intervention that occurred
enum InterventionType {
  scheduleViolation,    // Alcohol-free day violation
  limitExceeded,        // Daily limit exceeded
  approachingLimit,     // Approaching daily limit
  toleranceExceeded,    // Beyond tolerance threshold
  retroactiveEntry,     // Retroactive logging intervention
}

/// User's decision during intervention
enum InterventionDecision {
  proceeded,     // User chose to drink despite intervention
  declined,      // User chose NOT to drink (intervention win)
}

/// Model for tracking intervention events and outcomes
class InterventionEvent {
  final String id;
  final DateTime timestamp;
  final InterventionType type;
  final InterventionDecision decision;    // Proceeded or Declined
  final String? reason;                   // User's reason for decision
  final int? moodAtTime;                  // Mood during intervention (1-10 scale)
  final Map<String, dynamic>? context;   // Additional context data

  InterventionEvent({
    String? id,
    required this.timestamp,
    required this.type,
    required this.decision,
    this.reason,
    this.moodAtTime,
    this.context,
  }) : id = id ?? const Uuid().v4();

  /// Create from Hive data
  factory InterventionEvent.fromHive(Map<String, dynamic> data) {
    return InterventionEvent(
      id: data['id'] as String,
      timestamp: DateTime.parse(data['timestamp'] as String),
      type: InterventionType.values.firstWhere((e) => e.name == data['type']),
      decision: InterventionDecision.values.firstWhere((e) => e.name == data['decision']),
      reason: data['reason'] as String?,
      moodAtTime: data['moodAtTime'] as int?,
      context: data['context'] as Map<String, dynamic>?,
    );
  }

  /// Convert to Hive data
  Map<String, dynamic> toHive() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'decision': decision.name,
      'reason': reason,
      'moodAtTime': moodAtTime,
      'context': context,
    };
  }

  /// Create copy with updated fields
  InterventionEvent copyWith({
    String? id,
    DateTime? timestamp,
    InterventionType? type,
    InterventionDecision? decision,
    String? reason,
    int? moodAtTime,
    Map<String, dynamic>? context,
  }) {
    return InterventionEvent(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      decision: decision ?? this.decision,
      reason: reason ?? this.reason,
      moodAtTime: moodAtTime ?? this.moodAtTime,
      context: context ?? this.context,
    );
  }

  /// Check if this was a successful intervention (user chose not to drink)
  bool get isSuccess => decision == InterventionDecision.declined;

  /// Get user-friendly description of intervention type
  String get typeDescription {
    switch (type) {
      case InterventionType.scheduleViolation:
        return 'Alcohol-free day';
      case InterventionType.limitExceeded:
        return 'Daily limit exceeded';
      case InterventionType.approachingLimit:
        return 'Approaching limit';
      case InterventionType.toleranceExceeded:
        return 'Tolerance exceeded';
      case InterventionType.retroactiveEntry:
        return 'Retroactive entry';
    }
  }

  /// Get user-friendly description of decision
  String get decisionDescription {
    switch (decision) {
      case InterventionDecision.proceeded:
        return 'Proceeded with drink';
      case InterventionDecision.declined:
        return 'Chose not to drink';
    }
  }
}
