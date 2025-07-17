import 'package:flutter/material.dart';
import 'models/achievement_model.dart';

/// Central registry of all achievements in the app
class AchievementRegistry {
  static const Map<String, Achievement> _achievements = {
    // Account milestones
    'first_goal': Achievement(
      id: 'first_goal',
      name: 'First Step',
      description: 'Created your very first goal',
      icon: Icons.flag,
      color: Colors.green,
      category: AchievementCategory.goals,
    ),
    
    '1_day_down': Achievement(
      id: '1_day_down',
      name: 'Day One',
      description: 'Account active for 24 hours',
      icon: Icons.schedule,
      color: Colors.blue,
      category: AchievementCategory.account,
      chainPosition: 1,
    ),
    
    '3_days_down': Achievement(
      id: '3_days_down',
      name: 'Three Day Warrior',
      description: 'Account active for 3 days',
      icon: Icons.local_fire_department,
      color: Colors.orange,
      category: AchievementCategory.account,
      chainPosition: 3,
      prerequisites: ['1_day_down'],
    ),
    
    '7_days_down': Achievement(
      id: '7_days_down',
      name: 'Week Strong',
      description: 'Account active for 7 days',
      icon: Icons.emoji_events,
      color: Colors.purple,
      category: AchievementCategory.account,
      chainPosition: 7,
      prerequisites: ['3_days_down'],
    ),
    
    'first_goal_completed': Achievement(
      id: 'first_goal_completed',
      name: 'Goal Crusher',
      description: 'Completed your first goal at 100%',
      icon: Icons.stars,
      color: Colors.amber,
      category: AchievementCategory.goals,
      prerequisites: ['first_goal'],
    ),
    
    'first_goal_finished': Achievement(
      id: 'first_goal_finished',
      name: 'Goal Finisher',
      description: 'Finished your first goal',
      icon: Icons.check_circle,
      color: Colors.teal,
      category: AchievementCategory.goals,
      prerequisites: ['first_goal'],
    ),
  };

  /// Get achievement by ID
  static Achievement? getAchievement(String id) => _achievements[id];

  /// Get all achievements
  static List<Achievement> getAllAchievements() => _achievements.values.toList();

  /// Get achievements by category
  static List<Achievement> getAchievementsByCategory(AchievementCategory category) {
    return _achievements.values
        .where((achievement) => achievement.category == category)
        .toList();
  }

  /// Get achievement chain (progressive achievements like day counts)
  static List<Achievement> getAchievementChain(AchievementCategory category) {
    return getAchievementsByCategory(category)
        .where((achievement) => achievement.chainPosition != null)
        .toList()
        ..sort((a, b) => a.chainPosition!.compareTo(b.chainPosition!));
  }

  /// Check if achievement exists
  static bool hasAchievement(String id) => _achievements.containsKey(id);

  /// Get achievement count by category
  static int getCountByCategory(AchievementCategory category) {
    return getAchievementsByCategory(category).length;
  }

  /// Get total achievement count
  static int getTotalCount() => _achievements.length;

  /// Validate achievement prerequisites
  static bool canUnlock(String achievementId, List<String> unlockedIds) {
    final achievement = getAchievement(achievementId);
    if (achievement == null) return false;

    return achievement.prerequisites.every((prereq) => unlockedIds.contains(prereq));
  }

  /// Get next achievement in chain
  static Achievement? getNextInChain(Achievement current) {
    if (current.chainPosition == null) return null;

    final chain = getAchievementChain(current.category);
    final currentIndex = chain.indexWhere((a) => a.id == current.id);
    
    if (currentIndex == -1 || currentIndex >= chain.length - 1) return null;
    
    return chain[currentIndex + 1];
  }

  /// Get achievement statistics
  static Map<String, dynamic> getRegistryStats() {
    final byCategory = <AchievementCategory, int>{};
    
    for (final category in AchievementCategory.values) {
      byCategory[category] = getCountByCategory(category);
    }

    return {
      'total': getTotalCount(),
      'byCategory': byCategory,
      'chains': AchievementCategory.values
          .where((cat) => getAchievementChain(cat).isNotEmpty)
          .length,
    };
  }
}
