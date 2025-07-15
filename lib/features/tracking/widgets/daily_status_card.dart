import 'package:flutter/material.dart';

/// Daily status card showing progress, goal, and drinking day status
class DailyStatusCard extends StatelessWidget {
  final DateTime date;
  final double totalDrinks;
  final int dailyLimit;
  final bool isDrinkingDay;
  final bool isToday;

  const DailyStatusCard({
    super.key,
    required this.date,
    required this.totalDrinks,
    required this.dailyLimit,
    required this.isDrinkingDay,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final isOverLimit = totalDrinks > dailyLimit && isDrinkingDay;
    final isAtGoal = totalDrinks <= dailyLimit && isDrinkingDay;
    final isAlcoholFreeDayDeviation = !isDrinkingDay && totalDrinks > 0;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isAlcoholFreeDayDeviation)
                    Text(
                      'Plan deviation',
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else if (!isDrinkingDay)
                    Text(
                      'Alcohol-free day',
                      style: TextStyle(
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    Text(
                      '${totalDrinks.toStringAsFixed(1)} / $dailyLimit drinks',
                      style: TextStyle(
                        color: isOverLimit ? Colors.red.shade600 : Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
              _buildStatusIcon(isDrinkingDay, isOverLimit, isAtGoal, isAlcoholFreeDayDeviation),
            ],
          ),
          // Show additional context for alcohol-free day deviation
          if (isAlcoholFreeDayDeviation) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.red.shade700,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${totalDrinks.toStringAsFixed(1)} drink${totalDrinks != 1 ? 's' : ''} logged on alcohol-free day. Remember, setbacks are part of the journey.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Show drink visualizer for regular drinking days
          if (isDrinkingDay) ...[
            const SizedBox(height: 16),
            DrinkVisualizer(
              totalDrinks: totalDrinks,
              dailyLimit: dailyLimit,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIcon(bool isDrinkingDay, bool isOverLimit, bool isAtGoal, bool isAlcoholFreeDayDeviation) {
    if (isAlcoholFreeDayDeviation) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.error_outline,
          color: Colors.red.shade600,
          size: 20,
        ),
      );
    }
    
    if (!isDrinkingDay) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check,
          color: Colors.green.shade600,
          size: 20,
        ),
      );
    }
    
    if (isOverLimit) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.warning,
          color: Colors.red.shade600,
          size: 20,
        ),
      );
    }
    
    if (isAtGoal) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.thumb_up,
          color: Colors.blue.shade600,
          size: 20,
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.trending_up,
        color: Colors.grey.shade600,
        size: 20,
      ),
    );
  }
}

/// Visual drink progress indicator
class DrinkVisualizer extends StatelessWidget {
  final double totalDrinks;
  final int dailyLimit;

  const DrinkVisualizer({
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
                      color: isOverLimit ? Colors.red.shade400 : Colors.blue.shade400,
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
                color: isOverLimit ? Colors.red.shade600 : Colors.blue.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0 drinks',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            Text(
              '$dailyLimit drinks (goal)',
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
