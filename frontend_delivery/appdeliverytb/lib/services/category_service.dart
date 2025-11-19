import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/model/category.dart';

class CategoryService {
  static Future<List<Category>> getCategories() async {
    final data = await ApiService.get("/categories/");

    return (data as List).map((e) => Category.fromJson(e)).toList();
  }
}
