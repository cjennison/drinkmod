import 'package:flutter/material.dart';

/// Quick actions widget for fast drink logging and other actions
class QuickActionsWidget extends StatelessWidget {
  final VoidCallback onOpenDrinkLogging;
  final VoidCallback onShowQuickLogSheet;

  const QuickActionsWidget({
    super.key,
    required this.onOpenDrinkLogging,
    required this.onShowQuickLogSheet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onOpenDrinkLogging,
              icon: const Icon(Icons.add),
              label: const Text('Log Drink'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onShowQuickLogSheet,
              icon: const Icon(Icons.flash_on),
              label: const Text('Quick Log'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
