// lib/data/models/profile_model.dart

class ProfileModel {
  final String name;
  final int age;
  final double heightCm;
  final double weightKg;
  final String gender; // 'male' or 'female'
  final String targetExamId;

  ProfileModel({
    required this.name,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.gender,
    required this.targetExamId,
  });

  ProfileModel copyWith({
    String? name,
    int? age,
    double? heightCm,
    double? weightKg,
    String? gender,
    String? targetExamId,
  }) {
    return ProfileModel(
      name: name ?? this.name,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      gender: gender ?? this.gender,
      targetExamId: targetExamId ?? this.targetExamId,
    );
  }

  bool get isComplete =>
      name.isNotEmpty && age > 0 && heightCm > 0 && weightKg > 0;

  factory ProfileModel.empty() {
    return ProfileModel(
      name: '',
      age: 0,
      heightCm: 0,
      weightKg: 0,
      gender: 'male',
      targetExamId: 'ssc_gd',
    );
  }

  /// BMI calculation
  double get bmi {
    if (heightCm <= 0 || weightKg <= 0) return 0;
    final heightM = heightCm / 100.0;
    return weightKg / (heightM * heightM);
  }
}
