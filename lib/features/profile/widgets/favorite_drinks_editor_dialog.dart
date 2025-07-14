import 'package:flutter/material.dart';
import '../../../core/services/onboarding_service.dart';

/// Dialog for editing user's favorite drinks
class FavoriteDrinksEditorDialog extends StatefulWidget {
  final List<String>? currentDrinks;
  final Function(List<String>) onDrinksChanged;

  const FavoriteDrinksEditorDialog({
    super.key,
    required this.currentDrinks,
    required this.onDrinksChanged,
  });

  @override
  State<FavoriteDrinksEditorDialog> createState() => _FavoriteDrinksEditorDialogState();
}

class _FavoriteDrinksEditorDialogState extends State<FavoriteDrinksEditorDialog> {
  late List<String> selectedDrinks;
  final TextEditingController customDrinkController = TextEditingController();
  
  final List<String> commonDrinks = [
    'Beer',
    'Wine',
    'Cocktail',
    'Whiskey',
    'Vodka',
    'Rum',
    'Gin',
    'Tequila',
    'Champagne',
    'Hard Seltzer',
    'Cider',
    'Sake',
  ];

  @override
  void initState() {
    super.initState();
    selectedDrinks = List<String>.from(widget.currentDrinks ?? []);
  }

  @override
  void dispose() {
    customDrinkController.dispose();
    super.dispose();
  }

  void _addCustomDrink() {
    final customDrink = customDrinkController.text.trim();
    if (customDrink.isNotEmpty && !selectedDrinks.contains(customDrink)) {
      setState(() {
        selectedDrinks.add(customDrink);
        customDrinkController.clear();
      });
    }
  }

  void _removeDrink(String drink) {
    setState(() {
      selectedDrinks.remove(drink);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Favorite Drinks'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select your favorite drinks:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            
            // Selected drinks display
            if (selectedDrinks.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Selected drinks:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: selectedDrinks.map((drink) => Chip(
                  label: Text(drink),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => _removeDrink(drink),
                )).toList(),
              ),
              const SizedBox(height: 16),
            ],
            
            // Common drinks selection
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Popular choices:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 8),
            
            Flexible(
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: commonDrinks.map((drink) {
                  final isSelected = selectedDrinks.contains(drink);
                  return FilterChip(
                    label: Text(drink),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          if (!selectedDrinks.contains(drink)) {
                            selectedDrinks.add(drink);
                          }
                        } else {
                          selectedDrinks.remove(drink);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Custom drink input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: customDrinkController,
                    decoration: const InputDecoration(
                      labelText: 'Add custom drink',
                      hintText: 'e.g., Craft IPA, Prosecco',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                    onSubmitted: (_) => _addCustomDrink(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addCustomDrink,
                  icon: const Icon(Icons.add),
                  tooltip: 'Add drink',
                ),
              ],
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
            // Save the drinks
            await OnboardingService.updateUserData({
              'favoriteDrinks': selectedDrinks,
            });
            
            widget.onDrinksChanged(selectedDrinks);
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
