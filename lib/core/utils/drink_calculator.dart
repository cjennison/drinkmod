/// Utility class for calculating standard drinks based on alcohol content and volume
/// 
/// A standard drink contains 14 grams of pure alcohol, which is equivalent to:
/// - 12 fl oz of beer (5% alcohol)
/// - 5 fl oz of wine (12% alcohol)
/// - 1.5 fl oz of distilled spirits (40% alcohol)
class DrinkCalculator {
  static const double standardAlcoholGrams = 14.0;
  static const double alcoholDensity = 0.789; // g/ml

  /// Calculate standard drinks from volume (ml) and alcohol percentage
  static double calculateStandardDrinks(double volumeMl, double alcoholPercentage) {
    final alcoholVolumeMl = volumeMl * (alcoholPercentage / 100);
    final alcoholGrams = alcoholVolumeMl * alcoholDensity;
    return alcoholGrams / standardAlcoholGrams;
  }

  /// Calculate standard drinks from US fluid ounces and alcohol percentage
  static double calculateStandardDrinksFromOz(double volumeOz, double alcoholPercentage) {
    const double ozToMl = 29.5735;
    final volumeMl = volumeOz * ozToMl;
    return calculateStandardDrinks(volumeMl, alcoholPercentage);
  }

  /// Get suggested standard drink values for common drink types
  static List<DrinkSuggestion> getCommonDrinks() {
    const preset = _PresetDrinks();
    return [
      // Beers
      DrinkSuggestion('Light Beer (12 oz)', 'beer', preset.lightBeer()),
      DrinkSuggestion('Regular Beer (12 oz)', 'beer', preset.regularBeer()),
      DrinkSuggestion('Craft Beer (12 oz)', 'beer', preset.craftBeer()),
      DrinkSuggestion('Strong Beer (12 oz)', 'beer', preset.strongBeer()),
      
      // Wines
      DrinkSuggestion('White Wine (5 oz)', 'wine', preset.whiteWine()),
      DrinkSuggestion('Red Wine (5 oz)', 'wine', preset.redWine()),
      DrinkSuggestion('Fortified Wine (5 oz)', 'wine', preset.fortifiedWine()),
      
      // Spirits
      DrinkSuggestion('Shot (1.5 oz)', 'spirits', preset.spirits40Percent()),
      DrinkSuggestion('Double Shot (3 oz)', 'spirits', preset.spirits40Percent() * 2),
      
      // Cocktails
      DrinkSuggestion('Martini', 'cocktail', preset.martini()),
      DrinkSuggestion('Manhattan', 'cocktail', preset.manhattan()),
      DrinkSuggestion('Old Fashioned', 'cocktail', preset.oldFashioned()),
      DrinkSuggestion('Margarita', 'cocktail', preset.margarita()),
      DrinkSuggestion('Cosmopolitan', 'cocktail', preset.cosmopolitan()),
      DrinkSuggestion('Mojito', 'cocktail', preset.mojito()),
      DrinkSuggestion('Pina Colada', 'cocktail', preset.pinaColada()),
    ];
  }

  /// Format standard drinks for display (rounded to 1 decimal place)
  static String formatStandardDrinks(double standardDrinks) {
    return standardDrinks.toStringAsFixed(1);
  }

  /// Check if a number of drinks is considered moderate (varies by guidelines)
  /// This is a general guideline and should not be considered medical advice
  static bool isModerateConsumption(double standardDrinks, {bool isDailyLimit = true}) {
    if (isDailyLimit) {
      // US Dietary Guidelines: up to 1 drink per day for women, 2 for men
      // We'll use the more conservative 2 drinks as a general guideline
      return standardDrinks <= 2.0;
    } else {
      // Weekly limits are typically 7 drinks for women, 14 for men
      // Using 14 as a general guideline
      return standardDrinks <= 14.0;
    }
  }
}

class _PresetDrinks {
  const _PresetDrinks();

  // Beer calculations (12 oz servings)
  double lightBeer() => DrinkCalculator.calculateStandardDrinksFromOz(12, 3.5); // ~0.7 drinks
  double regularBeer() => DrinkCalculator.calculateStandardDrinksFromOz(12, 5.0); // 1.0 drink
  double craftBeer() => DrinkCalculator.calculateStandardDrinksFromOz(12, 7.0); // ~1.4 drinks
  double strongBeer() => DrinkCalculator.calculateStandardDrinksFromOz(12, 9.0); // ~1.8 drinks

  // Wine calculations (5 oz servings)
  double whiteWine() => DrinkCalculator.calculateStandardDrinksFromOz(5, 12.0); // 1.0 drink
  double redWine() => DrinkCalculator.calculateStandardDrinksFromOz(5, 13.5); // ~1.1 drinks
  double fortifiedWine() => DrinkCalculator.calculateStandardDrinksFromOz(5, 18.0); // ~1.5 drinks

  // Spirits calculations (1.5 oz servings)
  double spirits40Percent() => DrinkCalculator.calculateStandardDrinksFromOz(1.5, 40.0); // 1.0 drink
  double spirits45Percent() => DrinkCalculator.calculateStandardDrinksFromOz(1.5, 45.0); // ~1.1 drinks
  double spirits50Percent() => DrinkCalculator.calculateStandardDrinksFromOz(1.5, 50.0); // ~1.25 drinks

  // Common cocktails (estimated standard drinks)
  double martini() => 2.0; // typically 2.5-3 oz spirits
  double manhattan() => 2.0; // typically 2.5 oz spirits
  double oldFashioned() => 1.5; // typically 2 oz spirits, diluted
  double margarita() => 1.5; // typically 2 oz tequila, mixers
  double cosmopolitan() => 1.5; // typically 1.5 oz vodka, liqueurs
  double mojito() => 1.0; // typically 1.5 oz rum, lots of mixer
  double pinaColada() => 1.5; // typically 2 oz rum, heavy mixers
}

class DrinkSuggestion {
  final String name;
  final String type;
  final double standardDrinks;

  DrinkSuggestion(this.name, this.type, this.standardDrinks);
}
