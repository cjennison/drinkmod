import 'package:intl/intl.dart';

/// Utility class for date formatting and manipulation
class DateUtils {
  /// Formats a date in American format (MM/DD/YYYY)
  static String formatAmericanDate(DateTime date) {
    return DateFormat('M/d/yyyy').format(date);
  }

  /// Formats a date in American format with time (MM/DD/YYYY HH:mm)
  static String formatAmericanDateTime(DateTime date) {
    return DateFormat('M/d/yyyy HH:mm').format(date);
  }

  /// Formats a date for display (e.g., "Jan 15, 2025")
  static String formatDisplayDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  /// Formats a date for compact display (e.g., "Jan 15")
  static String formatCompactDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  /// Formats a date range in American format
  static String formatAmericanDateRange(DateTime startDate, DateTime endDate) {
    return '${formatAmericanDate(startDate)} - ${formatAmericanDate(endDate)}';
  }

  /// Formats a date for goal timeline display
  static String formatTimelineDate(DateTime date) {
    return formatAmericanDate(date);
  }

  /// Formats a date in short format (M/D) without year
  static String formatShortDate(DateTime date) {
    return DateFormat('M/d').format(date);
  }

  /// Parse a date string in various formats
  static DateTime? parseDate(String dateString) {
    try {
      // Try American format first
      if (dateString.contains('/')) {
        return DateFormat('M/d/yyyy').parse(dateString);
      }
      // Try ISO format
      if (dateString.contains('-')) {
        return DateTime.parse(dateString);
      }
    } catch (e) {
      // Return null if parsing fails
    }
    return null;
  }

  /// Get days remaining from now to target date
  static int daysUntil(DateTime targetDate) {
    final now = DateTime.now();
    return targetDate.difference(now).inDays;
  }

  /// Get days elapsed since start date
  static int daysSince(DateTime startDate) {
    final now = DateTime.now();
    return now.difference(startDate).inDays;
  }
}
