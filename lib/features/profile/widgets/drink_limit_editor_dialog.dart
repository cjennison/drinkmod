import 'package:flutter/material.dart';
import '../../../core/services/onboarding_service.dart';

/// Dialog for editing user's daily drink limit
class DrinkLimitEditorDialog extends StatefulWidget {
  final int? currentLimit;
  final Function(int) onLimitChanged;

  const DrinkLimitEditorDialog({
    super.key,
    required this.currentLimit,
    required this.onLimitChanged,
  });

  @override
  State<DrinkLimitEditorDialog> createState() => _DrinkLimitEditorDialogState();
}

class _DrinkLimitEditorDialogState extends State<DrinkLimitEditorDialog> {
  late double selectedLimit;
  
  @override
  void initState() {
    super.initState();
    selectedLimit = (widget.currentLimit ?? 2).toDouble();
  }

  String _getLimitDescription(int limit) {
    switch (limit) {
      case 1:
        return 'Light drinking - 1 standard drink';
      case 2:
        return 'Moderate drinking - 2 standard drinks';
      case 3:
        return 'Social drinking - 3 standard drinks';
      case 4:
        return 'Higher limit - 4 standard drinks';
      case 5:
        return 'High limit - 5 standard drinks';
      case 6:
        return 'Maximum recommended - 6 standard drinks';
      default:
        return '$limit standard drinks';
    }
  }

  Color _getLimitColor(int limit) {
    if (limit <= 2) return Colors.green;
    if (limit <= 4) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final limit = selectedLimit.round();
    
    return AlertDialog(
      title: const Text('Edit Daily Drink Limit'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Set your daily drink limit for drinking days:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            
            // Current selection display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getLimitColor(limit).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getLimitColor(limit).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '$limit drinks',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _getLimitColor(limit),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getLimitDescription(limit),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Slider
            Slider(
              value: selectedLimit,
              min: 1,
              max: 6,
              divisions: 5,
              label: '$limit drinks',
              onChanged: (value) {
                setState(() {
                  selectedLimit = value;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Health guidance
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Health guidelines suggest 1-2 drinks per day for moderation.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
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
          onPressed: () async {
            // Save the limit
            await OnboardingService.updateUserData({
              'drinkLimit': limit,
            });
            
            widget.onLimitChanged(limit);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
