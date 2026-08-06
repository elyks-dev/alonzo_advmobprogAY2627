import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state_management.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Enable Dark Mode'),
            value: themeModel.isDark,
            onChanged: (_) => themeModel.toggleTheme(),
          ),
        ],
      ),
    );
  }
}
