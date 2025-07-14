import 'package:flutter/material.dart';
import '../../../core/services/onboarding_service.dart';
import '../../../core/constants/onboarding_constants.dart';

/// Dialog for editing user's motivation for moderating alcohol consumption
class MotivationEditorDialog extends StatefulWidget {
  final String? currentMotivation;
  final Function(String) onMotivationChanged;

  const MotivationEditorDialog({
    super.key,
    required this.currentMotivation,
    required this.onMotivationChanged,
  });

  @override
  State<MotivationEditorDialog> createState() => _MotivationEditorDialogState();
}

class _MotivationEditorDialogState extends State<MotivationEditorDialog> {
  String? selectedMotivation;
  TextEditingController? customController;
  
  final List<Map<String, String>> motivationOptions = [
    {
      'value': OnboardingConstants.motivationHealth,
      'title': OnboardingConstants.getDisplayText(OnboardingConstants.motivationHealth),
      'description': 'Improve physical and mental health',
    },
    {
      'value': OnboardingConstants.motivationSaveMoney,
      'title': OnboardingConstants.getDisplayText(OnboardingConstants.motivationSaveMoney),
      'description': 'Save money on alcohol expenses',
    },
    {
      'value': OnboardingConstants.motivationFamily,
      'title': OnboardingConstants.getDisplayText(OnboardingConstants.motivationFamily),
      'description': 'Better relationships with family and friends',
    },
    {
      'value': OnboardingConstants.motivationPersonalGrowth,
      'title': OnboardingConstants.getDisplayText(OnboardingConstants.motivationPersonalGrowth),
      'description': 'Improve focus and performance',
    },
    {
      'value': OnboardingConstants.motivationWeightLoss,
      'title': OnboardingConstants.getDisplayText(OnboardingConstants.motivationWeightLoss),
      'description': 'Reduce calories and maintain weight',
    },
    {
      'value': OnboardingConstants.motivationBetterSleep,
      'title': OnboardingConstants.getDisplayText(OnboardingConstants.motivationBetterSleep),
      'description': 'Better sleep and recovery',
    },
    {
      'value': 'other',
      'title': 'Other',
      'description': 'Custom reason',
    },
  ];

  @override
  void initState() {
    super.initState();
    selectedMotivation = widget.currentMotivation;
    
    // If current motivation is not in predefined list, treat as custom
    if (selectedMotivation != null && 
        !motivationOptions.any((option) => option['value'] == selectedMotivation)) {
      customController = TextEditingController(text: selectedMotivation);
      selectedMotivation = 'other';
    }
  }

  @override
  void dispose() {
    customController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Motivation'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Why do you want to moderate your alcohol consumption?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: motivationOptions.length,
                itemBuilder: (context, index) {
                  final option = motivationOptions[index];
                  final isSelected = selectedMotivation == option['value'];
                  
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
                        value: option['value']!,
                        groupValue: selectedMotivation,
                        onChanged: (value) {
                          setState(() {
                            selectedMotivation = value;
                            if (value == 'other' && customController == null) {
                              customController = TextEditingController();
                            }
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          selectedMotivation = option['value'];
                          if (option['value'] == 'other' && customController == null) {
                            customController = TextEditingController();
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            
            // Custom motivation field
            if (selectedMotivation == 'other') ...[
              const SizedBox(height: 16),
              TextField(
                controller: customController,
                decoration: const InputDecoration(
                  labelText: 'Your reason',
                  hintText: 'Enter your custom motivation',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _canSave() ? () async {
            final motivationToSave = selectedMotivation == 'other' 
              ? customController?.text.trim() 
              : selectedMotivation;
              
            if (motivationToSave != null && motivationToSave.isNotEmpty) {
              // Save the motivation
              await OnboardingService.updateUserData({
                'motivation': motivationToSave,
              });
              
              widget.onMotivationChanged(motivationToSave);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            }
          } : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
  
  bool _canSave() {
    if (selectedMotivation == null) return false;
    if (selectedMotivation == 'other') {
      return customController?.text.trim().isNotEmpty == true;
    }
    return true;
  }
}
