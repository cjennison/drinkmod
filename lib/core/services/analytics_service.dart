import 'user_data_service.dart';
import 'drink_tracking_service.dart';

/// Service for calculating dashboard statistics and analytics
class AnalyticsService {
  static AnalyticsService? _instance;
  static AnalyticsService get instance => _instance ??= AnalyticsService._();
  
  AnalyticsService._();
  
  final UserDataService _userDataService = UserDataService.instance;
  final DrinkTrackingService _drinkTrackingService = DrinkTrackingService.instance;
  
  /// Get dashboard statistics
  Map<String, dynamic> getDashboardStats() {
    final userData = _userDataService.getUserData();
    if (userData == null) return {'streak': 0};
    
    // Calculate current streak (placeholder implementation)
    final allEntries = _drinkTrackingService.getAllDrinkEntries();
    if (allEntries.isEmpty) return {'streak': 0};
    
    // Simple streak calculation - days without drinks
    final now = DateTime.now();
    int streak = 0;
    
    for (int i = 0; i < 365; i++) { // Check up to a year
      final checkDate = now.subtract(Duration(days: i));
      final dailyDrinks = _drinkTrackingService.getTotalDrinksForDate(checkDate);
      
      if (dailyDrinks > 0) {
        break; // Streak broken
      }
      streak++;
    }
    
    return {
      'streak': streak,
      'totalDays': allEntries.length,
      'averageDrinksPerDay': _drinkTrackingService.calculateAverageDrinksPerDay(),
    };
  }
  
  /// Get comprehensive analytics for a date range
  Map<String, dynamic> getAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final end = endDate ?? DateTime.now();
    final start = startDate ?? end.subtract(const Duration(days: 30));
    
    final allEntries = _drinkTrackingService.getAllDrinkEntries();
    final periodEntries = allEntries.where((entry) {
      final entryDate = DateTime.parse(entry['drinkDate']);
      return entryDate.isAfter(start.subtract(const Duration(days: 1))) && 
             entryDate.isBefore(end.add(const Duration(days: 1)));
    }).toList();
    
    if (periodEntries.isEmpty) {
      return {
        'totalDrinks': 0.0,
        'averagePerDay': 0.0,
        'daysWithDrinks': 0,
        'totalDays': end.difference(start).inDays,
        'moodTrends': <String, dynamic>{},
        'timeOfDayPatterns': <String, dynamic>{},
      };
    }
    
    final totalDrinks = periodEntries.fold<double>(
      0.0, 
      (sum, entry) => sum + (entry['standardDrinks'] as double)
    );
    
    // Get unique days with drinks
    final daysWithDrinks = <String>{};
    for (final entry in periodEntries) {
      final date = DateTime.parse(entry['drinkDate']);
      final dateKey = '${date.year}-${date.month}-${date.day}';
      daysWithDrinks.add(dateKey);
    }
    
    final totalDays = end.difference(start).inDays;
    final averagePerDay = totalDays > 0 ? totalDrinks / totalDays : 0.0;
    
    return {
      'totalDrinks': totalDrinks,
      'averagePerDay': averagePerDay,
      'daysWithDrinks': daysWithDrinks.length,
      'totalDays': totalDays,
      'moodTrends': _calculateMoodTrends(periodEntries),
      'timeOfDayPatterns': _calculateTimeOfDayPatterns(periodEntries),
    };
  }
  
  /// Calculate mood trends from drink entries
  Map<String, dynamic> _calculateMoodTrends(List<Map<String, dynamic>> entries) {
    final moodEntries = entries.where((entry) => entry['moodBefore'] != null).toList();
    
    if (moodEntries.isEmpty) {
      return {
        'averageMood': 0.0,
        'moodDistribution': <int, int>{},
        'totalMoodEntries': 0,
      };
    }
    
    final moods = moodEntries.map((entry) => entry['moodBefore'] as int).toList();
    final averageMood = moods.reduce((a, b) => a + b) / moods.length;
    
    // Calculate mood distribution
    final moodDistribution = <int, int>{};
    for (final mood in moods) {
      moodDistribution[mood] = (moodDistribution[mood] ?? 0) + 1;
    }
    
    return {
      'averageMood': averageMood,
      'moodDistribution': moodDistribution,
      'totalMoodEntries': moodEntries.length,
    };
  }
  
  /// Calculate time of day drinking patterns
  Map<String, dynamic> _calculateTimeOfDayPatterns(List<Map<String, dynamic>> entries) {
    final timeEntries = entries.where((entry) => entry['timeOfDay'] != null).toList();
    
    if (timeEntries.isEmpty) {
      return {
        'timeDistribution': <String, int>{},
        'totalTimeEntries': 0,
      };
    }
    
    // Calculate time distribution
    final timeDistribution = <String, int>{};
    for (final entry in timeEntries) {
      final timeOfDay = entry['timeOfDay'] as String;
      timeDistribution[timeOfDay] = (timeDistribution[timeOfDay] ?? 0) + 1;
    }
    
    return {
      'timeDistribution': timeDistribution,
      'totalTimeEntries': timeEntries.length,
    };
  }
  
  /// Get weekly trends
  Map<String, dynamic> getWeeklyTrends({int numberOfWeeks = 4}) {
    final now = DateTime.now();
    final weeklyData = <Map<String, dynamic>>[];
    
    for (int i = 0; i < numberOfWeeks; i++) {
      final weekStart = now.subtract(Duration(days: (i + 1) * 7));
      final weekEnd = weekStart.add(const Duration(days: 7));
      
      final weeklyDrinks = _drinkTrackingService.getWeeklyDrinks(weekStart);
      
      weeklyData.add({
        'week': i + 1,
        'startDate': weekStart.toIso8601String(),
        'endDate': weekEnd.toIso8601String(),
        'totalDrinks': weeklyDrinks,
        'averagePerDay': weeklyDrinks / 7,
      });
    }
    
    // Reverse to show oldest to newest
    weeklyData.sort((a, b) => (a['week'] as int).compareTo(b['week'] as int));
    
    return {
      'weeklyData': weeklyData,
      'numberOfWeeks': numberOfWeeks,
    };
  }
}
