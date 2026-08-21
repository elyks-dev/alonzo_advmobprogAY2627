import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/user.dart';

class UserService {
  static const _userKey = 'authenticatedUser';
  final String _baseHost;
  final http.Client _client;

  UserService({String? baseHost, http.Client? client})
    : _baseHost = baseHost ?? host,
      _client = client ?? http.Client();

  Future<User> login(String username, String password) async {
    // Enhancement 2: Authenticate through the DummyJSON user service.
    final response = await _client
        .post(
          Uri.parse('$_baseHost/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': username,
            'password': password,
            'expiresInMins': 30,
          }),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Login failed (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid login response');
    }
    final user = User.fromJson(decoded);
    await saveUser(user);
    return user;
  }

  Future<void> saveUser(User user) async {
    // Enhancement 1: Persist the authenticated user for the next app launch.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<User?> getSavedUser() async {
    // Enhancement 1: Restore the saved user during splash/session loading.
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_userKey);
    if (encoded == null || encoded.isEmpty) return null;

    try {
      final decoded = jsonDecode(encoded);
      return decoded is Map<String, dynamic> ? User.fromJson(decoded) : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  void dispose() => _client.close();
}
