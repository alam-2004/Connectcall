import 'dart:async';

import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  List<UserModel> _users = [];

  bool _isLoading = false;

  String _searchQuery = '';

  StreamSubscription? _subscription;

  List<UserModel> get users {
    if (_searchQuery.isEmpty) {
      return _users;
    }

    return _users.where((user) {
      return user.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  bool get isLoading => _isLoading;

  void listenToUsers(String currentUserId) {
    _isLoading = true;

    notifyListeners();

    _subscription?.cancel();

    _subscription = _userService.getUsers(currentUserId).listen((users) {
      _users = users;

      _isLoading = false;

      notifyListeners();
    });
  }

  void searchUsers(String query) {
    _searchQuery = query;

    notifyListeners();
  }

  Future<void> updateProfile({
    required String uid,
    String? name,
    String? photoUrl,
  }) async {
    await _userService.updateProfile(uid: uid, name: name, photoUrl: photoUrl);
  }

  @override
  void dispose() {
    _subscription?.cancel();

    super.dispose();
  }
}
