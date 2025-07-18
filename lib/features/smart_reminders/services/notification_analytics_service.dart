import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/smart_reminder.dart';

/// Analytics service for tracking notification effectiveness and user engagement
class NotificationAnalyticsService {
  static const String _boxName = 'notification_analytics';
  static NotificationAnalyticsService? _instance;
  
  static NotificationAnalyticsService get instance {
    _instance ??= NotificationAnalyticsService._();
    return _instance!;
  }
  
  NotificationAnalyticsService._();
  
  Box<Map>? _analyticsBox;
  
  /// Initialize the analytics service
  Future<void> initialize() async {
    if (_analyticsBox?.isOpen != true) {
      _analyticsBox = await Hive.openBox<Map>(_boxName);
    }
  }
  
  /// Track notification delivery
  Future<void> trackNotificationSent(SmartReminder reminder, String messageType) async {
    await initialize();
    
    final event = {
      'reminderId': reminder.id,
      'reminderType': reminder.type.name,
      'messageType': messageType, // 'custom' or 'generated'
      'timestamp': DateTime.now().toIso8601String(),
      'dayOfWeek': DateTime.now().weekday,
      'timeOfDay': DateTime.now().hour,
      'event': 'notification_sent',
    };
    
    await _storeEvent(event);
  }
  
  /// Track notification tap/interaction
  Future<void> trackNotificationTapped(String reminderId) async {
    await initialize();
    
    final event = {
      'reminderId': reminderId,
      'timestamp': DateTime.now().toIso8601String(),
      'event': 'notification_tapped',
    };
    
    await _storeEvent(event);
  }
  
  /// Track notification dismissal (if platform supports it)
  Future<void> trackNotificationDismissed(String reminderId) async {
    await initialize();
    
    final event = {
      'reminderId': reminderId,
      'timestamp': DateTime.now().toIso8601String(),
      'event': 'notification_dismissed',
    };
    
    await _storeEvent(event);
  }
  
  /// Track reminder effectiveness (user completed intended action)
  Future<void> trackReminderEffective(String reminderId, String action) async {
    await initialize();
    
    final event = {
      'reminderId': reminderId,
      'action': action, // 'check_in_completed', 'log_updated', etc.
      'timestamp': DateTime.now().toIso8601String(),
      'event': 'reminder_effective',
    };
    
    await _storeEvent(event);
  }
  
  /// Store analytics event
  Future<void> _storeEvent(Map<String, dynamic> event) async {
    final key = '${event['event']}_${DateTime.now().millisecondsSinceEpoch}';
    await _analyticsBox!.put(key, event);
  }
  
  /// Get notification statistics for a reminder
  Future<Map<String, dynamic>> getReminderStats(String reminderId) async {
    await initialize();
    
    final allEvents = _analyticsBox!.values.where((event) => 
        event['reminderId'] == reminderId).toList();
    
    final sentCount = allEvents.where((e) => e['event'] == 'notification_sent').length;
    final tappedCount = allEvents.where((e) => e['event'] == 'notification_tapped').length;
    final effectiveCount = allEvents.where((e) => e['event'] == 'reminder_effective').length;
    
    return {
      'totalSent': sentCount,
      'totalTapped': tappedCount,
      'totalEffective': effectiveCount,
      'tapRate': sentCount > 0 ? (tappedCount / sentCount) : 0.0,
      'effectivenessRate': sentCount > 0 ? (effectiveCount / sentCount) : 0.0,
    };
  }
  
  /// Get overall notification analytics
  Future<Map<String, dynamic>> getOverallStats() async {
    await initialize();
    
    final allEvents = _analyticsBox!.values.toList();
    final sentEvents = allEvents.where((e) => e['event'] == 'notification_sent').toList();
    final tappedEvents = allEvents.where((e) => e['event'] == 'notification_tapped').toList();
    final effectiveEvents = allEvents.where((e) => e['event'] == 'reminder_effective').toList();
    
    // Analyze by time of day
    final timeAnalysis = <int, Map<String, int>>{};
    for (final event in sentEvents) {
      final hour = event['timeOfDay'] as int;
      timeAnalysis[hour] ??= {'sent': 0, 'tapped': 0};
      timeAnalysis[hour]!['sent'] = timeAnalysis[hour]!['sent']! + 1;
    }
    
    for (final event in tappedEvents) {
      // Find corresponding sent event to get time
      final reminderId = event['reminderId'];
      final sentEvent = sentEvents.where((e) => 
          e['reminderId'] == reminderId).firstOrNull;
      if (sentEvent != null) {
        final hour = sentEvent['timeOfDay'] as int;
        timeAnalysis[hour] ??= {'sent': 0, 'tapped': 0};
        timeAnalysis[hour]!['tapped'] = timeAnalysis[hour]!['tapped']! + 1;
      }
    }
    
    return {
      'totalSent': sentEvents.length,
      'totalTapped': tappedEvents.length,
      'totalEffective': effectiveEvents.length,
      'overallTapRate': sentEvents.isNotEmpty ? (tappedEvents.length / sentEvents.length) : 0.0,
      'overallEffectivenessRate': sentEvents.isNotEmpty ? (effectiveEvents.length / sentEvents.length) : 0.0,
      'timeAnalysis': timeAnalysis,
      'reminderTypeAnalysis': _analyzeByReminderType(allEvents),
    };
  }
  
