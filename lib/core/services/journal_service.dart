import 'dart:developer' as developer;
import '../models/journal_entry.dart';
import 'hive_core.dart';

/// Service for managing journal entries using HiveCore storage
class JournalService {
  static JournalService? _instance;
  static JournalService get instance => _instance ??= JournalService._();
  JournalService._();

  final HiveCore _hiveCore = HiveCore.instance;

  /// Get today's journal entry or create a new one
  Future<JournalEntry> getTodaysEntry() async {
    final today = _getTodayDateOnly();
    final entry = await getEntryByDate(today);
    
    if (entry != null) {
      return entry;
    }
    
    // Create new entry for today
    return JournalEntry(date: today);
  }

  /// Get or create today's journal entry (ensures it exists in storage)
  Future<JournalEntry> getOrCreateTodaysEntry() async {
    await _hiveCore.ensureInitialized();
    final today = _getTodayDateOnly();
    final dateKey = _formatDateKey(today);
    
    final entryData = _hiveCore.dailyReflectionLogsBox.get(dateKey);
    if (entryData != null) {
      return JournalEntry.fromJson(Map<String, dynamic>.from(entryData));
    }
    
    // Create new entry for today
    final entry = JournalEntry(date: today);
    await _hiveCore.dailyReflectionLogsBox.put(dateKey, entry.toJson());
    return entry;
  }

  /// Get journal entry for a specific date
  Future<JournalEntry?> getEntryByDate(DateTime date) async {
    await _hiveCore.ensureInitialized();
    final dateKey = _formatDateKey(_getDateOnly(date));
    final entryData = _hiveCore.dailyReflectionLogsBox.get(dateKey);
    
    if (entryData != null) {
      return JournalEntry.fromJson(Map<String, dynamic>.from(entryData));
    }
    return null;
  }

  /// Save or update a journal entry
  Future<void> saveEntry(JournalEntry entry) async {
    await _hiveCore.ensureInitialized();
    
    // Calculate completion
    final updatedEntry = entry.copyWith(
      completionPercentage: JournalEntry.calculateCompletionPercentage(entry),
      isComplete: JournalEntry.calculateCompletionPercentage(entry) >= 0.7, // 70% complete
    );
    
    final dateKey = _formatDateKey(_getDateOnly(updatedEntry.date));
    await _hiveCore.dailyReflectionLogsBox.put(dateKey, updatedEntry.toJson());
    
    // Update streak if this is today's entry and it's complete
    if (_isToday(updatedEntry.date) && updatedEntry.isComplete) {
      await _updateStreak(updatedEntry.date);
    }
    
    developer.log('Journal entry saved for ${dateKey}', name: 'JournalService');
  }

  /// Update today's journal entry
  Future<void> updateTodaysEntry(JournalEntry updatedEntry) async {
    await saveEntry(updatedEntry);
  }

  /// Get all journal entries
  Future<List<JournalEntry>> getAllEntries() async {
    await _hiveCore.ensureInitialized();
    final entriesData = _hiveCore.dailyReflectionLogsBox.values.toList();
    
    final entries = entriesData
        .map((data) => JournalEntry.fromJson(Map<String, dynamic>.from(data)))
        .toList();
    
    // Sort by date (newest first)
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  /// Get entries for a specific date range
  Future<List<JournalEntry>> getEntriesInRange(DateTime start, DateTime end) async {
    final allEntries = await getAllEntries();
    final startDate = _getDateOnly(start);
    final endDate = _getDateOnly(end);
    
    return allEntries.where((entry) {
      final entryDate = _getDateOnly(entry.date);
      return entryDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
             entryDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Get current journaling streak
  Future<int> getCurrentStreak() async {
    await _hiveCore.ensureInitialized();
    final streakData = _hiveCore.settingsBox.get('journal_streak');
    return streakData?['value'] ?? 0;
  }

  /// Check if user has journaled today
  Future<bool> hasJournaledToday() async {
    final todaysEntry = await getEntryByDate(_getTodayDateOnly());
    return todaysEntry != null && todaysEntry.completionPercentage > 0.1;
  }

  /// Get completion rate for last 7 days
  Future<double> getWeeklyCompletionRate() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final entries = await getEntriesInRange(weekAgo, now);
    
    if (entries.isEmpty) return 0.0;
    
    final totalCompletion = entries.fold<double>(
      0.0, 
      (sum, entry) => sum + entry.completionPercentage,
    );
    
    return totalCompletion / entries.length;
  }

  /// Get completion statistics
  Future<Map<String, dynamic>> getCompletionStats({int days = 30}) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final entries = await getEntriesInRange(startDate, now);
    
    final totalEntries = entries.length;
    final completedEntries = entries.where((e) => e.isComplete).length;
    final averageCompletion = entries.isEmpty 
        ? 0.0 
        : entries.fold<double>(0.0, (sum, e) => sum + e.completionPercentage) / totalEntries;
    
    return {
      'totalEntries': totalEntries,
      'completedEntries': completedEntries,
      'completionRate': totalEntries > 0 ? completedEntries / totalEntries : 0.0,
      'averageCompletion': averageCompletion,
      'currentStreak': await getCurrentStreak(),
    };
  }

  /// Get mood trends for analytics
  Future<Map<MoodLevel, int>> getMoodTrends({int days = 30}) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final entries = await getEntriesInRange(startDate, now);
    
    final moodCounts = <MoodLevel, int>{};
    for (final mood in MoodLevel.values) {
      moodCounts[mood] = 0;
    }
    
    for (final entry in entries) {
      if (entry.overallMood != null) {
        moodCounts[entry.overallMood!] = moodCounts[entry.overallMood!]! + 1;
      }
    }
    
    return moodCounts;
  }

  /// Get most common emotion tags
  Future<Map<String, int>> getTopEmotionTags({int days = 30}) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final entries = await getEntriesInRange(startDate, now);
    
    final tagCounts = <String, int>{};
    
    for (final entry in entries) {
      for (final tag in entry.emotionTags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }
    
    // Sort by frequency and return top 10
    final sortedEntries = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sortedEntries.take(10));
  }

