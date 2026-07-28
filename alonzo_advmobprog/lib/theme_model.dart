import 'package:flutter/material.dart';

/// Stores the application's theme state.
class ThemeModel with ChangeNotifier {
  bool _isDark = false;

  /// Returns whether dark mode is enabled.
  bool get isDark => _isDark;

  /// Toggles between light and dark themes.
  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}