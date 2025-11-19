import 'dart:convert';
import 'package:http/http.dart';
import '../services/api_service.dart';

class AuthService {
  static Future<bool> login(String username, String password) async {
    final Response resp = await ApiService.post(
      "/auth/login/",
      {
        "username": username,
        "password": password,
      },
    );

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return true;
    }

    return false;
  }
}
