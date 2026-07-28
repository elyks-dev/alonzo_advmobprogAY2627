import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_model.dart';

/// Entry point of the application.
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeModel(),
      child: const MyApp(),
    ),
  );
}

/// Root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'State Management',
      theme: themeModel.isDark ? ThemeData.dark() : ThemeData.light(),
      home: const HomePage(),
    );
  }
}

/// Home page with Bottom Navigation.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    EphemeralPage(),
    AppStatePage(),
  ];

  void _changePage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _changePage,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            label: 'Ephemeral',
          ),
          NavigationDestination(
            icon: Icon(Icons.dark_mode),
            label: 'App State',
          ),
        ],
      ),
    );
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
        child: SwitchListTile(
          title: const Text("Enable Dark Mode"),
          subtitle: const Text(
            "This changes the theme of the entire application.",
          ),
          value: themeModel.isDark,
          onChanged: (value) {
            themeModel.toggleTheme();
          },
        ),
      ),
    );
  }
}