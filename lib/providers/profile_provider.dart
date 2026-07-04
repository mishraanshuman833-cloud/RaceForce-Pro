// lib/providers/profile_provider.dart

import 'package:flutter/material.dart';
import '../data/models/profile_model.dart';
import '../data/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repo = ProfileRepository();

  ProfileModel _profile = ProfileModel.empty();
  bool _isLoaded = false;

  ProfileModel get profile => _profile;
  bool get isLoaded => _isLoaded;
  bool get hasProfile => _profile.isComplete;

  Future<void> loadProfile() async {
    _profile = await _repo.getProfile();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required int age,
    required double heightCm,
    required double weightKg,
    required String gender,
    required String targetExamId,
  }) async {
    _profile = ProfileModel(
      name: name,
      age: age,
      heightCm: heightCm,
      weightKg: weightKg,
      gender: gender,
      targetExamId: targetExamId,
    );
    notifyListeners();
    await _repo.saveProfile(_profile);
  }

  Future<void> setTargetExam(String examId) async {
    _profile = _profile.copyWith(targetExamId: examId);
    notifyListeners();
    await _repo.saveProfile(_profile);
  }
}
