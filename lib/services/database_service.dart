import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sht/models/habit_model.dart';
import 'package:sht/models/reward_model.dart';
import 'package:sht/models/stats_model.dart';
import 'package:sht/services/api_service.dart';

/// Abstract class for database operations
abstract class DatabaseService {
  // Factory constructor to get the right implementation based on platform
  factory DatabaseService() {
    if (kIsWeb) {
      return WebDatabaseService();
    } else {
      return MobileDatabaseService();
    }
  }

  // Habits
  Future<List<Habit>> getHabits();
  Future<Habit?> getHabit(int id);
  Future<Habit?> createHabit(Habit habit);
  Future<Habit?> updateHabit(Habit habit);
  Future<bool> deleteHabit(int id);

  // Habit Logs
  Future<List<HabitLog>> getHabitLogs(int habitId);
  Future<HabitLog?> getHabitLogByDate(int habitId, DateTime date);
  Future<HabitLog?> createHabitLog(HabitLog log);
  Future<HabitLog?> updateHabitLog(HabitLog log);

  // Rewards
  Future<List<Reward>> getRewards();
  Future<Reward?> getReward(int id);
  Future<Reward?> createReward(Reward reward);
  Future<Reward?> updateReward(Reward reward);
  Future<bool> deleteReward(int id);
  Future<Reward?> redeemReward(int id);

  // Stats
  Future<UserStats> getUserStats();
  Future<HabitStats?> getHabitStats(int habitId);

  // User
  Future<int> getUserPoints();
  Future<bool> updateUserPoints(int points);
}

/// Implementation for web platform using API calls
class WebDatabaseService implements DatabaseService {
  final ApiService _apiService = ApiService();

  @override
  Future<List<Habit>> getHabits() async {
    return await _apiService.getHabits();
  }

  @override
  Future<Habit?> getHabit(int id) async {
    return await _apiService.getHabit(id);
  }

  @override
  Future<Habit?> createHabit(Habit habit) async {
    return await _apiService.createHabit(habit);
  }

  @override
  Future<Habit?> updateHabit(Habit habit) async {
    return await _apiService.updateHabit(habit);
  }

  @override
  Future<bool> deleteHabit(int id) async {
    return await _apiService.deleteHabit(id);
  }

  @override
  Future<List<HabitLog>> getHabitLogs(int habitId) async {
    return await _apiService.getHabitLogs(habitId);
  }

  @override
  Future<HabitLog?> getHabitLogByDate(int habitId, DateTime date) async {
    final logs = await _apiService.getHabitLogs(habitId);
    final formattedDate = date.toIso8601String().split('T').first;

    return logs.firstWhere(
      (log) => log.date == formattedDate,
      orElse: () => HabitLog(
        id: -1,
        habitId: habitId,
        date: formattedDate,
        completed: false,
        completedCount: 0,
        notes: null,
      ),
    );
  }

  @override
  Future<HabitLog?> createHabitLog(HabitLog log) async {
    return await _apiService.createHabitLog(log);
  }

  @override
  Future<HabitLog?> updateHabitLog(HabitLog log) async {
    return await _apiService.updateHabitLog(log);
  }

  @override
  Future<List<Reward>> getRewards() async {
    return await _apiService.getRewards();
  }

  @override
  Future<Reward?> getReward(int id) async {
    final rewards = await _apiService.getRewards();
    return rewards.firstWhere(
      (reward) => reward.id == id,
      orElse: () => null,
    );
  }

  @override
  Future<Reward?> createReward(Reward reward) async {
    return await _apiService.createReward(reward);
  }

  @override
  Future<Reward?> updateReward(Reward reward) async {
    return await _apiService.updateReward(reward);
  }

  @override
  Future<bool> deleteReward(int id) async {
    return await _apiService.deleteReward(id);
  }

  @override
  Future<Reward?> redeemReward(int id) async {
    return await _apiService.redeemReward(id);
  }

