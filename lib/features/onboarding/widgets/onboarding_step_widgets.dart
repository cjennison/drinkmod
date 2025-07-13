import 'package:flutter/material.dart';
import '../widgets/shared_components.dart';

/// Builds all input card widgets for onboarding steps
class OnboardingStepWidgets {
  
  /// Build name and gender input card (Step 1)
  static Widget buildNameInputCard({
    required Function(String name, String gender) onSubmit,
  }) {
    final nameController = TextEditingController();
    String selectedGender = '';

    return InputCard(
      title: "Tell me about yourself",
      child: StatefulBuilder(
        builder: (context, setState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Your name or preferred name",
                hintText: "What should I call you?",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 16),
            const Text(
              "How do you identify? (Optional)",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['She/her', 'He/him', 'They/them', 'Prefer not to say']
                  .map((gender) => FilterChip(
                        label: Text(gender),
                        selected: selectedGender == gender,
                        onSelected: (selected) {
                          setState(() {
                            selectedGender = selected ? gender : '';
                          });
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            ActionButton(
              text: "Continue",
              onPressed: nameController.text.trim().isNotEmpty
                  ? () => onSubmit(nameController.text.trim(), selectedGender)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Build motivation input card (Step 2)
  static Widget buildMotivationInputCard({
    required Function(String motivation) onSubmit,
  }) {
    String selectedMotivation = '';
    final customController = TextEditingController();

    final motivationOptions = [
      'Health concerns',
      'Financial reasons',
      'Relationship impact',
      'Work/productivity',
      'Personal control',
      'Family concerns',
      'Sleep quality',
      'Mental clarity',
      'Other'
    ];

    return InputCard(
      title: "What's driving your journey?",
      child: StatefulBuilder(
        builder: (context, setState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select what resonates most with you:"),
            const SizedBox(height: 12),
            ...motivationOptions.map((motivation) => RadioListTile<String>(
                  title: Text(motivation),
                  value: motivation,
                  groupValue: selectedMotivation,
                  onChanged: (value) {
                    setState(() {
                      selectedMotivation = value!;
                      if (value != 'Other') {
                        customController.clear();
                      }
                    });
                  },
                )),
            if (selectedMotivation == 'Other') ...[
              const SizedBox(height: 8),
              TextField(
                controller: customController,
                decoration: const InputDecoration(
                  labelText: "Please describe",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ],
            const SizedBox(height: 20),
            ActionButton(
              text: "Continue",
              onPressed: selectedMotivation.isNotEmpty &&
                      (selectedMotivation != 'Other' || customController.text.trim().isNotEmpty)
                  ? () => onSubmit(
                        selectedMotivation == 'Other' 
                            ? customController.text.trim() 
                            : selectedMotivation
                      )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Build drinking patterns input card (Step 3)
  static Widget buildDrinkingPatternsInputCard({
    required Function(String frequency, String amount) onSubmit,
  }) {
    String selectedFrequency = '';
    String selectedAmount = '';

    final frequencyOptions = [
      'Daily',
      'Several times a week',
      'Once or twice a week',
      'A few times a month',
      'Once a month or less',
      'I don\'t currently drink'
    ];

    final amountOptions = [
      '1-2 drinks',
      '3-4 drinks',
      '5-6 drinks',
      'More than 6 drinks',
      'It varies a lot'
    ];

    return InputCard(
      title: "Your current drinking patterns",
      child: StatefulBuilder(
        builder: (context, setState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("How often do you typically drink?", 
                       style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            ...frequencyOptions.map((frequency) => RadioListTile<String>(
                  title: Text(frequency),
                  value: frequency,
                  groupValue: selectedFrequency,
                  onChanged: (value) {
                    setState(() {
                      selectedFrequency = value!;
                    });
                  },
                )),
            if (selectedFrequency.isNotEmpty && selectedFrequency != 'I don\'t currently drink') ...[
              const SizedBox(height: 16),
              const Text("When you do drink, how much do you typically have?", 
                         style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              ...amountOptions.map((amount) => RadioListTile<String>(
                    title: Text(amount),
                    value: amount,
                    groupValue: selectedAmount,
                    onChanged: (value) {
                      setState(() {
                        selectedAmount = value!;
                      });
                    },
                  )),
            ],
            const SizedBox(height: 20),
            ActionButton(
              text: "Continue",
              onPressed: selectedFrequency.isNotEmpty &&
                      (selectedFrequency == 'I don\'t currently drink' || selectedAmount.isNotEmpty)
                  ? () => onSubmit(selectedFrequency, selectedAmount)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Build favorite drinks input card (Step 4)
  static Widget buildFavoriteDrinksInputCard({
    required Function(List<String> drinks) onSubmit,
  }) {
    final drinkController = TextEditingController();
    List<String> selectedDrinks = [];

    final commonDrinks = [
      'Beer',
      'Wine',
      'Vodka',
      'Whiskey',
      'Rum',
      'Gin',
      'Tequila',
      'Cocktails',
      'Champagne',
      'Sangria'
    ];

    return InputCard(
      title: "Your favorite drinks",
      child: StatefulBuilder(
        builder: (context, setState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select your favorites (choose multiple):"),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: commonDrinks.map((drink) => FilterChip(
                label: Text(drink),
                selected: selectedDrinks.contains(drink),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedDrinks.add(drink);
                    } else {
                      selectedDrinks.remove(drink);
                    }
                  });
                },
              )).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: drinkController,
              decoration: const InputDecoration(
                labelText: "Other favorite drink",
                hintText: "Type any other drinks you enjoy",
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty && !selectedDrinks.contains(value.trim())) {
                  setState(() {
                    selectedDrinks.add(value.trim());
                    drinkController.clear();
                  });
                }
              },
            ),
            if (drinkController.text.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              ActionButton(
                text: "Add \"${drinkController.text.trim()}\"",
                isPrimary: false,
                onPressed: () {
                  final drink = drinkController.text.trim();
                  if (drink.isNotEmpty && !selectedDrinks.contains(drink)) {
                    setState(() {
                      selectedDrinks.add(drink);
                      drinkController.clear();
                    });
                  }
                },
              ),
            ],
            const SizedBox(height: 20),
            ActionButton(
              text: "Continue",
              onPressed: selectedDrinks.isNotEmpty
                  ? () => onSubmit(selectedDrinks)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Build schedule input card (Step 5)
  static Widget buildScheduleInputCard({
    required Function(String schedule) onSubmit,
  }) {
    String selectedSchedule = '';

    final scheduleOptions = [
      'Weekends Only (Friday-Sunday) [RECOMMENDED]',
      'Friday Only',
      'Social Occasions Only',
      'Custom Weekly Pattern',
      'Keep Current Pattern (with limits)'
    ];

    return InputCard(
      title: "Your drinking schedule",
      child: StatefulBuilder(
        builder: (context, setState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Choose a schedule that works for you:"),
            const SizedBox(height: 12),
            ...scheduleOptions.map((schedule) => RadioListTile<String>(
                  title: Text(
                    schedule,
                    style: TextStyle(
                      fontWeight: schedule.contains('[RECOMMENDED]') ? FontWeight.w600 : FontWeight.normal,
                      color: schedule.contains('[RECOMMENDED]') ? Theme.of(context).colorScheme.primary : null,
                    ),
                  ),
                  value: schedule,
                  groupValue: selectedSchedule,
                  onChanged: (value) {
                    setState(() {
                      selectedSchedule = value!;
                    });
                  },
                )),
            const SizedBox(height: 20),
            ActionButton(
              text: "Continue",
              onPressed: selectedSchedule.isNotEmpty
                  ? () => onSubmit(selectedSchedule)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Build drink limit input card (Step 6)
  static Widget buildDrinkLimitInputCard({
    required Function(int limit) onSubmit,
  }) {
    int selectedLimit = 2;

    return InputCard(
      title: "Daily drink limit",
      child: StatefulBuilder(
        builder: (context, setState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Drinks per drinking day: $selectedLimit"),
            const SizedBox(height: 16),
            Slider(
              value: selectedLimit.toDouble(),
              min: 1,
              max: 6,
              divisions: 5,
              label: selectedLimit.toString(),
              onChanged: (value) {
                setState(() {
                  selectedLimit = value.round();
                });
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1 drink', style: Theme.of(context).textTheme.bodySmall),
                Text('6 drinks', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, 
                       color: Theme.of(context).colorScheme.primary,
                       size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedLimit <= 2 
                          ? "Great choice! This aligns with health guidelines for moderate drinking."
                          : selectedLimit <= 4 
                              ? "Moderate choice. This should help you stay within healthy limits."
                              : "That's quite a few drinks. Consider starting lower and adjusting as needed.",
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ActionButton(
              text: "Complete Setup",
              onPressed: () => onSubmit(selectedLimit),
            ),
          ],
        ),
      ),
    );
  }
}
