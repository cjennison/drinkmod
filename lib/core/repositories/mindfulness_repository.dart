import '../models/mindfulness_session.dart';
import '../models/daily_reflection_log.dart';
import '../services/mindfulness_session_service.dart';
import '../services/reflection_service.dart';
import '../services/mindfulness_analytics_service.dart';

/// Repository pattern for mindfulness data management
/// Provides a clean interface for UI components to interact with mindfulness data
class MindfulnessRepository {
  
  // =============================================================================
  // MINDFULNESS SESSIONS
  // =============================================================================
  
  /// Start a new mindfulness session
  Future<MindfulnessSession> startSession({
    required MindfulnessExerciseType exerciseType,
    UrgeSurfingMetaphor? metaphor,
    int? plannedDurationSeconds,
    MoodRating? preMood,
    int? urgeIntensityBefore,
  }) async {
    final session = exerciseType == MindfulnessExerciseType.urgeSurfing
        ? MindfulnessSession.createUrgeSurfing(
            metaphor: metaphor!,
            plannedDurationSeconds: plannedDurationSeconds ?? 60,
            urgeIntensityBefore: urgeIntensityBefore,
            preMood: preMood,
          )
        : MindfulnessSession.createMindfulness(
            exerciseType: exerciseType,
            plannedDurationSeconds: plannedDurationSeconds,
            preMood: preMood,
          );

    await MindfulnessSessionService.saveSession(session);

    // Log the start event
    final event = MindfulnessAnalyticsService.createSessionStartedEvent(session);
    await MindfulnessAnalyticsService.logMindfulnessEvent(event);

    return session;
  }

  /// Complete a mindfulness session
  Future<MindfulnessSession> completeSession(
    String sessionId, {
    MoodRating? postMood,
    int? urgeIntensityAfter,
    String? notes,
  }) async {
    final completedSession = await MindfulnessSessionService.completeSession(
      sessionId,
      postMood: postMood,
      urgeIntensityAfter: urgeIntensityAfter,
      notes: notes,
    );

    // Log the completion event
    final event = MindfulnessAnalyticsService.createSessionCompletedEvent(completedSession);
    await MindfulnessAnalyticsService.logMindfulnessEvent(event);

    return completedSession;
  }

  /// Interrupt a mindfulness session
  Future<MindfulnessSession> interruptSession(
    String sessionId, {
    String? notes,
  }) async {
    return await MindfulnessSessionService.interruptSession(
      sessionId,
      notes: notes,
    );
  }

  /// Get a session by ID
  MindfulnessSession? getSession(String sessionId) {
    return MindfulnessSessionService.getSession(sessionId);
  }

  /// Get today's sessions
  List<MindfulnessSession> getTodaysSessions() {
    return MindfulnessSessionService.getTodaySessions();
  }

  /// Get sessions for a specific date
  List<MindfulnessSession> getSessionsForDate(DateTime date) {
    return MindfulnessSessionService.getSessionsForDate(date);
  }

  /// Get completed sessions
  List<MindfulnessSession> getCompletedSessions() {
    return MindfulnessSessionService.getCompletedSessions();
  }

  /// Get active sessions
  List<MindfulnessSession> getActiveSessions() {
    return MindfulnessSessionService.getActiveSessions();
  }

  /// Get sessions by type
  List<MindfulnessSession> getSessionsByType(MindfulnessExerciseType type) {
    return MindfulnessSessionService.getSessionsByType(type);
  }

