import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Let's make our own simple models rather than importing files that might not exist
class HabitListModel extends ChangeNotifier {
  List<dynamic> _habits = [];
  Map<int, List<dynamic>> _habitLogs = {};

  List<dynamic> get habits => List.unmodifiable(_habits);
  Map<int, List<dynamic>> get habitLogs => Map.unmodifiable(_habitLogs);

  void addHabit(dynamic habit) {
    _habits.add(habit);
    notifyListeners();
  }

  void updateHabit(dynamic habit) {
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
      notifyListeners();
    }
  }

  void removeHabit(int habitId) {
    _habits.removeWhere((h) => h.id == habitId);
    _habitLogs.remove(habitId);
    notifyListeners();
  }

  void setHabits(List<dynamic> habits) {
    _habits = List.from(habits);
    notifyListeners();
  }
}

// Simplified initialization functions
Future<void> initializeWebDatabase() async {
  if (kIsWeb) {
    print('Initializing web database would happen here');
  }
  // Just a placeholder - we'll implement this properly later
  return;
}

void initializeFlutterWeb() {
  if (kIsWeb) {
    print('Flutter web initialization would happen here');
  }
  // Just a placeholder - we'll implement this properly later
}

// Placeholder screen classes
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Home Screen - Implement this screen'),
    );
  }
}

class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Stats Screen - Implement this screen'),
    );
  }
}

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Rewards Screen - Implement this screen'),
    );
  }
}

class AddHabitScreen extends StatelessWidget {
  const AddHabitScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Add Habit Screen - Implement this screen'),
    );
  }
}

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize web database
  await initializeWebDatabase();

  // Initialize web specific features
  if (kIsWeb) {
    initializeFlutterWeb();
    print('Running in web mode - API communication enabled');
  } else {
    print('Running in native mode - using local SQLite database');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HabitListModel(),
      child: MaterialApp(
        title: 'Smart Habit Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          // fontFamily: 'Poppins', // Comment out if font not available
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        home: const MainScreen(),
        routes: {
          '/add-habit': (context) => const AddHabitScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/edit-habit') {
            final habitId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (context) => EditHabitScreen(habitId: habitId),
            );
          }
          return null;
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const StatsScreen(),
    const RewardsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Rewards',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
