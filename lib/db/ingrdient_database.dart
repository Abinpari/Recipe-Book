// lib/db/ingredient_database.dart
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/ingredients.dart';

class IngredientDatabase {
  static final IngredientDatabase instance = IngredientDatabase._init();

  static Database? _database;
  IngredientDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ingredients.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textNullable = 'TEXT';

    await db.execute('''
      CREATE TABLE ingredients (
        id $idType,
        name $textType,
        description $textNullable,
        quantity $textNullable,
        expirationDate $textNullable
      );
    ''');
  }

  // -------------------------
  // CRUD Operations
  // -------------------------
  Future<Ingredient> createIngredient(Ingredient ingredient) async {
    final db = await instance.database;
    final id = await db.insert('ingredients', ingredient.toMap());
    return ingredient.copyWith(id: id);
  }

  Future<Ingredient?> readIngredient(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      'ingredients',
      columns: ['id', 'name', 'description', 'quantity', 'expirationDate'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Ingredient.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Ingredient>> readAllIngredients() async {
    final db = await instance.database;
    const orderBy = 'id DESC';
    final result = await db.query('ingredients', orderBy: orderBy);

    return result.map((json) => Ingredient.fromMap(json)).toList();
  }

  Future<int> updateIngredient(Ingredient ingredient) async {
    final db = await instance.database;
    return db.update(
      'ingredients',
      ingredient.toMap(),
      where: 'id = ?',
      whereArgs: [ingredient.id],
    );
  }

  Future<int> deleteIngredient(int id) async {
    final db = await instance.database;
    return db.delete(
      'ingredients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}