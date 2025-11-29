import 'package:flutter/material.dart';

class L10n {
  static final all = [
    const Locale('en'), // English
    const Locale('ur'), // Urdu (Add this line!)
  ];

  static String getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'ur':
        return 'Urdu'; // The name displayed in the list
      default:
        return 'English';
    }
  }
}
