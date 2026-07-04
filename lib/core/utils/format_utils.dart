// lib/core/utils/format_utils.dart

import 'package:intl/intl.dart';

class FormatUtils {
  FormatUtils._();

  /// Formats duration in HH:MM:SS
  static String formatDuration(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Formats duration as human-readable string (e.g. "4 min 22 sec")
  static String formatDurationHuman(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    if (h > 0) {
      return '${h}h ${m}m ${s}s';
    }
    if (m > 0) {
      return '${m} min ${s} sec';
    }
    return '${s} sec';
  }

  /// Formats distance in km (e.g. "1.42 km")
  static String formatDistanceKm(double meters) {
    final km = meters / 1000.0;
    if (km >= 10) {
      return '${km.toStringAsFixed(1)} km';
    }
    return '${km.toStringAsFixed(2)} km';
  }

  /// Formats distance in miles
  static String formatDistanceMiles(double meters) {
    final miles = meters / 1000.0 * 0.621371;
    if (miles >= 10) {
      return '${miles.toStringAsFixed(1)} mi';
    }
    return '${miles.toStringAsFixed(2)} mi';
  }

  /// Formats speed in km/h
  static String formatSpeedKmh(double metersPerSecond) {
    final kmh = metersPerSecond * 3.6;
    return '${kmh.toStringAsFixed(1)} km/h';
  }

  /// Formats speed in mph
  static String formatSpeedMph(double metersPerSecond) {
    final mph = metersPerSecond * 2.23694;
    return '${mph.toStringAsFixed(1)} mph';
  }

  /// Formats pace as MM:SS per km
  static String formatPacePerKm(double metersPerSecond) {
    if (metersPerSecond <= 0) return '--:--';
    final secondsPerKm = 1000.0 / metersPerSecond;
    final m = secondsPerKm ~/ 60;
    final s = (secondsPerKm % 60).toInt();
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')} /km";
  }

  /// Formats pace as MM:SS per mile
  static String formatPacePerMile(double metersPerSecond) {
    if (metersPerSecond <= 0) return '--:--';
    final secondsPerMile = 1609.34 / metersPerSecond;
    final m = secondsPerMile ~/ 60;
    final s = (secondsPerMile % 60).toInt();
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')} /mi";
  }

  /// Formats date for display
  static String formatDate(DateTime date) {
    return DateFormat('EEE, dd MMM yyyy').format(date);
  }

  /// Formats date short
  static String formatDateShort(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Formats time
  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  /// Formats date and time
  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  /// Formats calories
  static String formatCalories(double calories) {
    return '${calories.toInt()} kcal';
  }

  /// Formats weight
  static String formatWeight(double kg) {
    return '${kg.toStringAsFixed(1)} kg';
  }

  /// Formats height
  static String formatHeight(double cm) {
    return '${cm.toInt()} cm';
  }

  /// Formats steps
  static String formatSteps(int steps) {
    if (steps >= 1000) {
      return '${(steps / 1000).toStringAsFixed(1)}k';
    }
    return steps.toString();
  }

  /// Formats seconds as time display (for standards)
  static String formatSecondsAsTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  /// Get distance value based on units setting
  static String formatDistance(double meters, String units) {
    if (units == 'miles') {
      return formatDistanceMiles(meters);
    }
    return formatDistanceKm(meters);
  }

  /// Get speed value based on units setting
  static String formatSpeed(double metersPerSecond, String units) {
    if (units == 'miles') {
      return formatSpeedMph(metersPerSecond);
    }
    return formatSpeedKmh(metersPerSecond);
  }

  /// Get pace value based on units setting
  static String formatPace(double metersPerSecond, String units) {
    if (units == 'miles') {
      return formatPacePerMile(metersPerSecond);
    }
    return formatPacePerKm(metersPerSecond);
  }
}
