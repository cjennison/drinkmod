import 'package:flutter/material.dart';

/// Mood scales widget for detailed wellbeing tracking
class MoodScalesWidget extends StatelessWidget {
  final int? anxietyLevel;
  final int? stressLevel;
  final int? energyLevel;
  final Function(String scale, int? value) onScaleChanged;

  const MoodScalesWidget({
    super.key,
    this.anxietyLevel,
    this.stressLevel,
    this.energyLevel,
    required this.onScaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rate different aspects of your wellbeing',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Slide to rate each area from 1 (low) to 10 (high)',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Anxiety scale
        _buildMoodScale(
          context,
          title: 'Anxiety Level',
          subtitle: 'How anxious did you feel today?',
          value: anxietyLevel,
          color: Colors.red,
          icon: Icons.psychology,
          scale: 'anxiety',
          lowLabel: 'Calm',
          highLabel: 'Very Anxious',
        ),
        
        const SizedBox(height: 24),
        
        // Stress scale
        _buildMoodScale(
          context,
          title: 'Stress Level',
          subtitle: 'How stressed did you feel today?',
          value: stressLevel,
          color: Colors.orange,
          icon: Icons.warning_amber,
          scale: 'stress',
          lowLabel: 'Relaxed',
          highLabel: 'Very Stressed',
        ),
        
        const SizedBox(height: 24),
        
        // Energy scale
        _buildMoodScale(
          context,
          title: 'Energy Level',
          subtitle: 'How energetic did you feel today?',
          value: energyLevel,
          color: Colors.green,
          icon: Icons.bolt,
          scale: 'energy',
          lowLabel: 'Drained',
          highLabel: 'Very Energetic',
        ),
      ],
    );
  }

  Widget _buildMoodScale(
    BuildContext context, {
    required String title,
    required String subtitle,
    required int? value,
    required Color color,
    required IconData icon,
    required String scale,
    required String lowLabel,
    required String highLabel,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (value != null)
                Container(
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    value.toString(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.3),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.2),
              valueIndicatorColor: color,
              valueIndicatorTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Slider(
              value: (value ?? 5).toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: value?.toString() ?? '5',
              onChanged: (newValue) {
                onScaleChanged(scale, newValue.round());
              },
            ),
          ),
          
          // Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lowLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Text(
                highLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
