import 'package:flutter/material.dart';
import 'product_screen.dart';
import 'cart_screen.dart';
import 'settings_screen.dart';
import '../models/user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.user});

  final User user;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int idx) {
    setState(() => _selectedIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Keep each tab alive so cart changes remain visible when switching tabs.
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const ProductScreen(),
          // Enhancement 3: Use the authenticated user's ID for the cart.
          CartScreen(userId: widget.user.id),
          ProfileScreen(user: widget.user),
        ],
      ),
      // Enhancement 2: Chat is an action FAB and is hidden while Cart is active.
      floatingActionButton: _selectedIndex == 1
          ? null
          : FloatingActionButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat is coming soon')),
              ),
              tooltip: 'Open chat',
              child: const Icon(Icons.chat_bubble_outline),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_rounded),
            label: 'Shop',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
