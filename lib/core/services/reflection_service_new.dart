import 'dart:developer' as developer;
import '../models/journal_entry.dart';
import '../services/journal_service.dart';

/// Service for managing daily reflections using the new JournalEntry model
/// This service acts as a wrapper around JournalService for backward compatibility
class ReflectionService {
  /// Get today's journal entry (creates if doesn't exist)
  static Future<JournalEntry> getTodaysJournalEntry() async {
    return await JournalService.instance.getTodaysEntry();
  }

  /// Get journal entry for a specific date
  static Future<JournalEntry?> getJournalEntryForDate(DateTime date) async {
    return await JournalService.instance.getEntryByDate(date);
  }

  /// Get or create journal entry for a specific date
  static Future<JournalEntry> getOrCreateJournalEntryForDate(DateTime date) async {
    final entry = await getJournalEntryForDate(date);
    if (entry != null) {
      return entry;
    }
    
    // Create new entry for the date
    final newEntry = JournalEntry(date: date);
    await JournalService.instance.saveEntry(newEntry);
    return newEntry;
  }

  /// Update today's free-form writing
  static Future<JournalEntry> updateTodaysWriting(String writingText) async {
    final entry = await getTodaysJournalEntry();
    final updatedEntry = entry.copyWith(freeformEntry: writingText);
    await JournalService.instance.saveEntry(updatedEntry);
    
    developer.log('Updated today\'s writing', name: 'ReflectionService');
    return updatedEntry;
  }

  /// Add gratitude entry to today
  static Future<JournalEntry> addGratitudeToday(String gratitude) async {
    final entry = await getTodaysJournalEntry();
    final currentGratitude = entry.gratitudeEntry ?? '';
    final updatedGratitude = currentGratitude.isEmpty 
        ? gratitude 
        : '$currentGratitude\n$gratitude';
    final updatedEntry = entry.copyWith(gratitudeEntry: updatedGratitude);
    await JournalService.instance.saveEntry(updatedEntry);
    
    developer.log('Added gratitude entry for today', name: 'ReflectionService');
    return updatedEntry;
  }

  /// Add challenge entry to today
  static Future<JournalEntry> addChallengeToday(String challenge) async {
    final entry = await getTodaysJournalEntry();
    final currentChallenges = entry.challengesEntry ?? '';
    final updatedChallenges = currentChallenges.isEmpty 
        ? challenge 
        : '$currentChallenges\n$challenge';
    final updatedEntry = entry.copyWith(challengesEntry: updatedChallenges);
    await JournalService.instance.saveEntry(updatedEntry);
    
    developer.log('Added challenge entry for today', name: 'ReflectionService');
    return updatedEntry;
  }

  /// Add accomplishment to today
  static Future<JournalEntry> addAccomplishmentToday(String accomplishment) async {
    final entry = await getTodaysJournalEntry();
    final currentAccomplishments = entry.accomplishmentsEntry ?? '';
    final updatedAccomplishments = currentAccomplishments.isEmpty 
        ? accomplishment 
        : '$currentAccomplishments\n$accomplishment';
    final updatedEntry = entry.copyWith(accomplishmentsEntry: updatedAccomplishments);
    await JournalService.instance.saveEntry(updatedEntry);
    
    developer.log('Added accomplishment entry for today', name: 'ReflectionService');
    return updatedEntry;
  }

  /// Add emotion tags to today
  static Future<JournalEntry> addEmotionTagsToday(List<String> tags) async {
    final entry = await getTodaysJournalEntry();
    final updatedTags = Set<String>.from(entry.emotionTags)..addAll(tags);
    final updatedEntry = entry.copyWith(emotionTags: updatedTags.toList());
    await JournalService.instance.saveEntry(updatedEntry);
    
    developer.log('Added emotion tags for today', name: 'ReflectionService');
    return updatedEntry;
  }

  /// Update mood for today
  static Future<JournalEntry> updateTodaysMood(MoodLevel mood, {int? anxietyLevel, int? stressLevel}) async {
    final entry = await getTodaysJournalEntry();
    final updatedEntry = entry.copyWith(
      overallMood: mood,
      anxietyLevel: anxietyLevel,
      stressLevel: stressLevel,
    );
    await JournalService.instance.saveEntry(updatedEntry);
    
    developer.log('Updated mood for today', name: 'ReflectionService');
    return updatedEntry;
  }

