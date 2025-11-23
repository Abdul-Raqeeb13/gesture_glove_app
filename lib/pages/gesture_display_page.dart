import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gesture_glove_app/providers/bluetooth_provider.dart';
import 'package:gesture_glove_app/providers/tts_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GestureDisplayPage extends StatelessWidget {
  const GestureDisplayPage({super.key});

  // Define a strong primary color (like the indigo/purple in the image)
  // We use this as a fallback if the theme doesn't provide a vibrant primary.
  static const Color _primaryHeaderColor = Color(0xFF673AB7); // Deep Purple

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final btProvider = context.watch<BluetoothProvider>();
    final ttsProvider = context.watch<TtsProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final bool isConnected = btProvider.isConnected;

    final String gesture = btProvider.lastGesture;
    final bool isWaiting = gesture.isEmpty ||
        gesture.toLowerCase() == "none" ||
        gesture.toLowerCase() == "no gesture";

    // Use a custom color for the header area
    final headerColor = colorScheme.primary;

    return Scaffold(
      // The background color of the scaffold serves as the visible border around the header
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
                offset: const Offset(0.0, -50.0), // Shift content up by 50px
                child: Container(
                  // *** MODIFIED: Increased top and bottom padding for visual security ***
                  padding: const EdgeInsets.only(
                      top: 60.0,
                      left: 24.0,
                      right: 24.0,
                      bottom: 60.0), // Increased top and bottom padding
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surface, // Light background for the card
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
                      _buildGestureHeader(context, l, ttsProvider, colorScheme),
                      const SizedBox(height: 24),

                      // NOTE: _buildGestureDisplayBox now uses fully static decoration
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

    // Logic for the dynamic status row at the bottom of the header
    final statusColor =
        isConnected ? Colors.lightGreenAccent : Colors.redAccent;
    final statusIcon =
        isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled;
    final statusText = isConnected
        ? "Device: ${btProvider.connectedDeviceName}"
        : "Connect Device"; // Custom disconnected text

    return Container(
      width: double.infinity,
      height: 220, // Fixed height for the header area
      padding: const EdgeInsets.fromLTRB(
          24, 60, 24, 24), // Use 60 for safe space below status bar
      decoration: BoxDecoration(
        color: headerColor,
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

          // Spacer ensures the middle area remains empty, pushing the status row down

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

  // --- MODIFIED: Restored title text, kept TTS icon alignment ---
  Widget _buildGestureHeader(BuildContext context, AppLocalizations l,
      TtsProvider ttsProvider, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title Text restored here
        Text(
          "Current Gesture Status",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
        ),
        Icon(
          ttsProvider.isTtsEnabled
              ? Icons.record_voice_over_rounded
              : Icons.volume_off_rounded,
          color: ttsProvider.isTtsEnabled
              ? colorScheme.primary
              : colorScheme.outline,
          size: 30,
        ),
      ],
    );
  }

  // --- MODIFIED: Unified Styling for Consistent Appearance (STATIC CONTAINER) ---
  Widget _buildGestureDisplayBox(BuildContext context, String gesture,
      bool isWaiting, ColorScheme colorScheme) {
    // Define a single, consistent aesthetic regardless of state
    const Color boxColor =
        Color.fromRGBO(240, 240, 245, 1); // Light subtle background
    final Color borderColor = colorScheme.outline.withOpacity(0.15);
    const Color shadowColor = Color.fromRGBO(0, 0, 0, 0.1);

    return Container(
      width: double.infinity,
      height: 280,
      // *** STATIC DECORATION ENSURING CONSISTENT LOOK ***
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: boxColor, // Static background color
        boxShadow: const [
          BoxShadow(
            color: shadowColor,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: borderColor, // Static border color
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
        isWaiting ? colorScheme.primary.withOpacity(0.5) : colorScheme.primary;

    // Text color: muted when waiting, vibrant when gesture detected
    final Color textColor =
        isWaiting ? colorScheme.primary.withOpacity(0.7) : colorScheme.primary;

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
