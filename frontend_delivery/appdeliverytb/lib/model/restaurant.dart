class RestaurantModel {
  final int id;
  final String name;
  final String image;
  final String description;
  final String category;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.category,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json["id"],
      name: json["nome"],
      image: json["imagem"],
      description: json["descricao"],
      category: json["categoria"],
    );
  }
}
