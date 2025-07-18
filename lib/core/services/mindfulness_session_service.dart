import 'package:hive/hive.dart';
import '../models/mindfulness_session.dart';
import 'hive_core.dart';

/// Service for managing mindfulness session data
class MindfulnessSessionService {
  /// Get the box instance from HiveCore
  static Box<Map> get _sessionBox {
    final hiveCore = HiveCore.instance;
    if (!hiveCore.isInitialized) {
      throw StateError('HiveCore not initialized. Initialize HiveCore first.');
    }
    return hiveCore.mindfulnessSessionsBox;
  }

  /// Save a mindfulness session
  static Future<void> saveSession(MindfulnessSession session) async {
    await _sessionBox.put(session.id, session.toHive());
  }

  /// Get a session by ID
  static MindfulnessSession? getSession(String sessionId) {
    final data = _sessionBox.get(sessionId);
    if (data == null) return null;
    
    return MindfulnessSession.fromHive(Map<String, dynamic>.from(data));
  }

  /// Update an existing session
  static Future<void> updateSession(MindfulnessSession session) async {
    final updatedSession = session.copyWith(updatedAt: DateTime.now());
    await _sessionBox.put(session.id, updatedSession.toHive());
  }

  /// Delete a session
  static Future<void> deleteSession(String sessionId) async {
    await _sessionBox.delete(sessionId);
  }

