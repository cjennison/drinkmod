import '../models/mindfulness_session.dart';
import '../models/daily_reflection_log.dart';
import '../models/app_event.dart';
import 'mindfulness_session_service.dart';
import 'reflection_service.dart';

/// Analytics service for mindfulness and reflection data insights
class MindfulnessAnalyticsService {
  
  /// Generate comprehensive mindfulness insights
  static Map<String, dynamic> generateMindfulnessInsights({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final sessionStats = MindfulnessSessionService.getSessionStatistics(
      startDate: startDate,
      endDate: endDate,
    );
    
    final reflectionStats = ReflectionService.getReflectionStatistics(
      startDate: startDate,
      endDate: endDate,
    );
    
    final moodPatterns = MindfulnessSessionService.getMoodPatterns(
      startDate: startDate,
      endDate: endDate,
    );
    
    final streaks = ReflectionService.getReflectionStreaks();
    final recentTrend = MindfulnessSessionService.getRecentTrend();
    
    return {
      'sessionStats': sessionStats,
      'reflectionStats': reflectionStats,
      'moodPatterns': moodPatterns,
      'streaks': streaks,
      'recentTrend': recentTrend,
      'combinedInsights': _generateCombinedInsights(
        sessionStats,
        reflectionStats,
        moodPatterns,
      ),
    };
  }

  /// Generate combined insights from session and reflection data
  static Map<String, dynamic> _generateCombinedInsights(
    Map<String, dynamic> sessionStats,
    Map<String, dynamic> reflectionStats,
    Map<String, dynamic> moodPatterns,
  ) {
    // Calculate overall mindfulness engagement
    final totalSessions = sessionStats['totalSessions'] as int;
    final activeDays = reflectionStats['activeDays'] as int;
    final totalMinutes = sessionStats['totalMinutes'] as int;
    
    // Engagement score (0-100)
    final engagementScore = _calculateEngagementScore(
      totalSessions,
      activeDays,
      totalMinutes,
    );
    
    // Effectiveness score based on mood improvements and urge reductions
    final avgMoodImprovement = sessionStats['averageMoodImprovement'] as double;
    final avgUrgeReduction = sessionStats['averageUrgeReduction'] as double;
    final effectivenessScore = _calculateEffectivenessScore(
      avgMoodImprovement,
      avgUrgeReduction,
    );
    
    // Consistency score based on reflection streaks and session completion
    final completionRate = sessionStats['completionRate'] as double;
    final consistencyRate = reflectionStats['consistencyRate'] as double;
    final consistencyScore = _calculateConsistencyScore(
      completionRate,
      consistencyRate,
    );
    
    return {
      'engagementScore': engagementScore,
      'effectivenessScore': effectivenessScore,
      'consistencyScore': consistencyScore,
      'overallScore': (engagementScore + effectivenessScore + consistencyScore) / 3,
      'recommendations': _generateRecommendations(
        engagementScore,
        effectivenessScore,
        consistencyScore,
        sessionStats,
        reflectionStats,
      ),
    };
  }
  
  /// Calculate engagement score (0-100)
  static double _calculateEngagementScore(
    int totalSessions,
    int activeDays,
    int totalMinutes,
  ) {
    // Base score from activity frequency
    double score = 0.0;
    
    // Sessions component (40% of score)
    if (totalSessions >= 30) {
      score += 40.0;
    } else if (totalSessions >= 15) {
      score += 30.0;
    } else if (totalSessions >= 5) {
      score += 20.0;
    } else if (totalSessions > 0) {
      score += 10.0;
    }
    
    // Active days component (30% of score)
    if (activeDays >= 21) {
      score += 30.0;
    } else if (activeDays >= 14) {
      score += 25.0;
    } else if (activeDays >= 7) {
      score += 20.0;
    } else if (activeDays > 0) {
      score += 10.0;
    }
    
    // Time investment component (30% of score)
    if (totalMinutes >= 180) { // 3+ hours
      score += 30.0;
    } else if (totalMinutes >= 120) { // 2+ hours
      score += 25.0;
    } else if (totalMinutes >= 60) { // 1+ hour
      score += 20.0;
    } else if (totalMinutes > 0) {
      score += 10.0;
    }
    
    return score.clamp(0.0, 100.0);
  }
  
  /// Calculate effectiveness score (0-100)
  static double _calculateEffectivenessScore(
    double avgMoodImprovement,
    double avgUrgeReduction,
  ) {
    double score = 0.0;
    
    // Mood improvement component (50% of score)
    if (avgMoodImprovement >= 2.0) {
      score += 50.0;
    } else if (avgMoodImprovement >= 1.5) {
      score += 40.0;
    } else if (avgMoodImprovement >= 1.0) {
      score += 30.0;
    } else if (avgMoodImprovement >= 0.5) {
      score += 20.0;
    } else if (avgMoodImprovement > 0) {
      score += 10.0;
    }
    
    // Urge reduction component (50% of score)
    if (avgUrgeReduction >= 3.0) {
      score += 50.0;
    } else if (avgUrgeReduction >= 2.0) {
      score += 40.0;
    } else if (avgUrgeReduction >= 1.0) {
      score += 30.0;
    } else if (avgUrgeReduction >= 0.5) {
      score += 20.0;
    } else if (avgUrgeReduction > 0) {
      score += 10.0;
    }
    
    return score.clamp(0.0, 100.0);
  }
  
  /// Calculate consistency score (0-100)
  static double _calculateConsistencyScore(
    double completionRate,
    double consistencyRate,
  ) {
    // Session completion component (50% of score)
    final completionScore = completionRate * 50;
    
    // Reflection consistency component (50% of score)
    final reflectionScore = consistencyRate * 50;
    
    return (completionScore + reflectionScore).clamp(0.0, 100.0);
  }
  
  /// Generate personalized recommendations
  static List<Map<String, String>> _generateRecommendations(
    double engagementScore,
    double effectivenessScore,
    double consistencyScore,
    Map<String, dynamic> sessionStats,
    Map<String, dynamic> reflectionStats,
  ) {
    final recommendations = <Map<String, String>>[];
    
    // Engagement recommendations
    if (engagementScore < 30) {
      recommendations.add({
        'type': 'engagement',
        'title': 'Start Small',
        'description': 'Try a 2-minute daily breathing exercise to build your mindfulness habit.',
        'priority': 'high',
      });
    } else if (engagementScore < 60) {
      recommendations.add({
        'type': 'engagement',
        'title': 'Increase Frequency',
        'description': 'Aim for at least one mindfulness session every other day.',
        'priority': 'medium',
      });
    }
    
    // Effectiveness recommendations
    if (effectivenessScore < 40) {
      recommendations.add({
        'type': 'effectiveness',
        'title': 'Focus on Urge Surfing',
        'description': 'When experiencing cravings, try the Wave visualization for better results.',
        'priority': 'high',
      });
    }
    
    // Consistency recommendations
    if (consistencyScore < 50) {
      recommendations.add({
        'type': 'consistency',
        'title': 'Set Reminders',
        'description': 'Enable daily mindfulness reminders to build a consistent practice.',
        'priority': 'medium',
      });
    }
    
    // Reflection-specific recommendations
    final reflectionRate = reflectionStats['consistencyRate'] as double;
    if (reflectionRate < 0.3) {
      recommendations.add({
        'type': 'reflection',
        'title': 'Daily Check-ins',
        'description': 'Spend 2 minutes each evening reflecting on your day.',
        'priority': 'medium',
      });
    }
    
    // Session-specific recommendations
    final completionRate = sessionStats['completionRate'] as double;
    if (completionRate < 0.7) {
      recommendations.add({
        'type': 'sessions',
        'title': 'Shorter Sessions',
        'description': 'Try shorter 1-3 minute sessions to improve completion rates.',
        'priority': 'low',
      });
    }
    
    return recommendations;
  }
  
  /// Get mindfulness activity summary for a specific date
  static Map<String, dynamic> getDailyMindfulnessSummary(DateTime date) {
    final sessions = MindfulnessSessionService.getSessionsForDate(date);
    final reflectionLog = ReflectionService.getReflectionLogForDate(date);
    
    final completedSessions = sessions.where((s) => s.wasCompleted).length;
    final totalMinutes = sessions
        .where((s) => s.actualDurationSeconds != null)
        .map((s) => s.actualDurationSeconds! ~/ 60)
        .fold(0, (sum, minutes) => sum + minutes);
    
    final urgeSurfingSessions = sessions.where((s) => s.isUrgeSurfing).length;
    
    return {
      'date': date,
      'totalSessions': sessions.length,
      'completedSessions': completedSessions,
      'totalMinutes': totalMinutes,
      'urgeSurfingSessions': urgeSurfingSessions,
      'hasReflection': reflectionLog?.hasContent ?? false,
      'reflectionEntries': reflectionLog?.entries.length ?? 0,
      'hasCheckIn': reflectionLog?.dailyCheckIn?.isNotEmpty ?? false,
    };
  }
  
  /// Get weekly mindfulness trends
  static List<Map<String, dynamic>> getWeeklyTrends() {
    final trends = <Map<String, dynamic>>[];
    final now = DateTime.now();
    
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      trends.add(getDailyMindfulnessSummary(date));
    }
    
    return trends.reversed.toList(); // Chronological order
  }
  
