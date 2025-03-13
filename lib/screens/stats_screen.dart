import 'package:flutter/material.dart';
import 'package:sht/models/stats_model.dart';
import 'package:sht/services/database_service.dart';
import 'package:sht/services/stats_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final StatsService _statsService = StatsService();

  UserStats? _userStats;
  bool _isLoading = true;

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
      final userStats = await _databaseService.getUserStats();

      setState(() {
        _userStats = userStats;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading stats: $e');
      setState(() {
        _isLoading = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading stats: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userStats == null
              ? _buildErrorState()
              : _buildStatsContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load statistics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please check your connection and try again',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContent() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Total points card
          _buildPointsCard(),

          const SizedBox(height: 16),

          // Habits overview
          _buildHabitsOverviewCard(),

          const SizedBox(height: 16),

          // Habits detailed stats
          ..._buildHabitDetailedStats(),
        ],
      ),
    );
  }

  Widget _buildPointsCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Total Points',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 48,
                ),
                const SizedBox(width: 16),
                Text(
                  '${_userStats!.points}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'You have ${_userStats!.totalHabits} active habits',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            if (kIsWeb)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Web Mode',
                  style: TextStyle(
                    color: Colors.blue[300],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitsOverviewCard() {
    // Calculate overall stats
    int totalCompletedDays = 0;
    int totalDays = 0;
    int totalCurrentStreak = 0;
    int totalLongestStreak = 0;

    for (final habitStat in _userStats!.habitStats) {
      totalCompletedDays += habitStat.completedDays;
      totalDays += habitStat.totalDays;
      totalCurrentStreak += habitStat.currentStreak;
      totalLongestStreak = totalLongestStreak > habitStat.longestStreak
          ? totalLongestStreak
          : habitStat.longestStreak;
    }

    final overallCompletionRate =
        totalDays > 0 ? (totalCompletedDays / totalDays) * 100 : 0.0;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2,
              children: [
                _buildStatTile(
                  'Habits',
                  '${_userStats!.totalHabits}',
                  Icons.list_alt,
                  Colors.blue,
                ),
                _buildStatTile(
                  'Completion Rate',
                  '${overallCompletionRate.toStringAsFixed(1)}%',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatTile(
                  'Current Streak',
                  '$totalCurrentStreak',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
                _buildStatTile(
                  'Longest Streak',
                  '$totalLongestStreak',
                  Icons.emoji_events,
                  Colors.amber,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildHabitDetailedStats() {
    if (_userStats!.habitStats.isEmpty) {
      return [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  size: 48,
                  color: Colors.amber,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No habit stats available',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add and track habits to see statistics',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to home to add habits
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text('Add Habits'),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    return _userStats!.habitStats.map((habitStat) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                habitStat.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${habitStat.completionRate.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const Text('Completion'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${habitStat.currentStreak}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const Text('Current Streak'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${habitStat.longestStreak}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                        const Text('Best Streak'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: habitStat.completionRate / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProgressColor(habitStat.completionRate),
                ),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Text(
                '${habitStat.completedDays} of ${habitStat.totalDays} days completed',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Color _getProgressColor(double percentage) {
    if (percentage < 30) {
      return Colors.red;
    } else if (percentage < 70) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}
