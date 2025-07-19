import 'package:flutter/material.dart';
import '../../../core/services/goal_management_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart' as theme;
import '../../progress/widgets/goal_progress_card.dart';
import '../../progress/shared/types/goal_display_types.dart';

/// Mini version of the goal card for home screen
/// Shows condensed goal progress and navigates to progress page when tapped
class MiniGoalCard extends StatefulWidget {
  final VoidCallback? onTap;
  
  const MiniGoalCard({
    super.key,
    this.onTap,
  });

  @override
  State<MiniGoalCard> createState() => _MiniGoalCardState();
}

class _MiniGoalCardState extends State<MiniGoalCard> {
  Map<String, dynamic>? _goalData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoalData();
  }

  Future<void> _loadGoalData() async {
    try {
      final goalService = GoalManagementService.instance;
      final activeGoal = await goalService.getActiveGoal();
      
      setState(() {
        _goalData = activeGoal;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _goalData = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_goalData == null) {
      return _buildGoalCTACard(context);
    }

    // Use the goal progress card in compact variant
    return GoalProgressCard(
      goalData: _goalData!,
      variant: GoalCardSize.compact,
      onTap: widget.onTap,
    );
  }

  Widget _buildGoalCTACard(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.zero, // Let parent handle spacing
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: AppSpacing.screenPadding, // Use consistent padding
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.AppTheme.blueLight,
              theme.AppTheme.purpleLight,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.AppTheme.blueMedium,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.flag,
                    color: theme.AppTheme.blueColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Your Progress Journey',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Research shows that setting clear goals increases success rates by up to 42%',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.AppTheme.greyColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Setting a goal provides structure and accountability on your journey to reduce consumption. When you have a clear target, every small step becomes meaningful progress.',
              style: TextStyle(
                fontSize: 14,
                color: theme.AppTheme.greyColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.onTap,
                icon: const Icon(Icons.trending_up, size: 20),
                label: const Text('View Progress'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.AppTheme.blueColor,
                  foregroundColor: theme.AppTheme.whiteColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
