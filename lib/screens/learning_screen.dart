import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// This page just shows what gestures are available.
// It's not connected to the glove, it's just a help page.
class LearningScreen extends StatelessWidget {
  const LearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    // Helper method to create consistent list tiles
    Widget _buildGestureTile({
      required IconData icon,
      required String title,
      required String subtitle,
    }) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: Icon(icon, size: 40, color: Theme.of(context).primaryColor),
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.gestureLearningTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildGestureTile(
            icon: Icons.back_hand, // Changed icon
            title: l.gestureFist,
            subtitle: l.gestureFistDescription,
          ),
          _buildGestureTile(
            icon: Icons.sign_language, // Changed icon
            title: l.gesturePeace,
            subtitle: l.gesturePeaceDescription,
          ),
          _buildGestureTile(
            icon: Icons.waving_hand, // Changed icon
            title: l.gestureHello,
            subtitle: l.gestureHelloDescription,
          ),
          // Add more gestures here as you program them
        ],
      ),
    );
  }
}
