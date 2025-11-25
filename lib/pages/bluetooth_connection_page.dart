import 'package:flutter/material.dart';
import 'package:Glovox/providers/bluetooth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:Glovox/main.dart'; // Ensure customPrimaryColor is imported

// NOTE: customPrimaryColor is assumed to be defined in main.dart and imported above.

class BluetoothConnectionPage extends StatefulWidget {
  const BluetoothConnectionPage({super.key});

  @override
  State<BluetoothConnectionPage> createState() =>
      _BluetoothConnectionPageState();
}

class _BluetoothConnectionPageState extends State<BluetoothConnectionPage> {
  BluetoothDevice? connectingDevice; // <-- track the device being connected

  @override
  void dispose() {
    if (mounted) {
      Provider.of<BluetoothProvider>(context, listen: false).stopScan();
    }
    super.dispose();
  }

  // Helper method to access customPrimaryColor (assuming it's defined globally)
  Color get _primaryColor => customPrimaryColor;

  // --- Adaptive Color Helpers ---
  bool get _isDarkMode => Theme.of(context).brightness == Brightness.dark;
  Color get _adaptiveContentColor =>
      _isDarkMode ? Colors.white : Theme.of(context).colorScheme.onBackground;
  Color get _adaptiveSubduedColor => _isDarkMode
      ? Colors.white.withOpacity(0.7)
      : Theme.of(context).colorScheme.onSurface.withOpacity(0.7);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final provider = context.watch<BluetoothProvider>();

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
          l.bluetoothSettings,
          style: const TextStyle(
            color: Colors.white, // Set title text color to white
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- CURRENT CONNECTION STATUS ---
          if (provider.isConnected)
            _buildConnectionCard(context, l, provider)
          else
            _buildPermissionCard(context, l, provider),

          // --- DEVICE LIST HEADER (Styled) ---
          Padding(
            padding: const EdgeInsets.only(left: 18.0, top: 16.0, bottom: 8.0),
            child: Text(
              'Available Devices',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _adaptiveContentColor,
                  ),
            ),
          ),

          // --- DEVICE LIST / STATUS VIEW ---
          Expanded(
            child: provider.isScanning
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: _primaryColor),
                        const SizedBox(height: 16),
                        Text(l.lookingForDevices,
                            style: TextStyle(color: _adaptiveContentColor)),
                      ],
                    ),
                  )
                : provider.availableDevices.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(l.noDevicesFound,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(color: _adaptiveSubduedColor)),
                        ),
                      )
                    : ListView.builder(
                        itemCount: provider.availableDevices.length,
                        itemBuilder: (context, index) {
                          final device = provider.availableDevices[index];
                          return _buildDeviceTile(context, l, provider, device);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // --- STYLISH HELPER METHODS ---

  Widget _buildDeviceTile(
    BuildContext context,
    AppLocalizations l,
    BluetoothProvider provider,
    BluetoothDevice device,
  ) {
    final bool isThisOneConnecting =
        (connectingDevice?.address == device.address);
    final Color primaryColor = _primaryColor;

    // Adaptive colors:
    final Color adaptiveTextColor =
        _isDarkMode ? Colors.white : Theme.of(context).colorScheme.onSurface;
    final Color defaultIconColor =
        _isDarkMode ? Colors.white : Theme.of(context).colorScheme.onSurface;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: isThisOneConnecting
            ? primaryColor.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        leading: Icon(
          Icons.bluetooth,
          color: isThisOneConnecting
              ? primaryColor
              : defaultIconColor.withOpacity(0.7), // Icon color is adaptive
        ),
        title: Text(
          device.name ?? "Unknown Device",
          style: TextStyle(
              fontWeight: FontWeight.w500,
              color: adaptiveTextColor), // Text color is adaptive
        ),
        subtitle: Text(
          device.address,
          style: TextStyle(
              color:
                  adaptiveTextColor.withOpacity(0.6)), // Subdued adaptive color
        ),
        trailing: isThisOneConnecting
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: primaryColor))
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  // FIX: Ensure button text is white in Dark Mode by using Colors.white
                  // or relying on onPrimary, which is the desired fallback here.
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  elevation: 0, // Flat design
                ),
                child: Text(l.connect), // Connect button text is adaptive
                onPressed: (connectingDevice != null)
                    ? null
                    : () async {
                        setState(() => connectingDevice = device);
                        final success = await provider.connectToDevice(device);
                        if (success && mounted) {
                          Navigator.of(context).pop();
                        }
                        setState(() => connectingDevice = null);
                      },
              ),
      ),
    );
  }

  Widget _buildConnectionCard(
      BuildContext context, AppLocalizations l, BluetoothProvider provider) {
    final successColor = Colors.green.shade400;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)), // Stylish rounded card
      color: successColor.withOpacity(0.1), // Subtle green background
      child: ListTile(
        leading: Icon(Icons.bluetooth_connected, color: successColor, size: 30),
        title: Text(l.connected,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w600,
                color: _adaptiveContentColor)), // Title text is adaptive
        subtitle: Text(provider.connectedDeviceName,
            style: TextStyle(
                color: _adaptiveSubduedColor)), // Subtitle text is adaptive
        trailing: ElevatedButton.icon(
          // Used icon button for disconnect
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          icon: const Icon(Icons.close, size: 18),
          label: Text(l.disconnect),
          onPressed: () {
            provider.disconnect();
          },
        ),
      ),
    );
  }

  Widget _buildPermissionCard(
      BuildContext context, AppLocalizations l, BluetoothProvider provider) {
    if (provider.permissionsGranted) {
      // Disconnected Card (Ready to Scan)
      return Card(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: ListTile(
          leading: Icon(Icons.bluetooth_disabled,
              color: _isDarkMode ? Colors.white : _primaryColor,
              size: 30), // Icon color is adaptive
          title: Text(l.disconnected,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _adaptiveContentColor)), // Title text is adaptive
          trailing: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              // FIX: Ensure button text is white in Dark Mode
              foregroundColor: _isDarkMode
                  ? Colors.white
                  : Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(l.findDevices), // Find Devices button text is adaptive
            onPressed: () {
              connectingDevice = null;
              provider.requestPermissionsAndScan();
            },
          ),
        ),
      );
    } else {
      // Permissions Denied Card (Warning)
      return Card(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: Theme.of(context).colorScheme.errorContainer,
        child: ListTile(
          leading: Icon(Icons.warning,
              color: Theme.of(context).colorScheme.error, size: 30),
          title: Text(l.permissionsDenied,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _adaptiveContentColor)), // Title text is adaptive
          subtitle: Text(l.pleaseGrantPermissions,
              style: TextStyle(
                  color: _adaptiveSubduedColor)), // Subtitle text is adaptive
          trailing: IconButton(
            icon: Icon(Icons.settings,
                color: Theme.of(context).colorScheme.error),
            onPressed: () {
              provider.openAppSettings();
            },
          ),
        ),
      );
    }
  }
}
