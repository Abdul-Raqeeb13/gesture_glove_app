import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// This class manages the app's theme (Dark, Light, System)
// and saves the user's choice to the device.
class ThemeProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  static const String _themeKey = 'themeMode';

  ThemeMode _themeMode = ThemeMode.dark; // Default to dark mode as requested

  ThemeProvider(this._prefs) {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;

  void _loadTheme() {
    final String? themeString = _prefs.getString(_themeKey);
    if (themeString == 'light') {
      _themeMode = ThemeMode.light;
    } else if (themeString == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (themeString == 'system') {
      _themeMode = ThemeMode.system;
    } else {
      // If nothing is saved, default to dark.
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners(); // Tell the app to rebuild with the new theme

    // Save the choice
    if (mode == ThemeMode.light) {
      await _prefs.setString(_themeKey, 'light');
    } else if (mode == ThemeMode.dark) {
      await _prefs.setString(_themeKey, 'dark');
    } else {
      await _prefs.setString(_themeKey, 'system');
    }
  }
}
