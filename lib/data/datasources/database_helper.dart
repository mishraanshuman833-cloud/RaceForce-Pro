// lib/data/datasources/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../../core/constants/app_constants.dart';
import '../models/run_model.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableRuns} (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        distance_meters REAL NOT NULL,
        duration_seconds INTEGER NOT NULL,
        avg_pace_mps REAL NOT NULL,
        avg_speed_mps REAL NOT NULL,
        max_speed_mps REAL NOT NULL,
        estimated_calories REAL NOT NULL,
        steps INTEGER,
        route_json TEXT,
        target_exam_id TEXT
      )
    ''');
  }

  Future<void> insertRun(RunModel run) async {
    final db = await database;
    await db.insert(
      AppConstants.tableRuns,
      run.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<RunModel>> getAllRuns() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableRuns,
      orderBy: 'date DESC',
    );
    return maps.map((m) => RunModel.fromDbMap(m)).toList();
  }

  Future<RunModel?> getRunById(String id) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableRuns,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return RunModel.fromDbMap(maps.first);
  }

  Future<void> deleteRun(String id) async {
    final db = await database;
    await db.delete(
      AppConstants.tableRuns,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllRuns() async {
    final db = await database;
    await db.delete(AppConstants.tableRuns);
  }

  Future<int> getTotalRunsCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM ${AppConstants.tableRuns}');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<double> getTotalDistanceMeters() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT SUM(distance_meters) as total FROM ${AppConstants.tableRuns}');
    final value = result.first['total'];
    if (value == null) return 0.0;
    return (value as num).toDouble();
  }

  Future<int> getTotalDurationSeconds() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT SUM(duration_seconds) as total FROM ${AppConstants.tableRuns}');
    final value = result.first['total'];
    if (value == null) return 0;
    return (value as num).toInt();
  }

  Future<double> getTotalCalories() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT SUM(estimated_calories) as total FROM ${AppConstants.tableRuns}');
    final value = result.first['total'];
    if (value == null) return 0.0;
    return (value as num).toDouble();
  }
}
