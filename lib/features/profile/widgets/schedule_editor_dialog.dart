import 'package:flutter/material.dart';
import '../../../core/services/onboarding_service.dart';
import '../../../core/constants/onboarding_constants.dart';

/// Dialog for editing user's drinking schedule
class ScheduleEditorDialog extends StatefulWidget {
  final String? currentSchedule;
  final Function(String) onScheduleChanged;

  const ScheduleEditorDialog({
    super.key,
    required this.currentSchedule,
    required this.onScheduleChanged,
  });

  @override
  State<ScheduleEditorDialog> createState() => _ScheduleEditorDialogState();
}

class _ScheduleEditorDialogState extends State<ScheduleEditorDialog> {
  String? selectedSchedule;
  
  final List<Map<String, String>> scheduleOptions = [
    {
      'type': OnboardingConstants.scheduleWeekendsOnly,
      'title': OnboardingConstants.getDisplayText(OnboardingConstants.scheduleWeekendsOnly),
      'description': 'Friday, Saturday, Sunday',
    },
    {
      'type': OnboardingConstants.scheduleFridayOnly,
      'title': OnboardingConstants.getDisplayText(OnboardingConstants.scheduleFridayOnly),
      'description': 'Social drinking on Fridays',
    },
    {
      'type': OnboardingConstants.scheduleSocialOccasions,
      'title': OnboardingConstants.getDisplayText(OnboardingConstants.scheduleSocialOccasions),
      'description': 'When out with friends or special events',
    },
    {
      'type': OnboardingConstants.scheduleCustomWeekly,
      'title': OnboardingConstants.getDisplayText(OnboardingConstants.scheduleCustomWeekly),
      'description': 'Set specific days of the week',
    },
    {
      'type': OnboardingConstants.scheduleReducedCurrent,
      'title': OnboardingConstants.getDisplayText(OnboardingConstants.scheduleReducedCurrent),
      'description': 'Less frequent than current habit',
    },
  ];

  @override
  void initState() {
    super.initState();
    selectedSchedule = widget.currentSchedule;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Drinking Schedule'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose when you plan to drink:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: scheduleOptions.length,
                itemBuilder: (context, index) {
                  final option = scheduleOptions[index];
                  final isSelected = selectedSchedule == option['type'];
                  
                  return Card(
                    color: isSelected 
                      ? Theme.of(context).colorScheme.primaryContainer 
                      : null,
                    child: ListTile(
                      title: Text(
                        option['title']!,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(option['description']!),
                      leading: Radio<String>(
                        value: option['type']!,
                        groupValue: selectedSchedule,
                        onChanged: (value) {
                          setState(() {
                            selectedSchedule = value;
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          selectedSchedule = option['type'];
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: selectedSchedule != null ? () async {
            // Save the schedule
            await OnboardingService.updateUserData({
              'scheduleType': selectedSchedule,
            });
            
            widget.onScheduleChanged(selectedSchedule!);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          } : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
