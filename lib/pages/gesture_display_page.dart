import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Glovox/main.dart';
import 'package:Glovox/providers/bluetooth_provider.dart';
import 'package:Glovox/providers/tts_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GestureDisplayPage extends StatelessWidget {
  const GestureDisplayPage({super.key});

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

    // Use a custom color for the header area
    final headerColor = customPrimaryColor;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Column(
        children: [
          // 1. TOP HEADER SECTION (Large Colored Area - static)
          _buildTopHeader(context, l, btProvider, headerColor),

          // 2. EXPANDED SCROLLABLE CONTENT (Overlapping White Card)
          Expanded(
            child: SingleChildScrollView(
              // Using Transform.translate to lift the content card up and overlap the header
              child: Transform.translate(
                offset: const Offset(0.0, -35.0), // Shift content up by 50px
                child: Container(
                  padding: const EdgeInsets.only(
                      top: 60.0,
                      left: 24.0,
                      right: 24.0,
                      bottom: 60.0), // Increased top and bottom padding
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color:
                        colorScheme.surface, // Adaptive background for the card
                    // NOTE: This card MUST have rounded top corners
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
                      // Main content structure
                      _buildGestureHeader(context, l, ttsProvider, btProvider,
                          colorScheme), // Pass btProvider here
                      const SizedBox(height: 24),

                      // Gesture Display Box
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

  // --- DYNAMIC TOP HEADER WIDGET (Status and Greeting) ---
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
        : "Connect Device"; // Custom disconnected text

    return Container(
      width: double.infinity,
      height: 190, // Fixed height for the header area
      padding: const EdgeInsets.fromLTRB(
          24, 60, 24, 24), // Use 60 for safe space below status bar
      decoration: BoxDecoration(
        color: headerColor,
        // FIX: Add rounded corners to the bottom of the header container
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        // Added gradient for a richer look
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
          // 1. Static Welcome Text (Always visible at the top)
          Text(
            "Welcome to Glovox",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),

          // ADDED SMALL VERTICAL SPACE HERE
          const SizedBox(height: 8),

          // 2. Dynamic Connection Status Row (at the bottom of the blue header)
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

  // --- MODIFIED: Added btProvider to header arguments and made icon clickable ---
  Widget _buildGestureHeader(
      BuildContext context,
      AppLocalizations l,
      TtsProvider ttsProvider,
      BluetoothProvider btProvider,
      ColorScheme colorScheme) {
    // Logic to determine if a valid gesture is present
    final String currentGesture = btProvider.lastGesture;
    final bool canSpeak = currentGesture.isNotEmpty &&
        currentGesture.toLowerCase() != "none" &&
        currentGesture.toLowerCase() != "no gesture";

    final primaryColor = customPrimaryColor;
    final isTtsEnabled = ttsProvider.isTtsEnabled;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title Text restored here
        Text(
          " Gesture Status",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: customPrimaryColor,
              ),
        ),

        // 2. TTS STATUS ICON (Now clickable for replay)
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
                  // ACTION: Speak the current gesture word again
                  ttsProvider.speak(currentGesture);
                }
              : null, // Disable if TTS is off or no valid gesture is detected
        ),
      ],
    );
  }

  // --- MODIFIED: Unified Styling for Consistent Appearance (STATIC CONTAINER) ---
  Widget _buildGestureDisplayBox(BuildContext context, String gesture,
      bool isWaiting, ColorScheme colorScheme) {
    // Define a single, consistent aesthetic regardless of state
    final Color boxColor = colorScheme.surfaceVariant; // Adaptive surface color
    final Color borderColor = colorScheme.outline.withOpacity(0.15);
    final Color shadowColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.transparent
        : Colors.black.withOpacity(0.1);

    return Container(
      width: double.infinity,
      height: 280,
      // *** STATIC DECORATION ENSURING CONSISTENT LOOK ***
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: boxColor, // Adaptive background color
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: borderColor, // Adaptive border color
          width: 1.5,
        ),
      ),
      // *** FIXED: Clip to respect border radius ***
      clipBehavior: Clip.antiAlias,
      // Simple fade transition without layout changes
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

  // *** FIXED: Only text styling changes, box design stays the same ***
  Widget _buildGestureContent(BuildContext context, String gesture,
      bool isWaiting, ColorScheme colorScheme) {
    // Icon color: muted when waiting, vibrant when gesture detected
    final Color iconColor =
        isWaiting ? customPrimaryColor.withOpacity(0.8) : customPrimaryColor;

    // Text color: muted when waiting, vibrant when gesture detected
    final Color textColor =
        isWaiting ? customPrimaryColor.withOpacity(0.8) : customPrimaryColor;

    // Determine the icon and text to display
    final IconData icon =
        isWaiting ? Icons.watch_later_outlined : Icons.waving_hand_rounded;
    final String text =
        isWaiting ? "Waiting for gesture ..." : gesture.toUpperCase();

    // *** FIX: Dynamic text style - bold when gesture detected ***
    final TextStyle textStyle =
        Theme.of(context).textTheme.titleLarge!.copyWith(
              color: textColor,
              fontWeight: isWaiting
                  ? FontWeight.w500
                  : FontWeight.w700, // Bold when gesture active
              fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
            );

    return Column(
      key:
          ValueKey('content_${isWaiting}_$gesture'), // Key ensures switch works
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
