// lib/providers/settings_provider.dart

import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/services/voice_coach_service.dart';
import '../data/repositories/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repo = SettingsRepository();

  ThemeMode _themeMode = ThemeMode.system;
  bool _voiceEnabled = true;
  bool _notificationsEnabled = true;
  String _units = AppConstants.unitsKm;
  bool _isLoaded = false;

  ThemeMode get themeMode => _themeMode;
  bool get voiceEnabled => _voiceEnabled;
  bool get notificationsEnabled => _notificationsEnabled;
  String get units => _units;
  bool get isLoaded => _isLoaded;
  bool get isMiles => _units == AppConstants.unitsMiles;

  String get themeModeLabel {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  Future<void> loadSettings() async {
    final themeStr = await _repo.getThemeMode();
    _themeMode = _stringToThemeMode(themeStr);
    _voiceEnabled = await _repo.getVoiceEnabled();
    _notificationsEnabled = await _repo.getNotificationsEnabled();
    _units = await _repo.getUnits();

    VoiceCoachService.instance.setEnabled(_voiceEnabled);

    _isLoaded = true;
    notifyListeners();
  }

  ThemeMode _stringToThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _repo.setThemeMode(_themeModeToString(mode));
  }

  Future<void> setVoiceEnabled(bool value) async {
    _voiceEnabled = value;
    VoiceCoachService.instance.setEnabled(value);
    notifyListeners();
    await _repo.setVoiceEnabled(value);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
    await _repo.setNotificationsEnabled(value);
  }

  Future<void> setUnits(String units) async {
    _units = units;
    notifyListeners();
    await _repo.setUnits(units);
  }
}
