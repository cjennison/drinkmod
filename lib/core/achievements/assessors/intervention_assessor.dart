import '../models/achievement_model.dart';
import '../../models/app_event.dart';
import '../../services/app_events_service.dart';
import 'base_assessor.dart';

/// Assessor for intervention-based achievements (successful interventions)
class InterventionAssessor extends BaseAssessor {
  final AppEventsService _eventsService = AppEventsService.instance;

  @override
  Future<AssessmentResult> assess(String achievementId, {Map<String, dynamic>? context}) async {
    switch (achievementId) {
      case 'first_intervention_win':
        return await _assessFirstInterventionWin();
      case '5_intervention_wins':
        return await _assess5InterventionWins();
      case '10_intervention_wins':
        return await _assess10InterventionWins();
      case 'intervention_champion':
        return await _assessInterventionChampion();
      case 'streak_saver':
        return await _assessStreakSaver();
      default:
        return const AssessmentResult.skip(reason: 'Unknown intervention achievement');
    }
  }

  /// Check if user has their first intervention win
  Future<AssessmentResult> _assessFirstInterventionWin() async {
    final hasWin = _eventsService.hasEventOfType(AppEventType.interventionWin);
    
    if (hasWin) {
      final firstWin = _eventsService.getFirstEventOfType(AppEventType.interventionWin);
      return AssessmentResult.grant(
        context: {
          'interventionType': firstWin?.metadata['interventionType'],
          'winAt': firstWin?.timestamp.toIso8601String(),
        },
        reason: 'User won their first intervention',
      );
    }
    
    return const AssessmentResult.skip(
      reason: 'User has not won any interventions yet',
    );
  }

  /// Check if user has 5 intervention wins
  Future<AssessmentResult> _assess5InterventionWins() async {
    final count = _eventsService.getEventCount(AppEventType.interventionWin);
    
    if (count >= 5) {
      return AssessmentResult.grant(
        context: {'totalInterventionWins': count},
        reason: 'User has $count intervention wins',
      );
    }
    
    return AssessmentResult.skip(
      context: {'totalInterventionWins': count},
      reason: 'User has only $count intervention wins',
    );
  }

  /// Check if user has 10 intervention wins
  Future<AssessmentResult> _assess10InterventionWins() async {
    final count = _eventsService.getEventCount(AppEventType.interventionWin);
    
    if (count >= 10) {
      return AssessmentResult.grant(
        context: {'totalInterventionWins': count},
        reason: 'User has $count intervention wins',
      );
    }
    
    return AssessmentResult.skip(
      context: {'totalInterventionWins': count},
      reason: 'User has only $count intervention wins',
    );
  }

  /// Check if user is an intervention champion (80% win rate with at least 10 interventions)
  Future<AssessmentResult> _assessInterventionChampion() async {
    final stats = _eventsService.getInterventionStats();
    final totalInterventions = stats['totalInterventions'] as int;
    final winRate = stats['winRate'] as double;
    
    // Need at least 10 interventions to be considered for champion status
    if (totalInterventions < 10) {
      return AssessmentResult.skip(
        context: stats,
        reason: 'Need at least 10 interventions to be considered for champion status',
      );
    }

    if (winRate >= 0.8) {
      return AssessmentResult.grant(
        context: stats,
        reason: 'User has ${(winRate * 100).round()}% intervention win rate with $totalInterventions total interventions',
      );
    }

    return AssessmentResult.skip(
      context: stats,
      reason: 'User has ${(winRate * 100).round()}% intervention win rate with $totalInterventions total interventions',
    );
  }

  /// Check if user saved their streak by declining a drink (schedule violation intervention win)
  Future<AssessmentResult> _assessStreakSaver() async {
    final winEvents = _eventsService.getEventsByType(AppEventType.interventionWin);
    
    // Look for schedule violation intervention wins
    final scheduleViolationWins = winEvents.where((event) => 
        event.metadata['interventionType'] == 'scheduleViolation').toList();
    
    if (scheduleViolationWins.isNotEmpty) {
      final firstWin = scheduleViolationWins.first;
      return AssessmentResult.grant(
        context: {
          'winAt': firstWin.timestamp.toIso8601String(),
          'totalScheduleViolationWins': scheduleViolationWins.length,
        },
        reason: 'User avoided drinking on an alcohol-free day',
      );
    }
    
    return const AssessmentResult.skip(
      reason: 'User has not avoided drinking on an alcohol-free day yet',
    );
  }
}
