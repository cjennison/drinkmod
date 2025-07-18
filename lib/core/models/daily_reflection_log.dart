import 'package:uuid/uuid.dart';

/// Categories for personal reflection entries
enum ReflectionCategory {
  gratitude,             // Things to be grateful for
  triggers,              // Situations/emotions that challenge recovery
  personalValues,        // Personal values and what matters most
  progress,              // Growth and achievements in recovery
}

/// Individual reflection entry within a category
class ReflectionEntry {
  final String id;
  final ReflectionCategory category;
  final String content;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  ReflectionEntry({
    String? id,
    required this.category,
    required this.content,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now(),
        metadata = metadata ?? {};

  /// Create from Hive data
  factory ReflectionEntry.fromHive(Map<String, dynamic> data) {
    return ReflectionEntry(
      id: data['id'] as String,
      category: ReflectionCategory.values
          .firstWhere((c) => c.name == data['category']),
      content: data['content'] as String,
      timestamp: DateTime.parse(data['timestamp'] as String),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  /// Convert to Hive data
  Map<String, dynamic> toHive() {
    return {
      'id': id,
      'category': category.name,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  ReflectionEntry copyWith({
    String? id,
    ReflectionCategory? category,
    String? content,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return ReflectionEntry(
      id: id ?? this.id,
      category: category ?? this.category,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'ReflectionEntry(id: $id, category: $category, content: ${content.length} chars)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReflectionEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Daily reflection log containing all reflection categories for a specific day
class DailyReflectionLog {
  final String id;
  final DateTime date; // Date this log represents (normalized to midnight)
  final String? dailyCheckIn; // Main daily check-in response
  final List<ReflectionEntry> entries; // All reflection entries for this day
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyReflectionLog({
    String? id,
    required this.date,
    this.dailyCheckIn,
    List<ReflectionEntry>? entries,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        entries = entries ?? [],
        metadata = metadata ?? {},
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create from Hive data
  factory DailyReflectionLog.fromHive(Map<String, dynamic> data) {
    final entriesData = data['entries'] as List? ?? [];
    final entries = entriesData
        .map((entryData) => ReflectionEntry.fromHive(entryData))
        .toList();

    return DailyReflectionLog(
      id: data['id'] as String,
      date: DateTime.parse(data['date'] as String),
      dailyCheckIn: data['dailyCheckIn'] as String?,
      entries: entries,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
    );
  }

  /// Convert to Hive data
  Map<String, dynamic> toHive() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'dailyCheckIn': dailyCheckIn,
      'entries': entries.map((entry) => entry.toHive()).toList(),
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  DailyReflectionLog copyWith({
    String? id,
    DateTime? date,
    String? dailyCheckIn,
    List<ReflectionEntry>? entries,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyReflectionLog(
      id: id ?? this.id,
      date: date ?? this.date,
      dailyCheckIn: dailyCheckIn ?? this.dailyCheckIn,
      entries: entries ?? List.from(this.entries),
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Add a new reflection entry to this log
  DailyReflectionLog addEntry(ReflectionEntry entry) {
    final updatedEntries = List<ReflectionEntry>.from(entries)..add(entry);
    return copyWith(entries: updatedEntries);
  }

  /// Update an existing reflection entry
  DailyReflectionLog updateEntry(ReflectionEntry updatedEntry) {
    final updatedEntries = entries.map((entry) {
      return entry.id == updatedEntry.id ? updatedEntry : entry;
    }).toList();
    return copyWith(entries: updatedEntries);
  }

  /// Remove a reflection entry
  DailyReflectionLog removeEntry(String entryId) {
    final updatedEntries = entries.where((entry) => entry.id != entryId).toList();
    return copyWith(entries: updatedEntries);
  }

  /// Get all entries for a specific category
  List<ReflectionEntry> getEntriesForCategory(ReflectionCategory category) {
    return entries.where((entry) => entry.category == category).toList();
  }

  /// Get gratitude entries
  List<ReflectionEntry> get gratitudeEntries => 
      getEntriesForCategory(ReflectionCategory.gratitude);

  /// Get trigger entries
  List<ReflectionEntry> get triggerEntries => 
      getEntriesForCategory(ReflectionCategory.triggers);

  /// Get values entries
  List<ReflectionEntry> get valuesEntries => 
      getEntriesForCategory(ReflectionCategory.personalValues);

  /// Get progress entries
  List<ReflectionEntry> get progressEntries => 
      getEntriesForCategory(ReflectionCategory.progress);

  /// Check if this log has any content
  bool get hasContent {
    return dailyCheckIn?.isNotEmpty == true || entries.isNotEmpty;
  }

  /// Get a summary of this log's content
  Map<ReflectionCategory, int> get categoryEntryCounts {
    final counts = <ReflectionCategory, int>{};
    for (final category in ReflectionCategory.values) {
      counts[category] = getEntriesForCategory(category).length;
    }
    return counts;
  }

  /// Get the date as a normalized string (YYYY-MM-DD)
  String get dateKey {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Factory method to create a log for today
  static DailyReflectionLog createForToday({String? dailyCheckIn}) {
    final today = DateTime.now();
    final normalizedDate = DateTime(today.year, today.month, today.day);
    
    return DailyReflectionLog(
      date: normalizedDate,
      dailyCheckIn: dailyCheckIn,
    );
  }

  /// Factory method to create a log for a specific date
  static DailyReflectionLog createForDate(DateTime date, {String? dailyCheckIn}) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    return DailyReflectionLog(
      date: normalizedDate,
      dailyCheckIn: dailyCheckIn,
    );
  }

  @override
  String toString() {
    return 'DailyReflectionLog(date: $dateKey, entries: ${entries.length}, hasCheckIn: ${dailyCheckIn != null})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyReflectionLog && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
