import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/recipes.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB("recipes.db");
    return _db!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE recipes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        imageUrl TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE steps(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipeId INTEGER,
        ingredients TEXT,
        time TEXT,
        instruction TEXT,
        FOREIGN KEY(recipeId) REFERENCES recipes(id)
      )
    ''');
  }

  // Insert Recipe
  Future<int> insertRecipe(Recipe recipe) async {
    final db = await database;
    return await db.insert("recipes", recipe.toMap());
  }

  // Insert Step
  Future<int> insertStep(RecipeStep step, int recipeId) async {
    final db = await database;
    return await db.insert("steps", step.toMap(recipeId));
  }
  Future<void> clearRecipesTable() async {
  final db = await database;
  await db.delete('recipes');
}

Future<void> clearStepsTable() async {
  final db = await database;
  await db.delete('steps');
}


  // Get All Recipes with Steps
  Future<List<Recipe>> getRecipes() async {
    final db = await database;
    final recipesData = await db.query("recipes");
    List<Recipe> recipes = [];

    for (var recipeRow in recipesData) {
      final stepsData = await db.query(
        "steps",
        where: "recipeId = ?",
        whereArgs: [recipeRow["id"]],
      );

      recipes.add(
        Recipe(
          id: recipeRow["id"] as int,
          title: recipeRow["title"] as String,
          imageUrl: recipeRow["imageUrl"] as String,
          steps: stepsData.map((s) => RecipeStep.fromMap(s)).toList(),
        ),
      );
    }
    return recipes;
  }
}