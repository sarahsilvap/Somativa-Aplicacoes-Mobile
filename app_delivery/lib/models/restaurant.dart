import 'product.dart';

class Restaurant {
  final int id;
  final String name;
  final String description;
  final String image;
  final int? category;
  final List<Product> products;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    this.category,
    this.products = const [],
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    var productsList = <Product>[];
    if (json['products'] != null) {
      productsList = (json['products'] as List)
          .map((p) => Product.fromJson(p))
          .toList();
    }

    return Restaurant(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      category: json['category'],
      products: productsList,
    );
  }
}
