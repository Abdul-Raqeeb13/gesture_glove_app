// lib/models/custom_gesture.dart
import 'package:hive/hive.dart';

part 'custom_gesture.g.dart'; // This file will be generated

@HiveType(typeId: 0)
class CustomGesture extends HiveObject {
  @HiveField(0)
  final String text;

  @HiveField(1)
  final List<int> flexReadings;

  // --- **** THESE ARE NOW double **** ---
  @HiveField(2)
  final double accelX;

  @HiveField(3)
  final double accelY;

  @HiveField(4)
  final double accelZ;
  // --- **** END OF CHANGE **** ---

  CustomGesture({
    required this.text,
    required this.flexReadings,
    required this.accelX,
    required this.accelY,
    required this.accelZ,
  });
}
