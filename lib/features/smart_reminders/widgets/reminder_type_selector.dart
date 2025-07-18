import 'package:flutter/material.dart';
import '../models/smart_reminder.dart';

/// Widget for selecting reminder type with visual cards
class ReminderTypeSelector extends StatelessWidget {
  final SmartReminderType selectedType;
  final ValueChanged<SmartReminderType> onTypeChanged;

  const ReminderTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: SmartReminderType.values.map((type) {
        final isSelected = type == selectedType;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onTypeChanged(type),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? type.color.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? type.color
                        : Colors.grey.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Type icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? type.color.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        type.icon,
                        color: isSelected ? type.color : Colors.grey[600],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Type info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type.displayName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? type.color : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            type.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildFeatureChips(type, isSelected),
                        ],
                      ),
                    ),
                    
                    // Selection indicator
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? type.color : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? type.color : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeatureChips(SmartReminderType type, bool isSelected) {
    final features = _getTypeFeatures(type);
    
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: features.map((feature) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected 
                ? type.color.withValues(alpha: 0.15)
                : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            feature,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? type.color : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  List<String> _getTypeFeatures(SmartReminderType type) {
    switch (type) {
      case SmartReminderType.friendlyCheckin:
        return ['Gentle nudges', 'Progress awareness', 'Motivational'];
      case SmartReminderType.scheduleReminder:
        return ['Goal tracking', 'Daily awareness', 'Habit building'];
    }
  }
}
