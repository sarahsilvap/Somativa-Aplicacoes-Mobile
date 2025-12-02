class ApiConfig {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // For different environments:
  // Android emulator: 'http://10.0.2.2:8000'
  // iOS simulator: 'http://localhost:8000'
  // Real device: 'http://192.168.1.XXX:8000' (your machine's local IP)

  // Endpoints (include /api prefix)
  static const String categories = '/api/categories/';
  static const String restaurants = '/api/restaurants/';
  static const String products = '/api/products/';
  static const String register = '/api/auth/register/';
  static const String login = '/api/auth/login/';
  static const String tokenRefresh = '/api/auth/token/refresh/';
  static const String orders = '/api/orders/';
}
