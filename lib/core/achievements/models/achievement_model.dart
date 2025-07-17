import 'package:flutter/material.dart';

/// Core achievement model with all necessary metadata
class Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final AchievementCategory category;
  final int? chainPosition; // For progressive achievements (1 day, 3 days, etc.)
  final List<String> prerequisites; // Other achievement IDs required first
  
  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
    this.chainPosition,
    this.prerequisites = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category.toString(),
    'chainPosition': chainPosition,
    'prerequisites': prerequisites,
  };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    icon: Icons.star, // Default, will be resolved by registry
    color: Colors.blue, // Default, will be resolved by registry
    category: AchievementCategory.values.firstWhere(
      (cat) => cat.toString() == json['category'],
      orElse: () => AchievementCategory.general,
    ),
    chainPosition: json['chainPosition'],
    prerequisites: List<String>.from(json['prerequisites'] ?? []),
  );
}

/// Granted achievement instance with user-specific data
class GrantedAchievement {
  final String id;
  final Achievement achievement;
  final DateTime grantedAt;
  final Map<String, dynamic> metadata;

  const GrantedAchievement({
    required this.id,
    required this.achievement,
    required this.grantedAt,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'achievementId': achievement.id,
    'grantedAt': grantedAt.toIso8601String(),
    'metadata': metadata,
  };

  factory GrantedAchievement.fromJson(Map<String, dynamic> json, Achievement achievement) => GrantedAchievement(
    id: json['id'],
    achievement: achievement,
    grantedAt: DateTime.parse(json['grantedAt']),
    metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
  );
}

/// Categories for organizing achievements
enum AchievementCategory {
  account,
  goals,
  streaks,
  milestones,
  special,
  general,
}

/// Assessment result with context
class AssessmentResult {
  final bool shouldGrant;
  final Map<String, dynamic> context;
  final String? reason;

  const AssessmentResult({
    required this.shouldGrant,
    this.context = const {},
    this.reason,
  });

  const AssessmentResult.grant({this.context = const {}, this.reason}) : shouldGrant = true;
  const AssessmentResult.skip({this.context = const {}, this.reason}) : shouldGrant = false;
}
