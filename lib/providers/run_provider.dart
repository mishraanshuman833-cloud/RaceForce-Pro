// lib/providers/run_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';
import '../core/services/location_service.dart';
import '../core/services/step_counter_service.dart';
import '../core/services/voice_coach_service.dart';
import '../core/utils/calculation_utils.dart';
import '../data/models/run_model.dart';
import '../data/repositories/run_repository.dart';

enum RunState { idle, running, paused, finished }

class RunProvider extends ChangeNotifier {
  final RunRepository _runRepository = RunRepository();
  final LocationService _locationService = LocationService.instance;
  final StepCounterService _stepCounterService = StepCounterService.instance;
  final VoiceCoachService _voiceCoach = VoiceCoachService.instance;

  RunState _state = RunState.idle;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _timer;

  // Run data
  final List<RoutePoint> _routePoints = [];
  double _totalDistanceMeters = 0.0;
  int _elapsedSeconds = 0;
  double _currentSpeedMps = 0.0;
  double _maxSpeedMps = 0.0;
  Position? _lastPosition;
  DateTime? _runStartTime;
  DateTime? _pauseStartTime;
  int _totalPausedSeconds = 0;

  // Steps
  bool _stepsSupported = false;
  int _steps = 0;

  // Target duration for voice milestones (optional, set via setTargetDuration)
  int? _targetDurationSeconds;

  // Recent window for current pace calculation (last 10 seconds)
  final List<_DistanceTimeSample> _recentSamples = [];

  // External config
  double _userWeightKg = 70.0;
  String? _targetExamId;

  RunState get state => _state;
  bool get isRunning => _state == RunState.running;
  bool get isPaused => _state == RunState.paused;
  bool get isIdle => _state == RunState.idle;
  bool get isFinished => _state == RunState.finished;

  double get totalDistanceMeters => _totalDistanceMeters;
  int get elapsedSeconds => _elapsedSeconds;
  double get currentSpeedMps => _currentSpeedMps;
  double get maxSpeedMps => _maxSpeedMps;
  bool get stepsSupported => _stepsSupported;
  int get steps => _steps;
  List<RoutePoint> get routePoints => List.unmodifiable(_routePoints);

  double get averageSpeedMps =>
      CalculationUtils.calculateAverageSpeed(_totalDistanceMeters, _elapsedSeconds);

  double get averagePaceMps =>
      CalculationUtils.calculateAveragePace(_totalDistanceMeters, _elapsedSeconds);

  double get currentPaceMps {
    if (_recentSamples.length < 2) return _currentSpeedMps;
    final oldest = _recentSamples.first;
    final newest = _recentSamples.last;
    final distDelta = newest.distance - oldest.distance;
    final timeDelta = newest.timeSeconds - oldest.timeSeconds;
    if (timeDelta <= 0) return 0.0;
    return distDelta / timeDelta;
  }

  double get estimatedCalories => CalculationUtils.estimateCalories(
        weightKg: _userWeightKg,
        durationSeconds: _elapsedSeconds,
        avgSpeedMps: averageSpeedMps,
      );

  /// Configures the provider with profile data before starting a run.
  void configure({required double weightKg, String? targetExamId}) {
    _userWeightKg = weightKg > 0 ? weightKg : 70.0;
    _targetExamId = targetExamId;
  }

  /// Sets a target duration (seconds) to enable halfway / 30-sec voice cues.
  void setTargetDuration(int? seconds) {
    _targetDurationSeconds = seconds;
  }

  Future<LocationPermissionStatus> checkPermission() async {
    return await _locationService.checkAndRequestPermission();
  }

  Future<void> startRun() async {
    if (_state == RunState.running) return;

    _resetRunData();
    _state = RunState.running;
    _runStartTime = DateTime.now();
    notifyListeners();

    _voiceCoach.resetMilestones();
    await _voiceCoach.announceRunStarted();

    _startTimer();
    _startLocationTracking();
    await _startStepTracking();
  }

