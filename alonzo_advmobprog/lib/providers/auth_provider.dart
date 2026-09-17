import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../models/user.dart';
import '../services/user_service.dart';

enum AuthStatus { checking, authenticating, signedOut, signedIn }

class AuthProvider with ChangeNotifier {
  final UserService _service;
  AuthStatus _status = AuthStatus.checking;
  User? _user;
  String? _error;
  String? _notice;
  bool _busy = false;

  AuthProvider({UserService? service}) : _service = service ?? UserService() {
    restoreSession();
  }

  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;
  bool get isBusy => _busy;

  String? takeNotice() {
    final notice = _notice;
    _notice = null;
    return notice;
  }

  Future<void> restoreSession() async {
    // Keep the splash visible briefly so the session-loading state is clear.
    final savedUserFuture = _service.getSavedUser();
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    _user = await savedUserFuture;
    _status = _user == null ? AuthStatus.signedOut : AuthStatus.signedIn;
    notifyListeners();
  }

  Future<bool> signIn(String username, String password) async {
    _busy = true;
    // Enhancement 1: Show the full splash loading page while login is running.
    _status = AuthStatus.authenticating;
    _error = null;
    notifyListeners();
    try {
      // Keep the splash visible long enough to communicate that login is in progress.
      final loginFuture = _service.login(username, password);
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      _user = await loginFuture;
      _status = AuthStatus.signedIn;
      return true;
    } catch (error) {
      _error = error.toString().replaceFirst('Exception: ', '');
      if (_error == 'Login failed') {
        _error = 'Account not found or email/password is incorrect.';
      }
      _notice = _error;
      _status = AuthStatus.signedOut;
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  // Enhancement 3: Request a password reset for a Firebase account.
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _service.sendPasswordResetEmail(email: email);
      return true;
    } on firebase_auth.FirebaseAuthException catch (error) {
      _error = switch (error.code) {
        'user-not-found' => 'Account not found.',
        _ => error.message ?? 'Unable to send password reset email',
      };
      return false;
    } catch (error) {
      _error = error.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }

  // Enhancement 2: Create a Firebase account and persist its signed-in user.
  Future<bool> createAccount(
    String email,
    String password,
    String username,
  ) async {
    _busy = true;
    _status = AuthStatus.authenticating;
    _error = null;
    notifyListeners();
    try {
      await _service.createAccount(email: email, password: password);
      await _service.updateUsername(username: username);
      _user = await _service.login(email, password);
      _status = AuthStatus.signedIn;
      return true;
    } catch (error) {
      _error = error.toString().replaceFirst('Exception: ', '');
      _status = AuthStatus.signedOut;
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  // Enhancement 3: Update the signed-in user's account details.
  Future<bool> updateUsername(String username) async {
    try {
      await _service.updateUsername(username: username);
      _user = await _service.getUserData();
      await _service.saveUser(_user!);
      return true;
    } catch (error) {
      _error = error.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final firebaseEmail = _service.currentUser?.email;
      if (firebaseEmail == null || firebaseEmail.isEmpty) {
        throw StateError('Password changes require a Firebase account');
      }
      await _service.resetPasswordFromCurrentPassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        email: firebaseEmail,
      );
      return true;
    } on firebase_auth.FirebaseAuthException catch (error) {
      _error = switch (error.code) {
        'invalid-credential' ||
        'wrong-password' => 'The current password is incorrect.',
        'requires-recent-login' =>
          'Please sign in again before changing your password.',
        _ => error.message ?? 'Unable to change password',
      };
      return false;
    } catch (error) {
      _error = error.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }

  Future<bool> deleteAccount(String password) async {
    try {
      final firebaseEmail = _service.currentUser?.email;
      if (firebaseEmail == null || firebaseEmail.isEmpty) {
        throw StateError('Account deletion requires a Firebase account');
      }
      await _service.deleteAccount(email: firebaseEmail, password: password);
      _user = null;
      _status = AuthStatus.signedOut;
      _notice = 'Account deleted successfully';
      notifyListeners();
      return true;
    } catch (error) {
      _error = error.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }

  Future<void> signOut() async {
    await _service.logout();
    _user = null;
    _status = AuthStatus.signedOut;
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
