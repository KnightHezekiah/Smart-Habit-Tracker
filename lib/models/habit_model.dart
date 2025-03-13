class Habit {
  final int id;
  final String name;
  final String? description;
  final String frequency;
  final List<String>? daysOfWeek;
  final int targetPerDay;
  final int points;
  final String colorCode;
  final String icon;
  final bool isArchived;
  final DateTime createdAt;

  Habit({
    required this.id,
    required this.name,
    this.description,
    required this.frequency,
    this.daysOfWeek,
    required this.targetPerDay,
    required this.points,
    required this.colorCode,
    required this.icon,
    required this.isArchived,
    required this.createdAt,
  });

  // Create a copy of this habit with optional parameter changes
  Habit copyWith({
    int? id,
    String? name,
    String? description,
    String? frequency,
    List<String>? daysOfWeek,
    int? targetPerDay,
    int? points,
    String? colorCode,
    String? icon,
    bool? isArchived,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      targetPerDay: targetPerDay ?? this.targetPerDay,
      points: points ?? this.points,
      colorCode: colorCode ?? this.colorCode,
      icon: icon ?? this.icon,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Convert habit to JSON format for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'frequency': frequency,
      'daysOfWeek': daysOfWeek,
      'targetPerDay': targetPerDay,
      'points': points,
      'colorCode': colorCode,
      'icon': icon,
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create a habit from JSON data received from API
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      frequency: json['frequency'],
      daysOfWeek: json['daysOfWeek'] != null
          ? List<String>.from(json['daysOfWeek'])
          : null,
      targetPerDay: json['targetPerDay'],
      points: json['points'],
      colorCode: json['colorCode'],
      icon: json['icon'],
      isArchived: json['isArchived'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  // For debugging purposes
  @override
  String toString() {
    return 'Habit{id: $id, name: $name, frequency: $frequency, points: $points}';
  }
}

class HabitLog {
  final int id;
  final int habitId;
  final String date;
  final bool completed;
  final int completedCount;
  final String? notes;

  HabitLog({
    required this.id,
    required this.habitId,
    required this.date,
    required this.completed,
    required this.completedCount,
    this.notes,
  });

  // Create a copy with optional parameter changes
  HabitLog copyWith({
    int? id,
    int? habitId,
    String? date,
    bool? completed,
    int? completedCount,
    String? notes,
  }) {
    return HabitLog(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      completed: completed ?? this.completed,
      completedCount: completedCount ?? this.completedCount,
      notes: notes ?? this.notes,
    );
  }

  // Convert log to JSON format for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habitId': habitId,
      'date': date,
      'completed': completed,
      'completedCount': completedCount,
      'notes': notes,
    };
  }

  // Create a log from JSON data received from API
  factory HabitLog.fromJson(Map<String, dynamic> json) {
    return HabitLog(
      id: json['id'],
      habitId: json['habitId'],
      date: json['date'],
      completed: json['completed'],
      completedCount: json['completedCount'],
      notes: json['notes'],
    );
  }

  // For debugging purposes
  @override
  String toString() {
    return 'HabitLog{id: $id, habitId: $habitId, date: $date, completed: $completed}';
  }
}

// Model for a list of habits, can be used with ChangeNotifier for state management
class HabitListModel {
  List<Habit> _habits = [];
  final Map<int, List<HabitLog>> _habitLogs = {};

  // Getters
  List<Habit> get habits => List.unmodifiable(_habits);
  Map<int, List<HabitLog>> get habitLogs => Map.unmodifiable(_habitLogs);

  // Add a habit to the list
  void addHabit(Habit habit) {
    _habits.add(habit);
    notifyListeners();
  }

  // Update a habit in the list
  void updateHabit(Habit habit) {
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
      notifyListeners();
    }
  }

  // Remove a habit from the list
  void removeHabit(int habitId) {
    _habits.removeWhere((h) => h.id == habitId);
    _habitLogs.remove(habitId);
    notifyListeners();
  }

  // Set all habits
  void setHabits(List<Habit> habits) {
    _habits = List.from(habits);
    notifyListeners();
  }

  // Get logs for a specific habit
  List<HabitLog> getLogsForHabit(int habitId) {
    return _habitLogs[habitId] ?? [];
  }

  // Add a log to a habit
  void addLog(HabitLog log) {
    if (!_habitLogs.containsKey(log.habitId)) {
      _habitLogs[log.habitId] = [];
    }

    // Check if a log for this date already exists
    final index =
        _habitLogs[log.habitId]!.indexWhere((l) => l.date == log.date);

    if (index != -1) {
      // Update existing log
      _habitLogs[log.habitId]![index] = log;
    } else {
      // Add new log
      _habitLogs[log.habitId]!.add(log);
    }

    notifyListeners();
  }

  // Set all logs for a habit
  void setLogsForHabit(int habitId, List<HabitLog> logs) {
    _habitLogs[habitId] = List.from(logs);
    notifyListeners();
  }

  // Placeholder for notifying listeners
  void notifyListeners() {
    // This would be implemented if using ChangeNotifier
  }
}
