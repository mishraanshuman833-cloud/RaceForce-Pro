// lib/core/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'RaceForce Pro';
  static const String appVersion = '1.0.0';
  static const String developerName = 'Anshuman Mishra';
  static const String developerEmail = 'contact@anshumanmishra.dev';
  static const String appDescription =
      'Your official exam running companion. Train smart. Run fast. Clear the cut-off.';

  // SharedPreferences Keys
  static const String prefThemeMode = 'theme_mode';
  static const String prefVoiceEnabled = 'voice_enabled';
  static const String prefNotificationsEnabled = 'notifications_enabled';
  static const String prefUnits = 'units';
  static const String prefProfileName = 'profile_name';
  static const String prefProfileAge = 'profile_age';
  static const String prefProfileHeight = 'profile_height';
  static const String prefProfileWeight = 'profile_weight';
  static const String prefProfileGender = 'profile_gender';
  static const String prefTargetExam = 'target_exam';
  static const String prefOnboardingDone = 'onboarding_done';

  // Database
  static const String dbName = 'raceforce_pro.db';
  static const int dbVersion = 1;
  static const String tableRuns = 'runs';
  static const String tableRoutePoints = 'route_points';

  // Run Constants
  static const double metValueRunning = 9.8; // MET value for running
  static const double stepsPerKm = 1250.0; // approximate
  static const int locationIntervalMs = 1000; // 1 second
  static const double locationDistanceFilter = 5.0; // 5 meters

  // Units
  static const String unitsKm = 'km';
  static const String unitsMiles = 'miles';
  static const double kmToMiles = 0.621371;
  static const double milesToKm = 1.60934;

  // Voice Coach Triggers
  static const double voiceHalfwayFraction = 0.5;
  static const int voice30SecondsRemaining = 30;

  // GPS
  static const int gpsAccuracyThreshold = 50; // meters
  static const double minSpeedThreshold = 0.5; // m/s - filter GPS noise

  // Exam IDs
  static const String examSscGd = 'ssc_gd';
  static const String examUpPolice = 'up_police';
  static const String examDelhiPolice = 'delhi_police';
  static const String examCisf = 'cisf';
  static const String examCrpf = 'crpf';

  static const List<String> examList = [
    examSscGd,
    examUpPolice,
    examDelhiPolice,
    examCisf,
    examCrpf,
  ];

  static const Map<String, String> examDisplayNames = {
    examSscGd: 'SSC GD Constable',
    examUpPolice: 'UP Police Constable',
    examDelhiPolice: 'Delhi Police Constable',
    examCisf: 'CISF Constable',
    examCrpf: 'CRPF Constable',
  };
}
