// lib/core/services/voice_coach_service.dart

import 'package:flutter_tts/flutter_tts.dart';

class VoiceCoachService {
  VoiceCoachService._internal();
  static final VoiceCoachService instance = VoiceCoachService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;
  bool _enabled = true;

  // Tracks which milestone announcements have already fired for current run
  bool _hasAnnouncedStart = false;
  bool _hasAnnouncedHalfway = false;
  bool _hasAnnounced30Sec = false;
  bool _hasAnnouncedComplete = false;

  Future<void> init() async {
    if (_isInitialized) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _isInitialized = true;
  }

  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  bool get isEnabled => _enabled;

  Future<void> _speak(String text) async {
    if (!_enabled) return;
    await init();
    await _tts.stop();
    await _tts.speak(text);
  }

  /// Resets milestone flags - call this when a new run starts
  void resetMilestones() {
    _hasAnnouncedStart = false;
    _hasAnnouncedHalfway = false;
    _hasAnnounced30Sec = false;
    _hasAnnouncedComplete = false;
  }

  Future<void> announceRunStarted() async {
    if (_hasAnnouncedStart) return;
    _hasAnnouncedStart = true;
    await _speak('Run started. Good luck!');
  }

  Future<void> announceHalfwayRemaining() async {
    if (_hasAnnouncedHalfway) return;
    _hasAnnouncedHalfway = true;
    await _speak('Half time remaining. Keep going!');
  }

  Future<void> announce30SecondsRemaining() async {
    if (_hasAnnounced30Sec) return;
    _hasAnnounced30Sec = true;
    await _speak('30 seconds remaining. Push hard!');
  }

  Future<void> announceRunCompleted() async {
    if (_hasAnnouncedComplete) return;
    _hasAnnouncedComplete = true;
    await _speak('Run completed. Great job!');
  }

  Future<void> announcePaused() async {
    await _speak('Run paused');
  }

  Future<void> announceResumed() async {
    await _speak('Run resumed');
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  Future<void> dispose() async {
    await _tts.stop();
  }
}
