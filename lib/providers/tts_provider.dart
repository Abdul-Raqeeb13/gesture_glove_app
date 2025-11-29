import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the Text-to-Speech (TTS) state and functionality.
class TtsProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  final FlutterTts _flutterTts = FlutterTts();
  static const _ttsEnabledKey = 'tts_enabled';
  static const _selectedVoiceKey = 'selected_voice_name';

  bool _isTtsEnabled = true;
  bool get isTtsEnabled => _isTtsEnabled;

  String? _currentVoiceId;
  String? get currentVoiceId => _currentVoiceId;

  String _currentLanguageCode = 'en';
  String get currentLanguageCode => _currentLanguageCode;

  List<Map<String, dynamic>> _availableVoices = [];
  List<Map<String, dynamic>> get availableVoices => _availableVoices;

  List<Map<String, dynamic>> _allVoices = [];
  List<Map<String, dynamic>> _urduVoices = [];
  List<Map<String, dynamic>> _englishVoices = [];

  TtsProvider(this._prefs) {
    _loadSettings();
    _setupTts();
  }

  void _loadSettings() {
    _isTtsEnabled = _prefs.getBool(_ttsEnabledKey) ?? true;
    _currentVoiceId = _prefs.getString(_selectedVoiceKey);
    debugPrint("✅ TTS Enabled: $_isTtsEnabled");
    notifyListeners();
  }

  Future<void> _setupTts() async {
    try {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);

      _flutterTts.setCompletionHandler(() {
        debugPrint("✅ TTS: Finished speaking");
      });

      _flutterTts.setErrorHandler((msg) {
        debugPrint("❌ TTS Error: $msg");
      });

      _flutterTts.setStartHandler(() {
        debugPrint("🔊 TTS: Started speaking");
      });

      debugPrint("✅ TTS Setup Complete");
    } catch (e) {
      debugPrint("❌ TTS Setup Error: $e");
    }
  }

  /// Load all voices at startup to cache them
  Future<void> loadAllVoices() async {
    try {
      debugPrint("═══════════════════════════════════════");
      debugPrint("🔍 LOADING ALL AVAILABLE VOICES...");
      debugPrint("═══════════════════════════════════════");

      List<dynamic> allVoices = await _flutterTts.getVoices;
      _allVoices = allVoices.map((v) => v as Map<String, dynamic>).toList();

      debugPrint("📊 Total voices found: ${_allVoices.length}");
      debugPrint("");

      // Print ALL voices for debugging
      for (var voice in _allVoices) {
        String name = voice['name'] ?? 'unknown';
        String locale = voice['locale'] ?? 'unknown';
        debugPrint("   🎤 Voice: $name");
        debugPrint("      Locale: $locale");
        debugPrint("");
      }

      // Cache Urdu voices - try multiple patterns
      _urduVoices = _allVoices.where((voice) {
        String locale = (voice['locale'] as String).toLowerCase();
        return locale.contains('ur') ||
            locale.contains('pk') ||
            locale.contains('pakistan');
      }).toList();

      // Cache English voices
      _englishVoices = _allVoices.where((voice) {
        String locale = (voice['locale'] as String).toLowerCase();
        return locale.contains('en');
      }).toList();

      debugPrint("═══════════════════════════════════════");
      debugPrint("✅ URDU VOICES FOUND: ${_urduVoices.length}");
      if (_urduVoices.isEmpty) {
        debugPrint("⚠️⚠️⚠️ NO URDU VOICES FOUND! ⚠️⚠️⚠️");
        debugPrint("📱 Your device does NOT have Urdu TTS installed!");
        debugPrint("📥 Please install Urdu voice data from:");
        debugPrint("   Settings → System → Language & Input");
        debugPrint("   → Text-to-Speech → Install voice data");
      } else {
        for (var voice in _urduVoices) {
          debugPrint("   ✅ ${voice['name']} (${voice['locale']})");
        }
      }
      debugPrint("═══════════════════════════════════════");
      debugPrint("✅ ENGLISH VOICES FOUND: ${_englishVoices.length}");
      for (var voice in _englishVoices.take(3)) {
        debugPrint("   ✅ ${voice['name']} (${voice['locale']})");
      }
      debugPrint("═══════════════════════════════════════");
    } catch (e) {
      debugPrint("❌ Error loading voices: $e");
    }
  }

  Future<void> loadVoices({String languageCode = 'en'}) async {
    _currentLanguageCode = languageCode;

    debugPrint("");
    debugPrint("🌍 LOADING VOICES FOR: $languageCode");

    // Get the appropriate cached voices
    if (languageCode == 'ur') {
      _availableVoices = _urduVoices;

      if (_availableVoices.isEmpty) {
        debugPrint("❌ NO URDU VOICES AVAILABLE!");
        debugPrint(
            "⚠️ TTS will speak in English because Urdu is not installed!");
        return;
      }

      await _flutterTts.setLanguage("ur-PK");
      debugPrint("✅ Set language to ur-PK");
    } else {
      _availableVoices = _englishVoices;
      await _flutterTts.setLanguage("en-US");
      debugPrint("✅ Set language to en-US");
    }

    if (_availableVoices.isNotEmpty) {
      await _setEngineVoice(_availableVoices.first);
    }

    notifyListeners();
  }

  Future<void> _setEngineVoice(Map<String, dynamic> voice) async {
    final String voiceName = voice['name'];
    final String locale = voice['locale'];

    debugPrint("🎤 Setting voice to: $voiceName ($locale)");

    await _flutterTts.setVoice({'name': voiceName, 'locale': locale});
    await _flutterTts.setLanguage(locale);

    _currentVoiceId = voiceName;
    await _prefs.setString(_selectedVoiceKey, voiceName);

    debugPrint("✅ Voice set successfully");
  }

  Future<void> setVoice(Map<String, dynamic> voice) async {
    await _setEngineVoice(voice);
    notifyListeners();
  }

  Future<void> toggleTts(bool value) async {
    _isTtsEnabled = value;
    await _prefs.setBool(_ttsEnabledKey, value);
    debugPrint("🔄 TTS Toggled to: $value");
    notifyListeners();
  }

  /// Speak with automatic language detection
  Future<void> speak(String text) async {
    if (!_isTtsEnabled) {
      debugPrint("🔇 TTS: Disabled, not speaking");
      return;
    }

    if (text.isEmpty ||
        text.toLowerCase() == "no gesture" ||
        text.toLowerCase() == "none") {
      debugPrint("⏭️ TTS: Skipping empty/none gesture");
      return;
    }

    try {
      // Detect language from text
      bool isUrduText = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
      String requiredLanguage = isUrduText ? 'ur' : 'en';

      debugPrint("");
      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      debugPrint("🔊 TTS SPEAK REQUEST");
      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      debugPrint("📝 Text: '$text'");
      debugPrint("🔍 Contains Urdu chars: $isUrduText");
      debugPrint(
          "🌍 Detected language: ${isUrduText ? 'URDU 🇵🇰' : 'ENGLISH 🇺🇸'}");
      debugPrint("📍 Current TTS language: $_currentLanguageCode");
      debugPrint("📍 Required language: $requiredLanguage");

      // Check if Urdu is available
      if (isUrduText && _urduVoices.isEmpty) {
        debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        debugPrint("❌ URDU TTS NOT AVAILABLE!");
        debugPrint(
            "⚠️ Speaking in English because Urdu voices are not installed");
        debugPrint("📥 Install Urdu TTS from device Settings");
        debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        // Fall back to English
        requiredLanguage = 'en';
      }

      // If language mismatch, reload voices
      if (_currentLanguageCode != requiredLanguage) {
        debugPrint("⚠️ LANGUAGE MISMATCH! Switching...");
        await loadVoices(languageCode: requiredLanguage);
      }

      // Set language and voice
      String targetLocale = isUrduText ? 'ur-PK' : 'en-US';
      await _flutterTts.setLanguage(targetLocale);
      debugPrint("✅ Set language: $targetLocale");

      if (_availableVoices.isNotEmpty) {
        final voice = _availableVoices.first;
        debugPrint("🎤 Using voice: ${voice['name']}");
        debugPrint("🌐 Voice locale: ${voice['locale']}");
        await _flutterTts
            .setVoice({'name': voice['name'], 'locale': voice['locale']});
      }

      // Small delay
      await Future.delayed(const Duration(milliseconds: 150));

      debugPrint("🔊 SPEAKING NOW...");
      await _flutterTts.speak(text);
      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    } catch (e) {
      debugPrint("❌ TTS speak error: $e");
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