  @override
  Future<UserStats> getUserStats() async {
    return await _apiService.getUserStats();
  }

  @override
  Future<HabitStats?> getHabitStats(int habitId) async {
    return await _apiService.getHabitStats(habitId);
  }

  @override
  Future<int> getUserPoints() async {
    final stats = await _apiService.getUserStats();
    return stats.points;
  }

  @override
  Future<bool> updateUserPoints(int points) async {
    // This is typically handled server-side when redeeming rewards
    // or completing habits, so we just return true here
    return true;
  }
}

/// Implementation for mobile platform using SQLite
class MobileDatabaseService implements DatabaseService {
  // In-memory storage for now, you would replace this with SQLite implementations
  final Map<int, Habit> _habits = {};
  final Map<int, List<HabitLog>> _habitLogs = {};
  final Map<int, Reward> _rewards = {};
  int _userPoints = 0;

  // Counter for generating IDs
  int _habitIdCounter = 1;
  int _habitLogIdCounter = 1;
  int _rewardIdCounter = 1;

  @override
  Future<List<Habit>> getHabits() async {
    return _habits.values.toList();
  }

  @override
  Future<Habit?> getHabit(int id) async {
    return _habits[id];
  }

  @override
  Future<Habit?> createHabit(Habit habit) async {
    final id = _habitIdCounter++;
    final now = DateTime.now();

    final newHabit = Habit(
      id: id,
      name: habit.name,
      description: habit.description,
      frequency: habit.frequency,
      daysOfWeek: habit.daysOfWeek,
      targetPerDay: habit.targetPerDay,
      points: habit.points,
      colorCode: habit.colorCode,
      icon: habit.icon,
      isArchived: false,
      createdAt: now,
    );

    _habits[id] = newHabit;
    return newHabit;
  }

  @override
  Future<Habit?> updateHabit(Habit habit) async {
    if (!_habits.containsKey(habit.id)) return null;

    _habits[habit.id] = habit;
    return habit;
  }

  @override
  Future<bool> deleteHabit(int id) async {
    if (!_habits.containsKey(id)) return false;

    _habits.remove(id);
    _habitLogs.remove(id);
    return true;
  }

  @override
  Future<List<HabitLog>> getHabitLogs(int habitId) async {
    return _habitLogs[habitId] ?? [];
  }

  @override
  Future<HabitLog?> getHabitLogByDate(int habitId, DateTime date) async {
    final logs = _habitLogs[habitId] ?? [];
    final formattedDate = date.toIso8601String().split('T').first;

    return logs.firstWhere(
      (log) => log.date == formattedDate,
      orElse: () => HabitLog(
        id: -1,
        habitId: habitId,
        date: formattedDate,
        completed: false,
        completedCount: 0,
        notes: null,
      ),
    );
  }

  @override
  Future<HabitLog?> createHabitLog(HabitLog log) async {
    if (!_habits.containsKey(log.habitId)) return null;

    // Check if a log for this date already exists
    final existingLog =
        await getHabitLogByDate(log.habitId, DateTime.parse(log.date));

    if (existingLog != null && existingLog.id != -1) {
      // Update existing log
      return updateHabitLog(log.copyWith(id: existingLog.id));
    }

    final id = _habitLogIdCounter++;
    final newLog = log.copyWith(id: id);

    if (!_habitLogs.containsKey(log.habitId)) {
      _habitLogs[log.habitId] = [];
    }

    _habitLogs[log.habitId]!.add(newLog);

    // Update user points if habit was completed
    if (log.completed) {
      final habit = _habits[log.habitId];
      if (habit != null) {
        _userPoints += habit.points;
      }
    }

    return newLog;
  }