  /// Analyze effectiveness by reminder type
  Map<String, Map<String, dynamic>> _analyzeByReminderType(List<Map> allEvents) {
    final typeAnalysis = <String, Map<String, dynamic>>{};
    
    for (final reminderType in ['friendlyCheckin', 'scheduleReminder']) {
      final typeEvents = allEvents.where((e) => e['reminderType'] == reminderType).toList();
      final sentCount = typeEvents.where((e) => e['event'] == 'notification_sent').length;
      final tappedCount = typeEvents.where((e) => e['event'] == 'notification_tapped').length;
      final effectiveCount = typeEvents.where((e) => e['event'] == 'reminder_effective').length;
      
      typeAnalysis[reminderType] = {
        'sent': sentCount,
        'tapped': tappedCount,
        'effective': effectiveCount,
        'tapRate': sentCount > 0 ? (tappedCount / sentCount) : 0.0,
        'effectivenessRate': sentCount > 0 ? (effectiveCount / sentCount) : 0.0,
      };
    }
    
    return typeAnalysis;
  }
  
  /// Get recommendations for optimal notification timing
  Future<Map<String, dynamic>> getTimingRecommendations() async {
    final stats = await getOverallStats();
    final timeAnalysis = stats['timeAnalysis'] as Map<int, Map<String, int>>;
    
    // Find best performing hours
    final hourScores = <int, double>{};
    timeAnalysis.forEach((hour, data) {
      final sent = data['sent']!;
      final tapped = data['tapped']!;
      if (sent > 0) {
        hourScores[hour] = tapped / sent;
      }
    });
    
    final sortedHours = hourScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return {
      'bestHours': sortedHours.take(3).map((e) => e.key).toList(),
      'worstHours': sortedHours.reversed.take(3).map((e) => e.key).toList(),
      'recommendedMorningTime': _findBestTimeInRange(hourScores, 6, 11),
      'recommendedEveningTime': _findBestTimeInRange(hourScores, 18, 22),
    };
  }
  
  /// Find best performing time within a range
  int? _findBestTimeInRange(Map<int, double> hourScores, int startHour, int endHour) {
    double bestScore = 0;
    int? bestHour;
    
    for (int hour = startHour; hour <= endHour; hour++) {
      final score = hourScores[hour] ?? 0;
      if (score > bestScore) {
        bestScore = score;
        bestHour = hour;
      }
    }
    
    return bestHour;
  }
  
  /// Clean up old analytics data (keep last 90 days)
  Future<void> cleanupOldData() async {
    await initialize();
    
    final cutoffDate = DateTime.now().subtract(const Duration(days: 90));
    final keysToDelete = <String>[];
    
    for (final key in _analyticsBox!.keys) {
      final event = _analyticsBox!.get(key);
      if (event != null) {
        final eventDate = DateTime.tryParse(event['timestamp'] ?? '');
        if (eventDate != null && eventDate.isBefore(cutoffDate)) {
          keysToDelete.add(key);
        }
      }
    }
    
    for (final key in keysToDelete) {
      await _analyticsBox!.delete(key);
    }
  }
  
  /// Export analytics data for debugging
  Future<String> exportAnalyticsData() async {
    await initialize();
    
    final allData = <String, dynamic>{};
    for (final key in _analyticsBox!.keys) {
      allData[key] = _analyticsBox!.get(key);
    }
    
    return jsonEncode(allData);
  }
  
  /// Clear all analytics data
  Future<void> clearAllData() async {
    await initialize();
    await _analyticsBox!.clear();
  }
}
