import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the Text-to-Speech (TTS) state and functionality.
class TtsProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  final FlutterTts _flutterTts = FlutterTts();
  static const _ttsEnabledKey = 'tts_enabled';

  bool _isTtsEnabled = false;
  bool get isTtsEnabled => _isTtsEnabled;

  TtsProvider(this._prefs) {
    _loadSettings();
    _setupTts();
  }

  /// Load the saved TTS setting from device storage.
  void _loadSettings() {
    _isTtsEnabled = _prefs.getBool(_ttsEnabledKey) ?? false;
    notifyListeners();
  }

  /// Configure the TTS engine.
  void _setupTts() {
    _flutterTts.setLanguage("en-US");
    _flutterTts.setPitch(1.0);
    _flutterTts.setSpeechRate(0.5);
  }

  /// Toggle the TTS setting and save it.
  Future<void> toggleTts(bool value) async {
    _isTtsEnabled = value;
    await _prefs.setBool(_ttsEnabledKey, value);
    notifyListeners();
  }

  /// Public method to speak a given text, if TTS is enabled.
  void speak(String text) {
    if (_isTtsEnabled) {
      _flutterTts.speak(text);
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
