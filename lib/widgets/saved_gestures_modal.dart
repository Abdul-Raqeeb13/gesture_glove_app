import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/custom_gesture.dart';
import '../services/database_service.dart';

class SavedGesturesModal extends StatefulWidget {
  const SavedGesturesModal({super.key});

  @override
  State<SavedGesturesModal> createState() => _SavedGesturesModalState();
}

class _SavedGesturesModalState extends State<SavedGesturesModal> {
  final DatabaseService _dbService = DatabaseService();
  late Map<dynamic, CustomGesture> _savedGestures;

  @override
  void initState() {
    super.initState();
    _loadGestures();
  }

  void _loadGestures() {
    setState(() {
      _savedGestures = _dbService.getAllGestures();
    });
  }

  Future<void> _deleteGesture(dynamic key) async {
    await _dbService.deleteGesture(key);
    _loadGestures(); // Refresh the list
  }

  Future<void> _deleteAllGestures() async {
    await _dbService.clearAllGestures();
    _loadGestures(); // Refresh the list
  }

  // Show a confirmation dialog before deleting all
  void _showDeleteAllConfirmation(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteAllGesturesTitle), // Add to l10n
        content: Text(l.deleteAllGesturesContent), // Add to l10n
        actions: [
          TextButton(
            child: Text(l.cancel),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            child: Text(l.delete), // Add to l10n
            onPressed: () {
              _deleteAllGestures();
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            l.savedGesturesTitle, // Add to l10n
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Divider(),
          if (_savedGestures.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  l.noSavedGestures, // Add to l10n
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _savedGestures.length,
                itemBuilder: (context, index) {
                  final key = _savedGestures.keys.elementAt(index);
                  final gesture = _savedGestures[key]!;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ExpansionTile(
                      title: Text(
                        gesture.text,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline,
                            color: Theme.of(context).colorScheme.error),
                        onPressed: () => _deleteGesture(key),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Flex: ${gesture.flexReadings}",
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Accel: [${gesture.accelX.toStringAsFixed(2)}, ${gesture.accelY.toStringAsFixed(2)}, ${gesture.accelZ.toStringAsFixed(2)}]",
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          const Divider(),
          if (_savedGestures.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete_forever),
                label: Text(l.deleteAll), // Add to l10n
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                onPressed: () => _showDeleteAllConfirmation(context),
              ),
            )
        ],
      ),
    );
  }
}
