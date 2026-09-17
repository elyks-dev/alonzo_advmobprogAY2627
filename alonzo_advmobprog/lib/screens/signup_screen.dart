import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

// Enhancement 2: Collect the required fields for Firebase account creation.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _age = TextEditingController();
  final _contactNo = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    for (final controller in [
      _firstName,
      _lastName,
      _age,
      _contactNo,
      _username,
      _email,
      _password,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.createAccount(
      _email.text.trim(),
      _password.text,
      _username.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Unable to create account')),
      );
    }
  }

  String? _required(String? value, String label) {
    return value == null || value.trim().isEmpty ? 'Enter your $label' : null;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _firstName,
              decoration: const InputDecoration(labelText: 'First name'),
              validator: (value) => _required(value, 'first name'),
            ),
            TextFormField(
              controller: _lastName,
              decoration: const InputDecoration(labelText: 'Last name'),
              validator: (value) => _required(value, 'last name'),
            ),
            TextFormField(
              controller: _age,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Age'),
              validator: (value) => _required(value, 'age'),
            ),
            TextFormField(
              controller: _contactNo,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Contact number'),
              validator: (value) => _required(value, 'contact number'),
            ),
            TextFormField(
              controller: _username,
              decoration: const InputDecoration(labelText: 'Username'),
              validator: (value) => _required(value, 'username'),
            ),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email address'),
              validator: (value) {
                if (_required(value, 'email address') != null) {
                  return 'Enter your email address';
                }
                return RegExp(r'^\S+@\S+\.\S+$').hasMatch(value!.trim())
                    ? null
                    : 'Enter a valid email address';
              },
            ),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (value) {
                if (_required(value, 'password') != null) {
                  return 'Enter your password';
                }
                return value!.length < 6
                    ? 'Password must be at least 6 characters'
                    : null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: auth.isBusy ? null : _createAccount,
              child: auth.isBusy
                  ? const CircularProgressIndicator()
                  : const Text('Create account'),
            ),
          ],
        ),
      ),
    );
  }
}
