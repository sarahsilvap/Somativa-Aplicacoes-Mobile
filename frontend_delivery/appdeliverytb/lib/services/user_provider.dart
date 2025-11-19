// lib/provider/user_provider.dart
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _userName = "";
  String? _token;

  String get userName => _userName;
  String? get token => _token;
  bool get isLogged => (_token != null && _token!.isNotEmpty);

  void setUser(String name) {
    _userName = name;
    notifyListeners();
  }

  void setToken(String token, {String? username}) {
    _token = token;
    if (username != null) _userName = username;
    notifyListeners();
  }

  void clearUser() {
    _userName = "";
    _token = null;
    notifyListeners();
  }
}
