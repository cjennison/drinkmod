import 'dart:developer' as developer;
import '../models/app_event.dart';
import 'hive_core.dart';

/// Service for tracking and managing app events for achievements
class AppEventsService {
  static AppEventsService? _instance;
  static AppEventsService get instance => _instance ??= AppEventsService._();
  
  AppEventsService._();
  
  final HiveCore _hiveCore = HiveCore.instance;
  
  /// Record an app event
  Future<String> recordEvent(AppEvent event) async {
    await _hiveCore.ensureInitialized();
    
    await _hiveCore.appEventsBox.put(event.id, event.toHive());
    developer.log('Recorded app event: ${event.type.name} - ${event.id}', name: 'AppEventsService');
    return event.id;
  }

  /// Get events by type with optional date filtering
  List<AppEvent> getEventsByType(
    AppEventType type, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    if (!_hiveCore.isInitialized) return [];
    
    var events = _hiveCore.appEventsBox.values
        .map((eventData) => AppEvent.fromHive(Map<String, dynamic>.from(eventData)))
        .where((event) => event.type == type)
        .toList();
    
    if (startDate != null || endDate != null) {
      events = events.where((event) {
        if (startDate != null && event.timestamp.isBefore(startDate)) return false;
        if (endDate != null && event.timestamp.isAfter(endDate)) return false;
        return true;
      }).toList();
    }
    
    // Sort by timestamp descending
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return events;
  }

  /// Get all events with optional date filtering
  List<AppEvent> getAllEvents({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    if (!_hiveCore.isInitialized) return [];
    
    var events = _hiveCore.appEventsBox.values
        .map((eventData) => AppEvent.fromHive(Map<String, dynamic>.from(eventData)))
        .toList();
    
    if (startDate != null || endDate != null) {
      events = events.where((event) {
        if (startDate != null && event.timestamp.isBefore(startDate)) return false;
        if (endDate != null && event.timestamp.isAfter(endDate)) return false;
        return true;
      }).toList();
    }
    
    // Sort by timestamp descending
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return events;
  }

  /// Get count of events by type
  int getEventCount(AppEventType type, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return getEventsByType(type, startDate: startDate, endDate: endDate).length;
  }

  /// Get drink logging statistics
  Map<String, dynamic> getDrinkLoggingStats({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final drinkEvents = getEventsByType(AppEventType.drinkLogged, startDate: startDate, endDate: endDate);
    
    if (drinkEvents.isEmpty) {
      return {
        'totalDrinks': 0,
        'compliantDrinks': 0,
        'nonCompliantDrinks': 0,
        'withinLimitDrinks': 0,
        'overLimitDrinks': 0,
        'interventionDrinks': 0,
        'complianceRate': 0.0,
        'limitComplianceRate': 0.0,
      };
    }

    final compliantDrinks = drinkEvents.where((e) => e.metadata['isScheduleCompliant'] == true).length;
    final withinLimitDrinks = drinkEvents.where((e) => e.metadata['isWithinLimit'] == true).length;
    final interventionDrinks = drinkEvents.where((e) => e.metadata['wasIntervention'] == true).length;

    return {
      'totalDrinks': drinkEvents.length,
      'compliantDrinks': compliantDrinks,
      'nonCompliantDrinks': drinkEvents.length - compliantDrinks,
      'withinLimitDrinks': withinLimitDrinks,
      'overLimitDrinks': drinkEvents.length - withinLimitDrinks,
      'interventionDrinks': interventionDrinks,
      'complianceRate': compliantDrinks / drinkEvents.length,
      'limitComplianceRate': withinLimitDrinks / drinkEvents.length,
    };
  }

  /// Get intervention statistics
  Map<String, dynamic> getInterventionStats({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final winEvents = getEventsByType(AppEventType.interventionWin, startDate: startDate, endDate: endDate);
    final lossEvents = getEventsByType(AppEventType.interventionLoss, startDate: startDate, endDate: endDate);
    
    final totalInterventions = winEvents.length + lossEvents.length;
    
    return {
      'totalInterventions': totalInterventions,
      'wins': winEvents.length,
      'losses': lossEvents.length,
      'winRate': totalInterventions > 0 ? winEvents.length / totalInterventions : 0.0,
    };
  }

  /// Get events for the last N days
  List<AppEvent> getEventsForLastDays(int days) {
    final startDate = DateTime.now().subtract(Duration(days: days));
    return getAllEvents(startDate: startDate);
  }

  /// Check if user has any events of a specific type
  bool hasEventOfType(AppEventType type) {
    return getEventCount(type) > 0;
  }

  /// Get the first event of a specific type
  AppEvent? getFirstEventOfType(AppEventType type) {
    final events = getEventsByType(type);
    if (events.isEmpty) return null;
    
    // Sort by timestamp ascending to get the first
    events.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return events.first;
  }

  /// Get recent events (last 50)
  List<AppEvent> getRecentEvents({int limit = 50}) {
    final events = getAllEvents();
    return events.take(limit).toList();
  }
}
