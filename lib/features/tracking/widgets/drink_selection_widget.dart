import 'package:flutter/material.dart';
import '../../../core/services/hive_database_service.dart';
import '../../../core/services/drink_database_service.dart';
import 'drink_selector_widget.dart';

/// Combined widget for drink selection and display of selected drink
class DrinkSelectionWidget extends StatelessWidget {
  final DrinkInfo? selectedDrink;
  final Function(DrinkInfo) onDrinkSelected;

  const DrinkSelectionWidget({
    super.key,
    required this.selectedDrink,
    required this.onDrinkSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Selected drink display
        if (selectedDrink != null) ...[
          _buildSelectedDrinkDisplay(context),
          const SizedBox(height: 24),
        ],
        
        // Drink selection
        _buildDrinkSelector(),
      ],
    );
  }

  Widget _buildSelectedDrinkDisplay(BuildContext context) {
    if (selectedDrink == null) return const SizedBox.shrink();
    
    final standardDrinks = selectedDrink!.standardDrinks;
    
    return Card(
      elevation: 3,
      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Selected Drink',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildDrinkIcon(selectedDrink!.category),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedDrink!.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedDrink!.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (selectedDrink!.ingredients.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Ingredients: ${selectedDrink!.ingredients.join(', ')}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${standardDrinks.toStringAsFixed(1)} standard drink${standardDrinks != 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrinkIcon(String category) {
    IconData iconData;
    Color iconColor;
    
    switch (category) {
      case 'beer':
        iconData = Icons.sports_bar;
        iconColor = Colors.amber;
        break;
      case 'wine':
        iconData = Icons.wine_bar;
        iconColor = Colors.purple;
        break;
      case 'spirits':
        iconData = Icons.local_bar;
        iconColor = Colors.brown;
        break;
      case 'cocktails':
        iconData = Icons.local_drink;
        iconColor = Colors.teal;
        break;
      default:
        iconData = Icons.local_drink;
        iconColor = Colors.grey;
    }
    
    return Icon(iconData, color: iconColor, size: 32);
  }

  Widget _buildDrinkSelector() {
    // Get user's favorite drinks from database
    final List<String> favoriteDrinkIds = HiveDatabaseService.instance.getFavoriteDrinks();
    
    return DrinkSelectorWidget(
      onDrinkSelected: onDrinkSelected,
      favoriteDrinkIds: favoriteDrinkIds,
      initialSelection: selectedDrink,
    );
  }
}
