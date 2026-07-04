// lib/data/repositories/profile_repository.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  Future<ProfileModel> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return ProfileModel(
      name: prefs.getString(AppConstants.prefProfileName) ?? '',
      age: prefs.getInt(AppConstants.prefProfileAge) ?? 0,
      heightCm: prefs.getDouble(AppConstants.prefProfileHeight) ?? 0.0,
      weightKg: prefs.getDouble(AppConstants.prefProfileWeight) ?? 0.0,
      gender: prefs.getString(AppConstants.prefProfileGender) ?? 'male',
      targetExamId:
          prefs.getString(AppConstants.prefTargetExam) ?? AppConstants.examSscGd,
    );
  }

  Future<void> saveProfile(ProfileModel profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefProfileName, profile.name);
    await prefs.setInt(AppConstants.prefProfileAge, profile.age);
    await prefs.setDouble(AppConstants.prefProfileHeight, profile.heightCm);
    await prefs.setDouble(AppConstants.prefProfileWeight, profile.weightKg);
    await prefs.setString(AppConstants.prefProfileGender, profile.gender);
    await prefs.setString(AppConstants.prefTargetExam, profile.targetExamId);
  }

  Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.prefOnboardingDone) ?? false;
  }

  Future<void> setOnboardingDone(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefOnboardingDone, value);
  }
}
