import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Today's status card showing current progress and daily goal
class TodayStatusCard extends StatelessWidget {
  final DateTime date;
  final double totalDrinks;
  final int dailyLimit;
  final bool isDrinkingDay;

  const TodayStatusCard({
    super.key,
    required this.date,
    required this.totalDrinks,
    required this.dailyLimit,
    required this.isDrinkingDay,
  });

  @override
  Widget build(BuildContext context) {
    Color cardColor;
    String statusText;
    IconData statusIcon;
    
    if (!isDrinkingDay) {
      cardColor = Colors.blue;
      statusText = 'Non-drinking day';
      statusIcon = Icons.schedule;
    } else if (totalDrinks == 0) {
      cardColor = Colors.green;
      statusText = 'Ready for the day';
      statusIcon = Icons.check_circle;
    } else if (totalDrinks <= dailyLimit) {
      cardColor = Colors.green;
      statusText = 'On track';
      statusIcon = Icons.trending_up;
    } else {
      cardColor = Colors.orange;
      statusText = 'Over limit';
      statusIcon = Icons.warning;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardColor.withValues(alpha: 0.1),
            cardColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  statusIcon,
                  color: cardColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today, ${DateFormat('MMM d').format(date)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: cardColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (isDrinkingDay)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      totalDrinks.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'of $dailyLimit drinks',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (isDrinkingDay) ...[
            const SizedBox(height: 20),
            HomeDrinkVisualizer(
              totalDrinks: totalDrinks,
              dailyLimit: dailyLimit,
            ),
          ],
        ],
      ),
    );
  }
}

/// Simplified drink visualizer for home screen
class HomeDrinkVisualizer extends StatelessWidget {
  final double totalDrinks;
  final int dailyLimit;

  const HomeDrinkVisualizer({
    super.key,
    required this.totalDrinks,
    required this.dailyLimit,
  });

  @override
  Widget build(BuildContext context) {
    final progress = dailyLimit > 0 ? (totalDrinks / dailyLimit).clamp(0.0, 1.0) : 0.0;
    final isOverLimit = totalDrinks > dailyLimit;
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isOverLimit 
                          ? Colors.orange.shade400 
                          : Colors.green.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isOverLimit 
                    ? Colors.orange.shade600 
                    : Colors.green.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            Text(
              '$dailyLimit (goal)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