  @override
  Future<HabitLog?> updateHabitLog(HabitLog log) async {
    if (!_habits.containsKey(log.habitId)) return null;

    final logs = _habitLogs[log.habitId] ?? [];
    final index = logs.indexWhere((l) => l.id == log.id);

    if (index == -1) return null;

    // Check if completion status changed
    final oldLog = logs[index];
    if (!oldLog.completed && log.completed) {
      // Habit was just completed, add points
      final habit = _habits[log.habitId];
      if (habit != null) {
        _userPoints += habit.points;
      }
    } else if (oldLog.completed && !log.completed) {
      // Habit was uncompleted, remove points
      final habit = _habits[log.habitId];
      if (habit != null) {
        _userPoints -= habit.points;
      }
    }

    logs[index] = log;
    return log;
  }

  @override
  Future<List<Reward>> getRewards() async {
    return _rewards.values.toList();
  }

  @override
  Future<Reward?> getReward(int id) async {
    return _rewards[id];
  }

  @override
  Future<Reward?> createReward(Reward reward) async {
    final id = _rewardIdCounter++;

    final newReward = Reward(
      id: id,
      name: reward.name,
      description: reward.description,
      pointsCost: reward.pointsCost,
      isRedeemed: false,
      redeemedAt: null,
    );

    _rewards[id] = newReward;
    return newReward;
  }

  @override
  Future<Reward?> updateReward(Reward reward) async {
    if (!_rewards.containsKey(reward.id)) return null;

    _rewards[reward.id] = reward;
    return reward;
  }

  @override
  Future<bool> deleteReward(int id) async {
    if (!_rewards.containsKey(id)) return false;

    _rewards.remove(id);
    return true;
  }

  @override
  Future<Reward?> redeemReward(int id) async {
    if (!_rewards.containsKey(id)) return null;

    final reward = _rewards[id]!;

    // Check if already redeemed
    if (reward.isRedeemed) return null;

    // Check if user has enough points
    if (_userPoints < reward.pointsCost) return null;

    // Deduct points and mark as redeemed
    _userPoints -= reward.pointsCost;

    final updatedReward = reward.copyWith(
      isRedeemed: true,
      redeemedAt: DateTime.now(),
    );

    _rewards[id] = updatedReward;
    return updatedReward;
  }

  @override
  Future<UserStats> getUserStats() async {
    final habits = await getHabits();
    final habitStats = <HabitStats>[];

    for (final habit in habits) {
      final stats = await getHabitStats(habit.id);
      if (stats != null) {
        habitStats.add(stats);
      }
    }

    return UserStats(
      points: _userPoints,
      totalHabits: habits.length,
      habitStats: habitStats,
    );
  }

  @override
  Future<HabitStats?> getHabitStats(int habitId) async {
    final habit = await getHabit(habitId);
    if (habit == null) return null;

    final logs = await getHabitLogs(habitId);

    // Calculate stats
    int currentStreak = 0;
    int longestStreak = 0;
    int completedDays = 0;
    double completionRate = 0.0;

    if (logs.isNotEmpty) {
      // Sort logs by date (most recent first for current streak)
      final sortedLogs = List<HabitLog>.from(logs)
        ..sort(
            (a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

      // Count completed days
      completedDays = logs.where((log) => log.completed).length;

      // Calculate completion rate
      completionRate = logs.isEmpty ? 0.0 : (completedDays / logs.length) * 100;

      // Calculate current streak
      currentStreak = _calculateCurrentStreak(sortedLogs);

      // Calculate longest streak
      longestStreak = _calculateLongestStreak(logs);
    }

    return HabitStats(
      habitId: habitId,
      name: habit.name,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      completedDays: completedDays,
      totalDays: logs.length,
      completionRate: completionRate,
    );
  }

  int _calculateCurrentStreak(List<HabitLog> sortedLogs) {
    if (sortedLogs.isEmpty) return 0;

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

  int _calculateLongestStreak(List<HabitLog> logs) {
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

  @override
  Future<int> getUserPoints() async {
    return _userPoints;
  }

  @override
  Future<bool> updateUserPoints(int points) async {
    _userPoints = points;
    return true;
  }
}
