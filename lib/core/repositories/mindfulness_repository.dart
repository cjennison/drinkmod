import '../models/mindfulness_session.dart';
import '../models/journal_entry.dart';
import '../services/journal_service.dart';
import '../services/mindfulness_analytics_service.dart';
import '../services/mindfulness_session_service.dart';
import '../services/reflection_service.dart';

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
  // DAILY JOURNAL ENTRIES
  // =============================================================================

  /// Get today's journal entry (creates if doesn't exist)
  Future<JournalEntry> getTodaysJournalEntry() async {
    return await JournalService.instance.getOrCreateTodaysEntry();
  }

  /// Get journal entry for a specific date
  Future<JournalEntry?> getJournalEntryForDate(DateTime date) async {
    return await JournalService.instance.getEntryByDate(date);
  }

  /// Update today's journal entry
  Future<JournalEntry> updateTodaysJournalEntry(JournalEntry entry) async {
    await JournalService.instance.updateTodaysEntry(entry);
    
    // Log the journal event
    final event = MindfulnessAnalyticsService.createJournalEntryEvent(entry);
    await MindfulnessAnalyticsService.logMindfulnessEvent(event);

    return entry;
  }

  /// Add gratitude entry to today's journal
  Future<JournalEntry> addGratitudeToday(String gratitude) async {
    final entry = await getTodaysJournalEntry();
    final currentGratitude = entry.gratitudeEntry ?? '';
    final updatedGratitude = currentGratitude.isEmpty 
        ? gratitude 
        : '$currentGratitude\n$gratitude';
    final updatedEntry = entry.copyWith(gratitudeEntry: updatedGratitude);
    
    return await updateTodaysJournalEntry(updatedEntry);
  }

  /// Add challenge entry to today's journal
  Future<JournalEntry> addChallengeToday(String challenge) async {
    final entry = await getTodaysJournalEntry();
    final currentChallenges = entry.challengesEntry ?? '';
    final updatedChallenges = currentChallenges.isEmpty 
        ? challenge 
        : '$currentChallenges\n$challenge';
    final updatedEntry = entry.copyWith(challengesEntry: updatedChallenges);
    
    return await updateTodaysJournalEntry(updatedEntry);
  }

  /// Add accomplishment to today's journal
  Future<JournalEntry> addAccomplishmentToday(String accomplishment) async {
    final entry = await getTodaysJournalEntry();
    final currentAccomplishments = entry.accomplishmentsEntry ?? '';
    final updatedAccomplishments = currentAccomplishments.isEmpty 
        ? accomplishment 
        : '$currentAccomplishments\n$accomplishment';
    final updatedEntry = entry.copyWith(accomplishmentsEntry: updatedAccomplishments);
    
    return await updateTodaysJournalEntry(updatedEntry);
  }

  /// Update mood for today's journal
  Future<JournalEntry> updateTodaysMood(MoodLevel mood, {int? anxietyLevel, int? stressLevel}) async {
    final entry = await getTodaysJournalEntry();
    final updatedEntry = entry.copyWith(
      overallMood: mood,
      anxietyLevel: anxietyLevel,
      stressLevel: stressLevel,
    );
    
    return await updateTodaysJournalEntry(updatedEntry);
  }

  /// Add emotion tags to today's journal
  Future<JournalEntry> addEmotionTagsToday(List<String> tags) async {
    final entry = await getTodaysJournalEntry();
    final updatedTags = Set<String>.from(entry.emotionTags)..addAll(tags);
    final updatedEntry = entry.copyWith(emotionTags: updatedTags.toList());
    
    return await updateTodaysJournalEntry(updatedEntry);
  }

  /// Get recent journal entries
  Future<List<JournalEntry>> getRecentJournalEntries(int days) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    return await JournalService.instance.getEntriesInRange(startDate, now);
  }

  /// Get reflection statistics
  Future<Map<String, dynamic>> getReflectionStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await ReflectionService.getReflectionStatistics(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Get reflection streaks
  Future<Map<String, int>> getReflectionStreaks() async {
    return await ReflectionService.getReflectionStreaks();
  }

  // =============================================================================
  // ANALYTICS & INSIGHTS
  // =============================================================================

  /// Generate comprehensive mindfulness insights
  Future<Map<String, dynamic>> generateMindfulnessInsights({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await MindfulnessAnalyticsService.generateMindfulnessInsights(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Get daily mindfulness summary
  Future<Map<String, dynamic>> getDailyMindfulnessSummary(DateTime date) async {
    return await MindfulnessAnalyticsService.getDailyMindfulnessSummary(date);
  }

  /// Get weekly mindfulness trends
  Future<List<Map<String, dynamic>>> getWeeklyTrends() async {
    return await MindfulnessAnalyticsService.getWeeklyTrends();
  }

  /// Get mindfulness milestones
  Future<List<Map<String, dynamic>>> getMindfulnessMilestones() async {
    return await MindfulnessAnalyticsService.getMindfulnessMilestones();
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
  Future<bool> hasActivityToday() async {
    final sessions = getTodaysSessions();
    final journalEntry = await getTodaysJournalEntry();
    
    return sessions.isNotEmpty || journalEntry.completionPercentage > 0.1;
  }

  /// Get today's mindfulness summary for dashboard
  Future<Map<String, dynamic>> getTodaysSummary() async {
    final sessions = getTodaysSessions();
    final completedSessions = sessions.where((s) => s.wasCompleted).length;
    final totalMinutes = sessions
        .where((s) => s.actualDurationSeconds != null)
        .map((s) => s.actualDurationSeconds! ~/ 60)
        .fold(0, (sum, minutes) => sum + minutes);
    
    final journalEntry = await getTodaysJournalEntry();
    
    return {
      'totalSessions': sessions.length,
      'completedSessions': completedSessions,
      'totalMinutes': totalMinutes,
      'hasReflection': journalEntry.completionPercentage > 0.1,
      'hasGratitude': (journalEntry.gratitudeEntry?.isNotEmpty ?? false),
      'hasChallenges': (journalEntry.challengesEntry?.isNotEmpty ?? false),
      'hasAccomplishments': (journalEntry.accomplishmentsEntry?.isNotEmpty ?? false),
      'overallMood': journalEntry.overallMood?.index,
      'anxietyLevel': journalEntry.anxietyLevel,
      'stressLevel': journalEntry.stressLevel,
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
  Future<Map<String, dynamic>> getStreakInformation() async {
    final streaks = await getReflectionStreaks();
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
    await ReflectionService.clearAllReflectionData();
  }
}
