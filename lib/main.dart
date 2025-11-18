import 'package:flutter/material.dart';
import 'package:gesture_glove_app/providers/bluetooth_provider.dart';
import 'package:gesture_glove_app/providers/tts_provider.dart';
import 'package:gesture_glove_app/services/database_service.dart'; // <-- ADD THIS
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'my_app.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';

void main() async {
  // Ensure widgets are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  // Load shared preferences to get saved settings
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // --- ADD THIS: Initialize the database ---
  await DatabaseService.init();
  // --- END ADD ---

  // --- Create providers that depend on each other ---
  // 1. Create TtsProvider first
  final ttsProvider = TtsProvider(prefs);

  // 2. Create BluetoothProvider. It no longer needs TtsProvider.
  //    (We will remove it in the next step)
  final bluetoothProvider =
      BluetoothProvider(ttsProvider); // <-- This will be changed

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
