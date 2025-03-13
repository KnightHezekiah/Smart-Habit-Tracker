import 'package:flutter/material.dart';
import 'package:sht/models/habit_model.dart';
import 'package:sht/services/database_service.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({Key? key}) : super(key: key);

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _frequency = 'Daily';
  List<String> _daysOfWeek = [];
  int _targetPerDay = 1;
  int _points = 5;
  String _colorCode = '#2196F3';
  String _icon = '0xe3af'; // calendar_today

  bool _isLoading = false;

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
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
      _isLoading = true;
    });

    try {
      final habit = Habit(
        id: -1, // Will be assigned by the database
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        frequency: _frequency,
        daysOfWeek: _frequency == 'Weekly' ? _daysOfWeek : null,
        targetPerDay: _targetPerDay,
        points: _points,
        colorCode: _colorCode,
        icon: _icon,
        isArchived: false,
        createdAt: DateTime.now(),
      );

      final newHabit = await _databaseService.createHabit(habit);

      if (newHabit != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Habit created successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      } else {
        throw Exception('Failed to create habit');
      }
    } catch (e) {
      print('Error saving habit: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving habit: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Habit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isLoading ? null : _saveHabit,
          ),
        ],
      ),
      body: _isLoading
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
                    onPressed: _isLoading ? null : _saveHabit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Save Habit'),
                  ),
                ],
              ),
            ),
    );
  }
}
