import 'package:flutter/material.dart';
import 'package:gesture_glove_app/providers/bluetooth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GestureDisplayPage extends StatelessWidget {
  const GestureDisplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final provider = context.watch<BluetoothProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final bool isConnected = provider.isConnected;

    // Condition for the gesture display
    final String gesture = provider.lastGesture;
    final bool isWaiting =
        gesture.isEmpty || gesture.toLowerCase() == l.none.toLowerCase();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- 1. Redesigned Connection Status ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isConnected ? Colors.green : colorScheme.error,
                  width: 1.5,
                ),
                // Add a subtle background color
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
                  // Use a Column for cleaner text alignment
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
                          provider.connectedDeviceName,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                  const Spacer(), // Pushes content to the left
                ],
              ),
            ),

            const SizedBox(height: 48),

            // --- 2. Redesigned Gesture Display ---
            Text(
              l.lastGesture, // Keep the original title
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // The main animated display card
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 250, // Give it a defined height
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: colorScheme.onSurface.withOpacity(0.05),
                border: Border.all(
                  // Border color changes with state
                  color: isWaiting
                      ? colorScheme.outline.withOpacity(0.3)
                      : colorScheme.primary.withOpacity(0.7),
                  width: 1.5,
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  // Fade and scale transition
                  return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child));
                },
                child: isWaiting
                    ? _buildWaitingState(context, l) // "Logo" state
                    : _buildDetectedState(context, gesture), // "Detected" state
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper widget for the "Waiting" state (this is your "logo")
  Widget _buildWaitingState(BuildContext context, AppLocalizations l) {
    // A dummy URL for your logo. Replace this with your real logo asset/URL.
    const String logoUrl =
        'https://placehold.co/100x100/transparent/888888?text=LOGO&font=lato';

    return Column(
      key: const ValueKey('waiting'), // Key for AnimatedSwitcher
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // --- Updated to show a Network Logo ---
        Image.network(
          logoUrl,
          width: 100,
          height: 100,
          // Add a loading builder for a modern feel
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child; // Image loaded
            return Container(
              width: 100,
              height: 100,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          // Add an error builder for robustness
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.broken_image_outlined, // Fallback icon
              size: 100,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            );
          },
        ),
        // --- End of update ---
        const SizedBox(height: 16),
        Text(
          l.none, // Use the "None" text as requested
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.normal,
              ),
        ),
      ],
    );
  }

  /// Helper widget for the "Detected" state
  Widget _buildDetectedState(BuildContext context, String gesture) {
    return Column(
      key: const ValueKey('detected'), // Key for AnimatedSwitcher
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.waving_hand_rounded, // Icon for detected
          size: 100,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          gesture.toUpperCase(), // Make it stand out
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
