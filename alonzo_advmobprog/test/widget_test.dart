import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../lib/main.dart';
import '../lib/models/user.dart';
import '../lib/providers/auth_provider.dart';
import '../lib/providers/theme_provider.dart';

void main() {
  testWidgets('home shell displays the three required tabs', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final savedUser = const User(
      id: 6,
      username: 'emilys',
      email: 'emily@example.com',
      firstName: 'Emily',
      lastName: 'Johnson',
      gender: 'female',
      image: '',
      accessToken: 'test-token',
      refreshToken: 'test-refresh-token',
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authenticatedUser', jsonEncode(savedUser.toJson()));
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeModel()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1600));

    expect(find.text('Shop'), findsOneWidget);
    expect(find.text('Cart'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pump();

    expect(find.text('Emily Johnson'), findsOneWidget);
  });
}
