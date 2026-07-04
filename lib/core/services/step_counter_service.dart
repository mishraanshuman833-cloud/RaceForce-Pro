// lib/core/services/step_counter_service.dart

import 'dart:async';
import 'package:pedometer/pedometer.dart';

enum StepCounterStatus {
  available,
  unavailable,
  permissionDenied,
  unknown,
}

class StepCounterService {
  StepCounterService._internal();
  static final StepCounterService instance = StepCounterService._internal();

  StreamSubscription<StepCount>? _stepCountSubscription;
  int _initialSteps = -1;
  int _currentSteps = 0;
  StepCounterStatus _status = StepCounterStatus.unknown;

  StepCounterStatus get status => _status;
  int get currentSteps => _currentSteps;
  bool get isSupported => _status == StepCounterStatus.available;

  /// Attempts to initialize the step counter stream.
  /// Returns true if device supports step counting.
  Future<bool> initialize({
    required void Function(int steps) onStepUpdate,
    required void Function(String error) onError,
  }) async {
    _initialSteps = -1;
    _currentSteps = 0;

    final completer = Completer<bool>();
    bool resolved = false;

    try {
      _stepCountSubscription = Pedometer.stepCountStream.listen(
        (StepCount event) {
          if (_initialSteps < 0) {
            _initialSteps = event.steps;
            _status = StepCounterStatus.available;
            if (!resolved) {
              resolved = true;
              completer.complete(true);
            }
          }
          _currentSteps = event.steps - _initialSteps;
          if (_currentSteps < 0) _currentSteps = 0;
          onStepUpdate(_currentSteps);
        },
        onError: (error) {
          _status = StepCounterStatus.unavailable;
          onError(error.toString());
          if (!resolved) {
            resolved = true;
            completer.complete(false);
          }
        },
        cancelOnError: true,
      );

      // Timeout fallback - if no event fires within 3 seconds,
      // consider the sensor unavailable on this device.
      Future.delayed(const Duration(seconds: 3), () {
        if (!resolved) {
          resolved = true;
          _status = StepCounterStatus.unavailable;
          completer.complete(false);
        }
      });

      return await completer.future;
    } catch (e) {
      _status = StepCounterStatus.unavailable;
      onError(e.toString());
      return false;
    }
  }

  void reset() {
    _initialSteps = -1;
    _currentSteps = 0;
  }

  Future<void> dispose() async {
    await _stepCountSubscription?.cancel();
    _stepCountSubscription = null;
    _initialSteps = -1;
    _currentSteps = 0;
  }
}
