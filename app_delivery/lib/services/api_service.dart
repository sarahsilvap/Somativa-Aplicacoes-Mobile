import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/category.dart';
import '../models/restaurant.dart';
import '../models/product.dart';

class ApiService {
  static String _buildUrl(String endpoint) {
    final baseUrl = ApiConfig.baseUrl.trim();
    final cleanEndpoint = endpoint.trim();
    final url = '$baseUrl$cleanEndpoint';
    print('[API] Building URL: $url'); // Debug log
    return url;
  }

  static Future<Map<String, String>> _getHeaders({String? token}) async {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Auth
  static Future<Map<String, dynamic>> register(
      String username, String password) async {
    try {
      final url = _buildUrl(ApiConfig.register);
      print('[API] Register URL: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      print('[API] Register error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    try {
      final url = _buildUrl(ApiConfig.login);
      print('[API] Login URL: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: jsonEncode({'username': username, 'password': password}),
      );

      print('[API] Login response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      print('[API] Login error: $e');
      throw Exception('Login failed: $e');
    }
  }

  // Categories
  static Future<List<Category>> getCategories() async {
    final url = _buildUrl(ApiConfig.categories);
    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // Restaurants
  static Future<List<Restaurant>> getRestaurants() async {
    final url = _buildUrl(ApiConfig.restaurants);
    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Restaurant.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load restaurants');
    }
  }

  // Products
  static Future<List<Product>> getProducts() async {
    final url = _buildUrl(ApiConfig.products);
    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  // Create Order
  static Future<Map<String, dynamic>> createOrder({
    required String token,
    required List<Map<String, dynamic>> items,
    required String address,
    required double total,
  }) async {
    try {
      final url = _buildUrl(ApiConfig.orders);
      final headers = await _getHeaders(token: token);

      print('[API] Create Order URL: $url');
      print(
          '[API] Token (first 20 chars): ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
      print('[API] Authorization Header: ${headers['Authorization']}');
      print('[API] Order items: ${items.length}');
      print('[API] Total: $total');
      print('[API] Address: $address');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          'items': items,
          'address': address,
          'total': total,
        }),
      );

      print('[API] Order response status: ${response.statusCode}');
      print('[API] Order response body: ${response.body}');

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create order: ${response.body}');
      }
    } catch (e) {
      print('[API] Create order error: $e');
      rethrow;
    }
  }
}
