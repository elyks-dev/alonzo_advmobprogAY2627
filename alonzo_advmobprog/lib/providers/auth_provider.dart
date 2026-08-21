import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/user_service.dart';

enum AuthStatus { checking, authenticating, signedOut, signedIn }

class AuthProvider with ChangeNotifier {
  final UserService _service;
  AuthStatus _status = AuthStatus.checking;
  User? _user;
  String? _error;
  bool _busy = false;

  AuthProvider({UserService? service}) : _service = service ?? UserService() {
    restoreSession();
  }

  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;
  bool get isBusy => _busy;

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
      _status = AuthStatus.signedOut;
      return false;
    } finally {
      _busy = false;
      notifyListeners();
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
