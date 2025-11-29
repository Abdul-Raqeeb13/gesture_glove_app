import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../l10n/l10n.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/tts_provider.dart';
import 'package:Glovox/main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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

  Widget _buildSettingTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final Color primaryColor = customPrimaryColor;
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color iconColor = isDarkMode ? Colors.white : primaryColor;
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
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
            Icon(Icons.chevron_right, color: onSurfaceColor.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedCard({
    required BuildContext context,
    required List<Widget> children,
  }) {
    final Color cardColor = Theme.of(context).colorScheme.surfaceVariant;
    final Color onCardColor = Theme.of(context).colorScheme.onSurfaceVariant;

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

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final ttsProvider = context.watch<TtsProvider>();
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        toolbarHeight: 70,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [customPrimaryColor, gradientSecondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        title: Text(
          l.settings,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18.0),
        children: [
          Text(
            l.general,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: customPrimaryColor,
                ),
          ),
          const SizedBox(height: 16),
          _buildSegmentedCard(
            context: context,
            children: [
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
              _buildSettingTile(
                context: context,
                title: l.language,
                subtitle:
                    L10n.getLanguageName(localeProvider.locale.languageCode),
                icon: Icons.language_outlined,
                onTap: () => _showLanguagePicker(context, l),
              ),
              _buildSettingTile(
                context: context,
                title: 'TTS Voice',
                subtitle: ttsProvider.currentVoiceId?.split('.').last ??
                    'Default Voice',
                icon: Icons.record_voice_over_outlined,
                onTap: () async {
                  if (ttsProvider.availableVoices.isEmpty) {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(
                            'Loading voices for ${localeProvider.locale.languageCode.toUpperCase()}...'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    await ttsProvider.loadVoices();
                    scaffoldMessenger.hideCurrentSnackBar();
                  }
                  if (ttsProvider.availableVoices.isNotEmpty) {
                    _showVoicePicker(context, ttsProvider);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'No voices found for the current language. Try changing the app language.')),
                    );
                  }
                },
              ),
              // ✅ NEW: Reload Voices Button
              _buildSettingTile(
                context: context,
                title: 'Reload TTS Voices',
                subtitle: 'Refresh after installing new language packs',
                icon: Icons.refresh_rounded,
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);

                  // Show loading
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 16),
                          Text('Reloading voices...'),
                        ],
                      ),
                      duration: Duration(seconds: 10),
                    ),
                  );

                  // Reload all voices
                  await ttsProvider.loadAllVoices();
                  await ttsProvider.loadVoices(
                      languageCode: localeProvider.locale.languageCode);

                  // Hide loading and show result
                  messenger.hideCurrentSnackBar();

                  final urduCount = ttsProvider.availableVoices.length;
                  final hasUrdu = localeProvider.locale.languageCode == 'ur' &&
                      urduCount > 0;

                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        hasUrdu
                            ? '✅ Success! Found $urduCount Urdu voice(s)'
                            : '⚠️ No Urdu voices found. Please install Urdu TTS from Android Settings.',
                      ),
                      backgroundColor: hasUrdu ? Colors.green : Colors.orange,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                },
              ),
            ],
          ),
          Text(
            'App Info',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: customPrimaryColor,
                ),
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

  void _showLanguagePicker(BuildContext context, AppLocalizations l) {
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

  void _showVoicePicker(BuildContext context, TtsProvider ttsProvider) {
    final voices = ttsProvider.availableVoices;
    if (voices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'No voices found or voices still loading. Please try again.')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select TTS Voice'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: voices.length,
              itemBuilder: (context, index) {
                final voice = voices[index];
                final String voiceName = voice['name'];
                String displayName = voiceName;
                if (voiceName.contains('.')) {
                  displayName = voiceName.split('.').last;
                }
                return RadioListTile<String>(
                  title: Text(displayName),
                  subtitle: Text(voice['locale'] ?? ''),
                  value: voiceName,
                  groupValue: ttsProvider.currentVoiceId,
                  onChanged: (String? newVoiceName) {
                    if (newVoiceName != null) {
                      final selectedVoice =
                          voices.firstWhere((v) => v['name'] == newVoiceName);
                      context.read<TtsProvider>().setVoice(selectedVoice);
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
