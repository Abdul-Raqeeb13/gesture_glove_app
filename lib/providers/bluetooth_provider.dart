import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:gesture_glove_app/providers/tts_provider.dart';
// Import with a prefix to avoid name conflicts
import 'package:permission_handler/permission_handler.dart' as perm_handler;

/// This class manages the entire Bluetooth state for the app.
/// - Handles permissions
/// - Scans for devices
/// - Connects and disconnects
/// - Listens for incoming data (gestures)
/// - Notifies all listeners (like GestureDisplayPage) of changes.
class BluetoothProvider with ChangeNotifier {
  final TtsProvider _ttsProvider;

  BluetoothProvider(this._ttsProvider) {
    _initBluetooth();
  }

  // --- Private State ---
  BluetoothConnection? _connection;
  BluetoothDevice? _connectedDevice;
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  StreamSubscription<BluetoothDiscoveryResult>? _scanSubscription;
  StreamSubscription<Uint8List>? _dataSubscription;
  String _dataBuffer = ''; // To handle data that arrives in chunks

  // --- Public State (Notifiers) ---
  bool _permissionsGranted = false;
  bool get permissionsGranted => _permissionsGranted;

  bool _isConnecting = false;
  bool get isConnecting => _isConnecting;

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  bool get isConnected => _connection != null && _connection!.isConnected;

  String get connectedDeviceName => _connectedDevice?.name ?? "Unknown Device";

  List<BluetoothDevice> _availableDevices = [];
  List<BluetoothDevice> get availableDevices => _availableDevices;

  String _lastGesture = "";
  String get lastGesture => _lastGesture;

  // --- Initialization ---
  Future<void> _initBluetooth() async {
    // Check initial permission status
    await _checkPermissions();
  }

  // --- 1. PERMISSION HANDLING ---

  Future<void> _checkPermissions() async {
    // Request Bluetooth Connect and Scan permissions
    // Use the 'perm_handler' prefix
    Map<perm_handler.Permission, perm_handler.PermissionStatus> statuses =
        await [
      perm_handler.Permission.bluetoothScan,
      perm_handler.Permission.bluetoothConnect,
      perm_handler.Permission.bluetoothAdvertise,
    ].request();

    _permissionsGranted =
        statuses[perm_handler.Permission.bluetoothScan]!.isGranted &&
            statuses[perm_handler.Permission.bluetoothConnect]!.isGranted;

    if (!_permissionsGranted) {
      debugPrint("Bluetooth permissions were not granted.");
    }
    notifyListeners();
  }

  Future<void> openAppSettings() async {
    // This is the correct implementation, using the prefix
    await perm_handler.openAppSettings();
  }

  // --- 2. SCANNING ---

  Future<void> requestPermissionsAndScan() async {
    debugPrint("Starting scan...");
    if (!_permissionsGranted) {
      await _checkPermissions();
      if (!_permissionsGranted) return;
    }

    // Stop any previous scan
    await _scanSubscription?.cancel();
    _availableDevices = [];
    _isScanning = true;
    notifyListeners(); // <-- isScanning becomes true

    // Start discovery
    _scanSubscription = _bluetooth.startDiscovery().listen(
      (result) {
        // Add device to list if it's new and has a name
        bool deviceExists = _availableDevices
            .any((device) => device.address == result.device.address);
        if (!deviceExists &&
            result.device.name != null &&
            result.device.name!.isNotEmpty) {
          _availableDevices.add(result.device);
          notifyListeners();
        }
      },
      onDone: () {
        debugPrint("Scan finished.");
        _isScanning = false; // <-- This is the fix!
        notifyListeners();
      },
      onError: (error) {
        debugPrint("Scan error: $error");
        _isScanning = false; // <-- This is the fix!
        notifyListeners();
      },
    );
  }

  void stopScan() {
    debugPrint("Stopping scan.");
    _scanSubscription?.cancel();
    _scanSubscription = null;
    _isScanning = false;
    notifyListeners();
  }

  // --- 3. CONNECTION ---

  Future<bool> connectToDevice(BluetoothDevice device) async {
    stopScan(); // Stop scanning before attempting to connect
    _isConnecting = true;
    notifyListeners();

    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      _connectedDevice = device; // Store the connected device info
      debugPrint('Connected to the device ${device.name}');

      // Start listening for data
      _startDataListener();

      _isConnecting = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Cannot connect, exception occurred: $e');
      _isConnecting = false;
      notifyListeners();
      return false;
    }
  }

  void disconnect() {
    debugPrint("Disconnecting...");
    _dataSubscription?.cancel();
    _connection?.close();
    _connection = null;
    _connectedDevice = null;
    _lastGesture = ""; // Clear last gesture on disconnect
    notifyListeners();
  }

  // --- 4. DATA HANDLING ---

  void _startDataListener() {
    _dataSubscription = _connection?.input?.listen(
      (Uint8List data) {
        // Decode the data as ASCII and add to buffer
        _dataBuffer += ascii.decode(data);

        // Process all complete lines in the buffer
        while (_dataBuffer.contains('\n')) {
          // Extract the first complete line
          int newlineIndex = _dataBuffer.indexOf('\n');
          String line = _dataBuffer.substring(0, newlineIndex).trim();
          // Remove the processed line from the buffer
          _dataBuffer = _dataBuffer.substring(newlineIndex + 1);

          if (line.isNotEmpty) {
            _processReceivedLine(line);
          }
        }
      },
      onDone: () {
        debugPrint('Disconnected by remote peer.');
        disconnect(); // Handle disconnection
      },
      onError: (error) {
        debugPrint('Data listener error: $error');
        disconnect(); // Handle error
      },
    );
  }

  void _processReceivedLine(String message) {
    debugPrint("Received message: $message");

    // This is the smart filter to find the "Word:"
    String gesture = _extractGesture(message);

    if (gesture.isNotEmpty) {
      debugPrint("Extracted gesture: $gesture");
      // Update the gesture
      _lastGesture = gesture;

      // Speak the gesture if TTS is enabled
      _ttsProvider.speak(gesture);

      // Notify listeners (like GestureDisplayPage)
      notifyListeners();
    } else {
      debugPrint("Ignoring raw data: $message");
    }
  }

  /// Extracts the gesture word (e.g., "YES") from a full data line.
  /// Example input: "Flex: 755 | ax: -4076 | ay: 32 -> Word: YES (Fully Bent...)"
  /// Example output: "YES"
  String _extractGesture(String data) {
    try {
      const String marker = "-> Word: ";
      final int wordIndex = data.indexOf(marker);

      // If "-> Word: " is not found, it's not a gesture line
      if (wordIndex == -1) {
        return "";
      }

      // Get the substring starting right after "-> Word: "
      String gesturePart = data.substring(wordIndex + marker.length);

      // Find the end of the gesture word (it's before the space or parenthesis)
      int endOfWordIndex = gesturePart.indexOf(' ');
      if (endOfWordIndex == -1) {
        // If no space, the whole remaining string is the gesture
        return gesturePart.trim();
      } else {
        // Otherwise, just take the part before the space
        return gesturePart.substring(0, endOfWordIndex).trim();
      }
    } catch (e) {
      debugPrint("Error extracting gesture: $e");
      return "";
    }
  }

  @override
  void dispose() {
    // Clean up all resources
    disconnect();
    _scanSubscription?.cancel();
    _dataSubscription?.cancel();
    super.dispose();
  }
}
