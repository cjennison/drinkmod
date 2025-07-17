import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/user_goal.dart';

/// Shared form field components for goal creation and editing
class GoalFormComponents {
  /// Creates a text input field with common styling and validation
  static Widget buildTextInput({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool isRequired = false,
    String? Function(String?)? validator,
    int maxLength = 100,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
    Widget? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        border: const OutlineInputBorder(),
        counterText: '',
      ),
      validator: validator ??
          (isRequired
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '$label is required';
                  }
                  return null;
                }
              : null),
      maxLength: maxLength,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
    );
  }

  /// Creates a numeric input field with validation
  static Widget buildNumericInput({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool isRequired = false,
    double? min,
    double? max,
    bool allowDecimals = false,
    Widget? suffixIcon,
    Widget? prefixIcon,
  }) {
    return buildTextInput(
      controller: controller,
      label: label,
      hint: hint,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimals),
      inputFormatters: [
        if (allowDecimals)
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
        else
          FilteringTextInputFormatter.digitsOnly,
      ],
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return '$label is required';
        }
        if (value != null && value.isNotEmpty) {
          final numValue = double.tryParse(value);
          if (numValue == null) {
            return 'Please enter a valid number';
          }
          if (min != null && numValue < min) {
            return 'Value must be at least $min';
          }
          if (max != null && numValue > max) {
            return 'Value must be at most $max';
          }
        }
        return null;
      },
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
    );
  }

  /// Creates a dropdown selection field
  static Widget buildDropdownField<T>({
    required T? value,
    required List<T> items,
    required String label,
    required void Function(T?) onChanged,
    required String Function(T) itemLabel,
    String? hint,
    bool isRequired = false,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(itemLabel(item)),
        );
      }).toList(),
      onChanged: onChanged,
      validator: isRequired
          ? (value) {
              if (value == null) {
                return '$label is required';
              }
              return null;
            }
          : null,
    );
  }

  /// Creates a labeled section container
  static Widget buildFormSection({
    required String title,
    required List<Widget> children,
    String? subtitle,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 16),
            ...children.map((child) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: child,
                )),
          ],
        ),
      ),
    );
  }

  /// Creates a goal type-specific field based on the goal type
  static Widget buildGoalTypeField({
    required GoalType goalType,
    required String label,
    required TextEditingController controller,
    String? hint,
    bool isRequired = false,
  }) {
    IconData icon;
    double? min, max;
    bool allowDecimals = false;
    String defaultHint;

    switch (goalType) {
      case GoalType.weeklyReduction:
        icon = Icons.trending_down;
        min = 0;
        max = 100;
        defaultHint = 'Enter target drinks per week';
        break;
      case GoalType.dailyLimit:
        icon = Icons.balance;
        min = 1;
        max = 10;
        allowDecimals = true;
        defaultHint = 'Enter daily limit';
        break;
      case GoalType.alcoholFreeDays:
        icon = Icons.calendar_today;
        min = 1;
        max = 7;
        defaultHint = 'Enter alcohol-free days per week';
        break;
      case GoalType.interventionWins:
        icon = Icons.psychology;
        min = 1;
        max = 100;
        defaultHint = 'Enter intervention wins';
        break;
      case GoalType.moodImprovement:
        icon = Icons.mood;
        min = 1;
        max = 10;
        defaultHint = 'Enter target mood rating';
        break;
      case GoalType.streakMaintenance:
        icon = Icons.local_fire_department;
        min = 1;
        max = 365;
        defaultHint = 'Enter streak days';
        break;
      case GoalType.costSavings:
        return buildMoneyField(
          controller: controller,
          label: label,
          hint: hint ?? 'Enter savings target',
          isRequired: isRequired,
        );
      case GoalType.customGoal:
        icon = Icons.edit;
        min = 0;
        max = 1000;
        allowDecimals = true;
        defaultHint = 'Enter custom target';
        break;
    }

    return buildNumericInput(
      controller: controller,
      label: label,
      hint: hint ?? defaultHint,
      isRequired: isRequired,
      min: min,
      max: max,
      allowDecimals: allowDecimals,
      suffixIcon: Icon(icon),
    );
  }

  /// Creates a duration input field with time unit selection
  static Widget buildDurationField({
    required TextEditingController controller,
    required String? selectedUnit,
    required void Function(String?) onUnitChanged,
    String label = 'Duration',
    bool isRequired = false,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: buildNumericInput(
            controller: controller,
            label: label,
            hint: 'Enter duration',
            isRequired: isRequired,
            min: 1,
            max: 365,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: buildDropdownField<String>(
            value: selectedUnit,
            items: const ['Days', 'Weeks', 'Months'],
            label: 'Unit',
            onChanged: onUnitChanged,
            itemLabel: (unit) => unit,
            isRequired: isRequired,
          ),
        ),
      ],
    );
  }

  /// Creates a monetary input field
  static Widget buildMoneyField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool isRequired = false,
    String currency = '\$',
  }) {
    return buildNumericInput(
      controller: controller,
      label: label,
      hint: hint ?? 'Enter amount',
      isRequired: isRequired,
      min: 0,
      max: 10000,
      allowDecimals: true,
      prefixIcon: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          currency,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
