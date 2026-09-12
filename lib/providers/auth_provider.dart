import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;

  bool _isLoading = false;

  String? _error;

  UserModel? get user => _user;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> loadUser() async {
    _setLoading(true);

    try {
      _user = await _authService.getCurrentUser();
    } catch (e) {
      _error = e.toString();
    }

    _setLoading(false);
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);

    try {
      _user = await _authService.login(email: email, password: password);

      _error = null;

      return true;
    } catch (e) {
      _error = e.toString();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    _setLoading(true);

    try {
      _user = await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );

      _error = null;

      return true;
    } catch (e) {
      _error = e.toString();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();

      _user = null;

      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _setLoading(false);
  }

  void clearError() {
    _error = null;

    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;

    notifyListeners();
  }
}
