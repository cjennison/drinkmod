import 'package:flutter/material.dart';

/// Widget for selecting days of the week for reminders
class WeekdaySelector extends StatelessWidget {
  final List<int> selectedDays;
  final ValueChanged<List<int>> onDaysChanged;

  const WeekdaySelector({
    super.key,
    required this.selectedDays,
    required this.onDaysChanged,
  });

  static const List<String> _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const List<String> _fullDayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick select buttons
        Row(
          children: [
            _buildQuickSelectButton(
              'Weekdays',
              [1, 2, 3, 4, 5],
              Icons.business_center,
            ),
            const SizedBox(width: 8),
            _buildQuickSelectButton(
              'Weekends',
              [6, 7],
              Icons.weekend,
            ),
            const SizedBox(width: 8),
            _buildQuickSelectButton(
              'Every day',
              [1, 2, 3, 4, 5, 6, 7],
              Icons.calendar_month,
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Individual day buttons
        Row(
          children: List.generate(7, (index) {
            final dayNumber = index + 1;
            final isSelected = selectedDays.contains(dayNumber);
            
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index < 6 ? 8 : 0,
                ),
                child: _buildDayButton(
                  dayNumber,
                  _dayNames[index],
                  _fullDayNames[index],
                  isSelected,
                ),
              ),
            );
          }),
        ),
        
        const SizedBox(height: 12),
        
        // Selection summary
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 16,
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getSelectionSummary(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickSelectButton(String label, List<int> days, IconData icon) {
    final isActive = _listsEqual(selectedDays, days);
    
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onDaysChanged(List<int>.from(days)),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: isActive 
                  ? Colors.blue.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActive 
                    ? Colors.blue
                    : Colors.grey.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isActive ? Colors.blue : Colors.grey[600],
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.blue : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayButton(int dayNumber, String shortName, String fullName, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleDay(dayNumber),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected 
                ? Colors.blue
                : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected 
                  ? Colors.blue
                  : Colors.grey.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Text(
                shortName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected 
                      ? Colors.white
                      : (selectedDays.isEmpty ? Colors.orange : Colors.transparent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleDay(int dayNumber) {
    final newDays = List<int>.from(selectedDays);
    
    if (newDays.contains(dayNumber)) {
      newDays.remove(dayNumber);
    } else {
      newDays.add(dayNumber);
    }
    
    newDays.sort();
    onDaysChanged(newDays);
  }

  bool _listsEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    final sortedA = List<int>.from(a)..sort();
    final sortedB = List<int>.from(b)..sort();
    
    for (int i = 0; i < sortedA.length; i++) {
      if (sortedA[i] != sortedB[i]) return false;
    }
    return true;
  }

  String _getSelectionSummary() {
    if (selectedDays.isEmpty) {
      return 'Select at least one day for your reminder';
    }
    
    if (selectedDays.length == 7) {
      return 'Reminder will repeat every day';
    }
    
    if (_listsEqual(selectedDays, [1, 2, 3, 4, 5])) {
      return 'Reminder will repeat on weekdays';
    }
    
    if (_listsEqual(selectedDays, [6, 7])) {
      return 'Reminder will repeat on weekends';
    }
    
    if (selectedDays.length == 1) {
      return 'Reminder will repeat every ${_fullDayNames[selectedDays.first - 1]}';
    }
    
    return 'Reminder will repeat on ${selectedDays.length} days per week';
  }
}