  /// Add coping strategy to today
  static Future<JournalEntry> addCopingStrategyToday(String strategy) async {
    final entry = await getTodaysJournalEntry();
    final updatedStrategies = List<String>.from(entry.copingStrategiesUsed)..add(strategy);
    final updatedEntry = entry.copyWith(copingStrategiesUsed: updatedStrategies);
    await JournalService.instance.saveEntry(updatedEntry);
    
    developer.log('Added coping strategy for today', name: 'ReflectionService');
    return updatedEntry;
  }

  /// Update coping strategies plan for today
  static Future<JournalEntry> updateCopingStrategiesPlan(String plan) async {
    final entry = await getTodaysJournalEntry();
    final updatedEntry = entry.copyWith(copingStrategiesEntry: plan);
    await JournalService.instance.saveEntry(updatedEntry);
    
    developer.log('Updated coping strategies plan for today', name: 'ReflectionService');
    return updatedEntry;
  }

  /// Get all journal entries
  static Future<List<JournalEntry>> getAllJournalEntries() async {
    return await JournalService.instance.getAllEntries();
  }

  /// Get journal entries in a date range
  static Future<List<JournalEntry>> getJournalEntriesInRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await JournalService.instance.getEntriesInRange(startDate, endDate);
  }

  /// Get recent journal entries
  static Future<List<JournalEntry>> getRecentJournalEntries(int days) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    return await getJournalEntriesInRange(startDate, now);
  }

  /// Get entries with content (completed entries)
  static Future<List<JournalEntry>> getEntriesWithContent() async {
    final allEntries = await getAllJournalEntries();
    return allEntries.where((entry) => entry.completionPercentage > 0.1).toList();
  }

  /// Get today's gratitude entries
  static Future<String> getTodaysGratitudeEntry() async {
    final entry = await getTodaysJournalEntry();
    return entry.gratitudeEntry ?? '';
  }

  /// Get today's challenge entries
  static Future<String> getTodaysChallengeEntry() async {
    final entry = await getTodaysJournalEntry();
    return entry.challengesEntry ?? '';
  }

  /// Get today's accomplishment entries
  static Future<String> getTodaysAccomplishmentEntry() async {
    final entry = await getTodaysJournalEntry();
    return entry.accomplishmentsEntry ?? '';
  }

  /// Get today's emotion tags
  static Future<List<String>> getTodaysEmotionTags() async {
    final entry = await getTodaysJournalEntry();
    return entry.emotionTags;
  }

  /// Get reflection statistics
  static Future<Map<String, dynamic>> getReflectionStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final now = DateTime.now();
    final start = startDate ?? now.subtract(const Duration(days: 30));
    final end = endDate ?? now;
    
    final entries = await getJournalEntriesInRange(start, end);
    final completedEntries = entries.where((e) => e.isComplete).toList();
    
    // Mood distribution
    final moodCounts = <MoodLevel, int>{};
    for (final mood in MoodLevel.values) {
      moodCounts[mood] = 0;
    }
    
    for (final entry in entries) {
      if (entry.overallMood != null) {
        moodCounts[entry.overallMood!] = moodCounts[entry.overallMood!]! + 1;
      }
    }
    
    // Calculate averages
    final totalEntries = entries.length;
    final completionRate = totalEntries > 0 ? completedEntries.length / totalEntries : 0.0;
    final averageCompletion = totalEntries > 0 
        ? entries.fold<double>(0.0, (sum, e) => sum + e.completionPercentage) / totalEntries
        : 0.0;
    
    // Streak calculation
    final currentStreak = await JournalService.instance.getCurrentStreak();
    
    return {
      'totalEntries': totalEntries,
      'completedEntries': completedEntries.length,
      'completionRate': completionRate,
      'averageCompletion': averageCompletion,
      'currentStreak': currentStreak,
      'moodDistribution': moodCounts,
      'dateRange': {
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
      },
    };
  }

  /// Get reflection streaks
  static Future<Map<String, int>> getReflectionStreaks() async {
    final currentStreak = await JournalService.instance.getCurrentStreak();
    final weeklyRate = await JournalService.instance.getWeeklyCompletionRate();
    
    return {
      'currentStreak': currentStreak,
      'weeklyCompletionRate': (weeklyRate * 100).round(),
    };
  }

  /// Check if user has journaled today
  static Future<bool> hasJournaledToday() async {
    return await JournalService.instance.hasJournaledToday();
  }

  /// Get today's completion percentage
  static Future<double> getTodaysCompletionPercentage() async {
    final entry = await getTodaysJournalEntry();
    return entry.completionPercentage;
  }

  /// Clear all reflection data
  static Future<void> clearAllReflectionData() async {
    await JournalService.instance.clearAllData();
    developer.log('All reflection data cleared', name: 'ReflectionService');
  }
}