  /// Get session statistics
  Map<String, dynamic> getSessionStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return MindfulnessSessionService.getSessionStatistics(
      startDate: startDate,
      endDate: endDate,
    );
  }

  // =============================================================================
  // DAILY REFLECTIONS
  // =============================================================================

  /// Get today's reflection log (creates if doesn't exist)
  DailyReflectionLog getTodaysReflectionLog() {
    return ReflectionService.getTodaysReflectionLog();
  }

  /// Get reflection log for a specific date
  DailyReflectionLog? getReflectionLogForDate(DateTime date) {
    return ReflectionService.getReflectionLogForDate(date);
  }

  /// Update today's daily check-in
  Future<DailyReflectionLog> updateTodaysCheckIn(String checkInText) async {
    final updatedLog = await ReflectionService.updateTodaysCheckIn(checkInText);

    // Log the check-in event
    final event = MindfulnessAnalyticsService.createDailyCheckInEvent(checkInText);
    await MindfulnessAnalyticsService.logMindfulnessEvent(event);

    return updatedLog;
  }

  /// Add a reflection entry to today
  Future<DailyReflectionLog> addReflectionEntryToday(
    ReflectionCategory category,
    String content,
  ) async {
    final updatedLog = await ReflectionService.addReflectionEntryToday(
      category,
      content,
    );

    // Log the reflection entry event
    final entry = updatedLog.entries.last; // Get the newly added entry
    final event = MindfulnessAnalyticsService.createReflectionEntryEvent(entry);
    await MindfulnessAnalyticsService.logMindfulnessEvent(event);

    return updatedLog;
  }

  /// Add a reflection entry to a specific date
  Future<DailyReflectionLog> addReflectionEntryToDate(
    DateTime date,
    ReflectionCategory category,
    String content,
  ) async {
    return await ReflectionService.addReflectionEntryToDate(
      date,
      category,
      content,
    );
  }

  /// Update a reflection entry
  Future<DailyReflectionLog> updateReflectionEntry(
    DateTime date,
    String entryId,
    String newContent,
  ) async {
    return await ReflectionService.updateReflectionEntry(
      date,
      entryId,
      newContent,
    );
  }

  /// Remove a reflection entry
  Future<DailyReflectionLog> removeReflectionEntry(
    DateTime date,
    String entryId,
  ) async {
    return await ReflectionService.removeReflectionEntry(date, entryId);
  }

  /// Get today's entries for a specific category
  List<ReflectionEntry> getTodaysEntriesForCategory(ReflectionCategory category) {
    return ReflectionService.getTodaysEntriesForCategory(category);
  }

  /// Get today's gratitude entries
  List<ReflectionEntry> getTodaysGratitudeEntries() {
    return ReflectionService.getTodaysGratitudeEntries();
  }

  /// Get today's trigger entries
  List<ReflectionEntry> getTodaysTriggerEntries() {
    return ReflectionService.getTodaysTriggerEntries();
  }

  /// Get today's values entries
  List<ReflectionEntry> getTodaysValuesEntries() {
    return ReflectionService.getTodaysValuesEntries();
  }

  /// Get today's progress entries
  List<ReflectionEntry> getTodaysProgressEntries() {
    return ReflectionService.getTodaysProgressEntries();
  }

  /// Get recent reflection logs
  List<DailyReflectionLog> getRecentReflectionLogs(int days) {
    return ReflectionService.getRecentReflectionLogs(days);
  }

  /// Get reflection statistics
  Map<String, dynamic> getReflectionStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ReflectionService.getReflectionStatistics(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Get reflection streaks
  Map<String, int> getReflectionStreaks() {
    return ReflectionService.getReflectionStreaks();
  }

  // =============================================================================
  // ANALYTICS & INSIGHTS
  // =============================================================================

  /// Generate comprehensive mindfulness insights
  Map<String, dynamic> generateMindfulnessInsights({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return MindfulnessAnalyticsService.generateMindfulnessInsights(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Get daily mindfulness summary
  Map<String, dynamic> getDailyMindfulnessSummary(DateTime date) {
    return MindfulnessAnalyticsService.getDailyMindfulnessSummary(date);
  }

  /// Get weekly mindfulness trends
  List<Map<String, dynamic>> getWeeklyTrends() {
    return MindfulnessAnalyticsService.getWeeklyTrends();
  }

  /// Get mindfulness milestones
  List<Map<String, dynamic>> getMindfulnessMilestones() {
    return MindfulnessAnalyticsService.getMindfulnessMilestones();
  }

  /// Get mood patterns analysis
  Map<String, dynamic> getMoodPatterns({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return MindfulnessSessionService.getMoodPatterns(
      startDate: startDate,
      endDate: endDate,
    );
  }

  // =============================================================================
  // CONVENIENCE METHODS
  // =============================================================================

  /// Check if user has any mindfulness activity today
  bool hasActivityToday() {
    final sessions = getTodaysSessions();
    final reflectionLog = getTodaysReflectionLog();
    
    return sessions.isNotEmpty || reflectionLog.hasContent;
  }

  /// Get today's mindfulness summary for dashboard
  Map<String, dynamic> getTodaysSummary() {
    final sessions = getTodaysSessions();
    final completedSessions = sessions.where((s) => s.wasCompleted).length;
    final totalMinutes = sessions
        .where((s) => s.actualDurationSeconds != null)
        .map((s) => s.actualDurationSeconds! ~/ 60)
        .fold(0, (sum, minutes) => sum + minutes);
    
    final reflectionLog = getTodaysReflectionLog();
    
    return {
      'totalSessions': sessions.length,
      'completedSessions': completedSessions,
      'totalMinutes': totalMinutes,
      'hasReflection': reflectionLog.hasContent,
      'reflectionEntries': reflectionLog.entries.length,
      'hasCheckIn': reflectionLog.dailyCheckIn?.isNotEmpty ?? false,
      'gratitudeCount': reflectionLog.gratitudeEntries.length,
      'triggerCount': reflectionLog.triggerEntries.length,
      'valuesCount': reflectionLog.valuesEntries.length,
      'progressCount': reflectionLog.progressEntries.length,
    };
  }

  /// Get recent urge surfing effectiveness
  Map<String, dynamic> getUrgeSurfingEffectiveness() {
    final urgeSessions = MindfulnessSessionService.getUrgeSurfingSessions()
        .where((s) => s.wasCompleted && s.urgeReduction != null)
        .toList();

    if (urgeSessions.isEmpty) {
      return {
        'totalSessions': 0,
        'averageReduction': 0.0,
        'effectivenessRate': 0.0,
      };
    }

    final totalReduction = urgeSessions
        .map((s) => s.urgeReduction!)
        .fold(0, (sum, reduction) => sum + reduction);
    
    final averageReduction = totalReduction / urgeSessions.length;
    final effectiveSessions = urgeSessions
        .where((s) => s.urgeReduction! > 0)
        .length;
    
    final effectivenessRate = effectiveSessions / urgeSessions.length;

    return {
      'totalSessions': urgeSessions.length,
      'averageReduction': averageReduction,
      'effectivenessRate': effectivenessRate,
      'mostEffectiveMetaphor': _getMostEffectiveMetaphor(urgeSessions),
    };
  }

  /// Find the most effective urge surfing metaphor
  String? _getMostEffectiveMetaphor(List<MindfulnessSession> urgeSessions) {
    final metaphorStats = <UrgeSurfingMetaphor, List<int>>{};
    
    for (final session in urgeSessions) {
      if (session.metaphor != null && session.urgeReduction != null) {
        metaphorStats.putIfAbsent(session.metaphor!, () => []);
        metaphorStats[session.metaphor!]!.add(session.urgeReduction!);
      }
    }

    if (metaphorStats.isEmpty) return null;

    String? bestMetaphor;
    double bestAverage = 0.0;

    for (final entry in metaphorStats.entries) {
      final average = entry.value.reduce((a, b) => a + b) / entry.value.length;
      if (average > bestAverage) {
        bestAverage = average;
        bestMetaphor = entry.key.name;
      }
    }

    return bestMetaphor;
  }

  /// Get streak information for dashboard
  Map<String, dynamic> getStreakInformation() {
    final streaks = getReflectionStreaks();
    final sessionStats = getSessionStatistics();
    
    return {
      'reflectionStreak': streaks['currentStreak'],
      'longestReflectionStreak': streaks['longestStreak'],
      'totalSessions': sessionStats['totalSessions'],
      'completionRate': sessionStats['completionRate'],
    };
  }

  /// Clear all mindfulness data (for testing/development)
  Future<void> clearAllData() async {
    await MindfulnessSessionService.clearAllSessions();
    await ReflectionService.clearAllReflections();
  }
}
