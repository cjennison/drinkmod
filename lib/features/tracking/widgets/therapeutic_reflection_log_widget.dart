import 'package:flutter/material.dart';

/// Widget for the therapeutic reflection step in the logging flow
class TherapeuticReflectionLogWidget extends StatelessWidget {
  final String? intention;
  final int? urgeIntensity;
  final bool? consideredAlternatives;
  final String? alternatives;
  final Function(String?) onIntentionChanged;
  final Function(int?) onUrgeIntensityChanged;
  final Function(bool?) onConsideredAlternativesChanged;
  final Function(String?) onAlternativesChanged;

  const TherapeuticReflectionLogWidget({
    super.key,
    required this.intention,
    required this.urgeIntensity,
    required this.consideredAlternatives,
    required this.alternatives,
    required this.onIntentionChanged,
    required this.onUrgeIntensityChanged,
    required this.onConsideredAlternativesChanged,
    required this.onAlternativesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reflection & Intention',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Mindful questions for deeper awareness',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          
          _buildIntentionInput(context),
          const SizedBox(height: 16),
          _buildUrgeIntensitySelector(context),
          const SizedBox(height: 16),
          _buildAlternativesSection(context),
        ],
      ),
    );
  }

  Widget _buildIntentionInput(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What\'s your plan for this session?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: intention,
              decoration: const InputDecoration(
                hintText: 'e.g., "Just this one drink with dinner"',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                onIntentionChanged(value.isNotEmpty ? value : null);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrgeIntensitySelector(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How strong was the urge? (1-10)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Slider(
              value: (urgeIntensity ?? 5).toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: urgeIntensity?.toString() ?? '5',
              onChanged: (value) {
                onUrgeIntensityChanged(value.round());
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mild', style: Theme.of(context).textTheme.bodySmall),
                Text('Intense', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlternativesSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Did you consider alternatives?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Yes'),
                    value: true,
                    groupValue: consideredAlternatives,
                    onChanged: onConsideredAlternativesChanged,
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('No'),
                    value: false,
                    groupValue: consideredAlternatives,
                    onChanged: onConsideredAlternativesChanged,
                  ),
                ),
              ],
            ),
            
            if (consideredAlternatives == true) ...[
              const SizedBox(height: 12),
              TextFormField(
                initialValue: alternatives,
                decoration: const InputDecoration(
                  hintText: 'What alternatives did you consider?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onChanged: (value) {
                  onAlternativesChanged(value.isNotEmpty ? value : null);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
