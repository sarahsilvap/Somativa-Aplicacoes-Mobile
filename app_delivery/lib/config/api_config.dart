class ApiConfig {
  // Change this to your backend URL
  static const String baseUrl = 'http://127.0.0.1:8000//api'; // Android emulator
  // For iOS simulator use: 'http://localhost:8000/api'
  // For real device use your machine's IP: 'http://192.168.1.XXX:8000/api'
  
  // Endpoints
  static const String categories = '/categories/';
  static const String restaurants = '/restaurants/';
  static const String products = '/products/';
  static const String register = '/auth/register/';
  static const String login = '/auth/login/';
  static const String tokenRefresh = '/auth/token/refresh/';
  static const String orders = '/orders/';
}
