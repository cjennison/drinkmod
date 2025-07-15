import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Individual drink entry card with actions and content indicators
class DrinkEntryCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final DateTime date;
  final VoidCallback onViewDetails;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DrinkEntryCard({
    super.key,
    required this.entry,
    required this.date,
    required this.onViewDetails,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final standardDrinks = entry['standardDrinks']?.toDouble() ?? 0.0;
    final drinkName = entry['drinkName'] as String;
    final hasAdditionalContent = _hasAdditionalContent();
    
    DateTime entryTime;
    try {
      entryTime = DateTime.parse(entry['drinkDate']);
    } catch (e) {
      entryTime = date;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_drink,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            drinkName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (hasAdditionalContent)
                          Icon(
                            Icons.star,
                            color: Colors.amber.shade600,
                            size: 16,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${standardDrinks.toStringAsFixed(1)} std drinks',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          entry['timeOfDay'] ?? DateFormat('h:mm a').format(entryTime),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onViewDetails,
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('View'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    textStyle: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    textStyle: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: onDelete,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  foregroundColor: Colors.red.shade600,
                  side: BorderSide(color: Colors.red.shade300),
                ),
                child: const Icon(Icons.delete_outline, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _hasAdditionalContent() {
    // Check for context info
    if (entry['location'] != null || entry['socialContext'] != null) {
      return true;
    }
    
    // Check for emotional info
    if (entry['moodBefore'] != null || 
        (entry['triggers'] != null && _hasTriggersContent(entry['triggers'])) ||
        entry['triggerDescription'] != null) {
      return true;
    }
    
    // Check for reflection info
    if (entry['intention'] != null && entry['intention'] != 'Quick logged' || 
        entry['urgeIntensity'] != null || 
        entry['consideredAlternatives'] != null) {
      return true;
    }
    
    // Check for notes or other additional fields
    if (entry['notes'] != null && (entry['notes'] as String).isNotEmpty) {
      return true;
    }
    
    return false;
  }

  bool _hasTriggersContent(dynamic triggers) {
    if (triggers == null) return false;
    if (triggers is List) {
      return triggers.isNotEmpty;
    }
    if (triggers is String) {
      String cleanString = triggers.replaceAll(RegExp(r'[\[\]]'), '').trim();
      return cleanString.isNotEmpty;
    }
    return false;
  }
}
