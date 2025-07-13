import 'package:flutter_test/flutter_test.dart';
import 'package:drinkmod/core/utils/drink_calculator.dart';

void main() {
  group('DrinkCalculator', () {
    test('should calculate standard drinks correctly from volume and percentage', () {
      // Test case: 12 oz beer at 5% alcohol should equal 1 standard drink
      final result = DrinkCalculator.calculateStandardDrinksFromOz(12, 5.0);
      expect(result, closeTo(1.0, 0.1));
    });

    test('should calculate standard drinks for wine correctly', () {
      // Test case: 5 oz wine at 12% alcohol should equal 1 standard drink
      final result = DrinkCalculator.calculateStandardDrinksFromOz(5, 12.0);
      expect(result, closeTo(1.0, 0.1));
    });

    test('should calculate standard drinks for spirits correctly', () {
      // Test case: 1.5 oz spirits at 40% alcohol should equal 1 standard drink
      final result = DrinkCalculator.calculateStandardDrinksFromOz(1.5, 40.0);
      expect(result, closeTo(1.0, 0.1));
    });

    test('should return preset drink suggestions', () {
      final suggestions = DrinkCalculator.getCommonDrinks();
      expect(suggestions.length, greaterThan(10));
      expect(suggestions.any((s) => s.name.contains('Beer')), isTrue);
      expect(suggestions.any((s) => s.name.contains('Wine')), isTrue);
      expect(suggestions.any((s) => s.name.contains('Shot')), isTrue);
    });

    test('should format standard drinks correctly', () {
      expect(DrinkCalculator.formatStandardDrinks(1.0), equals('1.0'));
      expect(DrinkCalculator.formatStandardDrinks(1.25), equals('1.3'));
      expect(DrinkCalculator.formatStandardDrinks(0.75), equals('0.8'));
    });

    test('should identify moderate consumption correctly', () {
      expect(DrinkCalculator.isModerateConsumption(1.0), isTrue);
      expect(DrinkCalculator.isModerateConsumption(2.0), isTrue);
      expect(DrinkCalculator.isModerateConsumption(3.0), isFalse);
      
      // Weekly limits
      expect(DrinkCalculator.isModerateConsumption(10.0, isDailyLimit: false), isTrue);
      expect(DrinkCalculator.isModerateConsumption(15.0, isDailyLimit: false), isFalse);
    });
  });

  group('DrinkSuggestion', () {
    test('should create suggestion with correct properties', () {
      final suggestion = DrinkSuggestion('Test Drink', 'beer', 1.5);
      expect(suggestion.name, equals('Test Drink'));
      expect(suggestion.type, equals('beer'));
      expect(suggestion.standardDrinks, equals(1.5));
    });
  });
}
