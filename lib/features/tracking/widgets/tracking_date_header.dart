import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Date header widget for tracking screen showing current date with navigation
class TrackingDateHeader extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final VoidCallback? onPreviousDay;
  final VoidCallback? onNextDay;
  final VoidCallback? onCalendarTap;

  const TrackingDateHeader({
    super.key,
    required this.date,
    required this.isToday,
    this.onPreviousDay,
    this.onNextDay,
    this.onCalendarTap,
  });

  @override
  Widget build(BuildContext context) {
    final dayName = DateFormat('EEEE').format(date);
    final dateString = DateFormat('MMMM d, y').format(date);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Navigation back button
              IconButton(
                onPressed: onPreviousDay,
                icon: const Icon(Icons.chevron_left),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                tooltip: 'Previous day',
              ),
              
              // Date display with calendar access
              Expanded(
                child: GestureDetector(
                  onTap: onCalendarTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dayName,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isToday ? Theme.of(context).primaryColor : Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.calendar_month,
                              size: 20,
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateString,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (isToday) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Today',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              
              // Navigation forward button
              IconButton(
                onPressed: onNextDay,
                icon: const Icon(Icons.chevron_right),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                tooltip: 'Next day',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }
}
