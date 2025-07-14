import 'package:flutter/material.dart';

/// Quick logging section for favorite drinks
class QuickLogSection extends StatelessWidget {
  final List<String> favoriteDrinks; // Changed from FavoriteDrink to String
  final bool canLogToday;
  final VoidCallback onQuickLog;
  final VoidCallback onDetailedLog;
  
  const QuickLogSection({
    super.key,
    required this.favoriteDrinks,
    required this.canLogToday,
    required this.onQuickLog,
    required this.onDetailedLog,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        // Primary action button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: canLogToday ? onQuickLog : null,
            icon: const Icon(Icons.add),
            label: Text(canLogToday ? 'Log a Drink' : 'Not a drinking day'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Secondary action button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onDetailedLog,
            icon: const Icon(Icons.edit_note),
            label: const Text('Detailed Entry'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        
        // Favorite drinks quick access
        if (favoriteDrinks.isNotEmpty && canLogToday) ...[
          const SizedBox(height: 20),
          Text(
            'Favorites',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: favoriteDrinks.take(4).map((drink) => 
              _buildFavoriteDrinkChip(context, drink)
            ).toList(),
          ),
        ],
      ],
    );
  }
  
  Widget _buildFavoriteDrinkChip(BuildContext context, String drinkName) {
    return ActionChip(
      avatar: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Text(
          drinkName.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      label: Text(drinkName),
      onPressed: () {
        // TODO: Implement quick log for specific drink
        onQuickLog();
      },
    );
  }
}
