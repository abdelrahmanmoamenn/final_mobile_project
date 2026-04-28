import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../model/News.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static const String _databaseName = 'favorites.db';
  static const int _databaseVersion = 2;
  static const String _tableName = 'favorites';

  // Singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  /// Get the database instance, initializing if necessary
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // Drop old table and create new one
      await db.execute('DROP TABLE IF EXISTS $_tableName');
      await _onCreate(db, newVersion);
    }
  }

  /// Create the database table
  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      '''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        itemId TEXT,
        imageUrl TEXT,
        source TEXT,
        date TEXT,
        body TEXT,
        isFeatured INTEGER DEFAULT 0
      )
      ''',
    );
  }

  /// Insert a favorite into the database
  Future<int> insertFavorite(News news) async {
    final db = await database;
    return db.insert(
      _tableName,
      news.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieve all favorites from the database
  Future<List<News>> getFavorites() async {
    final db = await database;
    final maps = await db.query(_tableName);

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(
      maps.length,
      (i) => News.fromMap(maps[i]),
    );
  }

  /// Delete a favorite by id
  Future<int> deleteFavorite(int id) async {
    final db = await database;
    return db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Check if a favorite exists by id
  Future<bool> isFavorited(int id) async {
    final db = await database;
    final result = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }

  /// Clear all favorites
  Future<int> clearFavorites() async {
    final db = await database;
    return db.delete(_tableName);
  }

  /// Close the database
  Future<void> closeDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}

