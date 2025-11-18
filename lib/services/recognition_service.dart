// lib/services/recognition_service.dart
import 'dart:math'; // We need this for the 'abs()' (absolute value) function
import '../models/custom_gesture.dart';

class RecognitionService {
  // --- 1. HERE ARE YOUR RANGES (TOLERANCES) ---

  /// For Flex Sensors (which have big values like 2300).
  /// A tolerance of 20 means if you saved 2300, the
  /// valid range is 2280 to 2320.
  static const int FLEX_TOLERANCE = 150; // <-- **** CHANGED FROM 20 ****
  /// For MPU6050 (which has small values like 2.19).
  /// A tolerance of 2.0 means if you saved 2.19, the
  /// valid range is 0.19 to 4.19.
  static const double MPU_TOLERANCE = 3.0; // <-- **** CHANGED FROM 2.0 ****
  // --- 2. THE NEW RECOGNITION LOGIC ---

  /// This function checks if a live value is within the "range"
  /// of a saved value.
  bool _isWithinRange(double liveValue, double savedValue, double tolerance) {
    return (liveValue - savedValue).abs() <= tolerance;
  }

  /// This is the new "matching" function.
  /// It checks if ALL sensors are within their tolerance ranges.
  bool _isGestureMatch(
    List<int> liveFlex,
    double liveAx,
    double liveAy,
    double liveAz,
    CustomGesture savedGesture,
  ) {
    // 1. Check MPU Accelerometer
    if (!_isWithinRange(liveAx, savedGesture.accelX, MPU_TOLERANCE))
      return false;
    if (!_isWithinRange(liveAy, savedGesture.accelY, MPU_TOLERANCE))
      return false;
    if (!_isWithinRange(liveAz, savedGesture.accelZ, MPU_TOLERANCE))
      return false;

    // 2. Check all Flex Sensors
    if (liveFlex.length != savedGesture.flexReadings.length) return false;

    for (int i = 0; i < liveFlex.length; i++) {
      // We cast the int to double to use the same function
      if (!_isWithinRange(liveFlex[i].toDouble(),
          savedGesture.flexReadings[i].toDouble(), FLEX_TOLERANCE.toDouble())) {
        return false; // If any flex sensor is out of range, fail the match
      }
    }

    // If we get here, all sensors were in range. It's a match!
    return true;
  }

  /// This is the main function called by GestureDisplayPage.
  /// It now uses the new "range" logic.
  @override
  String findBestMatch(
    List<int> liveFlex,
    double liveAx,
    double liveAy,
    double liveAz,
    List<CustomGesture> savedGestures,
  ) {
    if (savedGestures.isEmpty) {
      return "None";
    }

    // Loop through every gesture you've saved
    for (final gesture in savedGestures) {
      // Check if the live data matches the saved gesture's ranges
      if (_isGestureMatch(liveFlex, liveAx, liveAy, liveAz, gesture)) {
        // As soon as we find a gesture that matches, return its text.
        return gesture.text;
      }
    }

    // If we loop through all gestures and find no match, return "None".
    return "None";
  }
}
