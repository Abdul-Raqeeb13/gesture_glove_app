import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/app_drawer.dart';
// UPDATED IMPORT:
import '../pages/gesture_display_page.dart'; // Import the new gesture page

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        elevation: 0, // Modern flat look
      ),
      drawer: const AppDrawer(), // Add the drawer

      // UPDATED BODY:
      // We use the new GestureDisplayPage here.
      body: const GestureDisplayPage(),
    );
  }
}
