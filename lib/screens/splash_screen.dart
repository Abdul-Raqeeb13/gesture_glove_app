import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Define a custom primary color that matches the orange in the image
  static const Color _customOrange =
      Color(0xFFFF8C42); // A vibrant, soft orange

  @override
  void initState() {
    super.initState();
    // Navigate to the home screen after 5 seconds
    Timer(
      const Duration(seconds: 5),
      () {
        if (mounted) {
          // Replaces the splash screen with the home screen
          // so the user can't press "back" to go to it.
          Navigator.of(context).pushReplacementNamed('/home');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Set the background color to the custom orange
      backgroundColor: _customOrange,
      body: Stack(
        children: [
          // 2. Add visual elements (clouds/stars) for aesthetic appeal
          _buildBackgroundIllustration(),

          // 3. Centered Content (Logo, Text, Loader)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Custom Illustrated Logo Section (Inspired by the panda's wave)
                const _IllustratedLogo(
                  color: Colors.white,
                ),
                const SizedBox(height: 32),

                // App Title
                const Text(
                  "Glovox",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2.0,
                    shadows: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Loader (Styled to match the background)
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    color: Colors.white,
                    backgroundColor: Colors.white.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),

          // 4. Footer Text
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 50.0),
              child: Text(
                "Gesture Power", // A tagline
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Helper Widget for the Visual Illustration ---

class _IllustratedLogo extends StatelessWidget {
  final Color color;
  const _IllustratedLogo({required this.color});

  @override
  Widget build(BuildContext context) {
    // Replaces the panda with a waving/helpful hand/glove icon
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(
        Icons.waving_hand_rounded, // Use a welcoming gesture icon
        size: 120,
        color: _SplashScreenState
            ._customOrange, // Use the primary color for the icon
      ),
    );
  }
}

class _AnimatedCloud extends StatelessWidget {
  final double top;
  final double left;
  final Color color;

  const _AnimatedCloud(
      {required this.top, required this.left, required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: Icon(
        Icons.cloud,
        size: 150,
        color: color.withOpacity(0.4),
      ),
    );
  }
}

class _buildBackgroundIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use Positioned widgets to place clouds and stars like in the reference image
    return Stack(
      children: [
        // Clouds (Softly toned orange/white)
        const _AnimatedCloud(top: 80, left: 20, color: Colors.white),
        const _AnimatedCloud(top: 50, left: 150, color: Colors.white),

        // Stars/Sparkles
        _buildSparkle(150, 50),
        _buildSparkle(300, 200),
        _buildSparkle(100, 300),
      ],
    );
  }

  Widget _buildSparkle(double top, double right) {
    return Positioned(
      top: top,
      right: right,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.2),
        duration: const Duration(seconds: 2),
        curve: Curves.easeInOut,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: const Icon(Icons.star, size: 20, color: Colors.white70),
      ),
    );
  }
}
