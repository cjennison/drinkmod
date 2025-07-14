import 'dart:convert';
import 'package:flutter/services.dart';

class DrinkInfo {
  final String id;
  final String name;
  final String description;
  final List<String> ingredients;
  final double standardDrinks;
  final String category;
  final bool isBasic;

  DrinkInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.standardDrinks,
    required this.category,
    required this.isBasic,
  });

  factory DrinkInfo.fromJson(Map<String, dynamic> json) {
    return DrinkInfo(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      ingredients: List<String>.from(json['ingredients']),
      standardDrinks: json['standardDrinks'].toDouble(),
      category: json['category'],
      isBasic: json['isBasic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients,
      'standardDrinks': standardDrinks,
      'category': category,
      'isBasic': isBasic,
    };
  }
}

class DrinkDatabaseService {
  static DrinkDatabaseService? _instance;
  static DrinkDatabaseService get instance => _instance ??= DrinkDatabaseService._();
  
  DrinkDatabaseService._();

  List<DrinkInfo>? _drinks;

  /// Load drinks database from JSON asset
  Future<List<DrinkInfo>> loadDrinks() async {
    if (_drinks != null) return _drinks!;

    try {
      final String jsonString = await rootBundle.loadString('assets/data/drinks_database.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> drinksJson = jsonData['drinks'];
      
      _drinks = drinksJson.map((json) => DrinkInfo.fromJson(json)).toList();
      return _drinks!;
    } catch (e) {
      print('Error loading drinks database: $e');
      return _getDefaultDrinks();
    }
  }

  /// Get basic drinks (simple options like Beer, Wine, Vodka)
  Future<List<DrinkInfo>> getBasicDrinks() async {
    final drinks = await loadDrinks();
    return drinks.where((drink) => drink.isBasic).toList();
  }

  /// Get all drinks for search
  Future<List<DrinkInfo>> getAllDrinks() async {
    return await loadDrinks();
  }

  /// Search drinks by name or ingredients
  Future<List<DrinkInfo>> searchDrinks(String query) async {
    if (query.isEmpty) return [];
    
    final drinks = await loadDrinks();
    final searchTerm = query.toLowerCase();
    
    return drinks.where((drink) {
      return drink.name.toLowerCase().contains(searchTerm) ||
             drink.description.toLowerCase().contains(searchTerm) ||
             drink.ingredients.any((ingredient) => 
               ingredient.toLowerCase().contains(searchTerm));
    }).toList();
  }

  /// Get drinks by category
  Future<List<DrinkInfo>> getDrinksByCategory(String category) async {
    final drinks = await loadDrinks();
    return drinks.where((drink) => drink.category == category).toList();
  }

  /// Get favorite drinks based on user preferences
  Future<List<DrinkInfo>> getFavoriteDrinks(List<String> favoriteIds) async {
    final drinks = await loadDrinks();
    return drinks.where((drink) => favoriteIds.contains(drink.id)).toList();
  }

  /// Find drink by ID
  Future<DrinkInfo?> getDrinkById(String id) async {
    final drinks = await loadDrinks();
    try {
      return drinks.firstWhere((drink) => drink.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Default drinks fallback if JSON fails to load
  List<DrinkInfo> _getDefaultDrinks() {
    return [
      DrinkInfo(
        id: 'beer_regular',
        name: 'Beer',
        description: 'Regular beer (12 oz)',
        ingredients: ['Beer'],
        standardDrinks: 1.0,
        category: 'beer',
        isBasic: true,
      ),
      DrinkInfo(
        id: 'wine_white',
        name: 'White Wine',
        description: 'White wine (5 oz)',
        ingredients: ['White wine'],
        standardDrinks: 1.0,
        category: 'wine',
        isBasic: true,
      ),
      DrinkInfo(
        id: 'wine_red',
        name: 'Red Wine',
        description: 'Red wine (5 oz)',
        ingredients: ['Red wine'],
        standardDrinks: 1.1,
        category: 'wine',
        isBasic: true,
      ),
      DrinkInfo(
        id: 'vodka_shot',
        name: 'Vodka',
        description: 'Vodka shot (1.5 oz)',
        ingredients: ['Vodka'],
        standardDrinks: 1.0,
        category: 'spirits',
        isBasic: true,
      ),
      DrinkInfo(
        id: 'whiskey_shot',
        name: 'Whiskey',
        description: 'Whiskey shot (1.5 oz)',
        ingredients: ['Whiskey'],
        standardDrinks: 1.0,
        category: 'spirits',
        isBasic: true,
      ),
    ];
  }
}