  /// Delete a journal entry
  Future<void> deleteEntry(String entryId) async {
    await _hiveCore.ensureInitialized();
    final entries = await getAllEntries();
    final entryToDelete = entries.cast<JournalEntry?>().firstWhere(
      (entry) => entry?.id == entryId,
      orElse: () => null,
    );
    
    if (entryToDelete != null) {
      final dateKey = _formatDateKey(_getDateOnly(entryToDelete.date));
      await _hiveCore.dailyReflectionLogsBox.delete(dateKey);
      developer.log('Journal entry deleted for ${dateKey}', name: 'JournalService');
    }
  }

  /// Clear all journal data
  Future<void> clearAllData() async {
    await _hiveCore.ensureInitialized();
    await _hiveCore.dailyReflectionLogsBox.clear();
    await _hiveCore.settingsBox.delete('journal_streak');
    await _hiveCore.settingsBox.delete('last_journal_entry_date');
    developer.log('All journal data cleared', name: 'JournalService');
  }

  /// Update journaling streak
  Future<void> _updateStreak(DateTime entryDate) async {
    await _hiveCore.ensureInitialized();
    final lastEntryData = _hiveCore.settingsBox.get('last_journal_entry_date');
    final lastEntryDateStr = lastEntryData?['value'];
    final currentStreak = await getCurrentStreak();
    
    final today = _getTodayDateOnly();
    final yesterday = today.subtract(const Duration(days: 1));
    
    if (lastEntryDateStr == null) {
      // First entry ever
      await _hiveCore.settingsBox.put('journal_streak', {'value': 1});
    } else {
      final lastEntryDate = DateTime.parse(lastEntryDateStr);
      
      if (_getDateOnly(entryDate).isAtSameMomentAs(today)) {
        // Entry for today
        if (_getDateOnly(lastEntryDate).isAtSameMomentAs(yesterday)) {
          // Consecutive day - increment streak
          await _hiveCore.settingsBox.put('journal_streak', {'value': currentStreak + 1});
        } else if (!_getDateOnly(lastEntryDate).isAtSameMomentAs(today)) {
          // Gap in entries - reset streak
          await _hiveCore.settingsBox.put('journal_streak', {'value': 1});
        }
        // If last entry was today, don't change streak
      }
    }
    
    await _hiveCore.settingsBox.put('last_journal_entry_date', {'value': _getDateOnly(entryDate).toIso8601String()});
  }

  /// Format date key for Hive storage
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Check if date is today
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return _getDateOnly(date).isAtSameMomentAs(_getDateOnly(now));
  }

  /// Utility to get date without time component
  DateTime _getDateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get today's date without time
  DateTime _getTodayDateOnly() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Export journal data as JSON for backup
  Future<Map<String, dynamic>> exportData() async {
    final entries = await getAllEntries();
    final metadata = await getCompletionStats();
    
    return {
      'entries': entries.map((e) => e.toJson()).toList(),
      'metadata': metadata,
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0',
    };
  }

  /// Import journal data from backup
  Future<bool> importData(Map<String, dynamic> data) async {
    try {
      await _hiveCore.ensureInitialized();
      
      final List<dynamic> entriesJson = data['entries'];
      final entries = entriesJson.map((json) => JournalEntry.fromJson(json)).toList();
      
      // Clear existing data
      await clearAllData();
      
      // Save imported entries
      for (final entry in entries) {
        final dateKey = _formatDateKey(_getDateOnly(entry.date));
        await _hiveCore.dailyReflectionLogsBox.put(dateKey, entry.toJson());
      }
      
      developer.log('Journal data imported successfully', name: 'JournalService');
      return true;
    } catch (e) {
      developer.log('Error importing journal data: $e', name: 'JournalService');
      return false;
    }
  }
}
