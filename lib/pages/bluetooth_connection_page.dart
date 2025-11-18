// lib/pages/bluetooth_connection_page.dart

import 'package:flutter/material.dart';
import 'package:gesture_glove_app/providers/bluetooth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothConnectionPage extends StatefulWidget {
  const BluetoothConnectionPage({super.key});

  @override
  State<BluetoothConnectionPage> createState() =>
      _BluetoothConnectionPageState();
}

class _BluetoothConnectionPageState extends State<BluetoothConnectionPage> {
  // --- MODIFIED ---
  // 1. Add a variable to hold the provider
  late BluetoothProvider _bluetoothProvider;

  @override
  void initState() {
    super.initState();

    // --- MODIFIED ---
    // 2. Get the provider reference here (it's safe)
    // We use listen: false because we are not rebuilding in initState
    _bluetoothProvider = Provider.of<BluetoothProvider>(context, listen: false);

    // When this page loads, start scanning for devices
    // We use a post-frame callback to make sure the provider is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Use the saved variable
        _bluetoothProvider.requestPermissionsAndScan();
      }
    });
  }

  @override
  void dispose() {
    // When we leave this page, stop scanning to save battery

    // --- MODIFIED ---
    // 3. Use the saved variable. This is safe and doesn't use 'context'.
    _bluetoothProvider.stopScan();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    // We can still use context.watch() here to listen for UI changes
    final provider = context.watch<BluetoothProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l.bluetoothSettings),
      ),
      body: Column(
        children: [
          // --- CURRENT CONNECTION STATUS ---
          if (provider.isConnected)
            _buildConnectionCard(context, l, provider)
          else
            _buildPermissionCard(context, l, provider),

          // --- LIST OF AVAILABLE DEVICES ---
          Expanded(
            child: provider.isScanning
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(l.lookingForDevices),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: provider.requestPermissionsAndScan,
                    child: provider.availableDevices.isEmpty
                        ? Center(
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  l.noDevicesFound,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: provider.availableDevices.length,
                            itemBuilder: (context, index) {
                              final device = provider.availableDevices[index];
                              return _buildDeviceTile(
                                  context, l, provider, device);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceTile(
    BuildContext context,
    AppLocalizations l,
    BluetoothProvider provider,
    BluetoothDevice device,
  ) {
    return ListTile(
      leading: const Icon(Icons.bluetooth),
      title: Text(device.name ?? "Unknown Device"),
      subtitle: Text(device.address),
      trailing: provider.isConnecting
          ? const SizedBox(
              width: 24, height: 24, child: CircularProgressIndicator())
          : ElevatedButton(
              child: Text(l.connect),
              onPressed: () async {
                // Use the provider from the 'build' method here
                final success = await provider.connectToDevice(device);
                if (success && mounted) {
                  // Go back to the previous screen (home) after connecting
                  Navigator.of(context).pop();
                }
                // Handle connection failure (snackbar, etc.) if you want
              },
            ),
    );
  }

  Widget _buildConnectionCard(
      BuildContext context, AppLocalizations l, BluetoothProvider provider) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      color: Colors.green.withOpacity(0.1),
      child: ListTile(
        leading: const Icon(Icons.bluetooth_connected, color: Colors.green),
        title: Text(l.connected),
        subtitle: Text(provider.connectedDeviceName),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          child: Text(l.disconnect),
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
      return Card(
        margin: const EdgeInsets.all(16.0),
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: ListTile(
          leading: Icon(Icons.bluetooth_disabled,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
          title: Text(l.disconnected),
          trailing: ElevatedButton(
            child: Text(l.connect), // Changed from "Select Device"
            onPressed: () {
              provider.requestPermissionsAndScan();
            },
          ),
        ),
      );
    } else {
      // Permissions are denied
      return Card(
        margin: const EdgeInsets.all(16.0),
        color: Theme.of(context).colorScheme.errorContainer,
        child: ListTile(
          leading:
              Icon(Icons.warning, color: Theme.of(context).colorScheme.error),
          title: Text(l.permissionsDenied),
          subtitle: Text(l.pleaseGrantPermissions),
          trailing: IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              provider.openAppSettings();
            },
          ),
        ),
      );
    }
  }
}
