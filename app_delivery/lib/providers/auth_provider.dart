import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _username;
  String? _accessToken;
  bool _isLoading = true;

  bool get isAuthenticated => _isAuthenticated;
  String? get username => _username;
  String? get accessToken => _accessToken;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    _isLoading = true;
    notifyListeners();

    final token = await StorageService.getAccessToken();
    final savedUsername = await StorageService.getUsername();

    if (token != null && savedUsername != null) {
      _isAuthenticated = true;
      _accessToken = token;
      _username = savedUsername;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> register(String username, String password) async {
    try {
      await ApiService.register(username, password);
      // After registration, login automatically
      await login(username, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> login(String username, String password) async {
    try {
      final response = await ApiService.login(username, password);
      
      _accessToken = response['access'];
      _username = username;
      _isAuthenticated = true;

      await StorageService.saveTokens(
        response['access'],
        response['refresh'],
      );
      await StorageService.saveUsername(username);

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _username = null;
    _accessToken = null;

    await StorageService.clearAll();
    notifyListeners();
  }
}
