import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state_management.dart';

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
      theme: themeModel.isDark
          ? ThemeData.dark()
          : ThemeData.light(),
      home: const HomePage(),
    );
  }
}

/// Displays the Bottom Navigation Bar.
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
            icon: Icon(Icons.exposure_plus_1),
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