  /// Get mindfulness milestones achieved
  static List<Map<String, dynamic>> getMindfulnessMilestones() {
    final sessionStats = MindfulnessSessionService.getSessionStatistics();
    final streaks = ReflectionService.getReflectionStreaks();
    
    final milestones = <Map<String, dynamic>>[];
    
    // Session milestones
    final totalSessions = sessionStats['totalSessions'] as int;
    if (totalSessions >= 1) {
      milestones.add({
        'title': 'First Session',
        'description': 'Completed your first mindfulness session',
        'icon': 'star',
        'achieved': true,
      });
    }
    if (totalSessions >= 10) {
      milestones.add({
        'title': 'Mindful Explorer',
        'description': 'Completed 10 mindfulness sessions',
        'icon': 'explore',
        'achieved': true,
      });
    }
    if (totalSessions >= 50) {
      milestones.add({
        'title': 'Mindfulness Practitioner',
        'description': 'Completed 50 mindfulness sessions',
        'icon': 'self_improvement',
        'achieved': true,
      });
    }
    
    // Streak milestones
    final currentStreak = streaks['currentStreak'] as int;
    if (currentStreak >= 3) {
      milestones.add({
        'title': '3-Day Streak',
        'description': 'Reflected for 3 consecutive days',
        'icon': 'local_fire_department',
        'achieved': true,
      });
    }
    if (currentStreak >= 7) {
      milestones.add({
        'title': 'Week Warrior',
        'description': 'Reflected for 7 consecutive days',
        'icon': 'whatshot',
        'achieved': true,
      });
    }
    
    // Time milestones
    final totalMinutes = sessionStats['totalMinutes'] as int;
    if (totalMinutes >= 60) {
      milestones.add({
        'title': 'Hour of Mindfulness',
        'description': 'Spent 1 hour in mindful practice',
        'icon': 'schedule',
        'achieved': true,
      });
    }
    
    return milestones;
  }
  
