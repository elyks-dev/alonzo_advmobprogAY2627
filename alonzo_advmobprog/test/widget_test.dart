import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../lib/main.dart';
import '../lib/providers/theme_provider.dart';

void main() {
  testWidgets('home shell displays the three required tabs', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ChangeNotifierProvider(create: (_) => ThemeModel(), child: const MyApp()),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Shop'), findsOneWidget);
    expect(find.text('Cart'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pump();

    expect(find.text('Shopper Profile'), findsOneWidget);
  });
}
