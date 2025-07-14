import 'package:flutter/material.dart';
import '../../../core/models/drink_entry.dart';

/// Widget for selecting time of day when a drink was consumed
class TimeOfDaySelectorWidget extends StatelessWidget {
  final String? selectedTimeOfDay;
  final Function(String?) onTimeOfDaySelected;

  const TimeOfDaySelectorWidget({
    super.key,
    required this.selectedTimeOfDay,
    required this.onTimeOfDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time of day:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TriggerConstants.timeOfDayOptions.map((timeOfDay) {
                final isSelected = selectedTimeOfDay == timeOfDay;
                return FilterChip(
                  label: Text(timeOfDay),
                  selected: isSelected,
                  onSelected: (selected) {
                    onTimeOfDaySelected(selected ? timeOfDay : null);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
