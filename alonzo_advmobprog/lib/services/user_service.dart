import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/user.dart';

class UserService {
  static const _userKey = 'authenticatedUser';
  final http.Client _client;

  UserService({http.Client? client}) : _client = client ?? http.Client();

  // Enhancement 1: Expose Firebase Auth operations for account management.
  auth.FirebaseAuth get _firebaseAuth => auth.FirebaseAuth.instance;

  auth.User? get currentUser => _firebaseAuth.currentUser;

  Stream<auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<auth.UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Enhancement 3: Send a Firebase password-reset email.
  Future<void> sendPasswordResetEmail({required String email}) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<auth.UserCredential> createAccount({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> updateUsername({required String username}) async {
    final user = currentUser;
    if (user == null) throw StateError('No signed-in user');
    await user.updateDisplayName(username);
    await user.reload();
  }

  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    final user = currentUser;
    if (user == null) throw StateError('No signed-in user');
    final credential = auth.EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
    await user.delete();
    await logout();
  }

  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    final user = currentUser;
    if (user == null) throw StateError('No signed-in user');
    final credential = auth.EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  // Enhancement 2: Authenticate with Firebase first, then support existing
  // DummyJSON accounts as a fallback.
  Future<User> login(String email, String password) async {
    try {
      final credential = await signIn(email: email, password: password);
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Login failed');
      }

      final user = await getUserData();
      await saveUser(user);
      return user;
    } on auth.FirebaseAuthException {
      final response = await _client
          .post(
            Uri.parse('$host/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': email,
              'password': password,
              'expiresInMins': 30,
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Account not found or email/password is incorrect.');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid login response');
      }
      final user = User.fromJson(decoded);
      await saveUser(user);
      return user;
    }
  }

  // Enhancement 3: Fetch the signed-in user's profile data from Firebase Auth.
  Future<User> getUserData() async {
    final firebaseUser = currentUser;
    if (firebaseUser == null) throw StateError('No signed-in user');
    await firebaseUser.reload();
    final refreshedUser = currentUser;
    if (refreshedUser == null) throw StateError('No signed-in user');
    final email = refreshedUser.email ?? '';
    return User(
      id: refreshedUser.uid.hashCode,
      username: refreshedUser.displayName ?? email.split('@').first,
      email: email,
      firstName: refreshedUser.displayName ?? '',
      lastName: '',
      gender: '',
      image: refreshedUser.photoURL ?? '',
      accessToken: '',
      refreshToken: '',
    );
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

  // Enhancement 1: Sign out of Firebase and clear the locally saved session.
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  void dispose() => _client.close();
}
