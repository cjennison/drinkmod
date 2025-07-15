import 'package:flutter/material.dart';
import '../../../core/services/onboarding_service.dart';
import '../../../core/constants/onboarding_constants.dart';

/// Dialog for editing user's limit strictness level
class StrictnessLevelEditorDialog extends StatefulWidget {
  final String? currentStrictnessLevel;
  final Function(String) onStrictnessLevelChanged;

  const StrictnessLevelEditorDialog({
    super.key,
    required this.currentStrictnessLevel,
    required this.onStrictnessLevelChanged,
  });

  @override
  State<StrictnessLevelEditorDialog> createState() => _StrictnessLevelEditorDialogState();
}

class _StrictnessLevelEditorDialogState extends State<StrictnessLevelEditorDialog> {
  String? selectedStrictnessLevel;
  
  final List<Map<String, String>> strictnessOptions = [
    {
      'value': OnboardingConstants.strictnessHigh,
      'title': 'High Strictness',
      'description': 'No tolerance - limits are firm boundaries (0% over)',
      'detail': 'Best for those who need clear, non-negotiable limits'
    },
    {
      'value': OnboardingConstants.strictnessMedium,
      'title': 'Medium Strictness',
      'description': 'Some flexibility - moderate tolerance (50% over)',
      'detail': 'Balanced approach with some room for special occasions'
    },
    {
      'value': OnboardingConstants.strictnessLow,
      'title': 'Low Strictness',
      'description': 'Flexible approach - high tolerance (100% over)',
      'detail': 'For those focusing on awareness rather than rigid limits'
    },
  ];

  @override
  void initState() {
    super.initState();
    selectedStrictnessLevel = widget.currentStrictnessLevel ?? OnboardingConstants.defaultStrictnessLevel;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tune, color: Colors.blue),
                const SizedBox(width: 12),
                const Text(
                  'Limit Strictness Level',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            const Text(
              'How strict should DrinkMod be when you approach or exceed your daily limits?',
              style: TextStyle(color: Colors.grey),
            ),
            
            const SizedBox(height: 24),
            
            // Strictness level options
            ...strictnessOptions.map((option) => _buildStrictnessOption(option)),
            
            const SizedBox(height: 32),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: selectedStrictnessLevel != null ? _saveStrictnessLevel : null,
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrictnessOption(Map<String, String> option) {
    final isSelected = selectedStrictnessLevel == option['value'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              selectedStrictnessLevel = option['value'];
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              color: isSelected 
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected 
                      ? Theme.of(context).primaryColor 
                      : Colors.grey.shade600,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option['title']!,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected 
                              ? Theme.of(context).primaryColor 
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        option['description']!,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        option['detail']!,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveStrictnessLevel() async {
    if (selectedStrictnessLevel == null) return;

    // Save to user data
    await OnboardingService.updateUserData({
      'strictnessLevel': selectedStrictnessLevel!,
    });

    // Call the callback
    widget.onStrictnessLevelChanged(selectedStrictnessLevel!);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
