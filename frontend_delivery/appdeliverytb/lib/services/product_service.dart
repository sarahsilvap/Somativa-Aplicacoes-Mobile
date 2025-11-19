import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/model/product_model.dart';

class ProductService {
  static Future<List<Product>> getProducts(int restaurantId) async {
    final data = await ApiService.get("/products/?restaurant=$restaurantId");
    return (data as List).map((e) => Product.fromJson(e)).toList();
  }
}
