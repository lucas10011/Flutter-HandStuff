import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
// To parse this JSON data, do
//
//     final SettingsEstudante = settingsFromJson(jsonString);

SettingsEstudante settingsFromJson(String str) {
  final jsonData = json.decode(str);
  return SettingsEstudante.fromJson(jsonData);
}

String settingsToJson(SettingsEstudante data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class SettingsEstudante {
  String settingsId;

  SettingsEstudante({
    this.settingsId,
  });

  factory SettingsEstudante.fromJson(Map<String, dynamic> json) => new SettingsEstudante(
        settingsId: json["settingsId"],
      );

  Map<String, dynamic> toJson() => {
        "settingsId": settingsId,
      };

  factory SettingsEstudante.fromDocument(DocumentSnapshot doc) {
    return SettingsEstudante.fromJson(doc.data());
  }
}