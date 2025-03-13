// Model for user statistics (total points, habits, etc.)
class UserStats {
  final int points;
  final int totalHabits;
  final List<HabitStats> habitStats;

  UserStats({
    required this.points,
    required this.totalHabits,
    required this.habitStats,
  });

  // Create a stats object from JSON data received from API
  factory UserStats.fromJson(Map<String, dynamic> json) {
    final habitStatsJson = json['habitStats'] as List<dynamic>? ?? [];

    return UserStats(
      points: json['points'] ?? 0,
      totalHabits: json['totalHabits'] ?? 0,
      habitStats:
          habitStatsJson.map((item) => HabitStats.fromJson(item)).toList(),
    );
  }

  // Convert stats to JSON format for API requests
  Map<String, dynamic> toJson() {
    return {
      'points': points,
      'totalHabits': totalHabits,
      'habitStats': habitStats.map((s) => s.toJson()).toList(),
    };
  }
}

// Model for individual habit statistics
class HabitStats {
  final int habitId;
  final String name;
  final int currentStreak;
  final int longestStreak;
  final int completedDays;
  final int totalDays;
  final double completionRate;

  HabitStats({
    required this.habitId,
    required this.name,
    required this.currentStreak,
    required this.longestStreak,
    required this.completedDays,
    required this.totalDays,
    required this.completionRate,
  });

  // Create a habit stats object from JSON data received from API
  factory HabitStats.fromJson(Map<String, dynamic> json) {
    return HabitStats(
      habitId: json['habitId'],
      name: json['name'],
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      completedDays: json['completedDays'] ?? 0,
      totalDays: json['totalDays'] ?? 0,
      completionRate: (json['completionRate'] ?? 0).toDouble(),
    );
  }

  // Convert habit stats to JSON format for API requests
  Map<String, dynamic> toJson() {
    return {
      'habitId': habitId,
      'name': name,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'completedDays': completedDays,
      'totalDays': totalDays,
      'completionRate': completionRate,
    };
  }
}

// Model for tracking streak data over time
class StreakData {
  final DateTime date;
  final int streakCount;

  StreakData({
    required this.date,
    required this.streakCount,
  });
}

// Weekly summary data
class WeeklySummary {
  final DateTime weekStarting;
  final int completedHabits;
  final int totalHabits;
  final int pointsEarned;

  WeeklySummary({
    required this.weekStarting,
    required this.completedHabits,
    required this.totalHabits,
    required this.pointsEarned,
  });

  // Calculate completion rate as a percentage
  double get completionRate =>
      totalHabits > 0 ? (completedHabits / totalHabits) * 100 : 0;
}

// Monthly summary data
class MonthlySummary {
  final DateTime month;
  final int completedHabits;
  final int totalHabits;
  final int pointsEarned;
  final List<WeeklySummary> weeklySummaries;

  MonthlySummary({
    required this.month,
    required this.completedHabits,
    required this.totalHabits,
    required this.pointsEarned,
    required this.weeklySummaries,
  });

  // Calculate completion rate as a percentage
  double get completionRate =>
      totalHabits > 0 ? (completedHabits / totalHabits) * 100 : 0;
}
