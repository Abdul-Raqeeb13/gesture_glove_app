import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gesture_glove_app/main.dart';
import '../widgets/app_drawer.dart';
import '../pages/gesture_display_page.dart'; // Import the new gesture page

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          AppLocalizations.of(context)!.appTitle,
          style: const TextStyle(
            color: Colors.white, // Set title text color to white
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: const AppDrawer(), // Add the drawer

      // The GestureDisplayPage is the body
      body: const GestureDisplayPage(),
    );
  }
}
