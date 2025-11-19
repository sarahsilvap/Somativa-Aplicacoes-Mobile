class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final int restaurantId;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.restaurantId,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        name: json["nome"],
        description: json["descricao"],
        price: double.tryParse(json["preco"].toString()) ?? 0,
        restaurantId: json["restaurante"],
      );
}
