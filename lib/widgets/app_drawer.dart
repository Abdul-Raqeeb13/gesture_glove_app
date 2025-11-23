import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Assuming customPrimaryColor is a globally accessible variable/constant
import 'package:gesture_glove_app/main.dart';

// --- START: Helper function for Drawer Items (Theme-Aware) ---

Widget _buildDrawerItem(
  BuildContext context,
  String title,
  IconData icon,
  VoidCallback onTap, {
  bool isSelected = false,
  bool isSignout = false,
}) {
  // Use theme colors for adaptive styling
  final Color primaryColor = customPrimaryColor;
  final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;

  // Adaptive color for non-primary elements
  final Color defaultIconColor = onSurfaceColor.withOpacity(0.7);

  // Styling logic
  final Color selectedColor = primaryColor.withOpacity(0.1);
  final Color iconColor = isSelected ? primaryColor : defaultIconColor;
  final Color textColor = isSelected ? primaryColor : onSurfaceColor;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
    child: Material(
      // Background of selected item
      color: isSelected ? selectedColor : Colors.transparent,
      borderRadius: BorderRadius.circular(10.0),
      child: ListTile(
        leading: Icon(
          icon,
          color:
              isSignout ? defaultIconColor : iconColor, // Signout icon is muted
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    ),
  );
}

// --- START: Custom Painter for Curved Header ---

class _DrawerHeaderCurvePainter extends CustomPainter {
  final Color baseColor;

  _DrawerHeaderCurvePainter(this.baseColor);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;

    // First (larger, top-right) curve - lighter opacity
    paint.color = baseColor.withOpacity(0.5);
    final path1 = Path()
      ..moveTo(size.width * 0.7, 0)
      ..cubicTo(size.width * 0.9, size.height * 0.1, size.width,
          size.height * 0.3, size.width, size.height * 0.5)
      // FIX: Use size.width for radius to ensure correct scaling
      ..arcToPoint(Offset(size.width * 0.5, size.height * 0.9),
          radius: Radius.circular(size.width * 0.8), clockwise: false)
      ..lineTo(0, size.height)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(path1, paint);

    // Second (smaller, top-left) curve - slightly darker/more opaque
    paint.color = baseColor.withOpacity(0.7);
    final path2 = Path()
      ..moveTo(size.width * 0.3, 0)
      ..arcToPoint(Offset(size.width * 0.2, size.height * 0.2),
          radius: Radius.circular(size.width * 0.3), clockwise: true)
      // FIX: Use size.width for radius to ensure correct scaling
      ..arcToPoint(Offset(size.width * 0.1, size.height * 0.8),
          radius: Radius.circular(size.width * 0.5), clockwise: false)
      ..lineTo(0, size.height)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- END: Custom Painter for Curved Header ---

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  // Helper method for navigation logic
  void _navigateTo(BuildContext context, String routeName,
      {bool replace = false}) {
    Navigator.of(context).pop(); // Close the drawer first
    if (replace) {
      // Check to prevent pushing home if already there (for Home button)
      if (ModalRoute.of(context)!.settings.name != routeName) {
        Navigator.of(context).pushReplacementNamed(routeName);
      }
    } else {
      Navigator.of(context).pushNamed(routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    final Color primaryColor = customPrimaryColor;
    final Color onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final double headerHeight = 180.0;

    // Determine if we are in Dark Mode
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Set colors for the header content based on theme
    final Color headerTextColor = isDarkMode ? onPrimaryColor : Colors.black87;
    final Color avatarBackgroundColor =
        isDarkMode ? Colors.white : Colors.white.withOpacity(0.9);

    return Drawer(
      // Use the theme's surface color for the main drawer background
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            // 1. Stylish Drawer Header Section
            Stack(
              children: [
                // Background with the stylish curve
                Container(
                  height: headerHeight,
                  width: double.infinity,
                  // Use the primary color as the base for the header area
                  decoration:
                      BoxDecoration(color: primaryColor.withOpacity(0.85)),
                  child: CustomPaint(
                    painter: _DrawerHeaderCurvePainter(primaryColor),
                  ),
                ),

                // Header Content (Icon and Name 'Glovox')
                Container(
                  height: headerHeight,
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Profile/Icon Placeholder - Use Icon & Name 'Glovox'
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            // Theme-aware background for the avatar circle
                            backgroundColor: avatarBackgroundColor,
                            child: Icon(
                              Icons.settings_input_antenna,
                              size: 30,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Glovox', // Name requested
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white, // Adaptive color
                                    ),
                              ),
                              // View Profile text
                              Text(
                                'View Profile',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: primaryColor.withOpacity(0.9),
                                      decoration: TextDecoration.underline,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 2. Main Menu Items (Scrollable)
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // 1. Home
                  _buildDrawerItem(
                    context,
                    l.home,
                    Icons.home_outlined,
                    () => _navigateTo(context, '/home', replace: true),
                    isSelected:
                        ModalRoute.of(context)!.settings.name == '/home',
                  ),

                  // 2. Explore (Using learning from your original code)
                  _buildDrawerItem(
                    context,
                    l.learning, // Maps to 'Explore'
                    Icons.search,
                    () => _navigateTo(context, '/learning'),
                    isSelected:
                        ModalRoute.of(context)!.settings.name == '/learning',
                  ),

                  // 7. Settings
                  _buildDrawerItem(
                    context,
                    l.settings,
                    Icons.settings_outlined,
                    () => _navigateTo(context, '/settings'),
                    isSelected:
                        ModalRoute.of(context)!.settings.name == '/settings',
                  ),

                  // Separator for Bluetooth settings
                  Divider(
                    indent: 20,
                    endIndent: 20,
                    height: 1,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.1),
                  ),

                  // Bluetooth settings from your original code
                  _buildDrawerItem(
                    context,
                    l.bluetoothSettings,
                    Icons.bluetooth,
                    () => _navigateTo(context, '/bluetooth'),
                    isSelected:
                        ModalRoute.of(context)!.settings.name == '/bluetooth',
                  ),
                ],
              ),
            ),

            // 3. Signout Section (Fixed at bottom)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildDrawerItem(
                context,
                'Signout', // Placeholder text for Signout
                Icons.logout,
                () {
                  // Implement Signout logic here
                  Navigator.of(context).pop();
                },
                isSignout: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
