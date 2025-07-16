/// Intervention data model for tracking drinks logged through intervention
class InterventionData {
  final String interventionType; // Schedule violation, limit exceeded, etc.
  final String userMessage; // Message displayed during intervention
  final int? currentMood; // 1-10 mood scale at intervention
  final String? selectedReason; // Reason for proceeding despite intervention
  final bool hasReflected; // Whether user confirmed reflection
  final DateTime interventionTimestamp; // When intervention occurred
  final Map<String, dynamic>? additionalData; // Extensible intervention context

  InterventionData({
    required this.interventionType,
    required this.userMessage,
    this.currentMood,
    this.selectedReason,
    this.hasReflected = false,
    DateTime? interventionTimestamp,
    this.additionalData,
  }) : interventionTimestamp = interventionTimestamp ?? DateTime.now();

  /// Create from Hive data
  factory InterventionData.fromHive(Map<String, dynamic> data) {
    return InterventionData(
      interventionType: data['interventionType'] as String,
      userMessage: data['userMessage'] as String,
      currentMood: data['currentMood'] as int?,
      selectedReason: data['selectedReason'] as String?,
      hasReflected: data['hasReflected'] as bool? ?? false,
      interventionTimestamp: DateTime.parse(data['interventionTimestamp'] as String),
      additionalData: data['additionalData'] as Map<String, dynamic>?,
    );
  }

  /// Convert to Hive data
  Map<String, dynamic> toHive() {
    return {
      'interventionType': interventionType,
      'userMessage': userMessage,
      'currentMood': currentMood,
      'selectedReason': selectedReason,
      'hasReflected': hasReflected,
      'interventionTimestamp': interventionTimestamp.toIso8601String(),
      'additionalData': additionalData,
    };
  }

  /// Create copy with updated fields
  InterventionData copyWith({
    String? interventionType,
    String? userMessage,
    int? currentMood,
    String? selectedReason,
    bool? hasReflected,
    DateTime? interventionTimestamp,
    Map<String, dynamic>? additionalData,
  }) {
    return InterventionData(
      interventionType: interventionType ?? this.interventionType,
      userMessage: userMessage ?? this.userMessage,
      currentMood: currentMood ?? this.currentMood,
      selectedReason: selectedReason ?? this.selectedReason,
      hasReflected: hasReflected ?? this.hasReflected,
      interventionTimestamp: interventionTimestamp ?? this.interventionTimestamp,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  /// Get user-friendly intervention description
  String get interventionDescription {
    switch (interventionType) {
      case 'schedule_violation':
        return 'Alcohol-free day intervention';
      case 'limit_exceeded':
        return 'Daily limit intervention';
      case 'approaching_limit':
        return 'Approaching limit intervention';
      case 'tolerance_exceeded':
        return 'Tolerance exceeded intervention';
      default:
        return 'Therapeutic intervention';
    }
  }

  /// Get appropriate icon for intervention type
  String get interventionIcon {
    switch (interventionType) {
      case 'schedule_violation':
        return 'calendar_today';
      case 'limit_exceeded':
        return 'warning';
      case 'approaching_limit':
        return 'warning_amber';
      case 'tolerance_exceeded':
        return 'cancel';
      default:
        return 'info';
    }
  }
}
