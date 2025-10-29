import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gesture Glove - Single Finger',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: GestureGloveApp(),
    );
  }
}

class GestureGloveApp extends StatefulWidget {
  @override
  _GestureGloveAppState createState() => _GestureGloveAppState();
}

class _GestureGloveAppState extends State<GestureGloveApp> {
  // Bluetooth instances and state
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? _connection;
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice? _selectedDevice;
  bool _isConnected = false;

  // Text-to-Speech instance
  final FlutterTts _flutterTts = FlutterTts();

  // Language and Translation State
  String _selectedLanguage = 'en-US';
  final Map<String, String> _languageOptions = {
    'en-US': 'English (US)',
    'es-ES': 'Español (España)',
    'fr-FR': 'Français (France)',
    'hi-IN': 'हिन्दी (भारत)',
    'ur-PK': 'اردو (پاکستان)',
    'ar-SA': 'العربية (السعودية)',
    'zh-CN': '中文 (中国)',
    'de-DE': 'Deutsch (Deutschland)',
    'it-IT': 'Italiano (Italia)',
    'ja-JP': '日本語 (日本)',
  };

  // Voice Selection State
  List<Map<String, String>> _voices = [];
  String? _selectedVoiceName;

  // Translation map for single finger gestures
  final Map<String, Map<String, String>> _translations = {
    'HELLO': {
      'en-US': 'Hello',
      'es-ES': 'Hola',
      'fr-FR': 'Bonjour',
      'hi-IN': 'नमस्ते',
      'ur-PK': 'السلام علیکم',
      'ar-SA': 'مرحبا',
      'zh-CN': '你好',
      'de-DE': 'Hallo',
      'it-IT': 'Ciao',
      'ja-JP': 'こんにちは',
    },
    'MAYBE': {
      'en-US': 'Maybe',
      'es-ES': 'Quizás',
      'fr-FR': 'Peut-être',
      'hi-IN': 'शायद',
      'ur-PK': 'شاید',
      'ar-SA': 'ربما',
      'zh-CN': '也许',
      'de-DE': 'Vielleicht',
      'it-IT': 'Forse',
      'ja-JP': 'たぶん',
    },
    'YES': {
      'en-US': 'Yes',
      'es-ES': 'Sí',
      'fr-FR': 'Oui',
      'hi-IN': 'हाँ',
      'ur-PK': 'جی ہاں',
      'ar-SA': 'نعم',
      'zh-CN': '是的',
      'de-DE': 'Ja',
      'it-IT': 'Sì',
      'ja-JP': 'はい',
    },
    'LEFT': {
      'en-US': 'Left',
      'es-ES': 'Izquierda',
      'fr-FR': 'Gauche',
      'hi-IN': 'बाएं',
      'ur-PK': 'بائیں',
      'ar-SA': 'يسار',
      'zh-CN': '左',
      'de-DE': 'Links',
      'it-IT': 'Sinistra',
      'ja-JP': '左',
    },
    'RIGHT': {
      'en-US': 'Right',
      'es-ES': 'Derecha',
      'fr-FR': 'Droite',
      'hi-IN': 'दाएं',
      'ur-PK': 'دائیں',
      'ar-SA': 'يمين',
      'zh-CN': '右',
      'de-DE': 'Rechts',
      'it-IT': 'Destra',
      'ja-JP': '右',
    },
    'GO': {
      'en-US': 'Go',
      'es-ES': 'Vamos',
      'fr-FR': 'Aller',
      'hi-IN': 'जाओ',
      'ur-PK': 'جاؤ',
      'ar-SA': 'اذهب',
      'zh-CN': '走',
      'de-DE': 'Gehen',
      'it-IT': 'Vai',
      'ja-JP': '行く',
    },
    'STOP': {
      'en-US': 'Stop',
      'es-ES': 'Alto',
      'fr-FR': 'Arrêtez',
      'hi-IN': 'रुको',
      'ur-PK': 'رکو',
      'ar-SA': 'توقف',
      'zh-CN': '停止',
      'de-DE': 'Halt',
      'it-IT': 'Ferma',
      'ja-JP': '止まれ',
    },
    'NO': {
      'en-US': 'No',
      'es-ES': 'No',
      'fr-FR': 'Non',
      'hi-IN': 'नहीं',
      'ur-PK': 'نہیں',
      'ar-SA': 'لا',
      'zh-CN': '不',
      'de-DE': 'Nein',
      'it-IT': 'No',
      'ja-JP': 'いいえ',
    },
    'OK': {
      'en-US': 'Okay',
      'es-ES': 'Vale',
      'fr-FR': 'D\'accord',
      'hi-IN': 'ठीक है',
      'ur-PK': 'ٹھیک ہے',
      'ar-SA': 'حسنا',
      'zh-CN': '好的',
      'de-DE': 'Okay',
      'it-IT': 'Va bene',
      'ja-JP': 'わかった',
    },
  };

