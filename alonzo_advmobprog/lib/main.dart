import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/sign_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'providers/cart_provider.dart';

/// Entry point of the application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Development helpers: show runtime errors onscreen instead of a white
  // screen so we can diagnose crashes more easily during development.
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Text(
            details.exceptionAsString(),
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  };

  // Load environment variables but don't crash the app if the `.env` file is
  // missing or cannot be read. This prevents a white-screen failure when the
  // app cannot find the env file at startup
  try {
    await dotenv.load(fileName: 'assets/.env');
  } catch (e) {
    // Log the error to console; the ErrorWidget above will display runtime
    // exceptions if this causes downstream failures.
    print('dotenv.load() failed: $e');
  }
  runApp(
    MultiProvider(
      providers: [
      ChangeNotifierProvider(create: (_) => ThemeModel()),
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => CartProvider()),
    ],
      child: const MyApp(),
    ),
  );
}

/// Root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, themeModel, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'State Management',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            fontFamily: 'Poppins',
            textTheme: const TextTheme(
              displayLarge: TextStyle(fontWeight: FontWeight.w700),
              displayMedium: TextStyle(fontWeight: FontWeight.w600),
              headlineSmall: TextStyle(fontWeight: FontWeight.w600),
              titleLarge: TextStyle(fontWeight: FontWeight.w600),
              bodyLarge: TextStyle(fontWeight: FontWeight.w400),
              bodyMedium: TextStyle(fontWeight: FontWeight.w300),
              labelLarge: TextStyle(fontWeight: FontWeight.w500),
            ),
            scaffoldBackgroundColor: Colors.grey[50],
            appBarTheme: const AppBarTheme(
              elevation: 0,
              centerTitle: false,
              toolbarTextStyle: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Colors.black,
              ),
              titleTextStyle: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigo,
              brightness: Brightness.dark,
            ),
            fontFamily: 'Poppins',
            appBarTheme: const AppBarTheme(
              elevation: 0,
              centerTitle: false,
              toolbarTextStyle: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Colors.white,
              ),
              titleTextStyle: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            textTheme: const TextTheme(
              displayLarge: TextStyle(fontWeight: FontWeight.w700),
              displayMedium: TextStyle(fontWeight: FontWeight.w600),
              headlineSmall: TextStyle(fontWeight: FontWeight.w600),
              titleLarge: TextStyle(fontWeight: FontWeight.w600),
              bodyLarge: TextStyle(fontWeight: FontWeight.w400),
              bodyMedium: TextStyle(fontWeight: FontWeight.w300),
              labelLarge: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          themeMode: themeModel.isDark ? ThemeMode.dark : ThemeMode.light,
          home: const _AuthGate(),
        );
      },
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    switch (auth.status) {
      case AuthStatus.checking:
        // Enhancement 1: SplashScreen waits for the persisted session check.
        return const SplashScreen();
      case AuthStatus.authenticating:
        // Enhancement 1: Keep the visible splash page open while login loads.
        return const SplashScreen(message: 'Signing you in...');
      case AuthStatus.signedOut:
        // Enhancement 2: SignScreen owns the user-service login form.
        return const SignScreen();
      case AuthStatus.signedIn:
        return HomeScreen(user: auth.user!);
    }
  }
}
