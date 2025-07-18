import 'package:hive/hive.dart';
import '../models/daily_reflection_log.dart';
import 'hive_core.dart';

/// Service for managing daily reflection logs and personal journaling
class ReflectionService {
  /// Get the box instance from HiveCore
  static Box<Map> get _reflectionBox {
    final hiveCore = HiveCore.instance;
    if (!hiveCore.isInitialized) {
      throw StateError('HiveCore not initialized. Initialize HiveCore first.');
    }
    return hiveCore.dailyReflectionLogsBox;
  }

  /// Generate a date key for consistent storage
  static String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Save a daily reflection log
  static Future<void> saveReflectionLog(DailyReflectionLog log) async {
    await _reflectionBox.put(log.dateKey, log.toHive());
  }

  /// Get reflection log for a specific date
  static DailyReflectionLog? getReflectionLogForDate(DateTime date) {
    final dateKey = _dateKey(date);
    final data = _reflectionBox.get(dateKey);
    if (data == null) return null;
    
    return DailyReflectionLog.fromHive(Map<String, dynamic>.from(data));
  }

  /// Get or create reflection log for today
  static DailyReflectionLog getTodaysReflectionLog() {
    final today = DateTime.now();
    final existing = getReflectionLogForDate(today);
    
    if (existing != null) {
      return existing;
    }
    
    // Create new log for today
    return DailyReflectionLog.createForToday();
  }

  /// Get or create reflection log for a specific date
  static DailyReflectionLog getOrCreateReflectionLogForDate(DateTime date) {
    final existing = getReflectionLogForDate(date);
    
    if (existing != null) {
      return existing;
    }
    
    // Create new log for the date
    return DailyReflectionLog.createForDate(date);
  }

  /// Update the daily check-in for today
  static Future<DailyReflectionLog> updateTodaysCheckIn(String checkInText) async {
    final log = getTodaysReflectionLog();
    final updatedLog = log.copyWith(dailyCheckIn: checkInText);
    
    await saveReflectionLog(updatedLog);
    return updatedLog;
  }

  /// Add a reflection entry to today's log
  static Future<DailyReflectionLog> addReflectionEntryToday(
    ReflectionCategory category,
    String content,
  ) async {
    final log = getTodaysReflectionLog();
    final entry = ReflectionEntry(
      category: category,
      content: content,
    );
    
    final updatedLog = log.addEntry(entry);
    await saveReflectionLog(updatedLog);
    return updatedLog;
  }

  /// Add a reflection entry to a specific date
  static Future<DailyReflectionLog> addReflectionEntryToDate(
    DateTime date,
    ReflectionCategory category,
    String content,
  ) async {
    final log = getOrCreateReflectionLogForDate(date);
    final entry = ReflectionEntry(
      category: category,
      content: content,
    );
    
    final updatedLog = log.addEntry(entry);
    await saveReflectionLog(updatedLog);
    return updatedLog;
  }

  /// Update a reflection entry
  static Future<DailyReflectionLog> updateReflectionEntry(
    DateTime date,
    String entryId,
    String newContent,
  ) async {
    final log = getReflectionLogForDate(date);
    if (log == null) {
      throw ArgumentError('No reflection log found for date: ${_dateKey(date)}');
    }

    final existingEntry = log.entries.firstWhere(
      (entry) => entry.id == entryId,
      orElse: () => throw ArgumentError('Entry not found: $entryId'),
    );

    final updatedEntry = existingEntry.copyWith(content: newContent);
    final updatedLog = log.updateEntry(updatedEntry);
    
    await saveReflectionLog(updatedLog);
    return updatedLog;
  }

  /// Remove a reflection entry
  static Future<DailyReflectionLog> removeReflectionEntry(
    DateTime date,
    String entryId,
  ) async {
    final log = getReflectionLogForDate(date);
    if (log == null) {
      throw ArgumentError('No reflection log found for date: ${_dateKey(date)}');
    }

    final updatedLog = log.removeEntry(entryId);
    await saveReflectionLog(updatedLog);
    return updatedLog;
  }

  /// Get all reflection logs
  static List<DailyReflectionLog> getAllReflectionLogs() {
    return _reflectionBox.values
        .map((data) => DailyReflectionLog.fromHive(Map<String, dynamic>.from(data)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Most recent first
  }

  /// Get reflection logs within a date range
  static List<DailyReflectionLog> getReflectionLogsInRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return getAllReflectionLogs()
        .where((log) =>
            log.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            log.date.isBefore(endDate.add(const Duration(days: 1))))
        .toList();
  }

  /// Get recent reflection logs (last N days)
  static List<DailyReflectionLog> getRecentReflectionLogs(int days) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    
    return getReflectionLogsInRange(startDate, now);
  }

  /// Get reflection logs with content (non-empty)
  static List<DailyReflectionLog> getLogsWithContent() {
    return getAllReflectionLogs()
        .where((log) => log.hasContent)
        .toList();
  }

  /// Get today's entries for a specific category
  static List<ReflectionEntry> getTodaysEntriesForCategory(ReflectionCategory category) {
    final todaysLog = getTodaysReflectionLog();
    return todaysLog.getEntriesForCategory(category);
  }

  /// Get gratitude entries for today
  static List<ReflectionEntry> getTodaysGratitudeEntries() {
    return getTodaysEntriesForCategory(ReflectionCategory.gratitude);
  }

  /// Get trigger entries for today
  static List<ReflectionEntry> getTodaysTriggerEntries() {
    return getTodaysEntriesForCategory(ReflectionCategory.triggers);
  }

  /// Get values entries for today
  static List<ReflectionEntry> getTodaysValuesEntries() {
    return getTodaysEntriesForCategory(ReflectionCategory.personalValues);
  }

