import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/services/hive_database_service.dart';

/// Calendar widget for date selection with drinking day indicators
class DrinkingCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final Map<String, dynamic>? userSchedule;

  const DrinkingCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.userSchedule,
  });

  @override
  State<DrinkingCalendar> createState() => _DrinkingCalendarState();
}

class _DrinkingCalendarState extends State<DrinkingCalendar> {
  late DateTime _currentMonth;
  Map<String, bool> _daysWithData = {};
  final HiveDatabaseService _databaseService = HiveDatabaseService.instance;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month);
    _loadMonthData();
  }

  Future<void> _loadMonthData() async {
    final endOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    
    final Map<String, bool> daysWithData = {};
    
    // Check each day in the month for drink entries
    for (int day = 1; day <= endOfMonth.day; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      
      try {
        final entries = await _databaseService.getDrinkEntriesForDate(date);
        daysWithData[dateKey] = entries.isNotEmpty;
      } catch (e) {
        daysWithData[dateKey] = false;
      }
    }
    
    if (mounted) {
      setState(() {
        _daysWithData = daysWithData;
      });
    }
  }

  bool _isDrinkingDay(DateTime date) {
    return _databaseService.isDrinkingDay(date: date);
  }

  bool _hasDataOnDate(DateTime date) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    return _daysWithData[dateKey] ?? false;
  }

  void _navigateMonth(int monthOffset) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + monthOffset);
    });
    _loadMonthData();
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7; // Make Sunday = 0

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _navigateMonth(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  DateFormat('MMMM y').format(_currentMonth),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => _navigateMonth(1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(
                  color: Colors.green.shade100,
                  label: 'Drinking Day',
                  borderColor: Colors.green.shade300,
                ),
                _buildLegendItem(
                  color: Colors.blue.shade100,
                  label: 'Has Data',
                  borderColor: Colors.blue.shade300,
                ),
                _buildLegendItem(
                  color: Colors.grey.shade100,
                  label: 'No Data',
                  borderColor: Colors.grey.shade300,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Weekday headers
            Row(
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .map((day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            
            const SizedBox(height: 8),
            
            // Calendar grid
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                ),
                itemCount: 42, // 6 weeks
                itemBuilder: (context, index) {
                  final dayNumber = index - firstWeekday + 1;
                  
                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const SizedBox(); // Empty cell
                  }
                  
                  final date = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
                  final isSelected = date.day == widget.selectedDate.day &&
                      date.month == widget.selectedDate.month &&
                      date.year == widget.selectedDate.year;
                  final isToday = DateTime.now().day == date.day &&
                      DateTime.now().month == date.month &&
                      DateTime.now().year == date.year;
                  final isDrinkingDay = _isDrinkingDay(date);
                  final hasData = _hasDataOnDate(date);
                  final isFutureDate = date.isAfter(DateTime.now());
                  
                  return GestureDetector(
                    onTap: isFutureDate ? null : () {
                      widget.onDateSelected(date);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: _getDateBackgroundColor(isSelected, isDrinkingDay, hasData, isToday, isFutureDate),
                        borderRadius: BorderRadius.circular(8),
                        border: _getDateBorder(isSelected, isDrinkingDay, hasData, isToday, isFutureDate),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dayNumber.toString(),
                              style: TextStyle(
                                fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                                color: _getDateTextColor(isSelected, isDrinkingDay, hasData, isToday, isFutureDate),
                                fontSize: 12,
                              ),
                            ),
                            if (hasData)
                              Container(
                                width: 4,
                                height: 4,
                                margin: const EdgeInsets.only(top: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade600,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Close button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required Color borderColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: borderColor),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  Color _getDateBackgroundColor(bool isSelected, bool isDrinkingDay, bool hasData, bool isToday, bool isFutureDate) {
    if (isFutureDate) {
      return Colors.grey.shade100; // Disabled appearance for future dates
    }
    if (isSelected) {
      return Theme.of(context).primaryColor;
    }
    if (isToday) {
      return Theme.of(context).primaryColor.withValues(alpha: 0.2);
    }
    if (hasData && isDrinkingDay) {
      return Colors.green.shade100;
    }
    if (hasData) {
      return Colors.blue.shade100;
    }
    if (isDrinkingDay) {
      return Colors.green.shade50;
    }
    return Colors.grey.shade50;
  }

  Border? _getDateBorder(bool isSelected, bool isDrinkingDay, bool hasData, bool isToday, bool isFutureDate) {
    if (isFutureDate) {
      return Border.all(color: Colors.grey.shade300); // Muted border for future dates
    }
    if (isSelected) {
      return Border.all(color: Theme.of(context).primaryColor, width: 2);
    }
    if (isToday) {
      return Border.all(color: Theme.of(context).primaryColor, width: 1);
    }
    if (hasData && isDrinkingDay) {
      return Border.all(color: Colors.green.shade300);
    }
    if (hasData) {
      return Border.all(color: Colors.blue.shade300);
    }
    if (isDrinkingDay) {
      return Border.all(color: Colors.green.shade200);
    }
    return Border.all(color: Colors.grey.shade200);
  }

  Color _getDateTextColor(bool isSelected, bool isDrinkingDay, bool hasData, bool isToday, bool isFutureDate) {
    if (isFutureDate) {
      return Colors.grey.shade400; // Muted text for future dates
    }
    if (isSelected) {
      return Colors.white;
    }
    if (isToday) {
      return Theme.of(context).primaryColor;
    }
    return Colors.grey.shade700;
  }
}
