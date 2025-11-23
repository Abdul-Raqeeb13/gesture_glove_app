import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Needed for SystemOverlayStyle
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/app_drawer.dart';
import '../pages/gesture_display_page.dart'; // Import the new gesture page
// Assume customPrimaryColor is imported from here
import 'package:gesture_glove_app/main.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Check theme brightness to style status bar icons correctly
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Background color adapts to the overall theme
      backgroundColor: Theme.of(context).colorScheme.background,
      drawer: const AppDrawer(), // Keep the drawer

      appBar: AppBar(
        // Make AppBar transparent to let the custom header in the body (GestureDisplayPage) take over
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true, // Shows the drawer icon

        // Style the drawer and title to ensure they are visible against the dark header (customPrimaryColor)
        iconTheme: const IconThemeData(
          color: Colors.white, // Drawer icon color
        ),

        title: Text(
          AppLocalizations.of(context)!.appTitle,
          style: const TextStyle(color: Colors.white), // App title color
        ),

        // Set system status bar style for a modern, seamless look
        systemOverlayStyle: SystemUiOverlayStyle(
          // Make status bar icons light/dark depending on the current app background
          statusBarIconBrightness:
              isDarkMode ? Brightness.light : Brightness.dark,
          statusBarColor: Colors.transparent,
        ),
      ),

      // The GestureDisplayPage already contains the stylized, full-width content
      body: const GestureDisplayPage(),
    );
  }
}
