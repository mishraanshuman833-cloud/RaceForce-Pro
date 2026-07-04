// lib/data/repositories/run_repository.dart

import '../datasources/database_helper.dart';
import '../models/run_model.dart';

class RunRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<void> saveRun(RunModel run) async {
    await _db.insertRun(run);
  }

  Future<List<RunModel>> getAllRuns() async {
    return await _db.getAllRuns();
  }

  Future<RunModel?> getRunById(String id) async {
    return await _db.getRunById(id);
  }

  Future<void> deleteRun(String id) async {
    await _db.deleteRun(id);
  }

  Future<void> deleteAllRuns() async {
    await _db.deleteAllRuns();
  }

  Future<RunStats> getOverallStats() async {
    final totalRuns = await _db.getTotalRunsCount();
    final totalDistance = await _db.getTotalDistanceMeters();
    final totalDuration = await _db.getTotalDurationSeconds();
    final totalCalories = await _db.getTotalCalories();

    return RunStats(
      totalRuns: totalRuns,
      totalDistanceMeters: totalDistance,
      totalDurationSeconds: totalDuration,
      totalCalories: totalCalories,
    );
  }
}

class RunStats {
  final int totalRuns;
  final double totalDistanceMeters;
  final int totalDurationSeconds;
  final double totalCalories;

  RunStats({
    required this.totalRuns,
    required this.totalDistanceMeters,
    required this.totalDurationSeconds,
    required this.totalCalories,
  });

  factory RunStats.empty() {
    return RunStats(
      totalRuns: 0,
      totalDistanceMeters: 0.0,
      totalDurationSeconds: 0,
      totalCalories: 0.0,
    );
  }
}
