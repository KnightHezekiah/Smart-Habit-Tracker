import 'package:flutter/material.dart';
import 'package:sht/models/habit_model.dart';
import 'package:sht/services/database_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Habit> _habits = [];
  Map<int, List<HabitLog>> _habitLogs = {};
  bool _isLoading = true;
  final DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load habits
      final habits = await _databaseService.getHabits();

      // Load logs for each habit
      final habitLogs = <int, List<HabitLog>>{};
      for (final habit in habits) {
        final logs = await _databaseService.getHabitLogs(habit.id);
        habitLogs[habit.id] = logs;
      }

      setState(() {
        _habits = habits;
        _habitLogs = habitLogs;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleHabitCompletion(Habit habit) async {
    final today = DateTime.now();
    final formattedDate = DateTime(today.year, today.month, today.day)
        .toIso8601String()
        .split('T')
        .first;

    try {
      // Find existing log for today
      final logs = _habitLogs[habit.id] ?? [];
      final existingLog = logs.firstWhere(
        (log) => log.date == formattedDate,
        orElse: () => HabitLog(
          id: -1,
          habitId: habit.id,
          date: formattedDate,
          completed: false,
          completedCount: 0,
          notes: null,
        ),
      );

      HabitLog? updatedLog;

      if (existingLog.id == -1) {
        // Create new log
        updatedLog = await _databaseService.createHabitLog(
          HabitLog(
            id: -1, // Will be assigned by the database
            habitId: habit.id,
            date: formattedDate,
            completed: true,
            completedCount: 1,
            notes: null,
          ),
        );
      } else {
        // Toggle existing log
        updatedLog = await _databaseService.updateHabitLog(
          existingLog.copyWith(
            completed: !existingLog.completed,
            completedCount: existingLog.completed ? 0 : 1,
          ),
        );
      }

      if (updatedLog != null) {
        setState(() {
          final newLogs = List<HabitLog>.from(_habitLogs[habit.id] ?? []);
          final index = newLogs.indexWhere((log) => log.id == updatedLog!.id);

          if (index != -1) {
            newLogs[index] = updatedLog;
          } else {
            newLogs.add(updatedLog);
          }

          _habitLogs[habit.id] = newLogs;
        });
      }
    } catch (e) {
      print('Error toggling habit completion: $e');

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating habit: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addHabit() {
    // Navigate to add habit screen
    Navigator.pushNamed(context, '/add-habit').then((_) {
      // Refresh data when returning from add habit screen
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits'),
        actions: [
          if (kIsWeb)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Web Mode',
                  style: TextStyle(
                    color: Colors.blue[100],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _habits.isEmpty
              ? _buildEmptyState()
              : _buildHabitsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addHabit,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lightbulb_outline,
            size: 80,
            color: Colors.amber,
          ),
          const SizedBox(height: 16),
          const Text(
            'No habits yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first habit to start tracking',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addHabit,
            icon: const Icon(Icons.add),
            label: const Text('Add Habit'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _habits.length,
      itemBuilder: (context, index) {
        final habit = _habits[index];
        final logs = _habitLogs[habit.id] ?? [];

        // Find log for today
        final today = DateTime.now();
        final formattedDate = DateTime(today.year, today.month, today.day)
            .toIso8601String()
            .split('T')
            .first;

        final todayLog = logs.firstWhere(
          (log) => log.date == formattedDate,
          orElse: () => HabitLog(
            id: -1,
            habitId: habit.id,
            date: formattedDate,
            completed: false,
            completedCount: 0,
            notes: null,
          ),
        );

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () {
              // Navigate to habit details/edit screen
              Navigator.pushNamed(
                context,
                '/edit-habit',
                arguments: habit.id,
              ).then((_) {
                // Refresh data when returning
                _loadData();
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(
                          int.parse('0xFF${habit.colorCode.substring(1)}')),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      IconData(
                        int.tryParse(habit.icon) ??
                            0xe24e, // fallback to home icon
                        fontFamily: 'MaterialIcons',
                      ),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (habit.description != null &&
                            habit.description!.isNotEmpty)
                          Text(
                            habit.description!,
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.repeat,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              habit.frequency,
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${habit.points} pts',
                              style: const TextStyle(
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Checkbox(
                    value: todayLog.completed,
                    onChanged: (_) => _toggleHabitCompletion(habit),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
