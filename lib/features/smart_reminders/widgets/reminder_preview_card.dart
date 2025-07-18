import 'package:flutter/material.dart';
import '../models/smart_reminder.dart';

/// Shared preview card widget for reminder creation and editing
class ReminderPreviewCard extends StatelessWidget {
  final SmartReminderType selectedType;
  final TextEditingController titleController;
  final TextEditingController messageController;

  const ReminderPreviewCard({
    super.key,
    required this.selectedType,
    required this.titleController,
    required this.messageController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selectedType.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selectedType.color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview,
                color: selectedType.color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Preview',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: selectedType.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  selectedType.icon,
                  color: selectedType.color,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titleController.text.isEmpty
                            ? selectedType.defaultTitle
                            : titleController.text,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        messageController.text.isEmpty
                            ? 'Smart message based on your current progress'
                            : messageController.text,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
