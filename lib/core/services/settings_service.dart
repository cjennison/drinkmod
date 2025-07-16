import 'hive_core.dart';

/// Service for managing app settings and preferences
class SettingsService {
  static SettingsService? _instance;
  static SettingsService get instance => _instance ??= SettingsService._();
  
  SettingsService._();
  
  final HiveCore _hiveCore = HiveCore.instance;
  
  /// Set a setting value
  Future<void> setSetting(String key, dynamic value) async {
    await _hiveCore.ensureInitialized();
    
    await _hiveCore.settingsBox.put(key, {'value': value});
  }
  
  /// Get a setting value
  T? getSetting<T>(String key, [T? defaultValue]) {
    if (!_hiveCore.isInitialized) return defaultValue;
    
    final data = _hiveCore.settingsBox.get(key);
    if (data == null) return defaultValue;
    
    return data['value'] as T? ?? defaultValue;
  }
  
  /// Remove a setting
  Future<void> removeSetting(String key) async {
    await _hiveCore.ensureInitialized();
    
    await _hiveCore.settingsBox.delete(key);
  }
  
  /// Save favorite drinks list
  Future<void> saveFavoriteDrinks(List<String> drinks) async {
    await _hiveCore.ensureInitialized();
    
    final favoriteDrinksData = {
      'drinks': drinks,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    
    await _hiveCore.favoriteDrinksBox.put('favorites', favoriteDrinksData);
  }
  
  /// Get favorite drinks list
  List<String> getFavoriteDrinks() {
    if (!_hiveCore.isInitialized) return [];
    
    final data = _hiveCore.favoriteDrinksBox.get('favorites');
    if (data == null) return [];
    
    final drinks = data['drinks'];
    return drinks is List ? drinks.cast<String>() : [];
  }
}