  /// Get progress entries for today
  static List<ReflectionEntry> getTodaysProgressEntries() {
    return getTodaysEntriesForCategory(ReflectionCategory.progress);
  }

  /// Delete a reflection log
  static Future<void> deleteReflectionLog(DateTime date) async {
    final dateKey = _dateKey(date);
    await _reflectionBox.delete(dateKey);
  }

  /// Get reflection statistics
  static Map<String, dynamic> getReflectionStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final logs = startDate != null && endDate != null
        ? getReflectionLogsInRange(startDate, endDate)
        : getAllReflectionLogs();

    final logsWithContent = logs.where((log) => log.hasContent).toList();
    final totalDays = logs.length;
    final activeDays = logsWithContent.length;
    final consistencyRate = totalDays > 0 ? activeDays / totalDays : 0.0;

    // Category breakdown
    final categoryBreakdown = <ReflectionCategory, int>{};
    int totalEntries = 0;

    for (final category in ReflectionCategory.values) {
      final categoryEntries = logsWithContent
          .expand((log) => log.getEntriesForCategory(category))
          .length;
      categoryBreakdown[category] = categoryEntries;
      totalEntries += categoryEntries;
    }

    // Daily check-in stats
    final checkInsCount = logs
        .where((log) => log.dailyCheckIn?.isNotEmpty == true)
        .length;

    // Average entries per active day
    final avgEntriesPerDay = activeDays > 0 ? totalEntries / activeDays : 0.0;

    return {
      'totalDays': totalDays,
      'activeDays': activeDays,
      'consistencyRate': consistencyRate,
      'totalEntries': totalEntries,
      'averageEntriesPerDay': avgEntriesPerDay,
      'categoryBreakdown': categoryBreakdown,
      'dailyCheckInsCount': checkInsCount,
      'checkInRate': totalDays > 0 ? checkInsCount / totalDays : 0.0,
    };
  }

  /// Get reflection streaks (consecutive days with content)
  static Map<String, int> getReflectionStreaks() {
    final logs = getAllReflectionLogs();
    final logsWithContent = logs.where((log) => log.hasContent).toList();
    
    if (logsWithContent.isEmpty) {
      return {
        'currentStreak': 0,
        'longestStreak': 0,
      };
    }

    // Sort by date (oldest first for streak calculation)
    logsWithContent.sort((a, b) => a.date.compareTo(b.date));

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 1;
    
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    // Check if today has content for current streak
    final todaysLog = logsWithContent.lastWhere(
      (log) => log.date.isAtSameMomentAs(normalizedToday),
      orElse: () => logsWithContent.last,
    );

    if (todaysLog.date.isAtSameMomentAs(normalizedToday)) {
      currentStreak = 1;
      
      // Count backwards from today
      for (int i = logsWithContent.length - 2; i >= 0; i--) {
        final log = logsWithContent[i];
        final expectedDate = normalizedToday.subtract(Duration(days: currentStreak));
        
        if (log.date.isAtSameMomentAs(expectedDate)) {
          currentStreak++;
        } else {
          break;
        }
      }
    }

    // Calculate longest streak
    for (int i = 1; i < logsWithContent.length; i++) {
      final currentLog = logsWithContent[i];
      final previousLog = logsWithContent[i - 1];
      
      final daysDifference = currentLog.date.difference(previousLog.date).inDays;
      
      if (daysDifference == 1) {
        tempStreak++;
      } else {
        longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
        tempStreak = 1;
      }
    }
    longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;

    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
    };
  }

  /// Get content summary for insights
  static Map<String, dynamic> getContentSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final logs = startDate != null && endDate != null
        ? getReflectionLogsInRange(startDate, endDate)
        : getAllReflectionLogs();

    // Most common words in gratitude entries
    final gratitudeContent = logs
        .expand((log) => log.gratitudeEntries)
        .map((entry) => entry.content.toLowerCase())
        .join(' ');

    // Most common trigger patterns
    final triggerContent = logs
        .expand((log) => log.triggerEntries)
        .map((entry) => entry.content.toLowerCase())
        .join(' ');

    return {
      'totalLogs': logs.length,
      'gratitudeWordsCount': gratitudeContent.split(' ').length,
      'triggerWordsCount': triggerContent.split(' ').length,
      'averageWordsPerEntry': _calculateAverageWordsPerEntry(logs),
    };
  }

  /// Calculate average words per entry
  static double _calculateAverageWordsPerEntry(List<DailyReflectionLog> logs) {
    if (logs.isEmpty) return 0.0;
    
    final allEntries = logs.expand((log) => log.entries).toList();
    if (allEntries.isEmpty) return 0.0;
    
    final totalWords = allEntries
        .map((entry) => entry.content.split(' ').length)
        .fold(0, (sum, count) => sum + count);
    
    return totalWords / allEntries.length;
  }

  /// Clear all reflection data (for testing/development)
  static Future<void> clearAllReflections() async {
    await _reflectionBox.clear();
  }

  /// Export reflection data for backup/analysis
  static Map<String, dynamic> exportReflectionData() {
    final logs = getAllReflectionLogs();
    return {
      'exportDate': DateTime.now().toIso8601String(),
      'totalLogs': logs.length,
      'logs': logs.map((log) => log.toHive()).toList(),
    };
  }

  /// Import reflection data from backup
  static Future<void> importReflectionData(Map<String, dynamic> data) async {
    final logsData = data['logs'] as List;
    
    for (final logData in logsData) {
      final log = DailyReflectionLog.fromHive(Map<String, dynamic>.from(logData));
      await saveReflectionLog(log);
    }
  }
}
