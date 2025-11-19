import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the Text-to-Speech (TTS) state and functionality.
class TtsProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  final FlutterTts _flutterTts = FlutterTts();
  static const _ttsEnabledKey = 'tts_enabled';

  bool _isTtsEnabled = true; // Changed default to TRUE
  bool get isTtsEnabled => _isTtsEnabled;

  TtsProvider(this._prefs) {
    _loadSettings();
    _setupTts();
  }

  /// Load the saved TTS setting from device storage.
  void _loadSettings() {
    _isTtsEnabled = _prefs.getBool(_ttsEnabledKey) ?? true; // Default TRUE
    debugPrint("TTS Enabled: $_isTtsEnabled");
    notifyListeners();
  }

  /// Configure the TTS engine.
  Future<void> _setupTts() async {
    try {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);

      // Set up completion handler
      _flutterTts.setCompletionHandler(() {
        debugPrint("TTS: Finished speaking");
      });

      // Set up error handler
      _flutterTts.setErrorHandler((msg) {
        debugPrint("TTS Error: $msg");
      });

      // Set up start handler
      _flutterTts.setStartHandler(() {
        debugPrint("TTS: Started speaking");
      });

      debugPrint("TTS Setup Complete");
    } catch (e) {
      debugPrint("TTS Setup Error: $e");
    }
  }

  /// Toggle the TTS setting and save it.
  Future<void> toggleTts(bool value) async {
    _isTtsEnabled = value;
    await _prefs.setBool(_ttsEnabledKey, value);
    debugPrint("TTS Toggled to: $value");
    notifyListeners();
  }

  /// Public method to speak a given text, if TTS is enabled.
  Future<void> speak(String text) async {
    debugPrint("TTS speak() called with: '$text'");
    debugPrint("TTS is enabled: $_isTtsEnabled");

    // Filter out "No Gesture"
    if (text.isEmpty ||
        text.toLowerCase() == "no gesture" ||
        text.toLowerCase() == "none") {
      debugPrint("TTS: Ignoring '$text'");
      return;
    }

    if (_isTtsEnabled) {
      try {
        debugPrint("TTS: Speaking '$text'...");
        await _flutterTts.speak(text);
      } catch (e) {
        debugPrint("TTS speak error: $e");
      }
    } else {
      debugPrint("TTS: Disabled, not speaking");
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
