import 'dart:convert';

class UserModel {
  final String email;
  final String sub;
  UserModel({
    required this.email,
    required this.sub,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'sub': sub,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] as String,
      sub: map['sub'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
