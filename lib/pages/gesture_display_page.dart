import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Glovox/main.dart';
import 'package:Glovox/providers/bluetooth_provider.dart';
import 'package:Glovox/providers/tts_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GestureDisplayPage extends StatefulWidget {
  const GestureDisplayPage({super.key});

  @override
  State<GestureDisplayPage> createState() => _GestureDisplayPageState();
}

class _GestureDisplayPageState extends State<GestureDisplayPage> {
  String _previousGesture = "";
  String _previousLanguage = "en";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final btProvider = context.watch<BluetoothProvider>();
    final ttsProvider = context.watch<TtsProvider>();
    final currentGesture = btProvider.lastGesture;
    final currentLanguage = ttsProvider.currentLanguageCode;

    // Check if gesture is valid
    final bool isValidGesture = currentGesture.isNotEmpty &&
        currentGesture.toLowerCase() != "none" &&
        currentGesture.toLowerCase() != "no gesture";

    // ✅ CRITICAL: Speak when gesture changes OR language changes
    final bool gestureChanged = currentGesture != _previousGesture;
    final bool languageChanged = currentLanguage != _previousLanguage;

    if (isValidGesture && (gestureChanged || languageChanged)) {
      _previousGesture = currentGesture;
      _previousLanguage = currentLanguage;

      // Get the localized text
      final localizedText = _getLocalizedGestureName(context, currentGesture);

      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      debugPrint("🔄 GESTURE CHANGED DETECTED");
      debugPrint("📝 Raw gesture: '$currentGesture'");
      debugPrint("🌍 Localized text: '$localizedText'");
      debugPrint("🗣️ Current TTS language: $currentLanguage");
      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      // ✅ Speak with delay to let TTS engine prepare
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          debugPrint("🔊 Speaking after delay: '$localizedText'");
          ttsProvider.speak(localizedText);
        }
      });
    }
  }

  String _getLocalizedGestureName(BuildContext context, String rawGesture) {
    final l = AppLocalizations.of(context)!;

    // 1. Normalize the incoming string (lowercase, trim spaces, remove exclamation marks)
    String gestureKey = rawGesture.toLowerCase().trim();
    gestureKey = gestureKey.replaceAll('!', '');
    gestureKey = gestureKey.replaceAll('?', ''); // Also remove question marks

    switch (gestureKey) {
      // --- Basic Gestures ---
      case 'fist':
        return l.gestureFist;
      case 'peace':
        return l.gesturePeace;
      case 'hello':
      case 'wave':
        return l.gestureHello;
      case 'none':
      case 'no gesture':
        return l.none;

      // --- Original Sentences ---
      case 'i':
        return l.gestureI;
      case 'need':
        return l.gestureNeed;
      case 'assalam alaikum':
      case 'salam':
        return l.gestureSalam;
      case 'thank you':
      case 'thanks':
        return l.gestureThanks;
      case 'i love you':
        return l.gestureLove;
      case 'i am happy':
        return l.gestureHappy;
      case 'i am sorry':
        return l.gestureSorry;
      case 'its fine':
        return l.gestureFine;
      case 'i need water':
        return l.gestureWater;
      case 'i need food':
        return l.gestureFood;
      case 'help me':
        return l.gestureHelp;
      case 'please come here':
        return l.gestureCome;
      case 'i want some rest':
        return l.gestureRest;
      case 'i am feeling fever':
        return l.gestureFever;
      case 'i dont understand':
        return l.gestureUnderstand;

      // --- 🌟 NEW GESTURES ADDED HERE 🌟 ---
      case 'i am sick':
        return l.gestureSick;
      case 'how are you':
        return l.gestureHowAreYou;
      case 'nice to meet you':
        return l.gestureNiceToMeet;
      case 'i am busy at that moment': // Note: Matches Arduino string exactly (after lowercasing)
        return l.gestureBusy;
      case 'i need to go to the washroom':
        return l.gestureWashroom;
      case 'you are looking very beautiful':
        return l.gestureBeautiful;
      case 'goodbye take care':
        return l.gestureGoodbye;

      // --- Default Fallback ---
      default:
        // If no match found, capitalize the raw string and show it.
        if (rawGesture.length > 1) {
          return "${rawGesture[0].toUpperCase()}${rawGesture.substring(1)}";
        }
        return rawGesture;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final btProvider = context.watch<BluetoothProvider>();
    final ttsProvider = context.watch<TtsProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    final String gesture = btProvider.lastGesture;
    final bool isWaiting = gesture.isEmpty ||
        gesture.toLowerCase() == "none" ||
        gesture.toLowerCase() == "no gesture";

    final headerColor = customPrimaryColor;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Column(
        children: [
          _buildTopHeader(context, l, btProvider, headerColor),
          Expanded(
            child: SingleChildScrollView(
              child: Transform.translate(
                offset: const Offset(0.0, -35.0),
                child: Container(
                  padding: const EdgeInsets.only(
                      top: 60.0, left: 24.0, right: 24.0, bottom: 60.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGestureHeader(
                          context, l, ttsProvider, btProvider, colorScheme),
                      const SizedBox(height: 24),
                      _buildGestureDisplayBox(
                          context, gesture, isWaiting, colorScheme),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader(
    BuildContext context,
    AppLocalizations l,
    BluetoothProvider btProvider,
    Color headerColor,
  ) {
    final isConnected = btProvider.isConnected;
    final statusColor =
        isConnected ? Colors.lightGreenAccent : Colors.redAccent;
    final statusIcon =
        isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled;
    final statusText = isConnected
        ? "Device: ${btProvider.connectedDeviceName}"
        : "Connect Device";

    return Container(
      width: double.infinity,
      height: 190,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: BoxDecoration(
        color: headerColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        gradient: LinearGradient(
          colors: [headerColor, headerColor.withOpacity(0.8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Welcome to Glovox",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  statusText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGestureHeader(
      BuildContext context,
      AppLocalizations l,
      TtsProvider ttsProvider,
      BluetoothProvider btProvider,
      ColorScheme colorScheme) {
    final String currentGesture = btProvider.lastGesture;
    final bool canSpeak = currentGesture.isNotEmpty &&
        currentGesture.toLowerCase() != "none" &&
        currentGesture.toLowerCase() != "no gesture";

    final primaryColor = customPrimaryColor;
    final isTtsEnabled = ttsProvider.isTtsEnabled;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          " Gesture Status",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: customPrimaryColor,
              ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Icon(
            ttsProvider.isTtsEnabled
                ? Icons.record_voice_over_rounded
                : Icons.volume_off_rounded,
            color: isTtsEnabled ? primaryColor : colorScheme.outline,
            size: 30,
          ),
          tooltip: isTtsEnabled ? "Replay: ${currentGesture}" : "TTS Disabled",
          onPressed: isTtsEnabled && canSpeak
              ? () {
                  final localizedText =
                      _getLocalizedGestureName(context, currentGesture);
                  debugPrint("🔊 Manual replay: '$localizedText'");
                  ttsProvider.speak(localizedText);
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildGestureDisplayBox(BuildContext context, String gesture,
      bool isWaiting, ColorScheme colorScheme) {
    final Color boxColor = colorScheme.surfaceVariant;
    final Color borderColor = colorScheme.outline.withOpacity(0.15);
    final Color shadowColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.transparent
        : Colors.black.withOpacity(0.1);

    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: boxColor,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: _buildGestureContent(context, gesture, isWaiting, colorScheme),
      ),
    );
  }

  Widget _buildGestureContent(BuildContext context, String gesture,
      bool isWaiting, ColorScheme colorScheme) {
    final Color iconColor =
        isWaiting ? customPrimaryColor.withOpacity(0.8) : customPrimaryColor;
    final Color textColor =
        isWaiting ? customPrimaryColor.withOpacity(0.8) : customPrimaryColor;
    final IconData icon =
        isWaiting ? Icons.watch_later_outlined : Icons.waving_hand_rounded;

    String text;
    if (isWaiting) {
      text = "Waiting for gesture ...";
    } else {
      text = _getLocalizedGestureName(context, gesture).toUpperCase();
    }

    final TextStyle textStyle =
        Theme.of(context).textTheme.titleLarge!.copyWith(
              color: textColor,
              fontWeight: isWaiting ? FontWeight.w500 : FontWeight.w700,
              fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
            );

    return Column(
      key: ValueKey('content_${isWaiting}_$gesture'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 110,
          color: iconColor,
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            text,
            style: textStyle,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
