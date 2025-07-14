import 'package:flutter/material.dart';
import '../../../core/services/onboarding_service.dart';
import '../../../core/constants/onboarding_constants.dart';

/// Dialog for editing user's drinking patterns (frequency and amount)
class DrinkingPatternsEditorDialog extends StatefulWidget {
  final String? currentFrequency;
  final String? currentAmount;
  final Function(String frequency, String amount) onPatternsChanged;

  const DrinkingPatternsEditorDialog({
    super.key,
    required this.currentFrequency,
    required this.currentAmount,
    required this.onPatternsChanged,
  });

  @override
  State<DrinkingPatternsEditorDialog> createState() => _DrinkingPatternsEditorDialogState();
}

class _DrinkingPatternsEditorDialogState extends State<DrinkingPatternsEditorDialog> {
  String? selectedFrequency;
  String? selectedAmount;

  @override
  void initState() {
    super.initState();
    selectedFrequency = widget.currentFrequency ?? OnboardingConstants.frequencyOnceOrTwiceWeek;
    selectedAmount = widget.currentAmount ?? OnboardingConstants.amount1To2;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Drinking Patterns'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How often do you typically drink?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedFrequency,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: OnboardingConstants.frequencyOptions.map((frequency) {
                return DropdownMenuItem(
                  value: frequency,
                  child: Text(OnboardingConstants.getDisplayText(frequency)),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedFrequency = value!),
            ),
            const SizedBox(height: 24),
            
            const Text(
              'How much do you typically drink per occasion?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedAmount,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: OnboardingConstants.amountOptions.map((amount) {
                return DropdownMenuItem(
                  value: amount,
                  child: Text(OnboardingConstants.getDisplayText(amount)),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedAmount = value!),
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
          onPressed: () async {
            if (selectedFrequency != null && selectedAmount != null) {
              // Save the patterns
              await OnboardingService.updateUserData({
                'drinkingFrequency': selectedFrequency,
                'drinkingAmount': selectedAmount,
              });
              
              widget.onPatternsChanged(selectedFrequency!, selectedAmount!);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
