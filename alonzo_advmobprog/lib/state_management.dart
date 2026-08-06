import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// provider is used by pages; keep imports there.

/// Stores the application's shared theme state.
class ThemeModel with ChangeNotifier {
  static const _prefKey = 'isDarkMode';
  bool _isDark = false;

  ThemeModel() {
    _loadFromPrefs();
  }

  /// Returns whether dark mode is enabled.
  bool get isDark => _isDark;

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool(_prefKey) ?? false;
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, _isDark);
  }

  /// Toggles between light and dark themes.
  void toggleTheme() {
    _isDark = !_isDark;
    _saveToPrefs();
    notifyListeners();
  }
}