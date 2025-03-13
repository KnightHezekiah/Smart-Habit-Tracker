import 'package:flutter/material.dart';
import 'package:sht/models/habit_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ProgressChart extends StatelessWidget {
  final Habit habit;
  final List<HabitLog> logs;
  final bool showWeekly;

  const ProgressChart({
    Key? key,
    required this.habit,
    required this.logs,
    this.showWeekly = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return _buildEmptyChart();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                    color: Color(
                        int.parse(habit.colorCode.substring(1, 7), radix: 16) +
                            0xFF000000),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    habit.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: showWeekly
                  ? _buildWeeklyChart(context)
                  : _buildMonthlyChart(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                    color: Color(
                        int.parse(habit.colorCode.substring(1, 7), radix: 16) +
                            0xFF000000),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    habit.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'No data available yet',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context) {
    // Get the last 7 days
    final now = DateTime.now();
    final lastSevenDays = List.generate(7, (index) {
      return DateTime(now.year, now.month, now.day - (6 - index));
    });

    // Prepare data points for the chart
    final completionData = <FlSpot>[];

    for (int i = 0; i < lastSevenDays.length; i++) {
      final day = lastSevenDays[i];
      final dateString = DateFormat('yyyy-MM-dd').format(day);

      // Check if there is a log for this day
      final dayLogs = logs.where((log) {
        final logDateString = DateFormat('yyyy-MM-dd').format(log.date);
        return logDateString == dateString;
      }).toList();

      if (dayLogs.isNotEmpty && dayLogs.first.completed) {
        completionData.add(FlSpot(i.toDouble(), 1));
      } else {
        completionData.add(FlSpot(i.toDouble(), 0));
      }
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: false,
        ),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= lastSevenDays.length) {
                  return const SizedBox();
                }
                final day = lastSevenDays[value.toInt()];
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('E').format(day),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value == 0) {
                  return const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Text(
                      'No',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  );
                } else if (value == 1) {
                  return const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Text(
                      'Yes',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 1,
        lineBarsData: [
          LineChartBarData(
            spots: completionData,
            isCurved: false,
            color: Color(int.parse(habit.colorCode.substring(1, 7), radix: 16) +
                0xFF000000),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: spot.y == 1
                      ? Color(int.parse(habit.colorCode.substring(1, 7),
                              radix: 16) +
                          0xFF000000)
                      : Colors.grey.withOpacity(0.5),
                  strokeWidth: 0,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Color(
                      int.parse(habit.colorCode.substring(1, 7), radix: 16) +
                          0xFF000000)
                  .withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart(BuildContext context) {
    // Get the last 30 days
    final now = DateTime.now();
    final lastThirtyDays = List.generate(30, (index) {
      return DateTime(now.year, now.month, now.day - (29 - index));
    });

    // Calculate completion rate for each day
    final List<BarChartGroupData> barGroups = [];
    final daysInWeek = [[], [], [], []]; // Group days by week

    for (int i = 0; i < lastThirtyDays.length; i++) {
      final day = lastThirtyDays[i];
      final weekIndex = i ~/ 7;
      if (weekIndex < 4) {
        daysInWeek[weekIndex].add(day);
      }
    }

    // Calculate weekly completion rate
    for (int i = 0; i < daysInWeek.length; i++) {
      final weekDays = daysInWeek[i];
      int completedDays = 0;

      for (final day in weekDays) {
        final dateString = DateFormat('yyyy-MM-dd').format(day);

        final dayLogs = logs.where((log) {
          final logDateString = DateFormat('yyyy-MM-dd').format(log.date);
          return logDateString == dateString;
        }).toList();

        if (dayLogs.isNotEmpty && dayLogs.first.completed) {
          completedDays++;
        }
      }

      final completionRate =
          weekDays.isEmpty ? 0.0 : completedDays / weekDays.length;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: completionRate,
              color: Color(
                  int.parse(habit.colorCode.substring(1, 7), radix: 16) +
                      0xFF000000),
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        gridData: FlGridData(
          show: false,
        ),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= daysInWeek.length) {
                  return const SizedBox();
                }
                final weekNumber = value.toInt() + 1;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Week $weekNumber',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value == 0) {
                  return const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Text(
                      '0%',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  );
                } else if (value == 0.5) {
                  return const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Text(
                      '50%',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  );
                } else if (value == 1) {
                  return const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Text(
                      '100%',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        barGroups: barGroups,
        minY: 0,
        maxY: 1,
      ),
    );
  }
}
