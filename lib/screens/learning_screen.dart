// lib/screens/learning_screen.dart
import 'package:flutter/material.dart';
import 'package:gesture_glove_app/models/custom_gesture.dart';
import 'package:gesture_glove_app/providers/bluetooth_provider.dart';
import 'package:gesture_glove_app/services/database_service.dart';
// --- **** ADD THIS IMPORT **** ---
import 'package:gesture_glove_app/widgets/saved_gestures_modal.dart';
// --- **** END ADD **** ---
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  bool _isLearningMode = false;
  final _dbService = DatabaseService();
  final _textController = TextEditingController();

  // --- **** ADD THIS NEW FUNCTION **** ---
  void _showSavedGestures(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Creates a modal that takes up 80% of the screen height
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.8,
        child: const SavedGesturesModal(),
      ),
    );
  }
  // --- **** END ADD **** ---

  // Dialog to save the gesture
  void _showSaveGestureDialog(BluetoothProvider provider) {
    // ... (This function is unchanged)
    final currentFlex = List<int>.from(provider.rawFlexData);
    final currentAx = provider.accelX;
    final currentAy = provider.accelY;
    final currentAz = provider.accelZ;

    _textController.clear();

    showDialog(
      context: context,
      builder: (context) {
        final l = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l.setGestureTextTitle),
          content: TextField(
            controller: _textController,
            autofocus: true,
            decoration: InputDecoration(hintText: l.setGestureTextHint),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final text = _textController.text;
                if (text.isNotEmpty) {
                  final newGesture = CustomGesture(
                    text: text,
                    flexReadings: currentFlex,
                    accelX: currentAx,
                    accelY: currentAy,
                    accelZ: currentAz,
                  );
                  _dbService.saveGesture(newGesture);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.gestureSaved(text))),
                  );
                }
              },
              child: Text(l.save),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final provider = context.watch<BluetoothProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l.gestureLearningTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. The Toggle Button
            SwitchListTile(
              title: Text(l.learningMode),
              subtitle: Text(_isLearningMode
                  ? l.learningModeEnabled
                  : l.learningModeDisabled),
              value: _isLearningMode,
              onChanged: (value) {
                setState(() {
                  _isLearningMode = value;
                });
              },
              secondary: Icon(
                _isLearningMode ? Icons.school : Icons.school_outlined,
              ),
            ),

            // --- **** ADD THIS NEW BUTTON **** ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.list_alt_rounded),
                label: Text(l.showSavedGestures), // Add to l10n
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                ),
                onPressed: () => _showSavedGestures(context),
              ),
            ),
            // --- **** END ADD **** ---

            const Divider(height: 16), // Adjusted height

            // 2. Conditional UI
            if (_isLearningMode)
              _buildLearningUI(context, l, provider)
            else
              _buildDisabledUI(context, l),
          ],
        ),
      ),
    );
  }

  /// UI shown when Learning Mode is OFF
  Widget _buildDisabledUI(BuildContext context, AppLocalizations l) {
    // ... (This function is unchanged)
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline,
                  size: 60, color: Theme.of(context).colorScheme.secondary),
              const SizedBox(height: 16),
              Text(
                l.learningModeInstructions,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// UI shown when Learning Mode is ON
  Widget _buildLearningUI(
      BuildContext context, AppLocalizations l, BluetoothProvider provider) {
    // ... (This function is unchanged, I'm just including it for completeness)
    if (!provider.isConnected) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bluetooth_disabled, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                l.learningModeConnectGlove,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // This is the main "live data" UI
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(l.liveSensorData,
              style: Theme.of(context).textTheme.headlineSmall),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Flex Sensors:",
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    provider.rawFlexData.toString(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 16),
                  Text("Accelerometer (X, Y, Z):",
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    "[${provider.accelX.toStringAsFixed(2)}, ${provider.accelY.toStringAsFixed(2)}, ${provider.accelZ.toStringAsFixed(2)}]",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_task),
            label: Text(l.setGestureButton),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: Theme.of(context).textTheme.titleLarge,
            ),
            onPressed: () {
              _showSaveGestureDialog(provider);
            },
          ),
        ],
      ),
    );
  }
}
