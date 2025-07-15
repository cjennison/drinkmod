import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/services/hive_database_service.dart';

/// Week overview widget showing drinking patterns for the week
class WeekOverviewWidget extends StatelessWidget {
  final DateTime date;
  final HiveDatabaseService databaseService;

  const WeekOverviewWidget({
    super.key,
    required this.date,
    required this.databaseService,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate week start (Monday)
    final weekStart = date.subtract(Duration(days: date.weekday - 1));
    
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_view_week,
                color: Colors.purple.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'This Week',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple.shade700,
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
              final isFuture = dayDate.isAfter(DateTime.now());
              
              return _buildDayColumn(context, dayDate, isToday, isFuture);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDayColumn(BuildContext context, DateTime dayDate, bool isToday, bool isFuture) {
    final dayName = DateFormat('E').format(dayDate);
    final dayNumber = dayDate.day.toString();
    
    if (isFuture) {
      return Column(
        children: [
          Text(
            dayName,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
              border: isToday ? Border.all(color: Theme.of(context).primaryColor, width: 2) : null,
            ),
            child: Center(
              child: Text(
                dayNumber,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      );
    }

    // Get drink data for this day
    final totalDrinks = _getDayTotalDrinks(dayDate);
    final userData = databaseService.getUserData();
    final dailyLimit = userData?['dailyLimit'] as int? ?? 2;
    final isOverLimit = totalDrinks > dailyLimit;
    
    return Column(
      children: [
        Text(
          dayName,
          style: TextStyle(
            fontSize: 12,
            color: isToday ? Theme.of(context).primaryColor : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isToday ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.grey.shade50,
            shape: BoxShape.circle,
            border: isToday ? Border.all(color: Theme.of(context).primaryColor, width: 2) : null,
          ),
          child: Center(
            child: Text(
              dayNumber,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isToday ? Theme.of(context).primaryColor : Colors.grey.shade700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: totalDrinks == 0 
                ? Colors.green.shade300
                : isOverLimit 
                    ? Colors.red.shade400
                    : Colors.blue.shade400,
            borderRadius: BorderRadius.circular(2),
          ),
          child: totalDrinks > 0 
              ? Container(
                  decoration: BoxDecoration(
                    color: isOverLimit ? Colors.red.shade400 : Colors.blue.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                )
              : null,
        ),
      ],
    );
  }

  double _getDayTotalDrinks(DateTime day) {
    final entries = databaseService.getDrinkEntriesForDate(day);
    return entries.fold(0.0, (sum, entry) => sum + (entry['standardDrinks'] as double? ?? 0.0));
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }
}
