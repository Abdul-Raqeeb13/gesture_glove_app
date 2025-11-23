import 'package:flutter/material.dart';
import 'package:gesture_glove_app/providers/bluetooth_provider.dart';
import 'package:gesture_glove_app/providers/tts_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'my_app.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';

// 🎯 DEFINE THE CUSTOM COLOR GLOBALLY HERE
const Color customPrimaryColor = Color(0xFF023e7d);

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
  // 2. Create BluetoothProvider and give it the TtsProvider
  final bluetoothProvider = BluetoothProvider(ttsProvider);

  runApp(
    // Use MultiProvider to make providers available to the whole app
    MultiProvider(
      providers: [
        // --- Settings Providers ---
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(prefs),
        ),

        // --- App Logic Providers ---
        // Provide the instances we just created
        ChangeNotifierProvider.value(value: ttsProvider),
        ChangeNotifierProvider.value(value: bluetoothProvider),
      ],
      child: const MyApp(),
    ),
  );
}
