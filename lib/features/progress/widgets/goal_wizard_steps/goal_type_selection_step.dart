import 'package:flutter/material.dart';
import '../../../../core/models/user_goal.dart';

/// Goal type selection step with therapeutic explanations and visual indicators
class GoalTypeSelectionStep extends StatefulWidget {
  final Function(GoalType) onGoalTypeSelected;
  
  const GoalTypeSelectionStep({
    super.key,
    required this.onGoalTypeSelected,
  });

  @override
  State<GoalTypeSelectionStep> createState() => _GoalTypeSelectionStepState();
}

class _GoalTypeSelectionStepState extends State<GoalTypeSelectionStep> {
  GoalType? _selectedGoalType;
  
  static const List<GoalTypeInfo> _goalTypes = [
    GoalTypeInfo(
      type: GoalType.weeklyReduction,
      title: 'Weekly Reduction',
      subtitle: 'Gradually reduce weekly consumption',
      description: 'Perfect for sustainable, long-term change. Set a target number of drinks per week and work toward it over several months.',
      icon: Icons.trending_down_outlined,
      color: Colors.blue,
      difficulty: 'Beginner',
      duration: '2-6 months',
      benefits: ['Sustainable progress', 'Flexible daily limits', 'Long-term focused'],
    ),
    GoalTypeInfo(
      type: GoalType.dailyLimit,
      title: 'Daily Limit',
      subtitle: 'Stay under a daily drink limit',
      description: 'Set a strict daily limit and maintain it consistently. Great for building discipline and daily accountability.',
      icon: Icons.today_outlined,
      color: Colors.green,
      difficulty: 'Intermediate',
      duration: '2-8 weeks',
      benefits: ['Daily accountability', 'Clear boundaries', 'Builds discipline'],
    ),
    GoalTypeInfo(
      type: GoalType.alcoholFreeDays,
      title: 'Alcohol-Free Days',
      subtitle: 'Schedule regular alcohol-free days',
      description: 'Commit to specific alcohol-free days each week. Excellent for breaking routine drinking patterns.',
      icon: Icons.free_breakfast_outlined,
      color: Colors.purple,
      difficulty: 'Beginner',
      duration: '1-3 months',
      benefits: ['Break routines', 'Improved recovery', 'Pattern awareness'],
    ),
    GoalTypeInfo(
      type: GoalType.moodImprovement,
      title: 'Mood & Wellbeing',
      subtitle: 'Focus on mood and energy improvements',
      description: 'Track how reducing alcohol affects your mood, energy, and overall wellbeing over time.',
      icon: Icons.psychology_outlined,
      color: Colors.orange,
      difficulty: 'Advanced',
      duration: '4-12 weeks',
      benefits: ['Holistic health', 'Mental clarity', 'Energy boost'],
    ),
    GoalTypeInfo(
      type: GoalType.interventionWins,
      title: 'Intervention Success',
      subtitle: 'Build strength in moments of choice',
      description: 'Focus on successfully choosing not to drink when prompted by the app in high-risk situations.',
      icon: Icons.psychology_alt_outlined,
      color: Colors.teal,
      difficulty: 'Advanced',
      duration: '3-8 weeks',
      benefits: ['Mental resilience', 'Decision strength', 'Mindful drinking'],
    ),
    GoalTypeInfo(
      type: GoalType.costSavings,
      title: 'Cost Savings',
      subtitle: 'Track money saved by drinking less',
      description: 'Motivate yourself by seeing the financial benefits of reduced alcohol consumption.',
      icon: Icons.savings_outlined,
      color: Colors.indigo,
      difficulty: 'Beginner',
      duration: '1-6 months',
      benefits: ['Financial motivation', 'Tangible progress', 'Extra spending money'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          
          // Header
          _buildHeader(),
          
          const SizedBox(height: 24),
          
          // Goal type cards
          Expanded(
            child: ListView.builder(
              itemCount: _goalTypes.length,
              itemBuilder: (context, index) {
                final goalType = _goalTypes[index];
                final isSelected = _selectedGoalType == goalType.type;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildGoalTypeCard(goalType, isSelected),
                );
              },
            ),
          ),
          
          // Continue button
          if (_selectedGoalType != null) ...[
            const SizedBox(height: 16),
            _buildContinueButton(),
          ],
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Your Goal Type',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select the type of goal that best fits your current situation and motivation.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.3,
          ),
        ),
      ],
    );
  }
  
  Widget _buildGoalTypeCard(GoalTypeInfo goalType, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGoalType = goalType.type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? goalType.color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? goalType.color : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: goalType.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    goalType.icon,
                    color: goalType.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goalType.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goalType.subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: goalType.color,
                    size: 24,
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              goalType.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Goal metadata
            Row(
              children: [
                _buildMetadataChip(
                  goalType.difficulty,
                  Icons.bar_chart_outlined,
                  goalType.color,
                ),
                const SizedBox(width: 12),
                _buildMetadataChip(
                  goalType.duration,
                  Icons.schedule_outlined,
                  goalType.color,
                ),
              ],
            ),
            
            if (isSelected) ...[
              const SizedBox(height: 16),
              _buildBenefitsList(goalType.benefits, goalType.color),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildMetadataChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBenefitsList(List<String> benefits, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Benefits:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        ...benefits.map((benefit) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Icon(
                Icons.check,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                benefit,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
  
  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => widget.onGoalTypeSelected(_selectedGoalType!),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Continue',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class GoalTypeInfo {
  final GoalType type;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final String difficulty;
  final String duration;
  final List<String> benefits;
  
  const GoalTypeInfo({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.difficulty,
    required this.duration,
    required this.benefits,
  });
}
