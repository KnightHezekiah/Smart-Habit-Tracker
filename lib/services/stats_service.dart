import 'package:sht/models/habit_model.dart';

/// Service for calculating statistics from habit data
class StatsService {
  // Singleton instance
  static StatsService? _instance;

  // Factory constructor to return the singleton instance
  factory StatsService() {
    _instance ??= StatsService._internal();
    return _instance!;
  }

  // Private constructor
  StatsService._internal();

  /// Calculate the current streak for a habit
  int calculateCurrentStreak(List<HabitLog> logs) {
    if (logs.isEmpty) return 0;

    // Sort logs by date (most recent first)
    final sortedLogs = List<HabitLog>.from(logs)
      ..sort(
          (a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

    // Check if the most recent log is today or yesterday
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final mostRecentLogDate = DateTime.parse(sortedLogs.first.date);
    final mostRecentLogDay = DateTime(
        mostRecentLogDate.year, mostRecentLogDate.month, mostRecentLogDate.day);

    // If the most recent log is not from today or yesterday and is completed,
    // or if the most recent log is not completed, then the streak is broken
    if ((mostRecentLogDay.isBefore(yesterday) && sortedLogs.first.completed) ||
        !sortedLogs.first.completed) {
      return 0;
    }

    // Count consecutive completed days
    int streak = sortedLogs.first.completed ? 1 : 0;
    DateTime? previousDate = mostRecentLogDay;

    for (var i = 1; i < sortedLogs.length; i++) {
      final log = sortedLogs[i];
      final logDate = DateTime.parse(log.date);
      final logDay = DateTime(logDate.year, logDate.month, logDate.day);

      // Check if this log is for the day before the previous log
      final expectedPreviousDay =
          previousDate!.subtract(const Duration(days: 1));

      if (logDay.isAtSameMomentAs(expectedPreviousDay) && log.completed) {
        streak++;
        previousDate = logDay;
      } else {
        // The streak is broken
        break;
      }
    }

    return streak;
  }

  /// Calculate the longest streak for a habit
  int calculateLongestStreak(List<HabitLog> logs) {
    if (logs.isEmpty) return 0;

    // Sort logs by date (oldest first)
    final sortedLogs = List<HabitLog>.from(logs)
      ..sort(
          (a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));

    int longestStreak = 0;
    int currentStreak = 0;
    DateTime? previousDate;

    for (final log in sortedLogs) {
      if (log.completed) {
        final logDate = DateTime.parse(log.date);
        final logDay = DateTime(logDate.year, logDate.month, logDate.day);

        if (previousDate == null) {
          // First completed log
          currentStreak = 1;
        } else {
          // Check if this log is for the day after the previous log
          final expectedNextDay = previousDate.add(const Duration(days: 1));

          if (logDay.isAtSameMomentAs(expectedNextDay)) {
            // Consecutive day
            currentStreak++;
          } else if (logDay.isAfter(expectedNextDay)) {
            // Gap in logs, reset streak
            currentStreak = 1;
          }
          // If it's the same day, we ignore it (duplicate log)
        }

        previousDate = logDay;
        longestStreak =
            currentStreak > longestStreak ? currentStreak : longestStreak;
      }
    }

    return longestStreak;
  }

  /// Calculate completion rate (percentage of completed logs)
  double calculateCompletionRate(List<HabitLog> logs) {
    if (logs.isEmpty) return 0.0;

    final completedLogs = logs.where((log) => log.completed).length;
    return (completedLogs / logs.length) * 100;
  }

  /// Calculate total completed days
  int calculateCompletedDays(List<HabitLog> logs) {
    return logs.where((log) => log.completed).length;
  }

  /// Get logs for a specific date range
  List<HabitLog> getLogsInDateRange(
      List<HabitLog> logs, DateTime startDate, DateTime endDate) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    return logs.where((log) {
      final logDate = DateTime.parse(log.date);
      final logDay = DateTime(logDate.year, logDate.month, logDate.day);
      return logDay.isAtSameMomentAs(start) ||
          logDay.isAtSameMomentAs(end) ||
          (logDay.isAfter(start) && logDay.isBefore(end));
    }).toList();
  }

  /// Get logs for the last N days
  List<HabitLog> getLogsForLastDays(List<HabitLog> logs, int days) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = today.subtract(Duration(days: days - 1));

    return getLogsInDateRange(logs, startDate, today);
  }

  /// Get stats for multiple habits
  Map<int, Map<String, dynamic>> getStatsForHabits(
      List<Habit> habits, Map<int, List<HabitLog>> habitLogs) {
    final result = <int, Map<String, dynamic>>{};

    for (final habit in habits) {
      final logs = habitLogs[habit.id] ?? [];

      result[habit.id] = {
        'currentStreak': calculateCurrentStreak(logs),
        'longestStreak': calculateLongestStreak(logs),
        'completionRate': calculateCompletionRate(logs),
        'completedDays': calculateCompletedDays(logs),
        'totalDays': logs.length,
      };
    }

    return result;
  }
}
