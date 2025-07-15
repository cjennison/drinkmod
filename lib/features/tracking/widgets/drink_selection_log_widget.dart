import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/services/drink_database_service.dart';
import 'time_of_day_selector_widget.dart';
import 'drink_selection_widget.dart';

/// Widget for the drink selection step in the logging flow
class DrinkSelectionLogWidget extends StatelessWidget {
  final DateTime? selectedDate;
  final String? selectedTimeOfDay;
  final DrinkInfo? selectedDrink;
  final bool isInitializing;
  final Function(String?) onTimeOfDaySelected;
  final Function(DrinkInfo) onDrinkSelected;
  final VoidCallback onShowDatePicker;

  const DrinkSelectionLogWidget({
    super.key,
    required this.selectedDate,
    required this.selectedTimeOfDay,
    required this.selectedDrink,
    required this.isInitializing,
    required this.onTimeOfDaySelected,
    required this.onDrinkSelected,
    required this.onShowDatePicker,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What did you drink?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Select from common drinks or enter a custom amount',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          
          // Date selection (when not today)
          _buildDateSelector(context),
          
          // Time selection
          TimeOfDaySelectorWidget(
            selectedTimeOfDay: selectedTimeOfDay,
            onTimeOfDaySelected: onTimeOfDaySelected,
          ),
          const SizedBox(height: 24),
          
          // Drink selection and display
          if (isInitializing) 
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading drink information...'),
                ],
              ),
            )
          else
            DrinkSelectionWidget(
              selectedDrink: selectedDrink,
              onDrinkSelected: onDrinkSelected,
            ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    final selectedDate = this.selectedDate ?? DateTime.now();
    final isToday = _isSameDay(selectedDate, DateTime.now());
    
    if (isToday) {
      return const SizedBox.shrink(); // Don't show for today
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, 
                     color: Colors.orange.shade600, 
                     size: 20),
                const SizedBox(width: 8),
                Text(
                  'Date',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.history, color: Colors.orange.shade600, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Retroactive Entry',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('EEEE, MMMM d, y').format(selectedDate),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: onShowDatePicker,
                    child: const Text('Change'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}
