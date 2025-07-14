import 'package:flutter/material.dart';

/// Stats cards showing key metrics like streak and weekly progress
class DashboardStatsCard extends StatelessWidget {
  final int streak;
  final double weeklyAdherence;
  final String motivationalMessage;
  
  const DashboardStatsCard({
    super.key,
    required this.streak,
    required this.weeklyAdherence,
    required this.motivationalMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.local_fire_department,
            value: streak.toString(),
            label: 'Day Streak',
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.trending_up,
            value: '${(weeklyAdherence * 100).round()}%',
            label: 'This Week',
            color: Theme.of(context).colorScheme.tertiary,
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
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