  /// Generate app events for mindfulness activities
  static Future<void> logMindfulnessEvent(AppEvent event) async {
    // Here we could integrate with AppEventService if it exists
    // For now, this is a placeholder for event logging
  }
  
  /// Create session started event
  static AppEvent createSessionStartedEvent(MindfulnessSession session) {
    return AppEvent.mindfulnessSessionStarted(
      timestamp: session.startTime,
      sessionId: session.id,
      exerciseType: session.exerciseType.name,
      metaphor: session.metaphor?.name,
      plannedDurationSeconds: session.plannedDurationSeconds,
    );
  }
  
  /// Create session completed event
  static AppEvent createSessionCompletedEvent(MindfulnessSession session) {
    return AppEvent.mindfulnessSessionCompleted(
      timestamp: session.endTime ?? DateTime.now(),
      sessionId: session.id,
      exerciseType: session.exerciseType.name,
      actualDurationSeconds: session.actualDurationSeconds ?? 0,
      moodImprovement: session.moodImprovement,
      urgeReduction: session.urgeReduction,
    );
  }
  
  /// Create reflection entry event
  static AppEvent createReflectionEntryEvent(ReflectionEntry entry) {
    return AppEvent.reflectionEntryAdded(
      timestamp: entry.timestamp,
      entryId: entry.id,
      category: entry.category.name,
      contentLength: entry.content.length,
    );
  }
  
  /// Create daily check-in event
  static AppEvent createDailyCheckInEvent(String checkIn) {
    return AppEvent.dailyCheckInCompleted(
      timestamp: DateTime.now(),
      checkInLength: checkIn.length,
    );
  }
}
