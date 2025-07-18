import 'package:flutter/material.dart';

/// Shared form fields for reminder title and custom message
class ReminderFormFields extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController messageController;
  final VoidCallback? onChanged;

  const ReminderFormFields({
    super.key,
    required this.titleController,
    required this.messageController,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Field
        const Text(
          'Title',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: titleController,
          decoration: InputDecoration(
            hintText: 'Enter reminder title',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          maxLength: 50,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a title';
            }
            if (value.trim().length < 3) {
              return 'Title must be at least 3 characters';
            }
            return null;
          },
          onChanged: (_) => onChanged?.call(),
        ),
        
        const SizedBox(height: 16),
        
        // Custom Message Field
        const Text(
          'Custom Message (Optional)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Leave empty to use smart, personalized messages',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: messageController,
          decoration: InputDecoration(
            hintText: 'Enter custom notification message',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          maxLines: 3,
          maxLength: 150,
          onChanged: (_) => onChanged?.call(),
        ),
      ],
    );
  }
}
