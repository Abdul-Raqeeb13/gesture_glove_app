import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/l10n.dart';

// This class manages the app's language and saves the
// user's choice.
class LocaleProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  static const String _localeKey = 'locale';

  Locale _locale = const Locale('en'); // Default to English

  LocaleProvider(this._prefs) {
    _loadLocale();
  }

  Locale get locale => _locale;

  void _loadLocale() {
    final String? localeString = _prefs.getString(_localeKey);
    if (localeString != null &&
        L10n.all.any((loc) => loc.languageCode == localeString)) {
      _locale = Locale(localeString);
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (!L10n.all.contains(locale)) return; // Only allow supported locales
    _locale = locale;
    notifyListeners(); // Tell the app to rebuild with the new language
    await _prefs.setString(_localeKey, locale.languageCode);
  }
}
