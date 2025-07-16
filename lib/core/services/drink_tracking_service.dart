import 'dart:developer' as developer;
import 'hive_core.dart';

/// Service for managing drink entries and tracking
class DrinkTrackingService {
  static DrinkTrackingService? _instance;
  static DrinkTrackingService get instance => _instance ??= DrinkTrackingService._();
  
  DrinkTrackingService._();
  
  final HiveCore _hiveCore = HiveCore.instance;
  
  /// Create a new drink entry with enhanced therapeutic data
  Future<String> createDrinkEntry({
    required DateTime drinkDate,
    required String drinkName,
    required double standardDrinks,
    required String drinkType,
    String? timeOfDay,
    String? reason,
    String? notes,
    // Enhanced therapeutic fields
    String? location,
    String? socialContext,
    int? moodBefore,
    List<String>? triggers,
    String? triggerDescription,
    String? intention,
    int? urgeIntensity,
    bool? consideredAlternatives,
    String? alternatives,
    int? energyLevel,
    int? hungerLevel,
    int? stressLevel,
    String? sleepQuality,
    Map<String, dynamic>? interventionData,
  }) async {
    await _hiveCore.ensureInitialized();
    
    final entryId = DateTime.now().millisecondsSinceEpoch.toString();
    final entry = {
      'id': entryId,
      'drinkDate': drinkDate.toIso8601String(),
      'drinkName': drinkName,
      'standardDrinks': standardDrinks,
      'drinkType': drinkType,
      'timeOfDay': timeOfDay,
      'reason': reason,
      'notes': notes,
      'createdAt': DateTime.now().toIso8601String(),
      // Enhanced therapeutic data
      'location': location,
      'socialContext': socialContext,
      'moodBefore': moodBefore,
      'triggers': triggers,
      'triggerDescription': triggerDescription,
      'intention': intention,
      'urgeIntensity': urgeIntensity,
      'consideredAlternatives': consideredAlternatives,
      'alternatives': alternatives,
      'energyLevel': energyLevel,
      'hungerLevel': hungerLevel,
      'stressLevel': stressLevel,
      'sleepQuality': sleepQuality,
      'interventionData': interventionData,
    };
    
    await _hiveCore.drinkEntriesBox.put(entryId, entry);
    developer.log('Drink entry created with enhanced data: $entry', name: 'DrinkTrackingService');
    
    return entryId;
  }
  
  /// Get all drink entries
  List<Map<String, dynamic>> getAllDrinkEntries() {
    if (!_hiveCore.isInitialized) return [];
    
    return _hiveCore.drinkEntriesBox.values
        .map((e) => e.cast<String, dynamic>())
        .toList();
  }
  
  /// Get drink entries for a specific date
  List<Map<String, dynamic>> getDrinkEntriesForDate(DateTime date) {
    final allEntries = getAllDrinkEntries();
    final targetDate = DateTime(date.year, date.month, date.day);
    
    return allEntries.where((entry) {
      final entryDate = DateTime.parse(entry['drinkDate']);
      final entryDateOnly = DateTime(entryDate.year, entryDate.month, entryDate.day);
      return entryDateOnly.isAtSameMomentAs(targetDate);
    }).toList();
  }
  
  /// Get total drinks for a specific date
  double getTotalDrinksForDate(DateTime date) {
    final entries = getDrinkEntriesForDate(date);
    return entries.fold<double>(0.0, (sum, entry) => sum + (entry['standardDrinks'] as double));
  }
  
  /// Delete a drink entry
  Future<void> deleteDrinkEntry(String entryId) async {
    await _hiveCore.ensureInitialized();
    
    await _hiveCore.drinkEntriesBox.delete(entryId);
    developer.log('Drink entry deleted: $entryId', name: 'DrinkTrackingService');
  }
  
  /// Log a drink entry (simple interface)
  Future<void> logDrink({
    required String drinkName,
    required double standardDrinks,
    required DateTime timestamp,
    String? notes,
  }) async {
    await createDrinkEntry(
      drinkDate: timestamp,
      drinkName: drinkName,
      standardDrinks: standardDrinks,
      drinkType: 'other',
      notes: notes,
    );
  }

  /// Get drink logs for a specific date
  Future<List<Map<String, dynamic>>> getDrinkLogsForDate(DateTime date) async {
    await _hiveCore.ensureInitialized();
    
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final allEntries = _hiveCore.drinkEntriesBox.values.toList();
    final entriesForDate = <Map<String, dynamic>>[];
    
    for (final entry in allEntries) {
      final entryData = Map<String, dynamic>.from(entry);
      final drinkDateStr = entryData['drinkDate'] as String?;
      if (drinkDateStr != null) {
        final drinkDate = DateTime.parse(drinkDateStr);
        if (drinkDate.isAfter(startOfDay.subtract(const Duration(milliseconds: 1))) && 
            drinkDate.isBefore(endOfDay)) {
          entriesForDate.add(entryData);
        }
      }
    }
    
    return entriesForDate;
  }
  
  /// Get total drinks for the current week
  double getWeeklyDrinks(DateTime date) {
    // Get Monday of the current week
    final monday = date.subtract(Duration(days: date.weekday - 1));
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    
    final allEntries = getAllDrinkEntries();
    double weeklyTotal = 0.0;
    
    for (final entry in allEntries) {
      final drinkDate = DateTime.parse(entry['drinkDate']);
      if (drinkDate.isAfter(startOfWeek.subtract(const Duration(milliseconds: 1))) && 
          drinkDate.isBefore(endOfWeek)) {
        weeklyTotal += entry['standardDrinks'] as double;
      }
    }
    
    developer.log('Weekly drinks for week starting ${startOfWeek.toString().split(' ')[0]}: $weeklyTotal', name: 'DrinkTrackingService');
    return weeklyTotal;
  }
  
  /// Calculate average drinks per day
  double calculateAverageDrinksPerDay() {
    final allEntries = getAllDrinkEntries();
    if (allEntries.isEmpty) return 0.0;
    
    final totalDrinks = allEntries.fold<double>(0.0, (sum, entry) => sum + (entry['standardDrinks'] as double));
    
    // Get unique days with entries
    final uniqueDays = <String>{};
    for (final entry in allEntries) {
      final date = DateTime.parse(entry['drinkDate']);
      final dateKey = '${date.year}-${date.month}-${date.day}';
      uniqueDays.add(dateKey);
    }
    
    return uniqueDays.isNotEmpty ? totalDrinks / uniqueDays.length : 0.0;
  }
}
