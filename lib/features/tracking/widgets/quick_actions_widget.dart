import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/drink_intervention_utils.dart';
import '../../../core/services/hive_database_service.dart';

/// Quick actions widget for fast drink logging and other actions
class QuickActionsWidget extends StatelessWidget {
  final VoidCallback onOpenDrinkLogging;
  final VoidCallback onShowQuickLogSheet;
  final bool isRetroactive;
  final DateTime date;

  const QuickActionsWidget({
    super.key,
    required this.onOpenDrinkLogging,
    required this.onShowQuickLogSheet,
    this.isRetroactive = false,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final databaseService = HiveDatabaseService.instance;
    final shouldShowQuickLog = DrinkInterventionUtils.shouldShowQuickLog(
      date: date,
      databaseService: databaseService,
      isRetroactive: isRetroactive,
    );
    final quickLogButtonText = DrinkInterventionUtils.getQuickLogButtonText(
      date: date,
      databaseService: databaseService,
      isRetroactive: isRetroactive,
    );
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          if (isRetroactive) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.history, color: Colors.orange.shade600, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Logging drinks for ${DateFormat('EEEE, MMM d').format(date)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onOpenDrinkLogging,
                  icon: Icon(isRetroactive ? Icons.history : Icons.add),
                  label: Text(isRetroactive ? 'Add Past Drink' : 'Log Drink'),
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
                  onPressed: shouldShowQuickLog ? onShowQuickLogSheet : null,
                  icon: Icon(_getQuickLogIcon(quickLogButtonText)),
                  label: Text(quickLogButtonText),
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
        ],
      ),
    );
  }

  IconData _getQuickLogIcon(String buttonText) {
    switch (buttonText) {
      case 'Full Log Only':
        return Icons.schedule;
      case 'Alcohol-Free Day':
        return Icons.block;
      case 'Quick Log':
      default:
        return Icons.flash_on;
    }
  }
}
