import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});

  final User user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _loadUserData();
  }

  // Enhancement 3: Refresh profile details from Firebase Auth.
  Future<void> _loadUserData() async {
    try {
      final user = await UserService().getUserData();
      if (mounted) setState(() => _user = user);
    } catch (_) {
      // The cached user remains visible when no Firebase session is available.
    }
  }

  Future<void> _editUsername() async {
    final controller = TextEditingController(text: _user.username);
    final username = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update username'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Username'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (!mounted || username == null || username.isEmpty) return;
    final success = await context.read<AuthProvider>().updateUsername(username);
    if (!mounted) return;
    if (success) {
      await _loadUserData();
    } else {
      _showError(context.read<AuthProvider>().error);
    }
  }

  Future<void> _changePassword() async {
    final current = TextEditingController();
    final next = TextEditingController();
    final values = await showDialog<List<String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: current,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current password'),
            ),
            TextField(
              controller: next,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, [current.text, next.text]),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (!mounted || values == null) return;
    if (values[0].isEmpty) {
      _showError('Enter your current password');
      return;
    }
    if (values[1].length < 6) {
      _showError('New password must be at least 6 characters');
      return;
    }
    final success = await context.read<AuthProvider>().changePassword(
      currentPassword: values[0],
      newPassword: values[1],
    );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );
    } else {
      _showError(context.read<AuthProvider>().error);
    }
  }

  Future<void> _deleteAccount() async {
    final password = TextEditingController();
    final confirmed = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: TextField(
          controller: password,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, password.text),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed == null || confirmed.isEmpty) return;
    final success = await context.read<AuthProvider>().deleteAccount(confirmed);
    if (!success && mounted) _showError(context.read<AuthProvider>().error);
  }

  void _showError(String? message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message ?? 'Action failed')));
  }

  @override
  Widget build(BuildContext context) {
    // Enhancement 3: Display and manage the authenticated user's profile.
    final themeModel = context.watch<ThemeModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () => context.read<AuthProvider>().signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            backgroundImage: _user.image.isNotEmpty
                ? NetworkImage(_user.image)
                : null,
            child: _user.image.isEmpty
                ? Icon(
                    Icons.person,
                    size: 44,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            '${_user.firstName} ${_user.lastName}'.trim(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.alternate_email),
              title: Text('@${_user.username}'),
              subtitle: Text(_user.email),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Update username'),
                  onTap: _editUsername,
                ),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Change password'),
                  onTap: _changePassword,
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Delete account'),
                  onTap: _deleteAccount,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              title: const Text('Dark mode'),
              secondary: const Icon(Icons.dark_mode_outlined),
              value: themeModel.isDark,
              onChanged: (_) => themeModel.toggleTheme(),
            ),
          ),
        ],
      ),
    );
  }
}
