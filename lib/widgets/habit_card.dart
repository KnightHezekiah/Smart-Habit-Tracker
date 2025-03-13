import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sht/models/habit_model.dart';
import 'package:sht/screens/add_habit_screen.dart';
import 'package:intl/intl.dart';

class HabitCard extends StatefulWidget {
  final Habit habit;
  final DateTime date;

  const HabitCard({
    Key? key,
    required this.habit,
    required this.date,
  }) : super(key: key);

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  bool _isLoading = true;
  HabitLog? _log;
  int _completedCount = 0;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadHabitLog();
  }

  @override
  void didUpdateWidget(HabitCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date != widget.date ||
        oldWidget.habit.id != widget.habit.id) {
      _loadHabitLog();
    }
  }

  Future<void> _loadHabitLog() async {
    setState(() {
      _isLoading = true;
    });

    final habitListModel = Provider.of<HabitListModel>(context, listen: false);
    final logs = habitListModel.getLogsForHabit(widget.habit.id);

    // Filter logs for this specific date
    final dateString = DateFormat('yyyy-MM-dd').format(widget.date);
    final filteredLogs = logs.where((log) {
      final logDateString = DateFormat('yyyy-MM-dd').format(log.date);
      return logDateString == dateString;
    }).toList();

    setState(() {
      if (filteredLogs.isNotEmpty) {
        _log = filteredLogs.first;
        _completedCount = _log!.completedCount;
        _isCompleted = _log!.completed;
      } else {
        _log = null;
        _completedCount = 0;
        _isCompleted = false;
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final habitListModel = Provider.of<HabitListModel>(context);
    final Color habitColor = Color(
      int.parse(widget.habit.colorCode.substring(1, 7), radix: 16) + 0xFF000000,
    );
    final bool isFutureDate = widget.date.isAfter(
      DateTime.now().add(const Duration(days: 1)),
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: habitColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.habit.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'archive',
                      child: Row(
                        children: [
                          Icon(Icons.archive, size: 18),
                          SizedBox(width: 8),
                          Text('Archive'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'edit') {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddHabitScreen(habitToEdit: widget.habit),
                        ),
                      );
                      _loadHabitLog();
                    } else if (value == 'archive') {
                      await habitListModel.archiveHabit(widget.habit.id, true);
                    }
                  },
                ),
              ],
            ),
            if (widget.habit.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                widget.habit.description,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Target: ${widget.habit.targetPerDay} per day',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Completed: $_completedCount',
                        style: TextStyle(
                          color: _isCompleted ? Colors.green : Colors.grey[700],
                          fontSize: 14,
                          fontWeight: _isCompleted
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isLoading) ...[
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ] else if (!isFutureDate) ...[
                  Row(
                    children: [
                      if (_completedCount > 0)
                        IconButton(
                          onPressed: () {
                            habitListModel.toggleHabitCompletion(
                              widget.habit.id!,
                              widget.date,
                              false,
                            );
                            _loadHabitLog();
                          },
                          icon: const Icon(Icons.remove_circle_outline),
                          color: Colors.red,
                        ),
                      Container(
                        decoration: BoxDecoration(
                          color: _isCompleted
                              ? Colors.green.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: () {
                            habitListModel.toggleHabitCompletion(
                              widget.habit.id!,
                              widget.date,
                              true,
                            );
                            _loadHabitLog();
                          },
                          icon: Icon(
                            _isCompleted
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color: _isCompleted ? Colors.green : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Future date, show disabled state
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
