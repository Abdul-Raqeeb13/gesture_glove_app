import 'package:flutter/material.dart';
import 'package:gesture_glove_app/models/custom_gesture.dart';
import 'package:gesture_glove_app/providers/bluetooth_provider.dart';
import 'package:gesture_glove_app/providers/tts_provider.dart';
import 'package:gesture_glove_app/services/database_service.dart';
import 'package:gesture_glove_app/services/recognition_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GestureDisplayPage extends StatefulWidget {
  const GestureDisplayPage({super.key});

  @override
  State<GestureDisplayPage> createState() => _GestureDisplayPageState();
}

class _GestureDisplayPageState extends State<GestureDisplayPage> {
  // --- Services ---
  final DatabaseService _dbService = DatabaseService();
  final RecognitionService _recognitionService = RecognitionService();
  late TtsProvider _ttsProvider; // We'll get this from context

  // --- State ---
  List<CustomGesture> _savedGestures = [];
  String _recognizedText = "None";
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _loadGestures();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      // Get the TtsProvider once
      _ttsProvider = context.read<TtsProvider>();
      _isFirstLoad = false;
    }
  }

  void _loadGestures() {
    setState(() {
      _savedGestures = _dbService.getAllGestures().values.toList();
      print("Loaded ${_savedGestures.length} gestures.");
    });
  }

  // This is the core recognition logic
  void _onSensorDataUpdate(BluetoothProvider provider) {
    if (_savedGestures.isEmpty) {
      // If no custom gestures, just use the pre-programmed one
      // This bridges your old and new logic
      if (provider.lastGesture.isNotEmpty &&
          provider.lastGesture != _recognizedText) {
        setState(() {
          _recognizedText = provider.lastGesture;
        });
        // TTS is already handled by provider for this old logic
      }
      return;
    }

    // --- New Custom Gesture Logic ---
    final newText = _recognitionService.findBestMatch(
      provider.rawFlexData,
      provider.accelX,
      provider.accelY,
      provider.accelZ,
      _savedGestures,
    );

    if (newText != _recognizedText) {
      setState(() {
        _recognizedText = newText;
      });

      // Speak the new text
      if (newText != "None") {
        // We use the TtsProvider, respecting the user's settings
        _ttsProvider.speak(newText);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    // --- Use context.watch() ---
    // This makes the widget rebuild every time new data arrives
    final provider = context.watch<BluetoothProvider>();

    // --- Trigger recognition on build ---
    // This is simple and effective
    _onSensorDataUpdate(provider);

    final colorScheme = Theme.of(context).colorScheme;
    final bool isConnected = provider.isConnected;
    final bool isWaiting = _recognizedText.isEmpty ||
        _recognizedText.toLowerCase() == l.none.toLowerCase();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- 1. Connection Status (Your existing widget is great) ---
            _buildConnectionStatus(context, l, isConnected, provider),
            const SizedBox(height: 48),

            // --- 2. Gesture Display ---
            Text(
              l.lastGesture, // "Last Gesture"
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // The main animated display card
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: colorScheme.onSurface.withOpacity(0.05),
                border: Border.all(
                  color: isWaiting
                      ? colorScheme.outline.withOpacity(0.3)
                      : colorScheme.primary.withOpacity(0.7),
                  width: 1.5,
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child));
                },
                // We now use our local _recognizedText state
                child: isWaiting
                    ? _buildWaitingState(context, l)
                    : _buildDetectedState(context, _recognizedText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS (Copied from your code, unchanged) ---

  Widget _buildConnectionStatus(BuildContext context, AppLocalizations l,
      bool isConnected, BluetoothProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isConnected ? Colors.green : colorScheme.error,
          width: 1.5,
        ),
        color: isConnected
            ? Colors.green.withOpacity(0.1)
            : colorScheme.error.withOpacity(0.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
            color: isConnected ? Colors.green : colorScheme.error,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isConnected ? l.connected : l.disconnected,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isConnected ? Colors.green : colorScheme.error,
                    ),
              ),
              if (isConnected)
                Text(
                  provider.connectedDeviceName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  /// Helper widget for the "Waiting" state
  Widget _buildWaitingState(BuildContext context, AppLocalizations l) {
    // Replaced your logo with a standard icon for simplicity.
    // You can put your Image.network back here easily.
    return Column(
      key: const ValueKey('waiting'), // Key for AnimatedSwitcher
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.accessibility_new_rounded,
          size: 100,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
        ),
        const SizedBox(height: 16),
        Text(
          l.none,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.normal,
              ),
        ),
      ],
    );
  }

  /// Helper widget for the "Detected" state
  Widget _buildDetectedState(BuildContext context, String gesture) {
    return Column(
      key: const ValueKey('detected'), // Key for AnimatedSwitcher
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.record_voice_over_rounded, // Changed icon to "speaking"
          size: 100,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          gesture.toUpperCase(), // Make it stand out
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
