import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const Color _customOrange = Color.fromARGB(255, 120, 224, 209);

  late AnimationController _logoController;
  late Animation<double> _fadeAnimation;

  late AnimationController _cloudController;
  late Animation<double> _cloudAnimation1;
  late Animation<double> _cloudAnimation2;

  @override
  void initState() {
    super.initState();

    // Navigate to home after 5 seconds
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });

    // Blinking logo animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );
    _logoController.repeat(reverse: true);

    // Clouds animation (horizontal movement)
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _cloudAnimation1 = Tween<double>(begin: -100, end: 400).animate(
      CurvedAnimation(parent: _cloudController, curve: Curves.linear),
    );

    _cloudAnimation2 = Tween<double>(begin: 400, end: -100).animate(
      CurvedAnimation(parent: _cloudController, curve: Curves.linear),
    );

    _cloudController.repeat();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _cloudController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _customOrange,
      body: Stack(
        children: [
          // Background: animated clouds & stars
          AnimatedBuilder(
            animation: _cloudController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: 80,
                    left: _cloudAnimation1.value,
                    child: const Icon(
                      Icons.cloud,
                      size: 150,
                      color: Colors.white70,
                    ),
                  ),
                  Positioned(
                    top: 580,
                    left: _cloudAnimation2.value,
                    child: const Icon(
                      Icons.cloud,
                      size: 150,
                      color: Colors.white70,
                    ),
                  ),
                  _buildSparkle(150, 50),
                  _buildSparkle(700, 300),
                ],
              );
            },
          ),

          // Centered blinking logo
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 280,
                    height: 280,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),

          // Footer
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: Text(
                "POWERED BY HAZURA",
                style: TextStyle(
                  color: Color.fromARGB(179, 0, 0, 0),
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

  Widget _buildSparkle(double top, double right) {
    return Positioned(
      top: top,
      right: right,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.2),
        duration: const Duration(seconds: 2),
        curve: Curves.easeInOut,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: const Icon(Icons.star, size: 20, color: Colors.white70),
      ),
    );
  }
}
