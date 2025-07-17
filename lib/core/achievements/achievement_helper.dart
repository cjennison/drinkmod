import 'package:flutter/material.dart';
import 'achievement_manager.dart';
import 'ui/achievement_badge.dart';
import 'ui/achievements_list_view.dart';
import 'models/achievement_model.dart';

/// Convenient widget for integrating achievements into the progress page
class AchievementsSection extends StatefulWidget {
  final VoidCallback? onViewAllAchievements;

  const AchievementsSection({
    super.key,
    this.onViewAllAchievements,
  });

  @override
  State<AchievementsSection> createState() => AchievementsSectionState();
}

class AchievementsSectionState extends State<AchievementsSection> {
  final AchievementManager _manager = AchievementManager.instance;
  List<GrantedAchievement> _recentAchievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentAchievements();
  }

  Future<void> _loadRecentAchievements() async {
    try {
      final achievements = await _manager.getRecentAchievements(limit: 5);
      
      if (mounted) {
        setState(() {
          _recentAchievements = achievements;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Refresh achievements (call after new achievements are granted)
  void refreshAchievements() {
    _loadRecentAchievements();
  }

  void _onViewAllAchievements() {
    if (widget.onViewAllAchievements != null) {
      widget.onViewAllAchievements!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const AchievementsListView(),
        ),
      );
    }
  }

  void _onAchievementTap(GrantedAchievement achievement) {
    // For now, just navigate to the full list
    // In the future, we could show a detail modal
    _onViewAllAchievements();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_recentAchievements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: AchievementBadgeList(
        achievements: _recentAchievements,
        onAchievementTap: _onAchievementTap,
        onViewAllTap: _onViewAllAchievements,
        maxVisible: 5,
      ),
    );
  }
}

/// Convenience functions for checking achievements
class AchievementHelper {
  static final AchievementManager _manager = AchievementManager.instance;

  /// Check achievement - main entry point
  static Future<bool> checkAchievement(String achievementId, {Map<String, dynamic>? context}) {
    return _manager.checkAchievement(achievementId, context: context);
  }

  /// Check multiple achievements
  static Future<List<String>> checkMultiple(List<String> achievementIds, {Map<String, dynamic>? context}) {
    return _manager.checkMultipleAchievements(achievementIds, context: context);
  }

  /// Common achievement checks
  static Future<void> checkAccountMilestones() async {
    await checkMultiple(['1_day_down', '3_days_down', '7_days_down']);
  }

  static Future<void> checkGoalMilestones() async {
    await checkMultiple(['first_goal', 'first_goal_completed', 'first_goal_finished']);
  }

  static Future<void> checkTrackingMilestones() async {
    await checkMultiple([
      'first_drink_logged',
      '5_drinks_logged', 
      '10_drinks_logged',
      '25_drinks_logged',
      '50_drinks_logged',
      'compliant_logger',
    ]);
  }

  static Future<void> checkInterventionMilestones() async {
    await checkMultiple([
      'first_intervention_win',
      '5_intervention_wins',
      '10_intervention_wins',
      'intervention_champion',
      'streak_saver',
    ]);
  }

  static Future<void> checkAllCommonAchievements() async {
    await checkAccountMilestones();
    await checkGoalMilestones();
    await checkTrackingMilestones();
    await checkInterventionMilestones();
  }

  /// Get achievement statistics
  static Future<Map<String, dynamic>> getStats() {
    return _manager.getAchievementStats();
  }

  /// Initialize achievement system (call in main app)
  static void initialize(GlobalKey<NavigatorState> navigatorKey) {
    AchievementManager.navigatorKey = navigatorKey;
  }
}
