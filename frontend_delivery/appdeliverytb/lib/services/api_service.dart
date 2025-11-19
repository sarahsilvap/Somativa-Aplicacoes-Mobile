import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // coloque aqui o IP/porta do backend Django
  static const String baseUrl = "http://10.0.2.2:8000/api";

  static Future<dynamic> get(String path) async {
    final url = Uri.parse("$baseUrl$path");
    final response = await http.get(url);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erro GET $path: ${response.statusCode}");
    }
  }

  static Future<dynamic> post(String path, Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl$path");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erro POST $path: ${response.statusCode}");
    }
  }
}
