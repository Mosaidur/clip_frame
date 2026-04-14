import 'package:intl/intl.dart';

class SchedulingUtils {
  static const Map<String, int> _weekdayMap = {
    'Monday': DateTime.monday,
    'Tuesday': DateTime.tuesday,
    'Wednesday': DateTime.wednesday,
    'Thursday': DateTime.thursday,
    'Friday': DateTime.friday,
    'Saturday': DateTime.saturday,
    'Sunday': DateTime.sunday,
  };

  /// Finds the next upcoming [DateTime] for a given weekday name (e.g., 'Tuesday').
  /// If [from] is not provided, [DateTime.now()] is used.
  /// If [suggestedHour] and [suggestedMinute] are provided, it will ensure the
  /// returned DateTime is in the future compared to [from].
  static DateTime getNextUpcomingDate(
    String weekdayName, {
    DateTime? from,
    int? suggestedHour,
    int? suggestedMinute,
  }) {
    final now = from ?? DateTime.now();
    final weekday = _weekdayMap[weekdayName];
    if (weekday == null) return now;

    int daysToAdd = (weekday - now.weekday + 7) % 7;

    // If it's today, check if the suggested time has already passed
    if (daysToAdd == 0 && suggestedHour != null && suggestedMinute != null) {
      final suggestedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        suggestedHour,
        suggestedMinute,
      );
      if (suggestedDateTime.isBefore(now)) {
        daysToAdd = 7; // Move to next week
      }
    }

    return DateTime(
      now.year,
      now.month,
      now.day,
    ).add(Duration(days: daysToAdd));
  }

  /// Takes a list of weekday names and returns a list of [DateTime] objects representing
  /// their next upcoming occurrences, sorted chronologically in the future.
  static List<DateTime> getUpcomingSequence(
    List<String> weekdayNames, {
    DateTime? from,
    int? suggestedHour,
    int? suggestedMinute,
  }) {
    final now = from ?? DateTime.now();

    // Find the next occurrence for each day
    List<DateTime> upcomingDates = weekdayNames.map((dayName) {
      return getNextUpcomingDate(
        dayName,
        from: now,
        suggestedHour: suggestedHour,
        suggestedMinute: suggestedMinute,
      );
    }).toList();

    // Sort chronologically
    upcomingDates.sort((a, b) => a.compareTo(b));

    return upcomingDates;
  }

  /// Formats a [DateTime] to a readable date string like "Tuesday, 20 Apr".
  static String formatRecommendedDate(DateTime date) {
    return DateFormat('EEEE, d MMM').format(date);
  }
}
