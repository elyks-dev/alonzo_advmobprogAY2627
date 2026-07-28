import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Stores the application's shared theme state.
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

/// Demonstrates Ephemeral State using setState().
class EphemeralPage extends StatefulWidget {
  const EphemeralPage({super.key});

  @override
  State<EphemeralPage> createState() => _EphemeralPageState();
}

class _EphemeralPageState extends State<EphemeralPage> {
  int _counter = 0;

  /// Increments the counter.
  void incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ephemeral State"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "You have pushed the button this many times:",
            ),
            const SizedBox(height: 10),
            Text(
              "$_counter",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: incrementCounter,
        tooltip: "Increment",
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Demonstrates App State using Provider.
class AppStatePage extends StatelessWidget {
  const AppStatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("App State"),
        centerTitle: true,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SwitchListTile(
              title: const Text(
                "Enable Dark Mode",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                "This changes the theme of the entire application using Provider.",
              ),
              secondary: const Icon(Icons.dark_mode),
              value: themeModel.isDark,
              onChanged: (value) {
                themeModel.toggleTheme();
              },
            ),
          ),
        ),
      ),
    );
  }
}