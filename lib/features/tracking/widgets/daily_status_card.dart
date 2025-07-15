import 'package:flutter/material.dart';
import '../../../core/utils/drink_status_utils.dart';
import '../../../core/services/hive_database_service.dart';

/// Daily status card showing progress, goal, and drinking day status
class DailyStatusCard extends StatelessWidget {
  final DateTime date;
  final double totalDrinks;
  final int dailyLimit;
  final bool isDrinkingDay;
  final bool isToday;
  final HiveDatabaseService databaseService;

  const DailyStatusCard({
    super.key,
    required this.date,
    required this.totalDrinks,
    required this.dailyLimit,
    required this.isDrinkingDay,
    required this.isToday,
    required this.databaseService,
  });

  @override
  Widget build(BuildContext context) {
    // Use tolerance-aware status calculation
    final drinkStatus = DrinkStatusUtils.calculateDrinkStatus(
      date: date,
      databaseService: databaseService,
    );
    
    final isAlcoholFreeDayDeviation = drinkStatus == DrinkStatus.alcoholFreeViolation;
    
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
                        color: _getTextColor(drinkStatus),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
              _buildStatusIcon(drinkStatus),
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
              date: date,
              databaseService: databaseService,
            ),
          ],
        ],
      ),
    );
  }

  Color _getTextColor(DrinkStatus status) {
    switch (status) {
      case DrinkStatus.withinLimit:
      case DrinkStatus.alcoholFreeSuccess:
      case DrinkStatus.unused:
        return Colors.grey.shade600;
      case DrinkStatus.overButWithinTolerance:
        return Colors.orange.shade600;
      case DrinkStatus.exceeded:
      case DrinkStatus.alcoholFreeViolation:
        return Colors.red.shade600;
      case DrinkStatus.future:
        return Colors.grey.shade400;
    }
  }

  Widget _buildStatusIcon(DrinkStatus status) {
    switch (status) {
      case DrinkStatus.alcoholFreeViolation:
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
      
      case DrinkStatus.alcoholFreeSuccess:
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
      
      case DrinkStatus.withinLimit:
      case DrinkStatus.unused:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline,
            color: Colors.green.shade600,
            size: 20,
          ),
        );
      
      case DrinkStatus.overButWithinTolerance:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.warning_amber,
            color: Colors.orange.shade600,
            size: 20,
          ),
        );
      
      case DrinkStatus.exceeded:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.cancel,
            color: Colors.red.shade600,
            size: 20,
          ),
        );
      
      case DrinkStatus.future:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.schedule,
            color: Colors.grey.shade400,
            size: 20,
          ),
        );
    }
  }
}

/// Visual drink progress indicator
class DrinkVisualizer extends StatelessWidget {
  final double totalDrinks;
  final int dailyLimit;
  final DateTime date;
  final HiveDatabaseService databaseService;

  const DrinkVisualizer({
    super.key,
    required this.totalDrinks,
    required this.dailyLimit,
    required this.date,
    required this.databaseService,
  });

  @override
  Widget build(BuildContext context) {
    final progress = dailyLimit > 0 ? (totalDrinks / dailyLimit).clamp(0.0, 1.0) : 0.0;
    
    // Use tolerance-aware status calculation
    final drinkStatus = DrinkStatusUtils.calculateDrinkStatus(
      date: date,
      databaseService: databaseService,
    );
    
    // Get appropriate color based on status
    final statusColor = DrinkStatusUtils.getStatusColor(drinkStatus);
    
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
                      color: statusColor,
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
                color: statusColor,
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
