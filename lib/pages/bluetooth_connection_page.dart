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
  BluetoothDevice? connectingDevice; // <-- track the device being connected

  @override
  void dispose() {
    if (mounted) {
      Provider.of<BluetoothProvider>(context, listen: false).stopScan();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final provider = context.watch<BluetoothProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l.bluetoothSettings),
        actions: [
          // ---------- FIND DEVICES BUTTON ----------
          if (!provider.isConnected)
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: "Find Devices",
              onPressed: provider.isScanning
                  ? null
                  : () async {
                      setState(() => connectingDevice = null);
                      provider.requestPermissionsAndScan();
                    },
            ),
        ],
      ),
      body: Column(
        children: [
          // --- CURRENT CONNECTION STATUS ---
          if (provider.isConnected)
            _buildConnectionCard(context, l, provider)
          else
            _buildPermissionCard(context, l, provider),

          // --- DEVICE LIST ---
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
                : provider.availableDevices.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            l.noDevicesFound,
                            textAlign: TextAlign.center,
                          ),
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

  Widget _buildDeviceTile(
    BuildContext context,
    AppLocalizations l,
    BluetoothProvider provider,
    BluetoothDevice device,
  ) {
    final bool isThisOneConnecting =
        (connectingDevice?.address == device.address);

    return ListTile(
      leading: const Icon(Icons.bluetooth),
      title: Text(device.name ?? "Unknown Device"),
      subtitle: Text(device.address),
      trailing: isThisOneConnecting
          ? const SizedBox(
              width: 26, height: 26, child: CircularProgressIndicator())
          : ElevatedButton(
              child: Text(l.connect),
              onPressed: (connectingDevice != null) // disable other buttons
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
            child: Text(l.findDevices),
            onPressed: () {
              connectingDevice = null;
              provider.requestPermissionsAndScan();
            },
          ),
        ),
      );
    } else {
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
