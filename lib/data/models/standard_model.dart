// lib/data/models/standard_model.dart

class QualifyingCriteria {
  final String category;
  final int timeSeconds;
  final String timeDisplay;
  final int marks;
  final String note;

  QualifyingCriteria({
    required this.category,
    required this.timeSeconds,
    required this.timeDisplay,
    required this.marks,
    required this.note,
  });

  factory QualifyingCriteria.fromJson(Map<String, dynamic> json) {
    return QualifyingCriteria(
      category: json['category'] as String? ?? '',
      timeSeconds: json['time_seconds'] as int? ?? 0,
      timeDisplay: json['time_display'] as String? ?? '',
      marks: json['marks'] as int? ?? 0,
      note: json['note'] as String? ?? '',
    );
  }
}

class StandardEvent {
  final String name;
  final int distanceMeters;
  final String type;
  final List<QualifyingCriteria> qualifyingCriteria;

  StandardEvent({
    required this.name,
    required this.distanceMeters,
    required this.type,
    required this.qualifyingCriteria,
  });

  factory StandardEvent.fromJson(Map<String, dynamic> json) {
    return StandardEvent(
      name: json['name'] as String? ?? '',
      distanceMeters: json['distance_meters'] as int? ?? 0,
      type: json['type'] as String? ?? 'run',
      qualifyingCriteria: (json['qualifying_criteria'] as List<dynamic>? ?? [])
          .map((e) => QualifyingCriteria.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class StandardCategory {
  final String gender;
  final String label;
  final List<StandardEvent> events;

  StandardCategory({
    required this.gender,
    required this.label,
    required this.events,
  });

  factory StandardCategory.fromJson(Map<String, dynamic> json) {
    return StandardCategory(
      gender: json['gender'] as String? ?? '',
      label: json['label'] as String? ?? '',
      events: (json['events'] as List<dynamic>? ?? [])
          .map((e) => StandardEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AdditionalEvent {
  final String gender;
  final String name;
  final String standard;

  AdditionalEvent({
    required this.gender,
    required this.name,
    required this.standard,
  });

  factory AdditionalEvent.fromJson(Map<String, dynamic> json) {
    return AdditionalEvent(
      gender: json['gender'] as String? ?? '',
      name: json['name'] as String? ?? '',
      standard: json['standard'] as String? ?? '',
    );
  }
}

class ExamStandard {
  final String id;
  final String name;
  final String fullName;
  final String logo;
  final String colorHex;
  final List<StandardCategory> categories;
  final List<AdditionalEvent> additionalEvents;
  final String? additionalInfo;

  ExamStandard({
    required this.id,
    required this.name,
    required this.fullName,
    required this.logo,
    required this.colorHex,
    required this.categories,
    this.additionalEvents = const [],
    this.additionalInfo,
  });

  factory ExamStandard.fromJson(Map<String, dynamic> json) {
    return ExamStandard(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      logo: json['logo'] as String? ?? '',
      colorHex: json['color'] as String? ?? '#1565C0',
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((e) => StandardCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      additionalEvents: (json['additional_events'] as List<dynamic>? ?? [])
          .map((e) => AdditionalEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      additionalInfo: json['additional_info'] as String?,
    );
  }
}

class StandardsData {
  final String version;
  final String lastUpdated;
  final List<ExamStandard> standards;

  StandardsData({
    required this.version,
    required this.lastUpdated,
    required this.standards,
  });

  factory StandardsData.fromJson(Map<String, dynamic> json) {
    return StandardsData(
      version: json['version'] as String? ?? '1.0.0',
      lastUpdated: json['last_updated'] as String? ?? '',
      standards: (json['standards'] as List<dynamic>? ?? [])
          .map((e) => ExamStandard.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  ExamStandard? getById(String id) {
    try {
      return standards.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
