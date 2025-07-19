import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/services/hive_database_service.dart';
import '../../../core/utils/drink_intervention_utils.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart' as theme;

/// Week overview widget showing drinking patterns for the week
class WeekOverviewWidget extends StatelessWidget {
  final DateTime date;
  final HiveDatabaseService databaseService;
  final Function(DateTime)? onDateSelected;

  const WeekOverviewWidget({
    super.key,
    required this.date,
    required this.databaseService,
    this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate week start (Monday)
    final weekStart = date.subtract(Duration(days: date.weekday - 1));
    
    return Container(
      margin: EdgeInsets.zero, // Remove margin to let parent handle spacing
      padding: AppSpacing.screenPadding, // Use consistent padding
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_view_week,
                color: theme.AppTheme.purpleDark,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Week of ${DateFormat('MMM d').format(weekStart)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: theme.AppTheme.purpleDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final dayDate = weekStart.add(Duration(days: index));
              final isToday = _isSameDay(dayDate, DateTime.now());
              final isSelected = _isSameDay(dayDate, date);
              final isFuture = dayDate.isAfter(DateTime.now());
              
              return _buildDayColumn(context, dayDate, isToday, isSelected, isFuture);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDayColumn(BuildContext context, DateTime dayDate, bool isToday, bool isSelected, bool isFuture) {
    final dayName = DateFormat('E').format(dayDate);
    final dayNumber = dayDate.day.toString();
    
    if (isFuture) {
      return Column(
        children: [
          Text(
            dayName,
            style: TextStyle(
              fontSize: 12,
              color: theme.AppTheme.greyVeryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.AppTheme.greyExtraLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                dayNumber,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.AppTheme.greyVeryLight,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: theme.AppTheme.greyLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 2),
          const SizedBox(height: 10), // Space for drink count
        ],
      );
    }

    // Get adherence status and drink count for this day
    final adherenceStatus = DrinkInterventionUtils.getDayAdherenceStatus(
      date: dayDate,
      databaseService: databaseService,
    );
    final dayColor = DrinkInterventionUtils.getDayAdherenceColor(adherenceStatus);
    final totalDrinks = databaseService.getTotalDrinksForDate(dayDate);
    
    // Determine background color and border based on selection and today status
    Color backgroundColor;
    Border? border;
    Color textColor;
    
    if (isSelected) {
      // Selected day gets prominent highlight
      backgroundColor = Theme.of(context).primaryColor.withValues(alpha: 0.15);
      border = Border.all(color: Theme.of(context).primaryColor, width: 2);
      textColor = Theme.of(context).primaryColor;
    } else if (isToday) {
      // Today gets subtle highlight
      backgroundColor = Theme.of(context).primaryColor.withValues(alpha: 0.05);
      border = Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3), width: 1);
      textColor = Theme.of(context).primaryColor.withValues(alpha: 0.8);
    } else {
      // Regular days
      backgroundColor = theme.AppTheme.greyExtraLight;
      border = null;
      textColor = theme.AppTheme.greyMedium;
    }
    
    return GestureDetector(
      onTap: onDateSelected != null ? () => onDateSelected!(dayDate) : null,
      child: Column(
        children: [
          Text(
            dayName,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Theme.of(context).primaryColor : 
                     isToday ? Theme.of(context).primaryColor.withValues(alpha: 0.7) : 
                     theme.AppTheme.greyMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: border,
            ),
            child: Center(
              child: Text(
                dayNumber,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: dayColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 2),
          // Drink count display
          SizedBox(
            height: 10,
            child: totalDrinks > 0
                ? Text(
                    totalDrinks == totalDrinks.toInt() 
                        ? '${totalDrinks.toInt()}'
                        : totalDrinks.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: theme.AppTheme.greyMedium,
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }
}
