import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/user_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'workout_db.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Logged sets table - stores actual workout data
    await db.execute('''
      CREATE TABLE logged_sets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        exerciseId TEXT NOT NULL,
        exerciseName TEXT NOT NULL,
        setNumber INTEGER NOT NULL,
        weight REAL NOT NULL,
        reps INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    // Personal records table
    await db.execute('''
      CREATE TABLE personal_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        exerciseName TEXT NOT NULL,
        weight REAL NOT NULL,
        reps INTEGER NOT NULL,
        lastUpdated TEXT NOT NULL,
        UNIQUE(userId, exerciseName)
      )
    ''');
  }

  // Insert logged set
  Future<int> insertLoggedSet({
    required String userId,
    required String exerciseId,
    required String exerciseName,
    required int setNumber,
    required double weight,
    required int reps,
  }) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    return await db.insert(
      'logged_sets',
      {
        'userId': userId,
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'setNumber': setNumber,
        'weight': weight,
        'reps': reps,
        'date': now,
      },
    );
  }

  // Get last logged weight and reps for an exercise
  Future<Map<String, dynamic>?> getLastLoggedSet({
    required String userId,
    required String exerciseId,
  }) async {
    final db = await database;

    final result = await db.query(
      'logged_sets',
      where: 'userId = ? AND exerciseId = ?',
      whereArgs: [userId, exerciseId],
      orderBy: 'date DESC',
      limit: 1,
    );

    return result.isNotEmpty ? result.first : null;
  }

  // Update or insert personal record
  Future<void> updatePersonalRecord({
    required String userId,
    required String exerciseName,
    required double weight,
    required int reps,
  }) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    // Check if PR exists
    final existing = await db.query(
      'personal_records',
      where: 'userId = ? AND exerciseName = ?',
      whereArgs: [userId, exerciseName],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      // Only update if the new weight is greater
      final existingWeight = existing.first['weight'] as double;
      if (weight > existingWeight) {
        await db.update(
          'personal_records',
          {
            'weight': weight,
            'reps': reps,
            'lastUpdated': now,
          },
          where: 'userId = ? AND exerciseName = ?',
          whereArgs: [userId, exerciseName],
        );
      }
    } else {
      // Insert new PR
      await db.insert(
        'personal_records',
        {
          'userId': userId,
          'exerciseName': exerciseName,
          'weight': weight,
          'reps': reps,
          'lastUpdated': now,
        },
      );
    }
  }

  // Get all personal records for a user
  Future<List<PersonalRecord>> getPersonalRecords(String userId) async {
    final db = await database;

    final results = await db.query(
      'personal_records',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'weight DESC',
    );

    return results
        .map((record) => PersonalRecord(
          exerciseName: record['exerciseName'] as String,
          value: '${(record['weight'] as double).toInt()} lbs',
          icon: '🏋️',
        ))
        .toList();
  }

  // Get specific personal record
  Future<Map<String, dynamic>?> getPersonalRecord({
    required String userId,
    required String exerciseName,
  }) async {
    final db = await database;

    final result = await db.query(
      'personal_records',
      where: 'userId = ? AND exerciseName = ?',
      whereArgs: [userId, exerciseName],
      limit: 1,
    );

    return result.isNotEmpty ? result.first : null;
  }

  // Clear all data (for testing)
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('logged_sets');
    await db.delete('personal_records');
  }
}

