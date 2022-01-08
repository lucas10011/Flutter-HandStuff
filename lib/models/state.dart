import 'package:firebase_auth/firebase_auth.dart';
import 'package:hand_stuff/models/todo.dart';
import 'package:hand_stuff/models/settings.dart';


class StateModel {
  bool isLoading;
  User firebaseUserAuth;
  UserEstudante user;
  SettingsEstudante settings;

  StateModel({
    this.isLoading = false,
    this.firebaseUserAuth,
    this.user,
    this.settings,
  });
}