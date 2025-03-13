import 'package:flutter/material.dart';
import 'package:sht/models/habit_model.dart';
import 'package:sht/services/database_service.dart';

class EditHabitScreen extends StatefulWidget {
  final int habitId;

  const EditHabitScreen({
    Key? key,
    required this.habitId,
  }) : super(key: key);

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  Habit? _habit;
  String _frequency = 'Daily';
  List<String> _daysOfWeek = [];
  int _targetPerDay = 1;
  int _points = 5;
  String _colorCode = '#2196F3';
  String _icon = '0xe3af'; // calendar_today

  bool _isLoading = true;
  bool _isSaving = false;

  final DatabaseService _databaseService = DatabaseService();

  final List<String> _frequencies = ['Daily', 'Weekly', 'Monthly'];
  final List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

  @override
  void initState() {
    super.initState();
    _loadHabit();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadHabit() async {
    try {
      final habit = await _databaseService.getHabit(widget.habitId);

      if (habit == null) {
        throw Exception('Habit not found');
      }

      _nameController.text = habit.name;
      _descriptionController.text = habit.description ?? '';

      setState(() {
        _habit = habit;
        _frequency = habit.frequency;
        _daysOfWeek = habit.daysOfWeek ?? [];
        _targetPerDay = habit.targetPerDay;
        _points = habit.points;
        _colorCode = habit.colorCode;
        _icon = habit.icon;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading habit: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading habit: $e'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_frequency == 'Weekly' && _daysOfWeek.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one day of the week'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedHabit = _habit!.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        frequency: _frequency,
        daysOfWeek: _frequency == 'Weekly' ? _daysOfWeek : null,
        targetPerDay: _targetPerDay,
        points: _points,
        colorCode: _colorCode,
        icon: _icon,
      );

      final result = await _databaseService.updateHabit(updatedHabit);

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Habit updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      } else {
        throw Exception('Failed to update habit');
      }
    } catch (e) {
      print('Error updating habit: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating habit: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _deleteHabit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: const Text(
            'Are you sure you want to delete this habit? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final success = await _databaseService.deleteHabit(widget.habitId);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Habit deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      } else {
        throw Exception('Failed to delete habit');
      }
    } catch (e) {
      print('Error deleting habit: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting habit: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Habit'),
        actions: [
          if (!_isLoading && !_isSaving)
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: _deleteHabit,
            ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: (_isLoading || _isSaving) ? null : _saveHabit,
          ),
        ],
      ),
      body: (_isLoading || _isSaving)
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Habit Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a habit name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Description field
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 16),

                  // Frequency dropdown
                  DropdownButtonFormField<String>(
                    value: _frequency,
                    decoration: const InputDecoration(
                      labelText: 'Frequency',
                      border: OutlineInputBorder(),
                    ),
                    items: _frequencies
                        .map((frequency) => DropdownMenuItem(
                              value: frequency,
                              child: Text(frequency),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _frequency = value!;
                      });
                    },
                  ),

                  // Days of week selection for weekly frequency
                  if (_frequency == 'Weekly') ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Select Days of Week',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _weekdays.map((day) {
                        final isSelected = _daysOfWeek.contains(day);
                        return FilterChip(
                          label: Text(day),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _daysOfWeek.add(day);
                              } else {
                                _daysOfWeek.remove(day);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Target per day field
                  Row(
                    children: [
                      const Text('Target per day: '),
                      Expanded(
                        child: Slider(
                          value: _targetPerDay.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          label: _targetPerDay.toString(),
                          onChanged: (value) {
                            setState(() {
                              _targetPerDay = value.toInt();
                            });
                          },
                        ),
                      ),
                      Text(_targetPerDay.toString()),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Points field
                  Row(
                    children: [
                      const Text('Points per completion: '),
                      Expanded(
                        child: Slider(
                          value: _points.toDouble(),
                          min: 1,
                          max: 20,
                          divisions: 19,
                          label: _points.toString(),
                          onChanged: (value) {
                            setState(() {
                              _points = value.toInt();
                            });
                          },
                        ),
                      ),
                      Text(_points.toString()),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Save button
                  ElevatedButton(
                    onPressed: (_isLoading || _isSaving) ? null : _saveHabit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Save Changes'),
                  ),

                  const SizedBox(height: 16),

                  // Delete button
                  OutlinedButton(
                    onPressed: (_isLoading || _isSaving) ? null : _deleteHabit,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Delete Habit'),
                  ),
                ],
              ),
            ),
    );
  }
}
