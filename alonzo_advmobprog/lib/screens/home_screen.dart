import 'package:flutter/material.dart';
import 'product_screen.dart';
import '../pages/ephemeral_page.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final ValueNotifier<bool> _counterResetNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _counterResetNotifier.dispose();
    super.dispose();
  }

  void _onItemTapped(int idx) {
    if (_selectedIndex == 1 && idx != 1) {
      _counterResetNotifier.value = !_counterResetNotifier.value;
    }
    setState(() => _selectedIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        const ProductScreen(),
        EphemeralPage(resetNotifier: _counterResetNotifier),
        const SettingsScreen(),
      ][_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.storefront_rounded), label: 'Products'),
          NavigationDestination(icon: Icon(Icons.countertops), label: 'Counter'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}
