import 'package:flutter/material.dart';

/// Widget for the context step in the logging flow
class ContextLogWidget extends StatelessWidget {
  final String? location;
  final String? socialContext;
  final Function(String?) onLocationSelected;
  final Function(String?) onSocialContextSelected;

  const ContextLogWidget({
    super.key,
    required this.location,
    required this.socialContext,
    required this.onLocationSelected,
    required this.onSocialContextSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Context & Setting',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Help us understand the situation (optional)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          
          _buildLocationSelector(context),
          const SizedBox(height: 16),
          _buildSocialContextSelector(context),
        ],
      ),
    );
  }

  Widget _buildLocationSelector(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Where are you?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TriggerConstants.locations.map((location) {
                final isSelected = this.location == location;
                return FilterChip(
                  label: Text(location),
                  selected: isSelected,
                  onSelected: (selected) {
                    onLocationSelected(selected ? location : null);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialContextSelector(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Who are you with?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TriggerConstants.socialContexts.map((context) {
                final isSelected = socialContext == context;
                return FilterChip(
                  label: Text(context),
                  selected: isSelected,
                  onSelected: (selected) {
                    onSocialContextSelected(selected ? context : null);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// Constants for triggers and contexts
class TriggerConstants {
  static const List<String> locations = [
    'Home',
    'Restaurant',
    'Bar/Pub',
    'Friend\'s House',
    'Work',
    'Event/Party',
    'Outdoors',
    'Other',
  ];

  static const List<String> socialContexts = [
    'Alone',
    'With Partner',
    'With Friends',
    'With Family',
    'With Colleagues',
    'In a Group',
    'Other',
  ];

  static const Map<String, List<String>> triggersByCategory = {
    'Emotions': [
      'Stress',
      'Anxiety',
      'Sadness',
      'Loneliness',
      'Anger',
      'Boredom',
      'Celebration',
      'Relief',
    ],
    'Social': [
      'Peer Pressure',
      'Social Anxiety',
      'FOMO',
      'Networking',
      'Dating',
      'Family Gathering',
    ],
    'Environmental': [
      'Work Stress',
      'Home Alone',
      'Bad Day',
      'Good Day',
      'Weekend',
      'After Exercise',
      'With Meal',
    ],
    'Physical': [
      'Tired',
      'Hungry',
      'Thirsty',
      'Pain',
      'Headache',
      'Can\'t Sleep',
    ],
  };
}
