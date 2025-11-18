// lib/providers/bluetooth_provider.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:gesture_glove_app/providers/tts_provider.dart';
// Import with a prefix to avoid name conflicts
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

  // --- **** STATE CHANGE: int -> double **** ---
  List<int> _rawFlexData = [0, 0, 0, 0, 0];
  double _accelX = 0.0;
  double _accelY = 0.0;
  double _accelZ = 0.0;

  // --- **** GETTER CHANGE: int -> double **** ---
  List<int> get rawFlexData => _rawFlexData;
  double get accelX => _accelX;
  double get accelY => _accelY;
  double get accelZ => _accelZ;

  // --- Initialization & Permissions (Unchanged) ---
  Future<void> _initBluetooth() async {
    await _checkPermissions();
  }

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
    notifyListeners();
  }

  Future<void> openAppSettings() async {
    await perm_handler.openAppSettings();
  }

  // --- Scanning (Unchanged) ---
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
        _isScanning = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint("Scan error: $error");
        _isScanning = false;
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

  // --- Connection (Unchanged) ---
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
            debugPrint("RAW_GLOVE_DATA: $line");
            _parseRawData(line);
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

  // --- **** PARSER UPDATED **** ---
  /// This parser now looks for floats (doubles)
  void _parseRawData(String data) {
    try {
      bool dataChanged = false;

      // 1. Parse Flex Sensors (Unchanged)
      final flexListMatch = RegExp(r"Flex: \[(.*?)\]").firstMatch(data);
      if (flexListMatch != null && flexListMatch.group(1) != null) {
        _rawFlexData = flexListMatch
            .group(1)!
            .split(',')
            .map((s) => int.tryParse(s.trim()) ?? 0)
            .toList();
        while (_rawFlexData.length < 5) _rawFlexData.add(0);
        dataChanged = true;
      }

      // 2. Parse MPU6050 (Accel) - NOW PARSING DOUBLES
      // The RegExp (-?\d+\.?\d*) now matches "10" and "10.25" and "-3.1"
      final axMatch = RegExp(r"ax: (-?\d+\.?\d*)").firstMatch(data);
      if (axMatch != null && axMatch.group(1) != null) {
        _accelX = double.tryParse(axMatch.group(1)!) ?? 0.0;
        dataChanged = true;
      }

      final ayMatch = RegExp(r"ay: (-?\d+\.?\d*)").firstMatch(data);
      if (ayMatch != null && ayMatch.group(1) != null) {
        _accelY = double.tryParse(ayMatch.group(1)!) ?? 0.0;
        dataChanged = true;
      }

      final azMatch = RegExp(r"az: (-?\d+\.?\d*)").firstMatch(data);
      if (azMatch != null && azMatch.group(1) != null) {
        _accelZ = double.tryParse(azMatch.group(1)!) ?? 0.0;
        dataChanged = true;
      }

      if (dataChanged) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error parsing raw data: $e");
    }
  }

  // --- This is your original, working "Word:" extractor (Unchanged) ---
  void _processReceivedLine(String message) {
    String gesture = _extractGesture(message);

    if (gesture.isNotEmpty) {
      debugPrint("Extracted gesture: $gesture");
      _lastGesture = gesture;
      _ttsProvider.speak(gesture);
      notifyListeners();
    }
  }

  String _extractGesture(String data) {
    try {
      const String marker = "-> Word: ";
      final int wordIndex = data.indexOf(marker);

      if (wordIndex == -1) {
        return "";
      }
      String gesturePart = data.substring(wordIndex + marker.length);
      int endOfWordIndex = gesturePart.indexOf(' ');
      if (endOfWordIndex == -1) {
        return gesturePart.trim();
      } else {
        return gesturePart.substring(0, endOfWordIndex).trim();
      }
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
    super.dispose();
  }
}
