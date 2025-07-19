import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/drink_status_utils.dart';
import '../../../core/services/hive_database_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart' as theme;

/// Today's status card showing current progress and daily goal
class TodayStatusCard extends StatelessWidget {
  final DateTime date;
  final double totalDrinks;
  final int dailyLimit;
  final bool isDrinkingDay;
  final HiveDatabaseService databaseService;

  const TodayStatusCard({
    super.key,
    required this.date,
    required this.totalDrinks,
    required this.dailyLimit,
    required this.isDrinkingDay,
    required this.databaseService,
  });

  @override
  Widget build(BuildContext context) {
    // Use centralized day result state calculation
    final dayResultState = DrinkDayResultUtils.calculateDayResultState(
      date: date,
      databaseService: databaseService,
    );
    
    final cardColor = DrinkDayResultUtils.getStateColor(dayResultState);
    final statusText = DrinkDayResultUtils.getStateText(dayResultState);
    final statusIcon = DrinkDayResultUtils.getStateIcon(dayResultState);

    return Container(
      margin: EdgeInsets.zero, // Let parent handle spacing
      padding: AppSpacing.screenPadding, // Use consistent padding
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
                        color: theme.AppTheme.greyMedium,
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
              // Show drink count for alcohol-free day deviation or regular drinking day
              if (isDrinkingDay || (!isDrinkingDay && totalDrinks > 0))
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
                      isDrinkingDay ? 'of $dailyLimit drinks' : 'drink${totalDrinks != 1 ? 's' : ''} logged',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.AppTheme.greyMedium,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          // Show additional context for alcohol-free day deviation
          if (!isDrinkingDay && totalDrinks > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.AppTheme.redLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.AppTheme.redMedium),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.AppTheme.redDark,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You\'ve logged drinks on your planned alcohol-free day. That\'s okay - tomorrow is a fresh start.',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.AppTheme.redDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Show drink visualizer for regular drinking days
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
                  color: theme.AppTheme.greyLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isOverLimit 
                          ? theme.AppTheme.orangeMedium
                          : theme.AppTheme.greenMedium,
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
                    ? theme.AppTheme.orangeDark
                    : theme.AppTheme.greenDark,
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
                color: theme.AppTheme.greyDark,
              ),
            ),
            Text(
              '$dailyLimit (goal)',
              style: TextStyle(
                fontSize: 12,
                color: theme.AppTheme.greyDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
