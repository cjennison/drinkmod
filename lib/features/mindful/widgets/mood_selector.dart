import 'package:flutter/material.dart';
import '../../../core/models/journal_entry.dart';

/// Mood selector widget with visual mood indicators
class MoodSelector extends StatelessWidget {
  final MoodLevel? selectedMood;
  final ValueChanged<MoodLevel?> onMoodChanged;

  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How would you rate your overall mood today?',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Mood buttons
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: MoodLevel.values.map((mood) {
            final isSelected = selectedMood == mood;
            
            return InkWell(
              onTap: () => onMoodChanged(isSelected ? null : mood),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected 
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withValues(alpha: 0.2),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      mood.emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mood.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected 
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        
        if (selectedMood != null) ...[
          const SizedBox(height: 20),
          _buildMoodInsight(context, selectedMood!),
        ],
      ],
    );
  }

  Widget _buildMoodInsight(BuildContext context, MoodLevel mood) {
    final theme = Theme.of(context);
    String insight;
    Color insightColor;
    
    switch (mood) {
      case MoodLevel.veryLow:
        insight = 'It\'s okay to have difficult days. Be gentle with yourself.';
        insightColor = Colors.red;
        break;
      case MoodLevel.low:
        insight = 'Your feelings are valid. Consider what might help you feel better.';
        insightColor = Colors.orange;
        break;
      case MoodLevel.neutral:
        insight = 'A balanced mood is perfectly normal. Notice what\'s present for you.';
        insightColor = Colors.blue;
        break;
      case MoodLevel.good:
        insight = 'It\'s wonderful that you\'re feeling good today. What\'s contributing to this?';
        insightColor = Colors.green;
        break;
      case MoodLevel.veryGood:
        insight = 'You\'re feeling great! Take a moment to appreciate this positive energy.';
        insightColor = Colors.purple;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: insightColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: insightColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: insightColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              insight,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
