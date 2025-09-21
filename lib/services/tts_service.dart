// lib/services/tts_service.dart

import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

enum TtsState { playing, stopped, paused, continued }

class TTSService {
  static final TTSService instance = TTSService._init();
  late FlutterTts _flutterTts;
  bool _isInitialized = false;
  double _speechRate = 1.0;
  double _volume = 1.0;
  double _pitch = 1.0;

  final StreamController<TtsState> _ttsStateController = StreamController<TtsState>.broadcast();
  Stream<TtsState> get stateStream => _ttsStateController.stream;

  TTSService._init() {
    _initializeTTS();
  }

  Future<void> _initializeTTS() async {
    _flutterTts = FlutterTts();

    await _flutterTts.setLanguage('ja-JP');
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setVolume(_volume);
    await _flutterTts.setPitch(_pitch);

    // iOS specific settings
    if (!kIsWeb && Platform.isIOS) {
      await _flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          ],
          IosTextToSpeechAudioMode.voicePrompt
      );
    }

    // Set up listeners
    _flutterTts.setStartHandler(() {
      _ttsStateController.add(TtsState.playing);
    });

    _flutterTts.setCompletionHandler(() {
      _ttsStateController.add(TtsState.stopped);
    });

    _flutterTts.setErrorHandler((msg) {
      _ttsStateController.add(TtsState.stopped);
    });

    _isInitialized = true;
  }

  Future<void> speak(String text, {double? speed}) async {
    if (!_isInitialized) await _initializeTTS();

    if (speed != null) {
      await _flutterTts.setSpeechRate(speed);
    }

    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _ttsStateController.add(TtsState.stopped);
  }

  Future<void> pause() async {
    await _flutterTts.pause();
    _ttsStateController.add(TtsState.paused);
  }

  Future<void> setSpeed(double speed) async {
    _speechRate = speed.clamp(0.5, 2.0);
    await _flutterTts.setSpeechRate(_speechRate);
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _flutterTts.setVolume(_volume);
  }

  Future<void> setPitch(double pitch) async {
    _pitch = pitch.clamp(0.5, 2.0);
    await _flutterTts.setPitch(_pitch);
  }

  void dispose() {
    _flutterTts.stop();
    _ttsStateController.close();
  }
}