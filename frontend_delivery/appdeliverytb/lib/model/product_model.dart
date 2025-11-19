import 'package:appdeliverytb/model/dish.dart';

class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String image;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : json['price'],
      image: json['image'] ?? '',
    );
  }

  
factory ProductModel.fromDish(Dish dish) {
  return ProductModel(
    id: dish.id.hashCode,
    name: dish.name,
    description: dish.description,
    price: dish.price.toDouble(),
    image: dish.imagePath,
  );
}


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
    };
  }
}
