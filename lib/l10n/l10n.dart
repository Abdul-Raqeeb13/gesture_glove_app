import 'package:flutter/material.dart';

class L10n {
  static final all = [
    const Locale('en'), // English
    const Locale('es'), // Spanish
  ];

  static String getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        // Fix: Changed 'restiturn' to 'return'
        return 'English';
    }
  }
}
