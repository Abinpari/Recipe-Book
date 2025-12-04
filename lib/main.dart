import 'package:flutter/material.dart';
import 'package:flutterassignment/views/pages/auth_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutterassignment/db/recipe_database.dart';
import 'package:flutterassignment/models/recipes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize theme with error handling
  bool isDarkMode = false;
  try {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode = prefs.getBool('isDarkMode') ?? false;
  } catch (e) {
    print('Error loading theme preference: $e');
  }
await insertDummyData();
  runApp(MyApp(isDarkMode: isDarkMode));
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;

  const MyApp({super.key, required this.isDarkMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  Future<void> toggleTheme(bool isDark) async {
    setState(() {
      _isDarkMode = isDark;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', isDark);
    } catch (e) {
      print('Error saving theme to SharedPreferences: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 255, 255, 255),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: AuthLayout(toggleTheme: toggleTheme),
    );
  }
}
Future<void> insertDummyData() async {
  final db = DatabaseHelper.instance;

  // 1. CLEAR THE DATABASE
  // Make sure you delete from steps first to avoid foreign key issues.
  await db.clearStepsTable();
  await db.clearRecipesTable();

  print("Database cleared successfully!");

  // 2. INSERT DUMMY RECIPES
  // --- Recipe 1: Spaghetti Bolognese ---
  
}