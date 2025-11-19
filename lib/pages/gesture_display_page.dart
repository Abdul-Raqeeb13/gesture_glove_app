import 'package:flutter/material.dart';
import 'package:gesture_glove_app/providers/bluetooth_provider.dart';
import 'package:gesture_glove_app/providers/tts_provider.dart';
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
    final bool isConnected = btProvider.isConnected;

    final String gesture = btProvider.lastGesture;
    final bool isWaiting = gesture.isEmpty ||
        gesture.toLowerCase() == "none" ||
        gesture.toLowerCase() == "no gesture";

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Connection Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isConnected ? Colors.green : colorScheme.error,
                  width: 1.5,
                ),
                color: isConnected
                    ? Colors.green.withOpacity(0.1)
                    : colorScheme.error.withOpacity(0.1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isConnected
                        ? Icons.bluetooth_connected
                        : Icons.bluetooth_disabled,
                    color: isConnected ? Colors.green : colorScheme.error,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isConnected ? l.connected : l.disconnected,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isConnected
                                      ? Colors.green
                                      : colorScheme.error,
                                ),
                      ),
                      if (isConnected)
                        Text(
                          btProvider.connectedDeviceName,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Gesture Display Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l.lastGesture,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 8),
                if (ttsProvider.isTtsEnabled)
                  Icon(
                    Icons.volume_up_rounded,
                    color: colorScheme.primary,
                    size: 24,
                  )
                else
                  Icon(
                    Icons.volume_off_rounded,
                    color: colorScheme.onSurface.withOpacity(0.3),
                    size: 24,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Main Gesture Display
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: colorScheme.onSurface.withOpacity(0.05),
                border: Border.all(
                  color: isWaiting
                      ? colorScheme.outline.withOpacity(0.3)
                      : colorScheme.primary.withOpacity(0.7),
                  width: 1.5,
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child));
                },
                child: isWaiting
                    ? _buildWaitingState(context, l)
                    : _buildDetectedState(context, gesture, colorScheme),
              ),
            ),

            const SizedBox(height: 24),

            // Manual Speak Button
            if (!isWaiting && isConnected)
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      debugPrint("🔘 Manual Speak Button Pressed");
                      ttsProvider.speak(gesture);
                    },
                    icon: Icon(ttsProvider.isTtsEnabled
                        ? Icons.volume_up_outlined
                        : Icons.volume_off_outlined),
                    label: Text(ttsProvider.isTtsEnabled
                        ? "Speak Again"
                        : "TTS Disabled"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),

                  // Debug Info Panel
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Debug Info:",
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "• Gesture: \"$gesture\"",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          "• TTS Enabled: ${ttsProvider.isTtsEnabled}",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          "• Connected: $isConnected",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingState(BuildContext context, AppLocalizations l) {
    return Column(
      key: const ValueKey('waiting'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.back_hand_outlined,
          size: 100,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
        ),
        const SizedBox(height: 16),
        Text(
          "Waiting for gesture...",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.normal,
              ),
        ),
      ],
    );
  }

  Widget _buildDetectedState(
      BuildContext context, String gesture, ColorScheme colorScheme) {
    return Column(
      key: ValueKey('detected_$gesture'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.waving_hand_rounded,
          size: 100,
          color: colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            gesture,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
