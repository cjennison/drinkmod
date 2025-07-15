import 'package:flutter/material.dart';
import 'context_log_widget.dart';

/// Widget for the emotional check-in step in the logging flow
class EmotionalCheckinLogWidget extends StatelessWidget {
  final int? moodBefore;
  final List<String> triggers;
  final String? triggerDescription;
  final Function(int?) onMoodSelected;
  final Function(List<String>) onTriggersChanged;
  final Function(String?) onTriggerDescriptionChanged;

  const EmotionalCheckinLogWidget({
    super.key,
    required this.moodBefore,
    required this.triggers,
    required this.triggerDescription,
    required this.onMoodSelected,
    required this.onTriggersChanged,
    required this.onTriggerDescriptionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Check in with yourself (optional but helpful)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          
          _buildMoodSelector(context),
          const SizedBox(height: 16),
          _buildTriggerSelector(context),
          const SizedBox(height: 16),
          _buildTriggerDescription(context),
        ],
      ),
    );
  }

  Widget _buildMoodSelector(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood (1-10)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(10, (index) {
                final mood = index + 1;
                final isSelected = moodBefore == mood;
                return GestureDetector(
                  onTap: () {
                    onMoodSelected(mood);
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey.shade200,
                    ),
                    child: Center(
                      child: Text(
                        mood.toString(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('😢 Low', style: Theme.of(context).textTheme.bodySmall),
                Text('😊 High', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTriggerSelector(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What led to this drink?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...TriggerConstants.triggersByCategory.entries.map((category) {
              return ExpansionTile(
                title: Text(category.key),
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: category.value.map((trigger) {
                      final isSelected = triggers.contains(trigger);
                      return FilterChip(
                        label: Text(trigger),
                        selected: isSelected,
                        onSelected: (selected) {
                          final newTriggers = List<String>.from(triggers);
                          if (selected) {
                            newTriggers.add(trigger);
                          } else {
                            newTriggers.remove(trigger);
                          }
                          onTriggersChanged(newTriggers);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTriggerDescription(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tell us more (optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: triggerDescription,
              decoration: const InputDecoration(
                hintText: 'What led to this moment? How are you feeling?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                onTriggerDescriptionChanged(value.isNotEmpty ? value : null);
              },
            ),
          ],
        ),
      ),
    );
  }
}
