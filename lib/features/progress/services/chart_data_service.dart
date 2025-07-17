import '../../../core/services/hive_database_service.dart';
import '../../../core/utils/progress_metrics_service.dart';
import '../../../core/services/app_events_service.dart';
import '../../../core/models/app_event.dart';

/// Service for preparing chart data from database
class ChartDataService {
  final HiveDatabaseService _databaseService;
  final ProgressMetricsService _progressService;
  final AppEventsService _eventsService;
  
  ChartDataService(this._databaseService) 
    : _progressService = ProgressMetricsService(_databaseService),
      _eventsService = AppEventsService.instance;
  
  // ===================================================================
  // WEEKLY ADHERENCE CHART DATA
  // ===================================================================
  
  /// Get weekly adherence data for the last 12 weeks
  List<WeeklyAdherenceData> getWeeklyAdherenceData() {
    final now = DateTime.now();
    final data = <WeeklyAdherenceData>[];
    
    for (int i = 11; i >= 0; i--) {
      final weekEnd = now.subtract(Duration(days: i * 7));
      final adherence = _progressService.calculateWeeklyAdherence(date: weekEnd);
      final weekNumber = 12 - i;
      
      data.add(WeeklyAdherenceData(
        week: weekNumber,
        adherencePercentage: adherence,
        weekEndDate: weekEnd,
      ));
    }
    
    return data;
  }
  
  // ===================================================================
  // WEEKLY DRINKING PATTERN CHART DATA  
  // ===================================================================
  
  /// Get average drinks consumed by day of week over last 4 weeks
  List<DayOfWeekData> getWeeklyDrinkingPattern() {
    final now = DateTime.now();
    final fourWeeksAgo = now.subtract(const Duration(days: 28));
    
    final dayTotals = <int, List<double>>{
      1: [], // Monday
      2: [], // Tuesday  
      3: [], // Wednesday
      4: [], // Thursday
      5: [], // Friday
      6: [], // Saturday
      7: [], // Sunday
    };
    
    // Collect data for each day over the last 4 weeks
    for (int i = 0; i < 28; i++) {
      final date = fourWeeksAgo.add(Duration(days: i));
      final entries = _databaseService.getDrinkEntriesForDate(date);
      final totalDrinks = entries.fold<double>(
        0, 
        (sum, entry) => sum + (entry['standardDrinks'] as double),
      );
      
      final dayOfWeek = date.weekday;
      dayTotals[dayOfWeek]!.add(totalDrinks);
    }
    
    // Calculate averages
    final result = <DayOfWeekData>[];
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    for (int day = 1; day <= 7; day++) {
      final drinks = dayTotals[day]!;
      final average = drinks.isEmpty ? 0.0 : drinks.reduce((a, b) => a + b) / drinks.length;
      
      result.add(DayOfWeekData(
        dayName: dayNames[day - 1],
        averageDrinks: average,
        dayOfWeek: day,
      ));
    }
    
    return result;
  }
  
  // ===================================================================
  // TIME OF DAY PATTERN CHART DATA
  // ===================================================================
  
  /// Get drinking frequency by time of day over last 4 weeks
  List<TimeOfDayData> getTimeOfDayPattern() {
    final now = DateTime.now();
    final fourWeeksAgo = now.subtract(const Duration(days: 28));
    
    final timeSlotCounts = <String, int>{
      'Morning': 0,
      'Noon': 0,
      'Afternoon': 0,
      'Evening': 0,
      'Night': 0,
    };
    
    // Count drinks by time of day
    for (int i = 0; i < 28; i++) {
      final date = fourWeeksAgo.add(Duration(days: i));
      final entries = _databaseService.getDrinkEntriesForDate(date);
      
      for (final entry in entries) {
        final timeOfDay = entry['timeOfDay'] as String?;
        if (timeOfDay != null && timeSlotCounts.containsKey(timeOfDay)) {
          timeSlotCounts[timeOfDay] = timeSlotCounts[timeOfDay]! + 1;
        }
      }
    }
    
    return timeSlotCounts.entries.map((entry) => TimeOfDayData(
      timeSlot: entry.key,
      drinkCount: entry.value,
    )).toList();
  }
  
  // ===================================================================
  // INTERVENTION SUCCESS CHART DATA
  // ===================================================================
  
  /// Get intervention success rate data over last 6 months
  List<InterventionSuccessData> getInterventionSuccessData() {
    final now = DateTime.now();
    final data = <InterventionSuccessData>[];
    
    for (int i = 5; i >= 0; i--) {
      final monthEnd = DateTime(now.year, now.month - i, DateTime(now.year, now.month - i + 1, 0).day);
      final monthStart = DateTime(monthEnd.year, monthEnd.month, 1);
      
      // Get intervention win and loss events for this month
      final winEvents = _eventsService.getEventsByType(
        AppEventType.interventionWin,
        startDate: monthStart,
        endDate: monthEnd,
      );
      
      final lossEvents = _eventsService.getEventsByType(
        AppEventType.interventionLoss,
        startDate: monthStart,
        endDate: monthEnd,
      );
      
      final wins = winEvents.length;
      final losses = lossEvents.length;
      final total = wins + losses;
      
      final successRate = total > 0 ? (wins / total) * 100 : 0.0;
      
      data.add(InterventionSuccessData(
        month: monthEnd.month,
        year: monthEnd.year,
        successRate: successRate,
        totalInterventions: total,
      ));
    }
    
    return data;
  }
}

// ===================================================================
// DATA MODELS
// ===================================================================

class WeeklyAdherenceData {
  final int week;
  final double adherencePercentage;
  final DateTime weekEndDate;
  
  WeeklyAdherenceData({
    required this.week,
    required this.adherencePercentage,
    required this.weekEndDate,
  });
}

class DayOfWeekData {
  final String dayName;
  final double averageDrinks;
  final int dayOfWeek;
  
  DayOfWeekData({
    required this.dayName,
    required this.averageDrinks,
    required this.dayOfWeek,
  });
}

class TimeOfDayData {
  final String timeSlot;
  final int drinkCount;
  
  TimeOfDayData({
    required this.timeSlot,
    required this.drinkCount,
  });
}

class InterventionSuccessData {
  final int month;
  final int year;
  final double successRate;
  final int totalInterventions;
  
  InterventionSuccessData({
    required this.month,
    required this.year,
    required this.successRate,
    required this.totalInterventions,
  });
  
  String get monthName {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
