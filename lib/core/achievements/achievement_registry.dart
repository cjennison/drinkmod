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

    // Tracking achievements
    'first_drink_logged': Achievement(
      id: 'first_drink_logged',
      name: 'Mindful Start',
      description: 'Logged your first drink',
      icon: Icons.create,
      color: Colors.lightBlue,
      category: AchievementCategory.tracking,
    ),

    '5_drinks_logged': Achievement(
      id: '5_drinks_logged',
      name: 'Early Tracker',
      description: 'Logged 5 drinks total',
      icon: Icons.trending_up,
      color: Colors.blue,
      category: AchievementCategory.tracking,
      chainPosition: 5,
      prerequisites: ['first_drink_logged'],
    ),

    '10_drinks_logged': Achievement(
      id: '10_drinks_logged',
      name: 'Consistent Logger',
      description: 'Logged 10 drinks total',
      icon: Icons.analytics,
      color: Colors.indigo,
      category: AchievementCategory.tracking,
      chainPosition: 10,
      prerequisites: ['5_drinks_logged'],
    ),

    '25_drinks_logged': Achievement(
      id: '25_drinks_logged',
      name: 'Tracking Veteran',
      description: 'Logged 25 drinks total',
      icon: Icons.insights,
      color: Colors.deepPurple,
      category: AchievementCategory.tracking,
      chainPosition: 25,
      prerequisites: ['10_drinks_logged'],
    ),

    '50_drinks_logged': Achievement(
      id: '50_drinks_logged',
      name: 'Data Master',
      description: 'Logged 50 drinks total',
      icon: Icons.storage,
      color: Colors.purple,
      category: AchievementCategory.tracking,
      chainPosition: 50,
      prerequisites: ['25_drinks_logged'],
    ),

    'week_of_logging': Achievement(
      id: 'week_of_logging',
      name: 'Week Tracker',
      description: 'Logged drinks for 7 consecutive days',
      icon: Icons.calendar_view_week,
      color: Colors.cyan,
      category: AchievementCategory.tracking,
    ),

    'compliant_logger': Achievement(
      id: 'compliant_logger',
      name: 'Mindful Logger',
      description: '80% of drinks within schedule and limits',
      icon: Icons.verified,
      color: Colors.green,
      category: AchievementCategory.tracking,
    ),

    // Intervention achievements
    'first_intervention_win': Achievement(
      id: 'first_intervention_win',
      name: 'Self-Control',
      description: 'Declined a drink when prompted',
      icon: Icons.block,
      color: Colors.red,
      category: AchievementCategory.interventions,
    ),

    '5_intervention_wins': Achievement(
      id: '5_intervention_wins',
      name: 'Strong Will',
      description: 'Won 5 interventions',
      icon: Icons.security,
      color: Colors.deepOrange,
      category: AchievementCategory.interventions,
      chainPosition: 5,
      prerequisites: ['first_intervention_win'],
    ),

    '10_intervention_wins': Achievement(
      id: '10_intervention_wins',
      name: 'Iron Will',
      description: 'Won 10 interventions',
      icon: Icons.shield,
      color: Colors.red,
      category: AchievementCategory.interventions,
      chainPosition: 10,
      prerequisites: ['5_intervention_wins'],
    ),

    'intervention_champion': Achievement(
      id: 'intervention_champion',
      name: 'Champion',
      description: '80% intervention win rate',
      icon: Icons.military_tech,
      color: Colors.amber,
      category: AchievementCategory.interventions,
    ),

    'streak_saver': Achievement(
      id: 'streak_saver',
      name: 'Streak Saver',
      description: 'Avoided drinking on an alcohol-free day',
      icon: Icons.save,
      color: Colors.lightGreen,
      category: AchievementCategory.interventions,
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
