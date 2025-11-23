import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Assuming customPrimaryColor is a globally accessible variable/constant
import 'package:gesture_glove_app/main.dart';

// --- START: Modern Header Card Widget (Unchanged) ---

class _ModernHeaderCard extends StatelessWidget {
  final Color primaryColor;

  const _ModernHeaderCard(this.primaryColor);

  @override
  Widget build(BuildContext context) {
    final Color cardBackgroundColor = primaryColor.withOpacity(0.9);
    final Color cardContentColor = Theme.of(context).colorScheme.onPrimary;

    return Container(
      height: 180,
      margin: const EdgeInsets.only(bottom: 30.0),
      decoration: BoxDecoration(
        color: cardBackgroundColor, // Use the primary color prominently
        borderRadius: BorderRadius.circular(25.0),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative background element (Dribbble style curve)
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: cardContentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(75),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.waving_hand_rounded, // Central icon
                  color: cardContentColor,
                  size: 36,
                ),
                const SizedBox(height: 10),
                Text(
                  'Gesture Library',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cardContentColor,
                      ),
                ),
                Text(
                  'Master the hand signs to take full control.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cardContentColor.withOpacity(0.8),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- END: Modern Header Card Widget ---

// This page just shows what gestures are available.
// It's not connected to the glove, it's just a help page.
class LearningScreen extends StatelessWidget {
  const LearningScreen({super.key});

  // Helper method to create stylish, modern, and theme-aware gesture tiles
  Widget _buildGestureTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap, // Added onTap for interactivity
  }) {
    final Color primaryColor = customPrimaryColor;
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final Color cardColor = Theme.of(context).colorScheme.surfaceVariant;

    // Check for Dark Mode
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Adaptive Colors for Icon and Text
    final Color adaptiveIconColor = isDarkMode ? Colors.white : primaryColor;
    final Color adaptiveTextColor = isDarkMode ? Colors.white : onSurfaceColor;

    // Determine the shadow color based on the theme
    final Color shadowColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.transparent
        : Colors.black.withOpacity(0.08);

    return InkWell(
      // Use InkWell for better tap feedback
      onTap: onTap,
      borderRadius: BorderRadius.circular(15.0),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Increased padding
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Feature Icon Container
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  // Keep icon background primary colored
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                // Apply adaptive icon color
                child: Icon(icon, size: 28, color: adaptiveIconColor),
              ),
              const SizedBox(width: 16),

              // 2. Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600, // Medium bold
                            color:
                                adaptiveTextColor, // Apply adaptive text color
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: adaptiveTextColor.withOpacity(
                                0.7), // Apply adaptive subdued color
                          ),
                    ),
                  ],
                ),
              ),

              // 3. Arrow/Action Indicator (REMOVED)
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          l.gestureLearningTitle,
          style: const TextStyle(
            color: Colors.white, // Set title text color to white
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // 1. Dribbble-Style Header Card
            _ModernHeaderCard(customPrimaryColor),

            // --- Section Header: Training Focus ---
            Text(
              'Available Gestures',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
            const SizedBox(height: 16),

            // 2. Gesture List Tiles
            _buildGestureTile(
              context: context,
              icon: Icons.back_hand,
              title: l.gestureFist,
              subtitle: l.gestureFistDescription,
              onTap: () {
                // Implement navigation or modal for details
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Viewing Fist details...')));
              },
            ),
            _buildGestureTile(
              context: context,
              icon: Icons.sign_language,
              title: l.gesturePeace,
              subtitle: l.gesturePeaceDescription,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Viewing Peace details...')));
              },
            ),
            _buildGestureTile(
              context: context,
              icon: Icons.waving_hand,
              title: l.gestureHello,
              subtitle: l.gestureHelloDescription,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Viewing Wave details...')));
              },
            ),

            const SizedBox(height: 20),

            // --- Section Header: Quick Action ---
            Text(
              'Need Training?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
            const SizedBox(height: 10),

            // 3. Floating Action Button/Prompt Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Ready to pair and practice? Start the guided training now.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to the Connect Screen route
                      Navigator.of(context).pushNamed('/bluetooth');
                    },
                    icon: const Icon(Icons.bluetooth_connected),
                    label: const Text('Connect'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customPrimaryColor,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
