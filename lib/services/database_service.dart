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

  // ── Insert logged set ──────────────────────────────────────────────────────
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

    return await db.insert('logged_sets', {
      'userId': userId,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'setNumber': setNumber,
      'weight': weight,
      'reps': reps,
      'date': now,
    });
  }

  // ── Get last logged set for an exercise ───────────────────────────────────
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

  // ── Get overall average weight across all logged sets ─────────────────────
  /// Returns null if the user has no logged sets yet.
  Future<double?> getAverageWeight(String userId) async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT AVG(weight) as avgWeight FROM logged_sets WHERE userId = ?',
      [userId],
    );

    if (result.isEmpty) return null;
    final avg = result.first['avgWeight'];
    if (avg == null) return null;
    return double.parse((avg as num).toDouble().toStringAsFixed(1));
  }

  // ── Get weight change vs previous week ────────────────────────────────────
  /// Returns a signed double like -1.2 or +0.8. Null if not enough data.
  Future<double?> getWeightChangeSinceLastWeek(String userId) async {
    final db = await database;
    final now = DateTime.now();

    final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));

    Future<double?> avgForRange(DateTime start, DateTime end) async {
      final rows = await db.rawQuery(
        '''
        SELECT AVG(weight) as avg
        FROM logged_sets
        WHERE userId = ?
          AND date >= ?
          AND date < ?
        ''',
        [
          userId,
          DateTime(start.year, start.month, start.day).toIso8601String(),
          DateTime(end.year, end.month, end.day).toIso8601String(),
        ],
      );
      final v = rows.first['avg'];
      return v != null ? (v as num).toDouble() : null;
    }

    final thisWeekAvg = await avgForRange(thisWeekStart, now);
    final lastWeekAvg = await avgForRange(lastWeekStart, thisWeekStart);

    if (thisWeekAvg == null || lastWeekAvg == null) return null;
    return double.parse((thisWeekAvg - lastWeekAvg).toStringAsFixed(1));
  }

  // ── Get weekly volume (sum of weight*reps) for the last N weeks ───────────
  /// Returns a list of doubles, oldest week first.
  Future<List<double>> getWeeklyVolume(String userId, {int weeks = 4}) async {
    final db = await database;
    final now = DateTime.now();
    final List<double> result = [];

    for (int i = weeks - 1; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + i * 7));
      final weekEnd = weekStart.add(const Duration(days: 7));

      final rows = await db.rawQuery(
        '''
        SELECT SUM(weight * reps) as volume
        FROM logged_sets
        WHERE userId = ?
          AND date >= ?
          AND date < ?
        ''',
        [
          userId,
          DateTime(weekStart.year, weekStart.month, weekStart.day)
              .toIso8601String(),
          DateTime(weekEnd.year, weekEnd.month, weekEnd.day).toIso8601String(),
        ],
      );

      final vol = rows.first['volume'];
      result.add(vol != null ? (vol as num).toDouble() : 0.0);
    }

    return result;
  }

  // ── Get consistency heatmap grid ──────────────────────────────────────────
  /// Returns List<List<int>> — rows=weeks, cols=days (Mon–Sun).
  /// Intensity: 0=none, 1=light (1–3 sets), 2=medium (4–8), 3=high (9+).
  Future<List<List<int>>> getConsistencyGrid(String userId,
      {int weeks = 5}) async {
    final db = await database;
    final now = DateTime.now();

    final thisMonday = now.subtract(Duration(days: now.weekday - 1));
    final gridStart = thisMonday.subtract(Duration(days: (weeks - 1) * 7));

    final rows = await db.rawQuery(
      '''
      SELECT DATE(date) as day, COUNT(*) as setCount
      FROM logged_sets
      WHERE userId = ?
        AND date >= ?
      GROUP BY DATE(date)
      ''',
      [
        userId,
        DateTime(gridStart.year, gridStart.month, gridStart.day)
            .toIso8601String(),
      ],
    );

    final Map<String, int> dayMap = {};
    for (final row in rows) {
      dayMap[row['day'] as String] = row['setCount'] as int;
    }

    final List<List<int>> grid = [];
    for (int w = 0; w < weeks; w++) {
      final List<int> week = [];
      for (int d = 0; d < 7; d++) {
        final date = gridStart.add(Duration(days: w * 7 + d));
        final key =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final count = dayMap[key] ?? 0;
        int intensity = 0;
        if (count >= 1 && count <= 3) intensity = 1;
        else if (count <= 8) intensity = 2;
        else if (count > 8) intensity = 3;
        week.add(intensity);
      }
      grid.add(week);
    }

    return grid;
  }

  // ── Update or insert personal record ──────────────────────────────────────
  Future<void> updatePersonalRecord({
    required String userId,
    required String exerciseName,
    required double weight,
    required int reps,
  }) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final existing = await db.query(
      'personal_records',
      where: 'userId = ? AND exerciseName = ?',
      whereArgs: [userId, exerciseName],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      final existingWeight = existing.first['weight'] as double;
      if (weight > existingWeight) {
        await db.update(
          'personal_records',
          {'weight': weight, 'reps': reps, 'lastUpdated': now},
          where: 'userId = ? AND exerciseName = ?',
          whereArgs: [userId, exerciseName],
        );
      }
    } else {
      await db.insert('personal_records', {
        'userId': userId,
        'exerciseName': exerciseName,
        'weight': weight,
        'reps': reps,
        'lastUpdated': now,
      });
    }
  }

  // ── Get all personal records for a user ───────────────────────────────────
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

  // ── Get specific personal record ──────────────────────────────────────────
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

  // ── Clear all data (for testing) ──────────────────────────────────────────
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('logged_sets');
    await db.delete('personal_records');
  }
}