class PublishTiffin{
  String? id;
  String? name;
  int? price;
  String? description;
  String? image;

  PublishTiffin({this.id, this.name, this.price, this.description, this.image});

  factory PublishTiffin.fromJson(String id, Map<String, dynamic> json){
    return PublishTiffin(id: id, name: json['name'], price: json['price'], description: json['description'],
    image: json['image']);
  }

  Map<String, dynamic> toJson(){
    final data = Map<String, dynamic>();
    data['name'] = this.name;
    data['price'] = this.price;
    data['description'] = this.description;
    data['image'] = this.image;
    return data;
  }

}