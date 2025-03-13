import 'package:flutter/material.dart';

// We'll create simple placeholder screens right here instead of importing
// This ensures routes.dart works with our simplified main.dart

// Simple HomeScreen placeholder
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Home Screen - Implement this screen'),
    );
  }
}

// Simple StatsScreen placeholder
class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Stats Screen - Implement this screen'),
    );
  }
}

// Simple RewardsScreen placeholder
class RewardsScreen extends StatelessWidget {
  const RewardsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Rewards Screen - Implement this screen'),
    );
  }
}

// Simple AddHabitScreen placeholder
class AddHabitScreen extends StatelessWidget {
  const AddHabitScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Add Habit Screen - Implement this screen'),
    );
  }
}

// Simple EditHabitScreen placeholder
class EditHabitScreen extends StatelessWidget {
  final int habitId;

  const EditHabitScreen({Key? key, required this.habitId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Edit Habit Screen for ID: $habitId - Implement this screen'),
    );
  }
}

// Route names
const String homeRoute = '/';
const String addHabitRoute = '/add-habit';
const String editHabitRoute = '/edit-habit';
const String statsRoute = '/stats';
const String rewardsRoute = '/rewards';

// Route generator
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case homeRoute:
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    case addHabitRoute:
      return MaterialPageRoute(builder: (_) => const AddHabitScreen());
    case editHabitRoute:
      final habitId = settings.arguments as int;
      return MaterialPageRoute(
          builder: (_) => EditHabitScreen(habitId: habitId));
    case statsRoute:
      return MaterialPageRoute(builder: (_) => const StatsScreen());
    case rewardsRoute:
      return MaterialPageRoute(builder: (_) => const RewardsScreen());
    default:
      // If there is no such named route, create a error page route
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(
            child: Text('No route defined for ${settings.name}'),
          ),
        ),
      );
  }
}
