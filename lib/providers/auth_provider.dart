import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userName;

  bool get isAuthenticated => _isAuthenticated;
  String? get userName => _userName;

  AuthProvider() {
    _loadAuthState();
  }

  Future<bool> login(String username, String password) async {
    // Mock authentication: accept any non-empty username/password
    if (username.isNotEmpty && password.isNotEmpty) {
      _isAuthenticated = true;
      _userName = username;
      await _saveAuthState();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _userName = null;
    await _saveAuthState();
    notifyListeners();
  }

  Future<void> _saveAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth', json.encode({
      'isAuthenticated': _isAuthenticated,
      'userName': _userName,
    }));
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final authJson = prefs.getString('auth');
    if (authJson != null) {
      final decoded = json.decode(authJson);
      _isAuthenticated = decoded['isAuthenticated'] ?? false;
      _userName = decoded['userName'];
      notifyListeners();
    }
  }
}