import 'package:uuid/uuid.dart';

/// Enum defining different types of goals users can set
enum GoalType {
  weeklyReduction,      // "Drink X drinks per week over Y months"
  dailyLimit,           // "Stay under X drinks per day for Y weeks"  
  alcoholFreeDays,      // "Have X alcohol-free days per week for Y months"
  interventionWins,     // "Choose not to drink X times over Y weeks"
  moodImprovement,      // "Maintain average mood of X+ for Y weeks"
  streakMaintenance,    // "Maintain adherence streak for X days"
  costSavings,          // "Save $X over Y months through reduced drinking"
  customGoal,           // User-defined goal with custom metrics
}

/// Current status of a goal
enum GoalStatus {
  active,
  completed,
  paused,
  discontinued,
}

/// Types of charts that can be associated with goals
enum ChartType {
  weeklyDrinksTrend,
  adherenceOverTime,
  interventionStats,
  moodCorrelation,
  riskDayAnalysis,
  timeOfDayPattern,
  costSavingsProgress,
  calorieReduction,
  streakVisualization,
}

/// Individual milestone within a goal
class Milestone {
  final String id;
  final String title;
  final String description;
  final double threshold;                // Progress percentage for this milestone (0.0 to 1.0)
  final DateTime? achievedDate;
  final bool isAchieved;

  const Milestone({
    required this.id,
    required this.title,
    required this.description,
    required this.threshold,
    this.achievedDate,
    this.isAchieved = false,
  });

  /// Create from Hive data
  factory Milestone.fromHive(Map<String, dynamic> data) {
    return Milestone(
      id: data['id'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      threshold: (data['threshold'] as num).toDouble(),
      achievedDate: data['achievedDate'] != null 
          ? DateTime.parse(data['achievedDate'] as String) 
          : null,
      isAchieved: data['isAchieved'] as bool? ?? false,
    );
  }

  /// Convert to Hive data
  Map<String, dynamic> toHive() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'threshold': threshold,
      'achievedDate': achievedDate?.toIso8601String(),
      'isAchieved': isAchieved,
    };
  }

  /// Create copy with updated fields
  Milestone copyWith({
    String? id,
    String? title,
    String? description,
    double? threshold,
    DateTime? achievedDate,
    bool? isAchieved,
  }) {
    return Milestone(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      threshold: threshold ?? this.threshold,
      achievedDate: achievedDate ?? this.achievedDate,
      isAchieved: isAchieved ?? this.isAchieved,
    );
  }
}

/// Metrics and progress tracking for a goal
class GoalMetrics {
  final double currentProgress;          // 0.0 to 1.0 (percentage complete)
  final double targetValue;              // The target the user is working toward
  final double currentValue;             // Current measurement
  final String unit;                     // "drinks", "days", "dollars", etc.
  final DateTime lastUpdated;
  final List<Milestone> milestones;      // Progress milestones achieved
  final Map<String, dynamic> metadata;   // Goal-specific tracking data

  const GoalMetrics({
    required this.currentProgress,
    required this.targetValue,
    required this.currentValue,
    required this.unit,
    required this.lastUpdated,
    required this.milestones,
    required this.metadata,
  });

  /// Create from Hive data
  factory GoalMetrics.fromHive(Map<String, dynamic> data) {
    final milestonesData = data['milestones'] as List? ?? [];
    final milestones = milestonesData
        .cast<Map<String, dynamic>>()
        .map((m) => Milestone.fromHive(m))
        .toList();

    return GoalMetrics(
      currentProgress: (data['currentProgress'] as num).toDouble(),
      targetValue: (data['targetValue'] as num).toDouble(),
      currentValue: (data['currentValue'] as num).toDouble(),
      unit: data['unit'] as String,
      lastUpdated: DateTime.parse(data['lastUpdated'] as String),
      milestones: milestones,
      metadata: data['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Convert to Hive data
  Map<String, dynamic> toHive() {
    return {
      'currentProgress': currentProgress,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'unit': unit,
      'lastUpdated': lastUpdated.toIso8601String(),
      'milestones': milestones.map((m) => m.toHive()).toList(),
      'metadata': metadata,
    };
  }

  /// Create copy with updated fields
  GoalMetrics copyWith({
    double? currentProgress,
    double? targetValue,
    double? currentValue,
    String? unit,
    DateTime? lastUpdated,
    List<Milestone>? milestones,
    Map<String, dynamic>? metadata,
  }) {
    return GoalMetrics(
      currentProgress: currentProgress ?? this.currentProgress,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      milestones: milestones ?? this.milestones,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Main goal model for user-defined goals
class UserGoal {
  final String id;
  final GoalType goalType;
  final String title;                    // User-friendly goal name
  final String description;              // Detailed goal description
  final DateTime startDate;              // When goal tracking started
  final DateTime? endDate;               // When goal was completed/discontinued
  final GoalStatus status;               // Active, Completed, Paused, Discontinued
  final Map<String, dynamic> parameters; // Goal-specific parameters
  final List<ChartType> requiredCharts;  // Charts needed for this goal
  final GoalMetrics metrics;             // Current progress metrics
  final DateTime createdAt;
  final DateTime updatedAt;

  UserGoal({
    String? id,
    required this.goalType,
    required this.title,
    required this.description,
    required this.startDate,
    this.endDate,
    this.status = GoalStatus.active,
    required this.parameters,
    required this.requiredCharts,
    required this.metrics,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Create from Hive data
  factory UserGoal.fromHive(Map<String, dynamic> data) {
    final chartsData = data['requiredCharts'] as List? ?? [];
    final charts = chartsData
        .cast<String>()
        .map((c) => ChartType.values.firstWhere((e) => e.name == c))
        .toList();

    return UserGoal(
      id: data['id'] as String,
      goalType: GoalType.values.firstWhere((e) => e.name == data['goalType']),
      title: data['title'] as String,
      description: data['description'] as String,
      startDate: DateTime.parse(data['startDate'] as String),
      endDate: data['endDate'] != null 
          ? DateTime.parse(data['endDate'] as String) 
          : null,
      status: GoalStatus.values.firstWhere((e) => e.name == data['status']),
      parameters: data['parameters'] as Map<String, dynamic>? ?? {},
      requiredCharts: charts,
      metrics: GoalMetrics.fromHive(data['metrics'] as Map<String, dynamic>),
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
    );
  }

  /// Convert to Hive data
  Map<String, dynamic> toHive() {
    return {
      'id': id,
      'goalType': goalType.name,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status.name,
      'parameters': parameters,
      'requiredCharts': requiredCharts.map((c) => c.name).toList(),
      'metrics': metrics.toHive(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create copy with updated fields
  UserGoal copyWith({
    String? id,
    GoalType? goalType,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    GoalStatus? status,
    Map<String, dynamic>? parameters,
    List<ChartType>? requiredCharts,
    GoalMetrics? metrics,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserGoal(
      id: id ?? this.id,
      goalType: goalType ?? this.goalType,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      parameters: parameters ?? this.parameters,
      requiredCharts: requiredCharts ?? this.requiredCharts,
      metrics: metrics ?? this.metrics,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Check if goal is currently active
  bool get isActive => status == GoalStatus.active;

  /// Check if goal is completed
  bool get isCompleted => status == GoalStatus.completed;

  /// Get progress percentage as a formatted string
  String get progressText {
    final percentage = (metrics.currentProgress * 100).round();
    return '$percentage%';
  }
}
