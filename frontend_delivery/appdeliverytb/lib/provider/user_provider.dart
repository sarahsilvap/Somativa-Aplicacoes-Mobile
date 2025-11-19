// lib/provider/user_provider.dart
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _userName = "Usuário Teste";

  String get userName => _userName;

  bool get isLogged => _userName.isNotEmpty;

  void setUser(String name) {
    _userName = name;
    notifyListeners();
  }

  void logout() {
    _userName = "";
    notifyListeners();
  }
}
