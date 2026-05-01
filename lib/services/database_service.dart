import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/user_model.dart';
import '../utils/app_error_logger.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;
  final _firebaseRef = FirebaseDatabase.instance.ref();

  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'workout_db.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS workout_sessions(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId TEXT NOT NULL,
          startTime TEXT NOT NULL,
          endTime TEXT,
          totalSets INTEGER DEFAULT 0
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS pending_operations(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tableName TEXT NOT NULL,
          operation TEXT NOT NULL,
          data TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          status TEXT DEFAULT 'pending'
        )
      ''');
    }
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
    
    await db.execute('''
      CREATE TABLE workout_sessions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT,
        totalSets INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE pending_operations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tableName TEXT NOT NULL,
        operation TEXT NOT NULL,
        data TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        status TEXT DEFAULT 'pending'
      )
    ''');
  }

  // ── Sync Helpers ──────────────────────────────────────────────────────────

  Future<bool> _trySyncLoggedSet(Map<String, dynamic> data) async {
    try {
      final userId = data['userId'];
      final date = data['date'].toString().replaceAll('.', '_');
      await _firebaseRef.child('users/$userId/logged_sets/$date').set(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _trySyncPersonalRecord(Map<String, dynamic> data) async {
    try {
      final userId = data['userId'];
      final safeName = data['exerciseName'].toString().replaceAll(RegExp(r'[.#$\[\]]'), '_');
      await _firebaseRef.child('users/$userId/personal_records/$safeName').set(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _trySyncWorkoutSession(Map<String, dynamic> data) async {
    try {
      final userId = data['userId'];
      final startTime = data['startTime'].toString().replaceAll('.', '_');
      await _firebaseRef.child('users/$userId/sessions/$startTime').set(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Sync Pending Queue ────────────────────────────────────────────────────

  Future<void> syncPendingOperations() async {
    try {
      final db = await database;
      final pending = await db.query(
        'pending_operations',
        where: "status = 'pending'",
        orderBy: 'createdAt ASC',
      );

      if (pending.isEmpty) return;

      for (var op in pending) {
        final id = op['id'] as int;
        final tableName = op['tableName'] as String;
        final dataStr = op['data'] as String;
        
        Map<String, dynamic> data;
        try {
          data = jsonDecode(dataStr) as Map<String, dynamic>;
        } catch (e) {
          continue;
        }

        bool success = false;
        if (tableName == 'logged_sets') {
          success = await _trySyncLoggedSet(data);
        } else if (tableName == 'personal_records') {
          success = await _trySyncPersonalRecord(data);
        } else if (tableName == 'workout_sessions') {
          success = await _trySyncWorkoutSession(data);
        }

        if (success) {
          await markOperationSynced(id);
        }
      }
    } catch (e, stack) {
      appError('DatabaseService.syncPendingOperations', e, stack);
    }
  }

  // ── Database Operations ───────────────────────────────────────────────────

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
    
    final data = {
      'userId': userId,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'setNumber': setNumber,
      'weight': weight,
      'reps': reps,
      'date': now,
    };

    final id = await db.insert('logged_sets', data);
    
    // Attempt Firebase Sync
    bool synced = await _trySyncLoggedSet(data);
    if (!synced) {
      await queuePendingOperation(
        tableName: 'logged_sets',
        operation: 'INSERT',
        data: data,
      );
    }

    return id;
  }

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

    Map<String, dynamic>? dataToSync;

    if (existing.isNotEmpty) {
      final existingWeight = existing.first['weight'] as double;
      if (weight > existingWeight) {
        dataToSync = {
          'userId': userId,
          'exerciseName': exerciseName,
          'weight': weight,
          'reps': reps,
          'lastUpdated': now,
        };
        await db.update(
          'personal_records',
          dataToSync!,
          where: 'userId = ? AND exerciseName = ?',
          whereArgs: [userId, exerciseName],
        );
      }
    } else {
      dataToSync = {
        'userId': userId,
        'exerciseName': exerciseName,
        'weight': weight,
        'reps': reps,
        'lastUpdated': now,
      };
      await db.insert('personal_records', dataToSync);
    }

    if (dataToSync != null) {
      bool synced = await _trySyncPersonalRecord(dataToSync);
      if (!synced) {
        await queuePendingOperation(
          tableName: 'personal_records',
          operation: 'UPDATE',
          data: dataToSync,
        );
      }
    }
  }

  Future<int> startWorkoutSession(String userId) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    final data = {
      'userId': userId,
      'startTime': now,
      'totalSets': 0,
    };
    final id = await db.insert('workout_sessions', data);

    bool synced = await _trySyncWorkoutSession({...data, 'id': id});
    if (!synced) {
      await queuePendingOperation(
        tableName: 'workout_sessions',
        operation: 'INSERT',
        data: {...data, 'id': id},
      );
    }

    return id;
  }

  Future<void> endWorkoutSession(String userId) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    final sessions = await db.query(
      'workout_sessions',
      where: 'userId = ? AND endTime IS NULL',
      whereArgs: [userId],
      orderBy: 'startTime DESC',
      limit: 1,
    );
    
    if (sessions.isNotEmpty) {
      final session = sessions.first;
      final sessionId = session['id'] as int;
      final startTime = session['startTime'] as String;
      
      final setsResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM logged_sets WHERE userId = ? AND date >= ?',
        [userId, startTime],
      );
      
      final totalSets = (setsResult.first['count'] as int?) ?? 0;
      final updateData = {'endTime': now, 'totalSets': totalSets};

      await db.update('workout_sessions', updateData, where: 'id = ?', whereArgs: [sessionId]);

      final fullData = Map<String, dynamic>.from(session);
      fullData['endTime'] = now;
      fullData['totalSets'] = totalSets;

      bool synced = await _trySyncWorkoutSession(fullData);
      if (!synced) {
        await queuePendingOperation(
          tableName: 'workout_sessions',
          operation: 'UPDATE',
          data: fullData,
        );
      }
    }
  }

  Future<void> queuePendingOperation({
    required String tableName,
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    final db = await database;
    await db.insert('pending_operations', {
      'tableName': tableName,
      'operation': operation,
      'data': jsonEncode(data),
      'createdAt': DateTime.now().toIso8601String(),
      'status': 'pending',
    });
  }

  Future<void> markOperationSynced(int id) async {
    final db = await database;
    await db.update('pending_operations', {'status': 'synced'}, where: 'id = ?', whereArgs: [id]);
  }

  // ── Retrieval Methods (Existing) ──────────────────────────────────────────

  Future<Map<String, dynamic>?> getLastLoggedSet({required String userId, required String exerciseId}) async {
    final db = await database;
    final result = await db.query('logged_sets', where: 'userId = ? AND exerciseId = ?', whereArgs: [userId, exerciseId], orderBy: 'date DESC', limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  Future<double?> getAverageWeight(String userId) async {
    final db = await database;
    final result = await db.rawQuery('SELECT AVG(weight) as avgWeight FROM logged_sets WHERE userId = ?', [userId]);
    if (result.isEmpty || result.first['avgWeight'] == null) return null;
    return double.parse((result.first['avgWeight'] as num).toDouble().toStringAsFixed(1));
  }

  Future<double?> getWeightChangeSinceLastWeek(String userId) async {
    final db = await database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));

    Future<double?> avgForRange(DateTime start, DateTime end) async {
      final rows = await db.rawQuery('SELECT AVG(weight) as avg FROM logged_sets WHERE userId = ? AND date(date) >= ? AND date(date) < ?', [userId, _dateKey(start), _dateKey(end)]);
      return rows.isNotEmpty && rows.first['avg'] != null ? (rows.first['avg'] as num).toDouble() : null;
    }

    final thisWeekAvg = await avgForRange(thisWeekStart, today);
    final lastWeekAvg = await avgForRange(lastWeekStart, thisWeekStart);
    if (thisWeekAvg == null || lastWeekAvg == null) return null;
    return double.parse((thisWeekAvg - lastWeekAvg).toStringAsFixed(1));
  }

  Future<List<double>> getWeeklyVolume(String userId, {int weeks = 4}) async {
    final db = await database;
    final today = DateTime.now();
    final List<double> result = [];
    for (int i = weeks - 1; i >= 0; i--) {
      final weekStart = today.subtract(Duration(days: today.weekday - 1 + i * 7));
      final weekEnd = weekStart.add(const Duration(days: 7));
      final rows = await db.rawQuery('SELECT SUM(weight * reps) as volume FROM logged_sets WHERE userId = ? AND date(date) >= ? AND date(date) < ?', [userId, _dateKey(weekStart), _dateKey(weekEnd)]);
      result.add(rows.first['volume'] != null ? (rows.first['volume'] as num).toDouble() : 0.0);
    }
    return result;
  }

  Future<List<List<int>>> getConsistencyGrid(String userId, {int weeks = 5}) async {
    final db = await database;
    final today = DateTime.now();
    final thisMonday = today.subtract(Duration(days: today.weekday - 1));
    final gridStart = thisMonday.subtract(Duration(days: (weeks - 1) * 7));
    final rows = await db.rawQuery('SELECT date(date) as day, COUNT(*) as setCount FROM logged_sets WHERE userId = ? AND date(date) >= ? GROUP BY date(date)', [userId, _dateKey(gridStart)]);
    final Map<String, int> dayMap = {for (var row in rows) row['day'] as String: row['setCount'] as int};
    return List.generate(weeks, (w) => List.generate(7, (d) {
      final date = gridStart.add(Duration(days: w * 7 + d));
      final count = dayMap[_dateKey(date)] ?? 0;
      if (count == 0) return 0;
      if (count <= 3) return 1;
      return count <= 8 ? 2 : 3;
    }));
  }

  Future<List<PersonalRecord>> getPersonalRecords(String userId) async {
    final db = await database;
    final results = await db.query('personal_records', where: 'userId = ?', whereArgs: [userId], orderBy: 'weight DESC');
    return results.map((record) => PersonalRecord(exerciseName: record['exerciseName'] as String, value: '${(record['weight'] as double).toInt()} lbs', icon: '🏋️')).toList();
  }

  Future<Map<String, dynamic>?> getPersonalRecord({required String userId, required String exerciseName}) async {
    final db = await database;
    final result = await db.query('personal_records', where: 'userId = ? AND exerciseName = ?', whereArgs: [userId, exerciseName], limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  Future<double?> getAverageWorkoutDuration(String userId) async {
    final db = await database;
    try {
      final results = await db.query('workout_sessions', where: 'userId = ? AND endTime IS NOT NULL', whereArgs: [userId], orderBy: 'startTime DESC', limit: 30);
      if (results.isEmpty) return null;
      double total = 0; int count = 0;
      for (var s in results) {
        final d = DateTime.parse(s['endTime'] as String).difference(DateTime.parse(s['startTime'] as String)).inMinutes;
        if (d >= 5 && d <= 120) { total += d; count++; }
      }
      return count > 0 ? total / count : null;
    } catch (_) { return null; }
  }

  Future<int> getWorkoutsThisWeek(String userId) async {
    final db = await database;
    final weekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    final res = await db.rawQuery('SELECT COUNT(DISTINCT DATE(date)) as count FROM logged_sets WHERE userId = ? AND date >= ?', [userId, _dateKey(weekStart)]);
    return (res.first['count'] as int?) ?? 0;
  }

  Future<int> getCaloriesBurnedThisWeek(String userId) async {
    final vol = await getWeeklyVolume(userId, weeks: 1);
    return (vol.isNotEmpty ? vol.first * 0.001 : 0).round();
  }

  Future<int> getStreak(String userId) async {
    final db = await database;
    final rows = await db.rawQuery('SELECT DISTINCT DATE(date) as day FROM logged_sets WHERE userId = ? ORDER BY day DESC', [userId]);
    if (rows.isEmpty) return 0;
    int streak = 0; DateTime check = DateTime.now();
    for (var row in rows) {
      if (row['day'] == _dateKey(check)) { streak++; check = check.subtract(const Duration(days: 1)); }
      else if (row['day'] == _dateKey(check.subtract(const Duration(days: 1)))) { streak++; check = DateTime.parse(row['day'] as String).subtract(const Duration(days: 1)); }
      else break;
    }
    return streak;
  }

  String _dateKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('logged_sets');
    await db.delete('personal_records');
    await db.delete('workout_sessions');
    await db.delete('pending_operations');
  }
}
