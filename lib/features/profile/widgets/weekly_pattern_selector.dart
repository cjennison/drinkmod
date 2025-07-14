import 'package:flutter/material.dart';

/// Widget for selecting days of the week for custom weekly drinking patterns
class WeeklyPatternSelector extends StatefulWidget {
  final List<int>? initialPattern;
  final ValueChanged<List<int>> onPatternChanged;

  const WeeklyPatternSelector({
    super.key,
    this.initialPattern,
    required this.onPatternChanged,
  });

  @override
  State<WeeklyPatternSelector> createState() => _WeeklyPatternSelectorState();
}

class _WeeklyPatternSelectorState extends State<WeeklyPatternSelector> {
  late List<int> selectedDays;
  
  final List<String> dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<String> fullDayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  void initState() {
    super.initState();
    selectedDays = List<int>.from(widget.initialPattern ?? []);
  }

  @override
  void didUpdateWidget(WeeklyPatternSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPattern != oldWidget.initialPattern) {
      selectedDays = List<int>.from(widget.initialPattern ?? []);
    }
  }

  void _toggleDay(int dayIndex) {
    setState(() {
      if (selectedDays.contains(dayIndex)) {
        selectedDays.remove(dayIndex);
      } else {
        selectedDays.add(dayIndex);
      }
      selectedDays.sort(); // Keep sorted for consistency
    });
    widget.onPatternChanged(selectedDays);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select your drinking days:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        // Day selector grid
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Days of the week
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(7, (index) {
                  final isSelected = selectedDays.contains(index);
                  
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        children: [
                          Text(
                            dayNames[index],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isSelected 
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _toggleDay(index),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected 
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey[200],
                                border: Border.all(
                                  color: isSelected 
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey[400]!,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: isSelected
                                  ? Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 20,
                                    )
                                  : Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              
              if (selectedDays.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Selected days: ${selectedDays.map((i) => dayNames[i]).join(', ')}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        
        if (selectedDays.isEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  size: 16,
                  color: Colors.orange[700],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Please select at least one day for your drinking schedule.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
