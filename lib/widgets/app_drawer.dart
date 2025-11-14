import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Text(
              l.appTitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(l.home),
            onTap: () {
              // Close the drawer
              Navigator.of(context).pop();

              // Go to home, but don't push it on top if we are already there
              if (ModalRoute.of(context)!.settings.name != '/home') {
                Navigator.of(context).pushReplacementNamed('/home');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.school), // "Learn" icon
            title: Text(l.learning),
            onTap: () {
              Navigator.of(context).pop();
              // Don't replace, just push so the user can go back
              Navigator.of(context).pushNamed('/learning');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(l.settings),
            onTap: () {
              Navigator.of(context).pop();
              // Don't replace, just push so the user can go back
              Navigator.of(context).pushNamed('/settings');
            },
          ),
          // --- THIS IS THE MISSING SECTION ---
          const Divider(), // Adds a visual separator
          ListTile(
            // <-- Fixed typo here
            leading: const Icon(Icons.bluetooth), // Bluetooth icon
            title: Text(l.bluetoothSettings),
            onTap: () {
              Navigator.of(context).pop();
              // Go to the Bluetooth connection page
              Navigator.of(context).pushNamed('/bluetooth');
            },
          ),
          // --- END OF MISSING SECTION ---
        ],
      ),
    );
  }
}
