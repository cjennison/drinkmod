import 'dart:developer' as developer;
import '../models/intervention_event.dart';
import '../models/app_event.dart';
import 'hive_core.dart';
import 'app_events_service.dart';

/// Service for managing intervention events and therapeutic analytics
class InterventionService {
  static InterventionService? _instance;
  static InterventionService get instance => _instance ??= InterventionService._();
  
  InterventionService._();
  
  final HiveCore _hiveCore = HiveCore.instance;
  final AppEventsService _eventsService = AppEventsService.instance;
  
  /// Record an intervention event
  Future<String> recordInterventionEvent({
    required InterventionType interventionType,
    required InterventionDecision decision,
    String? drinkEntryId,
    Map<String, dynamic>? context,
  }) async {
    await _hiveCore.ensureInitialized();
    
    final eventId = 'intervention_${DateTime.now().millisecondsSinceEpoch}';
    
    final event = {
      'id': eventId,
      'interventionType': interventionType.toString(),
      'decision': decision.toString(),
      'timestamp': DateTime.now().toIso8601String(),
      'drinkEntryId': drinkEntryId,
      'context': context ?? <String, dynamic>{},
    };
    
    await _hiveCore.interventionEventsBox.put(eventId, event);
    
    // Also record as app event for achievement tracking
    if (decision == InterventionDecision.declined) {
      await _eventsService.recordEvent(AppEvent.interventionWin(
        timestamp: DateTime.now(),
        interventionType: interventionType.toString(),
        reason: context?['reason'] as String?,
        additionalData: context,
      ));
    } else if (decision == InterventionDecision.proceeded) {
      await _eventsService.recordEvent(AppEvent.interventionLoss(
        timestamp: DateTime.now(),
        interventionType: interventionType.toString(),
        drinkId: drinkEntryId ?? 'unknown',
        reason: context?['reason'] as String?,
        additionalData: context,
      ));
    }
    
    developer.log('Recorded intervention event: $eventId - $decision', name: 'InterventionService');
    return eventId;
  }

  /// Get intervention events with optional filters
  List<Map<String, dynamic>> getInterventionEvents({
    InterventionType? type,
    InterventionDecision? decision,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    if (!_hiveCore.isInitialized) return [];
    
    var events = _hiveCore.interventionEventsBox.values
        .map((event) => Map<String, dynamic>.from(event))
        .toList();
    
    if (type != null) {
      events = events.where((event) => event['interventionType'] == type.toString()).toList();
    }
    
    if (decision != null) {
      events = events.where((event) => event['decision'] == decision.toString()).toList();
    }
    
    if (startDate != null || endDate != null) {
      events = events.where((event) {
        final timestamp = DateTime.parse(event['timestamp']);
        if (startDate != null && timestamp.isBefore(startDate)) return false;
        if (endDate != null && timestamp.isAfter(endDate)) return false;
        return true;
      }).toList();
    }
    
    // Sort by timestamp descending
    events.sort((a, b) => DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])));
    
    return events;
  }

  /// Get intervention success rate
  Map<String, dynamic> getInterventionStats({
    InterventionType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final events = getInterventionEvents(
      type: type,
      startDate: startDate,
      endDate: endDate,
    );
    
    if (events.isEmpty) {
      return {
        'totalEvents': 0,
        'successfulEvents': 0,
        'successRate': 0.0,
        'breakdownByType': <String, dynamic>{},
      };
    }
    
    final successfulEvents = events.where((event) => 
        event['decision'] == InterventionDecision.declined.toString()).length;
    
    final successRate = successfulEvents / events.length;
    
    // Breakdown by intervention type
    final breakdownByType = <String, dynamic>{};
    for (final type in InterventionType.values) {
      final typeEvents = events.where((event) => 
          event['interventionType'] == type.toString()).toList();
      final typeSuccesses = typeEvents.where((event) => 
          event['decision'] == InterventionDecision.declined.toString()).length;
      
      breakdownByType[type.toString()] = {
        'total': typeEvents.length,
        'successful': typeSuccesses,
        'successRate': typeEvents.isNotEmpty ? typeSuccesses / typeEvents.length : 0.0,
      };
    }
    
    return {
      'totalEvents': events.length,
      'successfulEvents': successfulEvents,
      'successRate': successRate,
      'breakdownByType': breakdownByType,
    };
  }

  /// Get recent intervention events
  List<Map<String, dynamic>> getRecentInterventionEvents({int limit = 10}) {
    final events = getInterventionEvents();
    return events.take(limit).toList();
  }
}
