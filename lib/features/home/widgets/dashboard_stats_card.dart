import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart' as theme;

/// Clean stats cards showing key metrics without trendlines 
class DashboardStatsCard extends StatelessWidget {
  final int streak;
  final double weeklyAdherence;
  final String? patternDescription;
  final String motivationalMessage;
  
  const DashboardStatsCard({
    super.key,
    required this.streak,
    required this.weeklyAdherence,
    this.patternDescription,
    required this.motivationalMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.calendar_month,
            value: '${(weeklyAdherence * 100).round()}%',
            label: 'Weekly Success',
            subtitle: 'Goals met this week',
            color: _getAdherenceColor(weeklyAdherence),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.analytics,
            value: patternDescription ?? _getWeeklyPattern(),
            label: 'Pattern',
            subtitle: 'This week\'s trend',
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required String subtitle,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                const Spacer(),
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getAdherenceColor(double adherence) {
    if (adherence >= 0.8) return theme.AppTheme.greenColor;
    if (adherence >= 0.6) return theme.AppTheme.orangeColor;
    return theme.AppTheme.redColor;
  }
  
  String _getWeeklyPattern() {
    if (weeklyAdherence >= 0.9) return 'Excellent';
    if (weeklyAdherence >= 0.7) return 'Good';
    if (weeklyAdherence >= 0.5) return 'Fair';
    return 'Improving';
  }
}
