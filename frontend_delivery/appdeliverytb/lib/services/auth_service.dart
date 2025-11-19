import 'package:mobile_app/services/api_service.dart';

class AuthService {
  static Future<bool> login(String username, String password) async {
    final resp = await ApiService.post("/login/", {
      "username": username,
      "password": password,
    });

    return resp["status"] == "ok";
  }

  static Future<bool> register(String username, String email, String password) async {
    final resp = await ApiService.post("/register/", {
      "username": username,
      "email": email,
      "password": password,
    });

    return resp["status"] == "ok";
  }
}
