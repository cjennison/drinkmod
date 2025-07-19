import 'package:flutter/material.dart';
import 'drink_entry_card.dart';

/// List widget for displaying drink entries with proper formatting
class DrinkEntriesList extends StatelessWidget {
  final List<Map<String, dynamic>> entries;
  final DateTime date;
  final Function(Map<String, dynamic>) onViewDetails;
  final Function(Map<String, dynamic>) onEdit;
  final Function(Map<String, dynamic>) onDelete;

  const DrinkEntriesList({
    super.key,
    required this.entries,
    required this.date,
    required this.onViewDetails,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Container(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(
              Icons.local_drink_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No drinks logged',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track your first drink of the day',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Drinks Today (${entries.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DrinkEntryCard(
              entry: entry,
              date: date,
              onViewDetails: () => onViewDetails(entry),
              onEdit: () => onEdit(entry),
              onDelete: () => onDelete(entry),
            ),
          )),
        ],
      ),
    );
  }
}
