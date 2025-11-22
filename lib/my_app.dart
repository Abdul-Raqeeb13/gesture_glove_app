import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/l10n.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/learning_screen.dart';
import 'pages/bluetooth_connection_page.dart'; // <-- This is the fix

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch providers for changes
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      title: 'Glovox', // Updated title
      debugShowCheckedModeBanner: false,
      // --- Localization ---
      locale: localeProvider.locale,
      supportedLocales: L10n.all,
      localizationsDelegates: AppLocalizations.localizationsDelegates,

      // --- Theme ---
      themeMode: themeProvider.themeMode,

      // --- Light Theme (Pure White) ---
      theme: ThemeData(
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,

        // --- Overrides for "Pure White" look ---
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, // White app bar
          foregroundColor: Colors.black, // Black title and icons
          elevation: 0,
          scrolledUnderElevation: 0,
        ),

        // --- Modern ColorScheme ---
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue, // Your main brand color for buttons, etc.
          brightness: Brightness.light,
        ).copyWith(
          // Keep your original custom error colors
          error: Colors.red.shade700,
          errorContainer: Colors.red.shade100,
        ),
      ),

      // --- Dark Theme (Pure Black) ---
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,

        // --- Overrides for "Pure Black" look ---
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black, // Black app bar
          foregroundColor: Colors.white, // White title and icons
          elevation: 0,
          scrolledUnderElevation: 0,
        ),

        // --- Modern ColorScheme ---
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue, // Use *same* seed color for consistency
          brightness: Brightness.dark,
        ).copyWith(
          // Keep your original custom error colors
          error: Colors.red.shade300,
          errorContainer: const Color(0xFF5f1a1a),
        ),
      ),

      // --- Navigation (Routes) ---
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/learning': (context) => const LearningScreen(),
        '/bluetooth': (context) => const BluetoothConnectionPage(),
      },
    );
  }
}
