import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state_management.dart';

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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      themeModel.isDark ? 'Dark mode enabled' : 'Light mode enabled',
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
