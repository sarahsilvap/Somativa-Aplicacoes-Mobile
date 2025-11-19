import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/model/restaurant.dart';

class RestaurantService {
  static Future<List<RestaurantModel>> getRestaurants() async {
    final data = await ApiService.get("/restaurants/");

    return (data as List).map((e) => RestaurantModel.fromJson(e)).toList();
  }

  static Future<List<RestaurantModel>> getRestaurantsByCategory(String category) async {
    final data = await ApiService.get("/restaurants/?category=$category");
    return (data as List).map((e) => RestaurantModel.fromJson(e)).toList();
  }
}
