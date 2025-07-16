import 'dart:developer' as developer;
import 'hive_core.dart';

/// Service for managing user achievements and milestones
class AchievementsService {
  static AchievementsService? _instance;
  static AchievementsService get instance => _instance ??= AchievementsService._();
  
  AchievementsService._();
  
  final HiveCore _hiveCore = HiveCore.instance;

  /// Add a new achievement to the user's record
  Future<String> addAchievement({
    required AchievementType type,
    required String title,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    await _hiveCore.ensureInitialized();
    
    final achievementId = 'achievement_${DateTime.now().millisecondsSinceEpoch}';
    final achievement = {
      'id': achievementId,
      'type': type.toString(),
      'title': title,
      'description': description,
      'earnedAt': DateTime.now().toIso8601String(),
      'metadata': metadata ?? {},
    };
    
    await _hiveCore.achievementsBox.put(achievementId, achievement);
    developer.log('Achievement added: $title', name: 'AchievementsService');
    
    return achievementId;
  }

  /// Get all achievements, optionally filtered by type
  List<Map<String, dynamic>> getAllAchievements({AchievementType? type}) {
    if (!_hiveCore.isInitialized) return [];
    
    final achievements = _hiveCore.achievementsBox.values
        .map((achievement) => Map<String, dynamic>.from(achievement))
        .toList();
    
    if (type != null) {
      return achievements.where((achievement) => 
        achievement['type'] == type.toString()).toList();
    }
    
    // Sort by earned date (most recent first)
    achievements.sort((a, b) => 
      DateTime.parse(b['earnedAt']).compareTo(DateTime.parse(a['earnedAt'])));
    
    return achievements;
  }

  /// Get achievements count by type
  int getAchievementCount(AchievementType type) {
    return getAllAchievements(type: type).length;
  }

  /// Check if user has a specific achievement type
  bool hasAchievement(AchievementType type) {
    return getAchievementCount(type) > 0;
  }

  /// Get recent achievements (last 30 days)
  List<Map<String, dynamic>> getRecentAchievements({int days = 30}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    
    return getAllAchievements().where((achievement) {
      final earnedDate = DateTime.parse(achievement['earnedAt']);
      return earnedDate.isAfter(cutoffDate);
    }).toList();
  }

  /// Award goal completion achievement
  Future<String> awardGoalCompletion({
    required String goalTitle,
    required String goalType,
    required int durationDays,
    required double finalProgress,
  }) async {
    return await addAchievement(
      type: AchievementType.goalCompleted,
      title: 'Goal Completed',
      description: 'Successfully completed: $goalTitle',
      metadata: {
        'goalTitle': goalTitle,
        'goalType': goalType,
        'durationDays': durationDays,
        'finalProgress': finalProgress,
        'completedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Award streak achievement
  Future<String> awardStreak({
    required int streakDays,
    required String streakType,
  }) async {
    String title;
    if (streakDays >= 100) {
      title = 'Century Streak';
    } else if (streakDays >= 30) {
      title = 'Monthly Streak';
    } else if (streakDays >= 7) {
      title = 'Weekly Streak';
    } else {
      title = 'Streak Started';
    }

    return await addAchievement(
      type: AchievementType.streakMilestone,
      title: title,
      description: '$streakDays days of $streakType',
      metadata: {
        'streakDays': streakDays,
        'streakType': streakType,
      },
    );
  }

  /// Award milestone achievement
  Future<String> awardMilestone({
    required String milestone,
    required String description,
    Map<String, dynamic>? additionalData,
  }) async {
    return await addAchievement(
      type: AchievementType.milestone,
      title: milestone,
      description: description,
      metadata: additionalData,
    );
  }

  /// Clear all achievements (for testing)
  Future<void> clearAllAchievements() async {
    await _hiveCore.ensureInitialized();
    await _hiveCore.achievementsBox.clear();
    developer.log('All achievements cleared', name: 'AchievementsService');
  }

  /// Get achievement statistics
  Map<String, dynamic> getAchievementStats() {
    final all = getAllAchievements();
    
    return {
      'total': all.length,
      'goalCompletions': getAchievementCount(AchievementType.goalCompleted),
      'streaks': getAchievementCount(AchievementType.streakMilestone),
      'milestones': getAchievementCount(AchievementType.milestone),
      'recentCount': getRecentAchievements().length,
      'firstAchievement': all.isNotEmpty ? all.last['earnedAt'] : null,
      'latestAchievement': all.isNotEmpty ? all.first['earnedAt'] : null,
    };
  }
}

/// Types of achievements users can earn
enum AchievementType {
  goalCompleted,
  streakMilestone,
  milestone,
  special,
}
