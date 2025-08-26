import 'package:flutter/material.dart';

class UserSettings {
  final String themeMode;

  UserSettings({
    this.themeMode = 'system', // Default value
  });

  factory UserSettings.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) {
      return UserSettings(); // Return default settings if document doesn't exist
    }
    return UserSettings(themeMode: data['themeMode'] ?? 'system');
  }

  Map<String, dynamic> toJson() {
    return {'themeMode': themeMode};
  }

  ThemeMode get theme {
    switch (themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
