class Tiffin {
  int id;
  String name;
  String description;
  String image;
  String price;

  Tiffin(
      {required this.id,
      required this.name,
      required this.description,
      required this.image,
      required this.price});

  factory Tiffin.fromJson(Map<String, dynamic> json) {
    return Tiffin(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      price: json['price'] ?? 0.0,
    );
  }
}