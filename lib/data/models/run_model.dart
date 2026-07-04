// lib/data/models/run_model.dart

import 'dart:convert';

class RoutePoint {
  final double latitude;
  final double longitude;
  final double altitude;
  final double speed;
  final DateTime timestamp;

  RoutePoint({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.speed,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'speed': speed,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory RoutePoint.fromMap(Map<String, dynamic> map) {
    return RoutePoint(
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      altitude: (map['altitude'] as num?)?.toDouble() ?? 0.0,
      speed: (map['speed'] as num?)?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  static String encodeRoute(List<RoutePoint> points) {
    return jsonEncode(points.map((p) => p.toMap()).toList());
  }

  static List<RoutePoint> decodeRoute(String? json) {
    if (json == null || json.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(json);
      return list
          .map((e) => RoutePoint.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}

class RunModel {
  final String id;
  final DateTime date;
  final double distanceMeters;
  final int durationSeconds;
  final double avgPaceMps; // meters per second
  final double avgSpeedMps;
  final double maxSpeedMps;
  final double estimatedCalories;
  final int? steps; // null if pedometer not supported
  final List<RoutePoint> route;
  final String? targetExamId; // optional linked exam standard

  RunModel({
    required this.id,
    required this.date,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.avgPaceMps,
    required this.avgSpeedMps,
    required this.maxSpeedMps,
    required this.estimatedCalories,
    this.steps,
    this.route = const [],
    this.targetExamId,
  });

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'distance_meters': distanceMeters,
      'duration_seconds': durationSeconds,
      'avg_pace_mps': avgPaceMps,
      'avg_speed_mps': avgSpeedMps,
      'max_speed_mps': maxSpeedMps,
      'estimated_calories': estimatedCalories,
      'steps': steps,
      'route_json': RoutePoint.encodeRoute(route),
      'target_exam_id': targetExamId,
    };
  }

  factory RunModel.fromDbMap(Map<String, dynamic> map) {
    return RunModel(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      distanceMeters: (map['distance_meters'] as num).toDouble(),
      durationSeconds: map['duration_seconds'] as int,
      avgPaceMps: (map['avg_pace_mps'] as num).toDouble(),
      avgSpeedMps: (map['avg_speed_mps'] as num).toDouble(),
      maxSpeedMps: (map['max_speed_mps'] as num?)?.toDouble() ?? 0.0,
      estimatedCalories: (map['estimated_calories'] as num).toDouble(),
      steps: map['steps'] as int?,
      route: RoutePoint.decodeRoute(map['route_json'] as String?),
      targetExamId: map['target_exam_id'] as String?,
    );
  }
}
