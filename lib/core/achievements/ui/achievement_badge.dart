import 'package:flutter/material.dart';
import '../models/achievement_model.dart';

/// Individual achievement badge widget
class AchievementBadge extends StatelessWidget {
  final GrantedAchievement grantedAchievement;
  final VoidCallback? onTap;
  final double size;
  final bool showLabel;

  const AchievementBadge({
    super.key,
    required this.grantedAchievement,
    this.onTap,
    this.size = 48,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final achievement = grantedAchievement.achievement;
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: achievement.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: achievement.color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              achievement.icon,
              size: size * 0.5,
              color: Colors.white,
            ),
          ),
          if (showLabel) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: size + 16,
              child: Text(
                achievement.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Horizontal list of achievement badges
class AchievementBadgeList extends StatelessWidget {
  final List<GrantedAchievement> achievements;
  final Function(GrantedAchievement)? onAchievementTap;
  final VoidCallback? onViewAllTap;
  final int maxVisible;

  const AchievementBadgeList({
    super.key,
    required this.achievements,
    this.onAchievementTap,
    this.onViewAllTap,
    this.maxVisible = 5,
  });

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) {
      return const SizedBox.shrink();
    }

    final visibleAchievements = achievements.take(maxVisible).toList();
    final hasMore = achievements.length > maxVisible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Achievement Badges',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (hasMore && onViewAllTap != null)
              TextButton(
                onPressed: onViewAllTap,
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...visibleAchievements.map((granted) => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: AchievementBadge(
                  grantedAchievement: granted,
                  onTap: () => onAchievementTap?.call(granted),
                ),
              )),
              if (hasMore && onViewAllTap != null)
                GestureDetector(
                  onTap: onViewAllTap,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.more_horiz,
                      color: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
