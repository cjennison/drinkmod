import '../models/achievement_model.dart';
import '../../models/app_event.dart';
import '../../services/app_events_service.dart';
import 'base_assessor.dart';

/// Assessor for tracking-based achievements (drink logging milestones)
class TrackingAssessor extends BaseAssessor {
  final AppEventsService _eventsService = AppEventsService.instance;

  @override
  Future<AssessmentResult> assess(String achievementId, {Map<String, dynamic>? context}) async {
    switch (achievementId) {
      case 'first_drink_logged':
        return await _assessFirstDrinkLogged();
      case '5_drinks_logged':
        return await _assess5DrinksLogged();
      case '10_drinks_logged':
        return await _assess10DrinksLogged();
      case '25_drinks_logged':
        return await _assess25DrinksLogged();
      case '50_drinks_logged':
        return await _assess50DrinksLogged();
      case 'week_of_logging':
        return await _assessWeekOfLogging();
      case 'compliant_logger':
        return await _assessCompliantLogger();
      default:
        return const AssessmentResult.skip(reason: 'Unknown tracking achievement');
    }
  }

  /// Check if user has logged their first drink
  Future<AssessmentResult> _assessFirstDrinkLogged() async {
    final hasLogged = _eventsService.hasEventOfType(AppEventType.drinkLogged);
    
    if (hasLogged) {
      final firstEvent = _eventsService.getFirstEventOfType(AppEventType.drinkLogged);
      return AssessmentResult.grant(
        context: {
          'drinkName': firstEvent?.metadata['drinkName'],
          'loggedAt': firstEvent?.timestamp.toIso8601String(),
        },
        reason: 'User logged their first drink',
      );
    }
    
    return const AssessmentResult.skip(
      reason: 'User has not logged any drinks yet',
    );
  }

  /// Check if user has logged 5 drinks
  Future<AssessmentResult> _assess5DrinksLogged() async {
    final count = _eventsService.getEventCount(AppEventType.drinkLogged);
    
    if (count >= 5) {
      return AssessmentResult.grant(
        context: {'totalDrinksLogged': count},
        reason: 'User has logged $count drinks',
      );
    }
    
    return AssessmentResult.skip(
      context: {'totalDrinksLogged': count},
      reason: 'User has only logged $count drinks',
    );
  }

  /// Check if user has logged 10 drinks
  Future<AssessmentResult> _assess10DrinksLogged() async {
    final count = _eventsService.getEventCount(AppEventType.drinkLogged);
    
    if (count >= 10) {
      return AssessmentResult.grant(
        context: {'totalDrinksLogged': count},
        reason: 'User has logged $count drinks',
      );
    }
    
    return AssessmentResult.skip(
      context: {'totalDrinksLogged': count},
      reason: 'User has only logged $count drinks',
    );
  }

  /// Check if user has logged 25 drinks
  Future<AssessmentResult> _assess25DrinksLogged() async {
    final count = _eventsService.getEventCount(AppEventType.drinkLogged);
    
    if (count >= 25) {
      return AssessmentResult.grant(
        context: {'totalDrinksLogged': count},
        reason: 'User has logged $count drinks',
      );
    }
    
    return AssessmentResult.skip(
      context: {'totalDrinksLogged': count},
      reason: 'User has only logged $count drinks',
    );
  }

  /// Check if user has logged 50 drinks
  Future<AssessmentResult> _assess50DrinksLogged() async {
    final count = _eventsService.getEventCount(AppEventType.drinkLogged);
    
    if (count >= 50) {
      return AssessmentResult.grant(
        context: {'totalDrinksLogged': count},
        reason: 'User has logged $count drinks',
      );
    }
    
    return AssessmentResult.skip(
      context: {'totalDrinksLogged': count},
      reason: 'User has only logged $count drinks',
    );
  }

  /// Check if user has logged drinks for 7 consecutive days
  Future<AssessmentResult> _assessWeekOfLogging() async {
    final events = _eventsService.getEventsByType(AppEventType.drinkLogged);
    
    if (events.isEmpty) {
      return const AssessmentResult.skip(
        reason: 'No drinks logged yet',
      );
    }

    // Group events by date
    final eventsByDate = <String, List<AppEvent>>{};
    for (final event in events) {
      final dateKey = '${event.timestamp.year}-${event.timestamp.month.toString().padLeft(2, '0')}-${event.timestamp.day.toString().padLeft(2, '0')}';
      eventsByDate.putIfAbsent(dateKey, () => []).add(event);
    }

    // Check for 7 consecutive days
    final dates = eventsByDate.keys.toList()..sort();
    int consecutiveDays = 1;
    int maxConsecutiveDays = 1;

    for (int i = 1; i < dates.length; i++) {
      final currentDate = DateTime.parse(dates[i]);
      final previousDate = DateTime.parse(dates[i - 1]);
      
      if (currentDate.difference(previousDate).inDays == 1) {
        consecutiveDays++;
        maxConsecutiveDays = maxConsecutiveDays > consecutiveDays ? maxConsecutiveDays : consecutiveDays;
      } else {
        consecutiveDays = 1;
      }
    }

    if (maxConsecutiveDays >= 7) {
      return AssessmentResult.grant(
        context: {
          'maxConsecutiveDays': maxConsecutiveDays,
          'uniqueDaysLogged': eventsByDate.length,
        },
        reason: 'User logged drinks for $maxConsecutiveDays consecutive days',
      );
    }

    return AssessmentResult.skip(
      context: {
        'maxConsecutiveDays': maxConsecutiveDays,
        'uniqueDaysLogged': eventsByDate.length,
      },
      reason: 'User has only logged drinks for $maxConsecutiveDays consecutive days',
    );
  }

  /// Check if user is a compliant logger (80% of drinks within schedule/limits)
  Future<AssessmentResult> _assessCompliantLogger() async {
    final stats = _eventsService.getDrinkLoggingStats();
    final totalDrinks = stats['totalDrinks'] as int;
    
    // Need at least 10 drinks to assess compliance
    if (totalDrinks < 10) {
      return AssessmentResult.skip(
        context: stats,
        reason: 'Need at least 10 drinks logged to assess compliance',
      );
    }

    final complianceRate = stats['complianceRate'] as double;
    final limitComplianceRate = stats['limitComplianceRate'] as double;
    
    // Need both schedule and limit compliance >= 80%
    if (complianceRate >= 0.8 && limitComplianceRate >= 0.8) {
      return AssessmentResult.grant(
        context: stats,
        reason: 'User maintains ${(complianceRate * 100).round()}% schedule compliance and ${(limitComplianceRate * 100).round()}% limit compliance',
      );
    }

    return AssessmentResult.skip(
      context: stats,
      reason: 'User has ${(complianceRate * 100).round()}% schedule compliance and ${(limitComplianceRate * 100).round()}% limit compliance',
    );
  }
}
