import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:Glovox/providers/tts_provider.dart';
import 'package:permission_handler/permission_handler.dart' as perm_handler;

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
  String _dataBuffer = '';
  Timer? _scanTimer;

  // --- Public State ---
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
    await _checkPermissions();
  }

  // --- 1. PERMISSION HANDLING ---
  Future<void> _checkPermissions() async {
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
    await perm_handler.openAppSettings();
  }

  // --- 2. SCANNING ---
  Future<void> requestPermissionsAndScan() async {
    debugPrint("Starting scan...");
    if (!_permissionsGranted) {
      await _checkPermissions();
      if (!_permissionsGranted) return;
    }

    await _scanSubscription?.cancel();
    _availableDevices = [];
    _isScanning = true;
    notifyListeners();

    _scanTimer?.cancel();
    _scanTimer = Timer(const Duration(seconds: 10), () {
      if (_isScanning) {
        debugPrint(
            "Scan timeout reached (10 seconds), automatically stopping scan.");
        stopScan();
      }
    });

    _scanSubscription = _bluetooth.startDiscovery().listen(
      (result) {
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
        _scanTimer?.cancel();
        _isScanning = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint("Scan error: $error");
        _scanTimer?.cancel();
        _isScanning = false;
        notifyListeners();
      },
    );
  }

  void stopScan() {
    debugPrint("Stopping scan.");
    _scanTimer?.cancel();
    _scanSubscription?.cancel();
    _scanSubscription = null;
    _isScanning = false;
    notifyListeners();
  }

  // --- 3. CONNECTION ---
  Future<bool> connectToDevice(BluetoothDevice device) async {
    stopScan();
    _isConnecting = true;
    notifyListeners();

    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      _connectedDevice = device;
      debugPrint('Connected to the device ${device.name}');

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
    _lastGesture = "";
    notifyListeners();
  }

  // --- 4. DATA HANDLING ---
  void _startDataListener() {
    _dataSubscription = _connection?.input?.listen(
      (Uint8List data) {
        _dataBuffer += ascii.decode(data);

        while (_dataBuffer.contains('\n')) {
          int newlineIndex = _dataBuffer.indexOf('\n');
          String line = _dataBuffer.substring(0, newlineIndex).trim();
          _dataBuffer = _dataBuffer.substring(newlineIndex + 1);

          if (line.isNotEmpty) {
            _processReceivedLine(line);
          }
        }
      },
      onDone: () {
        debugPrint('Disconnected by remote peer.');
        disconnect();
      },
      onError: (error) {
        debugPrint('Data listener error: $error');
        disconnect();
      },
    );
  }

  void _processReceivedLine(String message) {
    debugPrint("📱 BT Received: $message");

    String gesture = _extractGesture(message);

    if (gesture.isNotEmpty) {
      debugPrint("✅ Extracted gesture: $gesture");
      _lastGesture = gesture;

      // ✅ CRITICAL FIX: Don't speak here!
      // Let the UI (GestureDisplayPage) handle TTS with localized text
      // We just update the gesture and notify listeners
      debugPrint("📢 Notifying listeners (UI will handle TTS)...");
      notifyListeners();

      // ❌ REMOVED: _ttsProvider.speak(gesture);
      // The problem was speaking the raw English text here!
    } else {
      debugPrint("❌ No valid gesture found in message");
    }
  }

  String _extractGesture(String data) {
    try {
      String gesture =
          data.trim().replaceAll(';', '').replaceAll('.', '').trim();

      if (gesture.isEmpty ||
          gesture.startsWith("Flex:") ||
          gesture.startsWith("Accel:") ||
          gesture.startsWith("==") ||
          gesture.startsWith("Bluetooth") ||
          gesture.startsWith("Current") ||
          gesture.startsWith("Gesture Calibrated") ||
          gesture.startsWith("Found a MPU") ||
          gesture.startsWith("The device with name") ||
          gesture.contains("----------")) {
        return "";
      }

      return gesture;
    } catch (e) {
      debugPrint("Error extracting gesture: $e");
      return "";
    }
  }

  @override
  void dispose() {
    disconnect();
    _scanSubscription?.cancel();
    _dataSubscription?.cancel();
    _scanTimer?.cancel();
    super.dispose();
  }
}
