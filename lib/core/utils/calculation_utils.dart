// lib/core/utils/calculation_utils.dart

import '../constants/app_constants.dart';

class CalculationUtils {
  CalculationUtils._();

  /// Estimates calories burned using MET formula.
  /// Calories = MET * weight(kg) * duration(hours)
  /// This is an ESTIMATE only - actual calories vary by individual.
  static double estimateCalories({
    required double weightKg,
    required int durationSeconds,
    required double avgSpeedMps,
  }) {
    if (weightKg <= 0 || durationSeconds <= 0) return 0.0;

    // Adjust MET value based on speed (faster = higher MET)
    double met = AppConstants.metValueRunning;
    final speedKmh = avgSpeedMps * 3.6;

    if (speedKmh < 8) {
      met = 8.0; // Jogging slow
    } else if (speedKmh < 10) {
      met = 9.8; // Running moderate
    } else if (speedKmh < 12) {
      met = 11.0;
    } else if (speedKmh < 14) {
      met = 12.8;
    } else {
      met = 14.5; // Fast running
    }

    final durationHours = durationSeconds / 3600.0;
    return met * weightKg * durationHours;
  }

  /// Estimates step count based on distance when pedometer unavailable.
  /// This is a FALLBACK ESTIMATE only.
  static int estimateSteps(double distanceMeters) {
    if (distanceMeters <= 0) return 0;
    final km = distanceMeters / 1000.0;
    return (km * AppConstants.stepsPerKm).round();
  }

  /// Calculates current pace from recent distance/time window (m/s)
  static double calculateCurrentPace(
    double recentDistanceMeters,
    int recentTimeSeconds,
  ) {
    if (recentTimeSeconds <= 0 || recentDistanceMeters <= 0) return 0.0;
    return recentDistanceMeters / recentTimeSeconds;
  }

  /// Calculates average pace across entire run (m/s)
  static double calculateAveragePace(
    double totalDistanceMeters,
    int totalTimeSeconds,
  ) {
    if (totalTimeSeconds <= 0 || totalDistanceMeters <= 0) return 0.0;
    return totalDistanceMeters / totalTimeSeconds;
  }

  /// Calculates average speed in m/s (same formula, kept separate for clarity)
  static double calculateAverageSpeed(
    double totalDistanceMeters,
    int totalTimeSeconds,
  ) {
    if (totalTimeSeconds <= 0) return 0.0;
    return totalDistanceMeters / totalTimeSeconds;
  }

  /// Converts km/h speed to m/s
  static double kmhToMps(double kmh) => kmh / 3.6;

  /// Converts m/s speed to km/h
  static double mpsToKmh(double mps) => mps * 3.6;
}