  void _resetRunData() {
    _routePoints.clear();
    _recentSamples.clear();
    _totalDistanceMeters = 0.0;
    _elapsedSeconds = 0;
    _currentSpeedMps = 0.0;
    _maxSpeedMps = 0.0;
    _lastPosition = null;
    _totalPausedSeconds = 0;
    _pauseStartTime = null;
    _steps = 0;
    _stepsSupported = false;
    _stepCounterService.reset();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_state != RunState.running) return;
      _elapsedSeconds++;
      _checkVoiceMilestones();
      notifyListeners();
    });
  }

  void _checkVoiceMilestones() {
    if (_targetDurationSeconds == null || _targetDurationSeconds! <= 0) return;
    final remaining = _targetDurationSeconds! - _elapsedSeconds;
    final halfway = _targetDurationSeconds! ~/ 2;

    if (_elapsedSeconds == halfway && halfway > 0) {
      _voiceCoach.announceHalfwayRemaining();
    }
    if (remaining == AppConstants.voice30SecondsRemaining) {
      _voiceCoach.announce30SecondsRemaining();
    }
    if (remaining <= 0) {
      _voiceCoach.announceRunCompleted();
    }
  }

  void _startLocationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription =
        _locationService.startPositionStream().listen((Position position) {
      if (_state != RunState.running) return;
      _processNewPosition(position);
    }, onError: (_) {
      // Silently handle stream errors; GPS may be temporarily unavailable.
    });
  }

  void _processNewPosition(Position position) {
    if (!_locationService.isAccuratePosition(position)) {
      return; // Filter out inaccurate GPS readings
    }

    final point = RoutePoint(
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: position.altitude,
      speed: position.speed < 0 ? 0.0 : position.speed,
      timestamp: DateTime.now(),
    );

    if (_lastPosition != null) {
      final distance = _locationService.calculateDistance(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      // Filter GPS jitter - ignore unrealistic jumps
      if (distance > 0.5 && distance < 100) {
        _totalDistanceMeters += distance;
      }
    }

    _lastPosition = position;
    _routePoints.add(point);

    // Update current speed (use GPS speed if valid, else 0)
    _currentSpeedMps = position.speed < 0 ? 0.0 : position.speed;
    if (_currentSpeedMps > _maxSpeedMps) {
      _maxSpeedMps = _currentSpeedMps;
    }

    // Track recent samples for current pace calc (keep last 10 seconds)
    _recentSamples.add(_DistanceTimeSample(
      distance: _totalDistanceMeters,
      timeSeconds: _elapsedSeconds,
    ));
    _recentSamples.removeWhere(
      (s) => _elapsedSeconds - s.timeSeconds > 10,
    );

    notifyListeners();
  }

  Future<void> _startStepTracking() async {
    final supported = await _stepCounterService.initialize(
      onStepUpdate: (steps) {
        _steps = steps;
        if (_state == RunState.running) {
          notifyListeners();
        }
      },
      onError: (_) {
        _stepsSupported = false;
        notifyListeners();
      },
    );
    _stepsSupported = supported;
    notifyListeners();
  }

  Future<void> pauseRun() async {
    if (_state != RunState.running) return;
    _state = RunState.paused;
    _pauseStartTime = DateTime.now();
    _timer?.cancel();
    await _voiceCoach.announcePaused();
    notifyListeners();
  }

  Future<void> resumeRun() async {
    if (_state != RunState.paused) return;
    if (_pauseStartTime != null) {
      _totalPausedSeconds +=
          DateTime.now().difference(_pauseStartTime!).inSeconds;
      _pauseStartTime = null;
    }
    _state = RunState.running;
    _startTimer();
    await _voiceCoach.announceResumed();
    notifyListeners();
  }

  /// Finalizes the run, saves to history, and returns the saved RunModel.
  Future<RunModel> finishRun() async {
    _state = RunState.finished;
    _timer?.cancel();
    await _positionSubscription?.cancel();
    await _stepCounterService.dispose();

    if (_elapsedSeconds > 0) {
      await _voiceCoach.announceRunCompleted();
    }

    final run = RunModel(
      id: const Uuid().v4(),
      date: _runStartTime ?? DateTime.now(),
      distanceMeters: _totalDistanceMeters,
      durationSeconds: _elapsedSeconds,
      avgPaceMps: averagePaceMps,
      avgSpeedMps: averageSpeedMps,
      maxSpeedMps: _maxSpeedMps,
      estimatedCalories: estimatedCalories,
      steps: _stepsSupported ? _steps : null,
      route: List.from(_routePoints),
      targetExamId: _targetExamId,
    );

    await _runRepository.saveRun(run);

    notifyListeners();
    return run;
  }

  /// Discards the current run without saving (e.g. user cancels).
  Future<void> discardRun() async {
    _timer?.cancel();
    await _positionSubscription?.cancel();
    await _stepCounterService.dispose();
    _state = RunState.idle;
    _resetRunData();
    notifyListeners();
  }

  /// Resets provider back to idle after viewing the finished summary.
  void resetToIdle() {
    _state = RunState.idle;
    _resetRunData();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionSubscription?.cancel();
    _stepCounterService.dispose();
    super.dispose();
  }
}

class _DistanceTimeSample {
  final double distance;
  final int timeSeconds;

  _DistanceTimeSample({required this.distance, required this.timeSeconds});
}
