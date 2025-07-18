import 'package:flutter/material.dart';
import '../../../core/utils/drink_status_utils.dart';
import '../../../core/services/hive_database_service.dart';
import '../../../core/constants/onboarding_constants.dart';
import '../../../core/theme/app_theme.dart' as theme;

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
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.AppTheme.whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.AppTheme.greyLight,
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
                        color: theme.AppTheme.redMediumDark,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else if (!isDrinkingDay)
                    Text(
                      'Alcohol-free day',
                      style: TextStyle(
                        color: theme.AppTheme.greenDark,
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
                      '${totalDrinks.toStringAsFixed(1)} drink${totalDrinks != 1 ? 's' : ''} logged on alcohol-free day. Remember, setbacks are part of the journey.',
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
        return theme.AppTheme.greyMedium;
      case DrinkStatus.overButWithinTolerance:
        return theme.AppTheme.orangeDark;
      case DrinkStatus.exceeded:
      case DrinkStatus.alcoholFreeViolation:
        return theme.AppTheme.redMediumDark;
      case DrinkStatus.future:
        return theme.AppTheme.greyVeryLight;
    }
  }

  Widget _buildStatusIcon(DrinkStatus status) {
    switch (status) {
      case DrinkStatus.alcoholFreeViolation:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.AppTheme.redVeryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error_outline,
            color: theme.AppTheme.redMediumDark,
            size: 20,
          ),
        );
      
      case DrinkStatus.alcoholFreeSuccess:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.AppTheme.greenLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            color: theme.AppTheme.greenDark,
            size: 20,
          ),
        );
      
      case DrinkStatus.withinLimit:
      case DrinkStatus.unused:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.AppTheme.greenLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline,
            color: theme.AppTheme.greenDark,
            size: 20,
          ),
        );
      
      case DrinkStatus.overButWithinTolerance:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.AppTheme.orangeLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.warning_amber,
            color: theme.AppTheme.orangeDark,
            size: 20,
          ),
        );
      
      case DrinkStatus.exceeded:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.AppTheme.redVeryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.cancel,
            color: theme.AppTheme.redMediumDark,
            size: 20,
          ),
        );
      
      case DrinkStatus.future:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.AppTheme.greyExtraLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.schedule,
            color: theme.AppTheme.greyVeryLight,
            size: 20,
          ),
        );
    }
  }
}

/// Visual drink progress indicator with tolerance-aware display
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
    // Get tolerance-aware status 
    final drinkStatus = DrinkStatusUtils.calculateDrinkStatus(
      date: date,
      databaseService: databaseService,
    );
    
    // Use the centralized status color instead of custom logic
    final progressColor = DrinkStatusUtils.getStatusColor(drinkStatus);
    
    // Calculate progress display
    double progress;
    String progressText;
    String limitText;
    
    if (totalDrinks <= dailyLimit) {
      // Within normal limit 
      progress = dailyLimit > 0 ? (totalDrinks / dailyLimit).clamp(0.0, 1.0) : 0.0;
      progressText = '${(progress * 100).toInt()}%';
      limitText = '$dailyLimit drinks (goal)';
    } else {
      // Over limit - show percentage over goal
      progress = (totalDrinks / dailyLimit).clamp(0.0, 2.0);
      progressText = '${(totalDrinks / dailyLimit * 100).toInt()}%';
      
      // Get limit text based on status
      switch (drinkStatus) {
        case DrinkStatus.overButWithinTolerance:
          final userData = databaseService.getUserData();
          final strictnessLevel = userData?['strictnessLevel'] as String? ?? OnboardingConstants.defaultStrictnessLevel;
          final tolerance = OnboardingConstants.strictnessToleranceMap[strictnessLevel] ?? 0.5;
          final toleranceLimit = dailyLimit * (1 + tolerance);
          limitText = '${toleranceLimit.toStringAsFixed(1)} drinks (tolerance)';
          break;
        case DrinkStatus.exceeded:
          limitText = 'Limit exceeded';
          break;
        default:
          limitText = '$dailyLimit drinks (goal)';
      }
    }
    
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
                child: Stack(
                  children: [
                    // Base progress bar
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress.clamp(0.0, 1.0), // Show actual progress up to 100%
                      child: Container(
                        decoration: BoxDecoration(
                          color: progressColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              progressText,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: progressColor,
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
                color: theme.AppTheme.greyDark,
              ),
            ),
            Text(
              limitText,
              style: TextStyle(
                fontSize: 12,
                color: progressColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        // Show status message
        if (totalDrinks > 0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: progressColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: progressColor.withValues(alpha: 0.2)),
            ),
            child: Text(
              DrinkStatusUtils.getStatusMessage(drinkStatus),
              style: TextStyle(
                fontSize: 12,
                color: progressColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
