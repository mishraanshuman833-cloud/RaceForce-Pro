// lib/data/repositories/settings_repository.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class SettingsRepository {
  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.prefThemeMode) ?? 'system';
  }

  Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefThemeMode, mode);
  }

  Future<bool> getVoiceEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.prefVoiceEnabled) ?? true;
  }

  Future<void> setVoiceEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefVoiceEnabled, value);
  }

  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.prefNotificationsEnabled) ?? true;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefNotificationsEnabled, value);
  }

  Future<String> getUnits() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.prefUnits) ?? AppConstants.unitsKm;
  }

  Future<void> setUnits(String units) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefUnits, units);
  }
}
