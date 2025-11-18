// lib/services/database_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/custom_gesture.dart';

class DatabaseService {
  static const String _gestureBoxName = 'gestures';

  // 1. Initialize Hive
  static Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    Hive.registerAdapter(CustomGestureAdapter());
    await Hive.openBox<CustomGesture>(_gestureBoxName);
  }

  // 2. Get the Hive box
  Box<CustomGesture> get _gestureBox =>
      Hive.box<CustomGesture>(_gestureBoxName);

  // 3. Save a gesture
  Future<void> saveGesture(CustomGesture gesture) async {
    await _gestureBox.add(gesture);
  }

  // --- **** MODIFIED **** ---
  // Get all gestures as a Map, so we have their keys
  Map<dynamic, CustomGesture> getAllGestures() {
    return _gestureBox.toMap();
  }
  // --- **** END MODIFIED **** ---

  // --- **** NEW METHOD **** ---
  // Delete a specific gesture by its key
  Future<void> deleteGesture(dynamic key) async {
    await _gestureBox.delete(key);
  }
  // --- **** END NEW METHOD **** ---

  // 5. Clear all gestures (you already had this)
  Future<void> clearAllGestures() async {
    await _gestureBox.clear();
  }
}
