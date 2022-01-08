import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

// To parse this JSON data, do
//
//     final UserEstudante = userFromJson(jsonString);

UserEstudante userFromJson(String str) {
  final jsonData = json.decode(str);
  return UserEstudante.fromJson(jsonData);
}

String userToJson(UserEstudante data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class UserEstudante {
  String id;
  String token;
  String user_nome;
  String user_status;
  String user_descricao;
  String user_foto;
  String createdAt;
  String chattingWith;
  int user_bytes;


  UserEstudante({
    this.id,
    this.token,
    this.user_nome,
    this.user_status,
    this.user_descricao,
    this.user_foto,
    this.createdAt,
    this.chattingWith,
    this.user_bytes,
  });

  factory UserEstudante.fromJson(Map<String, dynamic> json) => new UserEstudante(
        id: json["id"],
        token: json["token"],
        user_nome: json["user_nome"],
        user_status: json["user_status"],
        user_descricao: json["user_descricao"],
        user_foto: json["user_foto"],
        createdAt: json["createdAt"],
        chattingWith: json["chattingWith"],
        user_bytes: json["user_bytes"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "token": token,
        "user_nome": user_nome,
        "user_status": user_status,
        "user_descricao": user_descricao,
        "user_foto": user_foto,
        "createdAt": createdAt,
        "chattingWith": chattingWith,
        "user_bytes": user_bytes,
      };

  factory UserEstudante.fromDocument(DocumentSnapshot doc) {
    return UserEstudante.fromJson(doc.data());
  }
}