import 'package:flutter/material.dart';
import '../../../core/services/onboarding_service.dart';

/// Dialog for editing user's name and gender
class NameEditorDialog extends StatefulWidget {
  final String? currentName;
  final String? currentGender;
  final Function(String name, String gender) onDataChanged;

  const NameEditorDialog({
    super.key,
    required this.currentName,
    required this.currentGender,
    required this.onDataChanged,
  });

  @override
  State<NameEditorDialog> createState() => _NameEditorDialogState();
}

class _NameEditorDialogState extends State<NameEditorDialog> {
  late TextEditingController nameController;
  String? selectedGender;
  
  final List<String> genderOptions = ['male', 'female', 'non-binary', 'prefer not to say'];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentName ?? '');
    selectedGender = widget.currentGender;
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  String _formatGender(String gender) {
    switch (gender) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      case 'non-binary':
        return 'Non-binary';
      case 'prefer not to say':
        return 'Prefer not to say';
      default:
        return gender;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Personal Information'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Name field
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your name or preferred name',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            
            const SizedBox(height: 24),
            
            // Gender selection
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Gender',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            ...genderOptions.map((gender) => RadioListTile<String>(
              title: Text(_formatGender(gender)),
              value: gender,
              groupValue: selectedGender,
              onChanged: (value) {
                setState(() {
                  selectedGender = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: nameController.text.trim().isNotEmpty && selectedGender != null ? () async {
            // Save the data
            await OnboardingService.updateUserData({
              'name': nameController.text.trim(),
              'gender': selectedGender,
            });
            
            widget.onDataChanged(nameController.text.trim(), selectedGender!);
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
