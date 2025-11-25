import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../l10n/l10n.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
// Assuming customPrimaryColor is accessible (from main.dart or similar)
import 'package:Glovox/main.dart';

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

  // --- NEW: Helper Widget for Custom Setting Item ---
// --- NEW: Helper Widget for Custom Setting Item ---
  Widget _buildSettingTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final Color primaryColor = customPrimaryColor;
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    // 1. Check if the app is currently in Dark Mode
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // 2. Define the icon color based on the mode
    final Color iconColor = isDarkMode ? Colors.white : primaryColor;

    // 3. Define the icon background color (more opaque white in dark mode)
    final Color iconBackgroundColor = isDarkMode
        ? Colors.white.withOpacity(0.15)
        : primaryColor.withOpacity(0.1);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          children: [
            // Icon Container (Visual Separator)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                // Use the new icon background color
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              // Use the new adaptive iconColor
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),

            // Text Content (rest of the content remains theme-aware)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: onSurfaceColor,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: onSurfaceColor.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),

            // Trailing Icon (remains subdued onSurface color)
            Icon(Icons.chevron_right, color: onSurfaceColor.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

// ... rest of the SettingsScreen class remains the same ...

  // --- NEW: Helper Widget for Segmented Card ---
  Widget _buildSegmentedCard({
    required BuildContext context,
    required List<Widget> children,
  }) {
    final Color cardColor = Theme.of(context).colorScheme.surfaceVariant;
    final Color onCardColor = Theme.of(context).colorScheme.onSurfaceVariant;

    // Add vertical dividers between items
    final List<Widget> itemsWithDividers = [];
    for (int i = 0; i < children.length; i++) {
      itemsWithDividers.add(children[i]);
      if (i < children.length - 1) {
        itemsWithDividers.add(Divider(
          height: 1,
          indent: 20,
          endIndent: 20,
          color: onCardColor.withOpacity(0.1),
        ));
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: itemsWithDividers,
      ),
    );
  }
  // ---------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        // --- ADDED: Set iconTheme to white for drawer/back buttons ---
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        toolbarHeight: 70,

        flexibleSpace: Container(
          decoration: BoxDecoration(
            // Apply the gradient using your colors
            gradient: LinearGradient(
              colors: [customPrimaryColor, gradientSecondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            // Optional: Add a subtle shadow for elevation effect
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),

        // --- MODIFIED: Apply TextStyle directly to the Text widget ---
        title: Text(
          l.settings,
          style: const TextStyle(
            color: Colors.white, // Set title text color to white
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18.0),
        children: [
          // Section Title
          Text(
            l.general, // Assuming 'General' localization exists
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Set title text color to white
                ),
          ),
          const SizedBox(height: 16),

          // --- Theme and Language Settings in a Segmented Card ---
          _buildSegmentedCard(
            context: context,
            children: [
              // 1. Theme Setting
              _buildSettingTile(
                context: context,
                title: l.theme,
                subtitle: _getThemeName(themeProvider.themeMode, l),
                icon: themeProvider.themeMode == ThemeMode.light
                    ? Icons.wb_sunny_outlined
                    : themeProvider.themeMode == ThemeMode.dark
                        ? Icons.brightness_2_outlined
                        : Icons.smartphone_outlined,
                onTap: () => _showThemePicker(context, l),
              ),

              // 2. Language Setting
              _buildSettingTile(
                context: context,
                title: l.language,
                subtitle:
                    L10n.getLanguageName(localeProvider.locale.languageCode),
                icon: Icons.language_outlined,
                onTap: () => _showLanguagePicker(context, l),
              ),
            ],
          ),

          // --- Example of another settings group ---
          Text(
            'App Info', // Placeholder text
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          _buildSegmentedCard(
            context: context,
            children: [
              _buildSettingTile(
                context: context,
                title: 'Version',
                subtitle: '1.0.3',
                icon: Icons.info_outline,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Helper Method for Theme Picker Dialog (Unchanged) ---
  void _showThemePicker(BuildContext context, AppLocalizations l) {
    final themeProvider = context.read<ThemeProvider>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // ... (Theme Picker Dialog logic remains the same)
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
                  Navigator.of(context).pop();
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
                  Navigator.of(context).pop();
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
                  Navigator.of(context).pop();
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

  // --- Helper Method for Language Picker Dialog (Unchanged) ---
  void _showLanguagePicker(BuildContext context, AppLocalizations l) {
    final localeProvider = context.read<LocaleProvider>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // ... (Language Picker Dialog logic remains the same)
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
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
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
}
