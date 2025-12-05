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
  final spaghettiId = await db.insertRecipe(
    Recipe(
      title: "Spaghetti Bolognese",
      imageUrl: "https://images.pexels.com/photos/4819464/pexels-photo-4819464.jpeg",
      steps: [],
    ),
  );

  await db.insertStep(
    RecipeStep(
      ingredients: "Onions, Garlic, Carrots",
      time: "10 min",
      instruction: "Chop them finely.",
    ),
    spaghettiId,
  );

  await db.insertStep(
    RecipeStep(
      ingredients: "Beef, Olive oil",
      time: "15 min",
      instruction: "Cook until browned.",
    ),
    spaghettiId,
  );

  await db.insertStep(
    RecipeStep(
      ingredients: "Tomato paste, Spices, Salt",
      time: "20 min",
      instruction: "Mix with beef and simmer until sauce thickens.",
    ),
    spaghettiId,
  );

  // --- Recipe 2: Chicken Curry ---
  final chickenCurryId = await db.insertRecipe(
    Recipe(
      title: "Chicken Curry",
      imageUrl: "https://images.pexels.com/photos/1111317/pexels-photo-1111317.jpeg",
      steps: [],
    ),
  );

  await db.insertStep(
    RecipeStep(
      ingredients: "Chicken, Turmeric, Salt",
      time: "15 min",
      instruction: "Marinate the chicken with turmeric and salt.",
    ),
    chickenCurryId,
  );

  await db.insertStep(
    RecipeStep(
      ingredients: "Onions, Ginger, Garlic, Tomatoes",
      time: "10 min",
      instruction: "Sauté until golden and fragrant.",
    ),
    chickenCurryId,
  );

  await db.insertStep(
    RecipeStep(
      ingredients: "Spices, Coconut milk, Water",
      time: "25 min",
      instruction: "Add spices and coconut milk, simmer until chicken is cooked.",
    ),
    chickenCurryId,
  );

  // --- Recipe 3: Vegetable Stir-Fry ---
  final stirFryId = await db.insertRecipe(
    Recipe(
      title: "Vegetable Stir-Fry",
      imageUrl: "https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg",
      steps: [],
    ),
  );

  await db.insertStep(
    RecipeStep(
      ingredients: "Broccoli, Bell peppers, Carrots",
      time: "5 min",
      instruction: "Wash and chop vegetables into bite-sized pieces.",
    ),
    stirFryId,
  );

  await db.insertStep(
    RecipeStep(
      ingredients: "Garlic, Soy sauce, Olive oil",
      time: "10 min",
      instruction: "Heat oil, add garlic, then stir-fry vegetables quickly.",
    ),
    stirFryId,
  );

  await db.insertStep(
    RecipeStep(
      ingredients: "Sesame seeds, Green onions",
      time: "2 min",
      instruction: "Garnish with sesame seeds and green onions before serving.",
    ),
    stirFryId,
  );

  print("Dummy data inserted successfully!");
}