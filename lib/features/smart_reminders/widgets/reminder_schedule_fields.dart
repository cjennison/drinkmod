import 'package:flutter/material.dart';
import 'time_picker_field.dart';
import 'weekday_selector.dart';

/// Shared time and weekday selection widgets
class ReminderScheduleFields extends StatelessWidget {
  final TimeOfDay selectedTime;
  final List<int> selectedWeekDays;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final ValueChanged<List<int>> onDaysChanged;

  const ReminderScheduleFields({
    super.key,
    required this.selectedTime,
    required this.selectedWeekDays,
    required this.onTimeChanged,
    required this.onDaysChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time Selector
        const Text(
          'Time',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TimePickerField(
          selectedTime: selectedTime,
          onTimeChanged: onTimeChanged,
        ),
        
        const SizedBox(height: 24),
        
        // Days Selector
        const Text(
          'Days of the Week',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        WeekdaySelector(
          selectedDays: selectedWeekDays,
          onDaysChanged: onDaysChanged,
        ),
      ],
    );
  }
}