  // App UI state
  String _lastGestureKey = "---";
  String _statusText = "Disconnected. Please select a device and connect.";
  String _sensorData = "Waiting for data...";

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _initBluetooth();
    _initTts().then((_) => _getVoices());
  }

  Future<void> _requestPermissions() async {
    await [Permission.bluetoothScan, Permission.bluetoothConnect].request();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage(_selectedLanguage);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  // Get all available voices from the phone's TTS engine
  Future<void> _getVoices() async {
    try {
      var voices = await _flutterTts.getVoices;
      if (voices != null) {
        final voicesList = List<Map>.from(voices)
            .map((v) => {
                  "name": v["name"] as String,
                  "locale": v["locale"] as String,
                })
            .toList();
        setState(() => _voices = voicesList);
      }
    } catch (e) {
      print('Error getting voices: $e');
    }
  }

  // Change the TTS language and reset voice
  Future<void> _setLanguage(String newLanguage) async {
    setState(() {
      _selectedLanguage = newLanguage;
      _selectedVoiceName = null;
    });
    await _flutterTts.setLanguage(newLanguage);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Language changed to ${_languageOptions[newLanguage]}')),
      );
    }
  }

  // Set the chosen voice
  Future<void> _setVoice(String voiceName) async {
    await _flutterTts
        .setVoice({"name": voiceName, "locale": _selectedLanguage});
    setState(() => _selectedVoiceName = voiceName);
  }

  void _initBluetooth() async {
    try {
      List<BluetoothDevice> devices = await _bluetooth.getBondedDevices();
      setState(() => _devicesList = devices);
    } catch (e) {
      print("Error getting paired devices: $e");
    }
  }

  void _connect() async {
    if (_selectedDevice == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please select a device')));
      return;
    }
    if (!(_selectedDevice!.isBonded)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please pair the device in phone settings first')));
      return;
    }
    setState(() => _statusText = "Connecting...");
    try {
      _connection =
          await BluetoothConnection.toAddress(_selectedDevice!.address);
      setState(() {
        _isConnected = true;
        _statusText = "Connected to ${_selectedDevice!.name}";
      });
      _connection!.input!.listen(_onDataReceived).onDone(() {
        if (mounted) _disconnect();
      });
    } catch (e) {
      print('Cannot connect, exception: $e');
      setState(() => _statusText = "Connection Failed. Try again.");
    }
  }

  // Parse incoming data from ESP32
  void _onDataReceived(Uint8List data) {
    String receivedString = ascii.decode(data).trim();
    print("Received: $receivedString");

    // Extract the gesture word from the format: "-> Word: GESTURE (description)"
    final RegExp regExp = RegExp(r"Word:\s*(\w+)\s*\(");
    final match = regExp.firstMatch(receivedString);

    if (match != null && match.group(1) != null) {
      String gestureKey = match.group(1)!.trim();

      // Extract sensor data for display
      final RegExp sensorRegExp =
          RegExp(r"Flex:\s*(\d+)\s*\|\s*ax:\s*(-?\d+)\s*\|\s*ay:\s*(-?\d+)");
      final sensorMatch = sensorRegExp.firstMatch(receivedString);

      if (sensorMatch != null) {
        String flex = sensorMatch.group(1) ?? "0";
        String ax = sensorMatch.group(2) ?? "0";
        String ay = sensorMatch.group(3) ?? "0";
        setState(() {
          _sensorData = "Flex: $flex | ax: $ax | ay: $ay";
        });
      }

      if (gestureKey != _lastGestureKey) {
        setState(() => _lastGestureKey = gestureKey);
        _speak(gestureKey);
      }
    }
  }

  // Speak the translated gesture
  Future<void> _speak(String gestureKey) async {
    final String? textToSpeak = _translations[gestureKey]?[_selectedLanguage];
    if (textToSpeak != null && textToSpeak.isNotEmpty) {
      await _flutterTts.speak(textToSpeak);
    } else {
      print("No translation for '$gestureKey' in '$_selectedLanguage'");
      await _flutterTts.speak(gestureKey); // Fallback to English key
    }
  }

  void _disconnect() {
    setState(() {
      _isConnected = false;
      _statusText = "Disconnected.";
      _lastGestureKey = "---";
      _sensorData = "Waiting for data...";
    });
    _connection?.dispose();
    _connection = null;
  }

  @override
  void dispose() {
    _connection?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter voices based on selected language
    final List<DropdownMenuItem<String>> voiceItems = _voices
        .where((v) => v['locale'] == _selectedLanguage)
        .map((v) => DropdownMenuItem<String>(
              value: v['name'],
              child: Text(v['name']!, overflow: TextOverflow.ellipsis),
            ))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Gesture Glove - Single Finger'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              // Bluetooth Connection Section
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bluetooth Connection',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: DropdownButton<BluetoothDevice>(
                                  isExpanded: true,
                                  hint: Text('Select Device'),
                                  value: _selectedDevice,
                                  onChanged: (d) =>
                                      setState(() => _selectedDevice = d),
                                  items: _devicesList
                                      .map((d) => DropdownMenuItem(
                                            child: Text(d.name ?? "Unknown"),
                                            value: d,
                                          ))
                                      .toList(),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              backgroundColor:
                                  _isConnected ? Colors.red : Colors.green,
                            ),
                            onPressed: _isConnected ? _disconnect : _connect,
                            child:
                                Text(_isConnected ? 'Disconnect' : 'Connect'),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        _statusText,
                        style: TextStyle(
                          color: _isConnected ? Colors.green : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Language & Voice Settings Section
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Language & Voice Settings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      // Language Selection
                      DropdownButtonHideUnderline(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedLanguage,
                            items: _languageOptions.entries
                                .map((entry) => DropdownMenuItem<String>(
                                      value: entry.key,
                                      child: Text(entry.value),
                                    ))
                                .toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) _setLanguage(newValue);
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      // Voice Selection
                      DropdownButtonHideUnderline(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: Text('Select Voice (Optional)'),
                            value: _selectedVoiceName,
                            items: voiceItems,
                            onChanged: (String? newValue) {
                              if (newValue != null) _setVoice(newValue);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Sensor Data Display
              Card(
                elevation: 3,
                color: Colors.grey.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.sensors, color: Colors.indigo),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _sensorData,
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Courier',
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Gesture Display Section
              Expanded(
                child: Card(
                  elevation: 3,
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.back_hand,
                          size: 80,
                          color: Theme.of(context).primaryColor,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Detected Gesture:',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            _lastGestureKey,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        if (_lastGestureKey != "---" &&
                            _translations[_lastGestureKey] != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Translation: ${_translations[_lastGestureKey]![_selectedLanguage] ?? _lastGestureKey}',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.indigo.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Info Section
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '9 gestures: HELLO, MAYBE, YES, LEFT, RIGHT, GO, STOP, NO, OK',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