  /// Get all sessions
  static List<MindfulnessSession> getAllSessions() {
    return _sessionBox.values
        .map((data) => MindfulnessSession.fromHive(Map<String, dynamic>.from(data)))
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime)); // Most recent first
  }

  /// Get sessions within a date range
  static List<MindfulnessSession> getSessionsInRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return getAllSessions()
        .where((session) =>
            session.startTime.isAfter(startDate.subtract(const Duration(days: 1))) &&
            session.startTime.isBefore(endDate.add(const Duration(days: 1))))
        .toList();
  }

  /// Get sessions for today
  static List<MindfulnessSession> getTodaySessions() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return getSessionsInRange(startOfDay, endOfDay);
  }

  /// Get sessions for a specific date
  static List<MindfulnessSession> getSessionsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return getSessionsInRange(startOfDay, endOfDay);
  }

  /// Get sessions by type
  static List<MindfulnessSession> getSessionsByType(MindfulnessExerciseType type) {
    return getAllSessions()
        .where((session) => session.exerciseType == type)
        .toList();
  }

  /// Get completed sessions only
  static List<MindfulnessSession> getCompletedSessions() {
    return getAllSessions()
        .where((session) => session.wasCompleted)
        .toList();
  }

  /// Get urge surfing sessions only
  static List<MindfulnessSession> getUrgeSurfingSessions() {
    return getSessionsByType(MindfulnessExerciseType.urgeSurfing);
  }

  /// Get active (started but not completed) sessions
  static List<MindfulnessSession> getActiveSessions() {
    return getAllSessions()
        .where((session) => session.status == SessionStatus.started)
        .toList();
  }

  /// Complete a session
  static Future<MindfulnessSession> completeSession(
    String sessionId, {
    MoodRating? postMood,
    int? urgeIntensityAfter,
    String? notes,
  }) async {
    final session = getSession(sessionId);
    if (session == null) {
      throw ArgumentError('Session not found: $sessionId');
    }

    final now = DateTime.now();
    final actualDurationSeconds = now.difference(session.startTime).inSeconds;

    final completedSession = session.copyWith(
      endTime: now,
      status: SessionStatus.completed,
      actualDurationSeconds: actualDurationSeconds,
      postMood: postMood,
      urgeIntensityAfter: urgeIntensityAfter,
      notes: notes,
      updatedAt: now,
    );

    await updateSession(completedSession);
    return completedSession;
  }

  /// Mark a session as interrupted
  static Future<MindfulnessSession> interruptSession(
    String sessionId, {
    String? notes,
  }) async {
    final session = getSession(sessionId);
    if (session == null) {
      throw ArgumentError('Session not found: $sessionId');
    }

    final now = DateTime.now();
    final actualDurationSeconds = now.difference(session.startTime).inSeconds;

    final interruptedSession = session.copyWith(
      endTime: now,
      status: SessionStatus.interrupted,
      actualDurationSeconds: actualDurationSeconds,
      notes: notes,
      updatedAt: now,
    );

    await updateSession(interruptedSession);
    return interruptedSession;
  }

  /// Get session statistics
  static Map<String, dynamic> getSessionStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final sessions = startDate != null && endDate != null
        ? getSessionsInRange(startDate, endDate)
        : getAllSessions();

    final completedSessions = sessions.where((s) => s.wasCompleted).toList();
    final urgeSurfingSessions = sessions.where((s) => s.isUrgeSurfing).toList();

    // Calculate totals
    final totalSessions = sessions.length;
    final totalCompleted = completedSessions.length;
    final totalMinutes = completedSessions
        .map((s) => s.actualDurationSeconds ?? 0)
        .fold(0, (sum, duration) => sum + duration) ~/
        60;

    // Calculate completion rate
    final completionRate = totalSessions > 0 ? totalCompleted / totalSessions : 0.0;

    // Calculate average mood improvement
    final moodImprovements = completedSessions
        .map((s) => s.moodImprovement)
        .where((improvement) => improvement != null)
        .cast<int>();
    final avgMoodImprovement = moodImprovements.isNotEmpty
        ? moodImprovements.reduce((a, b) => a + b) / moodImprovements.length
        : 0.0;

    // Calculate average urge reduction for urge surfing
    final urgeReductions = urgeSurfingSessions
        .map((s) => s.urgeReduction)
        .where((reduction) => reduction != null)
        .cast<int>();
    final avgUrgeReduction = urgeReductions.isNotEmpty
        ? urgeReductions.reduce((a, b) => a + b) / urgeReductions.length
        : 0.0;

    // Exercise type breakdown
    final exerciseBreakdown = <MindfulnessExerciseType, int>{};
    for (final type in MindfulnessExerciseType.values) {
      exerciseBreakdown[type] = sessions
          .where((s) => s.exerciseType == type)
          .length;
    }

    return {
      'totalSessions': totalSessions,
      'completedSessions': totalCompleted,
      'completionRate': completionRate,
      'totalMinutes': totalMinutes,
      'averageMoodImprovement': avgMoodImprovement,
      'averageUrgeReduction': avgUrgeReduction,
      'exerciseBreakdown': exerciseBreakdown,
      'urgeSurfingSessions': urgeSurfingSessions.length,
    };
  }

  /// Get mood pattern analysis
  static Map<String, dynamic> getMoodPatterns({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final sessions = startDate != null && endDate != null
        ? getSessionsInRange(startDate, endDate)
        : getAllSessions();

    final sessionsWithMoods = sessions
        .where((s) => s.preMood != null && s.postMood != null)
        .toList();

    if (sessionsWithMoods.isEmpty) {
      return {
        'preMoodAverage': 0.0,
        'postMoodAverage': 0.0,
        'moodImprovementAverage': 0.0,
        'moodDistribution': <int, int>{},
      };
    }

    // Calculate averages
    final preMoodSum = sessionsWithMoods
        .map((s) => s.preMood!.value)
        .reduce((a, b) => a + b);
    final postMoodSum = sessionsWithMoods
        .map((s) => s.postMood!.value)
        .reduce((a, b) => a + b);

    final preMoodAverage = preMoodSum / sessionsWithMoods.length;
    final postMoodAverage = postMoodSum / sessionsWithMoods.length;
    final moodImprovementAverage = postMoodAverage - preMoodAverage;

    // Mood distribution (pre-session)
    final moodDistribution = <int, int>{};
    for (int i = 1; i <= 10; i++) {
      moodDistribution[i] = sessionsWithMoods
          .where((s) => s.preMood!.value == i)
          .length;
    }

    return {
      'preMoodAverage': preMoodAverage,
      'postMoodAverage': postMoodAverage,
      'moodImprovementAverage': moodImprovementAverage,
      'moodDistribution': moodDistribution,
      'totalSessionsWithMoods': sessionsWithMoods.length,
    };
  }

  /// Clear all session data (for testing/development)
  static Future<void> clearAllSessions() async {
    await _sessionBox.clear();
  }

  /// Get session count by exercise type for insights
  static Map<MindfulnessExerciseType, int> getExerciseTypeStats() {
    final sessions = getAllSessions();
    final stats = <MindfulnessExerciseType, int>{};
    
    for (final type in MindfulnessExerciseType.values) {
      stats[type] = sessions.where((s) => s.exerciseType == type).length;
    }
    
    return stats;
  }

  /// Get recent session trend (last 7 days)
  static List<Map<String, dynamic>> getRecentTrend() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    final trend = <Map<String, dynamic>>[];
    
    for (int i = 0; i < 7; i++) {
      final date = weekAgo.add(Duration(days: i));
      final sessionsForDay = getSessionsForDate(date);
      final completedForDay = sessionsForDay.where((s) => s.wasCompleted).length;
      
      trend.add({
        'date': date,
        'totalSessions': sessionsForDay.length,
        'completedSessions': completedForDay,
        'totalMinutes': sessionsForDay
            .where((s) => s.actualDurationSeconds != null)
            .map((s) => s.actualDurationSeconds! ~/ 60)
            .fold(0, (sum, minutes) => sum + minutes),
      });
    }
    
    return trend;
  }
}
