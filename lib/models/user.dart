class Users{
  String? email;
  String? user_type;

  Users({this.email, this.user_type});

  factory Users.fromJson(Map<String, dynamic> json){
    return Users(email: json['email'], user_type: json['user_type']);
  }

  Map<String, dynamic> toJson(){
    final data = Map<String, dynamic>();
    data['email'] = this.email;
    data['user_type'] = this.user_type;
    return data;
  }

}