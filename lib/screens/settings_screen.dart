import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../l10n/l10n.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Helper function to get the theme name from the ThemeMode enum
  String _getThemeName(ThemeMode themeMode, AppLocalizations l) {
    switch (themeMode) {
      case ThemeMode.light:
        return l.lightMode;
      case ThemeMode.dark:
        return l.darkMode;
      case ThemeMode.system:
        return l.systemDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the providers
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final l = AppLocalizations.of(context)!; // Get localization strings

    return Scaffold(
      appBar: AppBar(
        title: Text(l.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Theme Settings (Updated Layout) ---
          Text(l.theme, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(
                  color:
                      Theme.of(context).colorScheme.outline.withOpacity(0.5)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              _getThemeName(themeProvider.themeMode, l),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            // Show an icon that matches the current theme
            leading: Icon(
              themeProvider.themeMode == ThemeMode.light
                  ? Icons.wb_sunny
                  : themeProvider.themeMode == ThemeMode.dark
                      ? Icons.brightness_2
                      : Icons.smartphone,
            ),
            trailing: const Icon(Icons.keyboard_arrow_down),
            onTap: () {
              _showThemePicker(context, l);
            },
          ),
          const Divider(height: 40),

          // --- Language Settings (Improved Layout) ---
          Text(l.language, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(
                  color:
                      Theme.of(context).colorScheme.outline.withOpacity(0.5)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              L10n.getLanguageName(localeProvider.locale.languageCode),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            leading:
                const Icon(Icons.language), // Added an icon for consistency
            trailing: const Icon(Icons.keyboard_arrow_down),
            onTap: () {
              _showLanguagePicker(context, l);
            },
          ),
        ],
      ),
    );
  }

  // --- Helper Method for Theme Picker Dialog ---
  void _showThemePicker(BuildContext context, AppLocalizations l) {
    final themeProvider = context.read<ThemeProvider>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l.theme),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: Text(l.lightMode),
                value: ThemeMode.light,
                groupValue: themeProvider.themeMode,
                onChanged: (ThemeMode? newMode) {
                  if (newMode != null) {
                    themeProvider.setThemeMode(newMode);
                  }
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text(l.darkMode),
                value: ThemeMode.dark,
                groupValue: themeProvider.themeMode,
                onChanged: (ThemeMode? newMode) {
                  if (newMode != null) {
                    themeProvider.setThemeMode(newMode);
                  }
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text(l.systemDefault),
                value: ThemeMode.system,
                groupValue: themeProvider.themeMode,
                onChanged: (ThemeMode? newMode) {
                  if (newMode != null) {
                    themeProvider.setThemeMode(newMode);
                  }
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
          ],
        );
      },
    );
  }

  // --- Helper Method for Language Picker Dialog ---
  void _showLanguagePicker(BuildContext context, AppLocalizations l) {
    // We can 'read' the provider here, no need to pass it
    final localeProvider = context.read<LocaleProvider>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l.language),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: L10n.all.length,
              itemBuilder: (context, index) {
                final locale = L10n.all[index];
                final languageName = L10n.getLanguageName(locale.languageCode);
                return RadioListTile<Locale>(
                  title: Text(languageName),
                  value: locale,
                  groupValue: localeProvider.locale,
                  onChanged: (Locale? newLocale) {
                    if (newLocale != null) {
                      localeProvider.setLocale(newLocale);
                    }
                    Navigator.of(context).pop(); // Close the dialog
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              // Use the standard Material label for "Cancel"
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
          ],
        );
      },
    );
  }
}
