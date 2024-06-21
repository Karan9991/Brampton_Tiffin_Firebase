class CreateKitchen{
  String? id;
  String? name;
  String? banner;

  CreateKitchen({this.id, this.name, this.banner});

  factory CreateKitchen.fromJson(String id, Map<String, dynamic> json){
    return CreateKitchen(id: id, name: json['name'], banner: json['banner']);
  }

  Map<String, dynamic> toJson(){
    final data = Map<String, dynamic>();
    data['name'] = this.name;
    data['banner'] = this.banner;
    return data;
  }

}