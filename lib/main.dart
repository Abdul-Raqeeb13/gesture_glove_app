import 'package:flutter/material.dart';
import 'package:Glovox/providers/bluetooth_provider.dart';
import 'package:Glovox/providers/tts_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'my_app.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';

// 🎯 DEFINE THE CUSTOM COLOR GLOBALLY HERE
const Color customPrimaryColor = Color(0xFF23BFA7);
// const Color customPrimaryColor = Color(0xFF023e7d);

const Color gradientSecondaryColor =
    Color.fromARGB(255, 52, 154, 138); // Your desired secondary color

void main() async {
  // Ensure widgets are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  // Load shared preferences to get saved settings
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // ✅ FORCE ENABLE TTS - THIS IS THE FIX!
  await prefs.setBool('tts_enabled', true);
  debugPrint("🔧 MAIN: Force enabled TTS in SharedPreferences");

  // --- Create providers that depend on each other ---
  // 1. Create TtsProvider first
  final ttsProvider = TtsProvider(prefs);
  // 2. Create LocaleProvider
  final localeProvider = LocaleProvider(prefs);
  // 3. Create BluetoothProvider and give it the TtsProvider
  final bluetoothProvider = BluetoothProvider(ttsProvider);

  // ✅ CRITICAL: Load ALL voices at startup (both Urdu and English)
  debugPrint("🔄 MAIN: Loading all voices at startup...");
  await ttsProvider.loadAllVoices();
  debugPrint("✅ MAIN: All voices cached successfully");

  // --- Initialize TTS voices for the starting locale ---
  // This ensures voices are ready immediately after app start
  debugPrint(
      "🔄 MAIN: Setting initial language to ${localeProvider.locale.languageCode}");
  await ttsProvider.loadVoices(
      languageCode: localeProvider.locale.languageCode);
  debugPrint(
      "✅ MAIN: Initial TTS voices loaded for ${localeProvider.locale.languageCode}");

  // --- NEW: Add Listener for Locale Changes to load voices ---
  localeProvider.addListener(() {
    final newLang = localeProvider.locale.languageCode;
    debugPrint("🌍 MAIN: Locale changed to $newLang");
    debugPrint("🔄 MAIN: Switching TTS voices to $newLang...");
    // When the locale changes, reload the available voices for the new language.
    ttsProvider.loadVoices(languageCode: newLang);
  });

  runApp(
    // Use MultiProvider to make providers available to the whole app
    MultiProvider(
      providers: [
        // --- Settings Providers ---
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(prefs),
        ),
        // Provide the LocaleProvider instance we created
        ChangeNotifierProvider.value(value: localeProvider),

        // --- App Logic Providers ---
        // Provide the instances we just created
        ChangeNotifierProvider.value(value: ttsProvider),
        ChangeNotifierProvider.value(value: bluetoothProvider),
      ],
      child: const MyApp(),
    ),
  );
}
