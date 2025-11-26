class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String image;
  final int restaurant;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.restaurant,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: double.parse(json['price'].toString()),
      image: json['image'] ?? '',
      restaurant: json['restaurant'],
    );
  }
}
