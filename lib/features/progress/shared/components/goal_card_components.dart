import 'package:flutter/material.dart';

/// Common UI components for goal cards
class GoalCardComponents {
  
  /// Build a progress indicator with percentage
  static Widget buildProgressIndicator({
    required double percentage,
    required Color color,
    required bool isOnTrack,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${percentage.toStringAsFixed(0)}% Complete',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isOnTrack)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'On Track',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage / 100.0,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
      ],
    );
  }

  /// Build a metric chip with icon and value
  static Widget buildMetricChip({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Build a card header with icon and title
  static Widget buildCardHeader({
    required Map<String, dynamic> goalData,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build a list of recent actions
  static Widget buildActionsList({
    required List<dynamic> actions,
    required String title,
  }) {
    if (actions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        ...actions.take(3).map((action) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 6,
                color: Colors.grey[400],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  action['text']?.toString() ?? 'Action completed',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  /// Build a card container with gradient background
  static Widget buildCardContainer({
    required Widget child,
    required Color color,
    required EdgeInsets margin,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        margin: margin,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.05),
                color.withOpacity(0.02),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
