import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:Glovox/main.dart';

/// ------------------------------------------------------------
/// FIXED: Drawer Header Painter must be OUTSIDE the widget class
/// ------------------------------------------------------------
class _DrawerHeaderCurvePainter extends CustomPainter {
  final Color baseColor;

  _DrawerHeaderCurvePainter(this.baseColor);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;

    // First curve
    paint.color = baseColor.withOpacity(0.5);
    final path1 = Path()
      ..moveTo(size.width * 0.7, 0)
      ..cubicTo(size.width * 0.9, size.height * 0.1, size.width,
          size.height * 0.3, size.width, size.height * 0.5)
      ..arcToPoint(Offset(size.width * 0.5, size.height * 0.9),
          radius: Radius.circular(size.width * 0.8), clockwise: false)
      ..lineTo(0, size.height)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(path1, paint);

    // Second curve
    paint.color = baseColor.withOpacity(0.7);
    final path2 = Path()
      ..moveTo(size.width * 0.3, 0)
      ..arcToPoint(Offset(size.width * 0.2, size.height * 0.2),
          radius: Radius.circular(size.width * 0.3), clockwise: true)
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

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _slide = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget animatedDrawerItem({
    required double start,
    required double end,
    required Widget child,
  }) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(-0.1, 0), end: Offset.zero)
            .animate(animation),
        child: child,
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isSelected = false,
  }) {
    final Color primaryColor = customPrimaryColor;
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? primaryColor : onSurfaceColor.withOpacity(0.7),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? primaryColor : onSurfaceColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final Color primaryColor = customPrimaryColor;

    const double headerHeight = 180.0;

    return Drawer(
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                // ---------------- HEADER ----------------
                SizedBox(
                  height: headerHeight,
                  child: Stack(
                    children: [
                      Container(
                        height: headerHeight,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.85),
                        ),
                        child: CustomPaint(
                          painter: _DrawerHeaderCurvePainter(primaryColor),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(180, 239, 239, 239),
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(120),
                                  bottomRight: Radius.circular(120),
                                ),
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  width: 120,
                                  height: 120,
                                ),
                              ),
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                    ],
                  ),
                ),

                // ---------------- ITEMS ----------------
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      animatedDrawerItem(
                        start: 0.2,
                        end: 0.4,
                        child: _buildDrawerItem(
                          context,
                          l.home,
                          Icons.home_outlined,
                          () =>
                              Navigator.pushReplacementNamed(context, '/home'),
                          isSelected:
                              ModalRoute.of(context)!.settings.name == '/home',
                        ),
                      ),
                      animatedDrawerItem(
                        start: 0.3,
                        end: 0.5,
                        child: _buildDrawerItem(
                          context,
                          l.learning,
                          Icons.search,
                          () => Navigator.pushNamed(context, '/learning'),
                          isSelected: ModalRoute.of(context)!.settings.name ==
                              '/learning',
                        ),
                      ),
                      animatedDrawerItem(
                        start: 0.4,
                        end: 0.6,
                        child: _buildDrawerItem(
                          context,
                          l.settings,
                          Icons.settings_outlined,
                          () => Navigator.pushNamed(context, '/settings'),
                          isSelected: ModalRoute.of(context)!.settings.name ==
                              '/settings',
                        ),
                      ),
                      const Divider(height: 1),
                      animatedDrawerItem(
                        start: 0.5,
                        end: 0.8,
                        child: _buildDrawerItem(
                          context,
                          l.bluetoothSettings,
                          Icons.bluetooth,
                          () => Navigator.pushNamed(context, '/bluetooth'),
                          isSelected: ModalRoute.of(context)!.settings.name ==
                              '/bluetooth',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
