import 'package:flutter/material.dart';
import '../../../../core/models/user_goal.dart';
import '../../shared/components/goal_preview_components.dart';

/// Goal preview step with comprehensive goal summary and confirmation
class GoalPreviewStep extends StatelessWidget {
  final UserGoal goal;
  final Function() onConfirm;
  final Function() onEdit;
  
  const GoalPreviewStep({
    super.key,
    required this.goal,
    required this.onConfirm,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  GoalPreviewComponents.buildGoalPreviewCard(goal: goal),
                  const SizedBox(height: 20),
                  GoalPreviewComponents.buildProgressPreview(
                    goal: goal,
                    mockProgress: 0.0,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: GoalPreviewComponents.buildActionButtons(
              onEdit: onEdit,
              onConfirm: onConfirm,
              context: context,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review Your Goal',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Make sure everything looks right before creating your goal.',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade600,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
