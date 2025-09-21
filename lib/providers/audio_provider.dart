// lib/providers/audio_provider.dart

import 'package:flutter/material.dart';
import '../services/tts_service.dart';

class AudioProvider extends ChangeNotifier {
  final TTSService _ttsService = TTSService.instance;
  double _playbackSpeed = 1.0;
  bool _isPlaying = false;
  String? _currentText;

  double get playbackSpeed => _playbackSpeed;
  bool get isPlaying => _isPlaying;
  String? get currentText => _currentText;

  AudioProvider() {
    _initAudio();
  }

  void _initAudio() {
    _ttsService.stateStream.listen((state) {
      _isPlaying = state == TtsState.playing;
      if (state == TtsState.stopped) {
        _currentText = null;
      }
      notifyListeners();
    });
  }

  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed.clamp(0.5, 2.0);
    _ttsService.setSpeed(_playbackSpeed);
    notifyListeners();
  }

  Future<void> playText(String text) async {
    if (_isPlaying && _currentText == text) {
      await stop();
      return;
    }

    _currentText = text;
    _isPlaying = true;
    notifyListeners();

    try {
      await _ttsService.speak(text, speed: _playbackSpeed);
    } catch (e) {
      debugPrint('Error playing audio: $e');
      _isPlaying = false;
      _currentText = null;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    await _ttsService.stop();
    _isPlaying = false;
    _currentText = null;
    notifyListeners();
  }

  Future<void> pause() async {
    await _ttsService.pause();
    _isPlaying = false;
    notifyListeners();
  }

  void increaseSpeed() {
    setPlaybackSpeed(_playbackSpeed + 0.25);
  }

  void decreaseSpeed() {
    setPlaybackSpeed(_playbackSpeed - 0.25);
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }
}