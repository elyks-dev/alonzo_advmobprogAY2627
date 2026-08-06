import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../lib/state_management.dart';

void main() {
  test('ThemeModel persists preference', () async {
    // Start with empty mock preferences.
    SharedPreferences.setMockInitialValues({});

    final model = ThemeModel();

    // Wait briefly for the model to load values.
    await Future.delayed(const Duration(milliseconds: 50));

    // Initially should be false (default).
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('isDarkMode') ?? false, false);

    // Toggle theme and allow save to complete.
    model.toggleTheme();
    await Future.delayed(const Duration(milliseconds: 50));

    final after = await SharedPreferences.getInstance();
    expect(after.getBool('isDarkMode'), true);
  });
}
