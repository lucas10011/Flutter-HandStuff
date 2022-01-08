import 'dart:async';
//import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/services.dart';
import 'package:hand_stuff/models/settings.dart';
import 'package:hand_stuff/models/todo.dart';


enum authProblems { UserNotFound, PasswordNotValid, NetworkError, UnknownError }

class Auth {
  static Future<String> signUp(String email, String password) async {
    User user = (await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password)).user;
    return user.uid;
  }

  static void addUserSettingsDB(UserEstudante user) async {
    checkUserExist(user.id).then((value) {
      if (!value) {
        print("user ${user.user_nome} ${user.token} added");
        Firestore.instance
            .document("users/${user.id}")
            .setData(user.toJson());
        _addSettings(new SettingsEstudante(
          settingsId: user.id,
        ));
      } else {
        print("user ${user.user_nome} ${user.token} exists");
      }
    });
  }

  static Future<bool> checkUserExist(String id) async {
    bool exists = false;
    try {
      await Firestore.instance.document("users/$id").get().then((doc) {
        if (doc.exists)
          exists = true;
        else
          exists = false;
      });
      return exists;
    } catch (e) {
      return false;
    }
  }

  static void _addSettings(SettingsEstudante settings) async {
    Firestore.instance
        .document("settings/${settings.settingsId}")
        .setData(settings.toJson());
  }
  static Stream<String> get onAuthStateChanged {
    return FirebaseAuth.instance.onAuthStateChanged.map((User user) => user?.uid);
  }

  static Future<String> signIn(String email, String password) async {
    User user = (await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password)).user;
    return user.uid;
  }

  static Future<UserEstudante> getUserFirestore(String id) async {
    if (id != null) {
      return Firestore.instance
          .collection('users')
          .document(id)
          .get()
          .then((documentSnapshot) => UserEstudante.fromDocument(documentSnapshot));
    } else {
      print('firestore userId can not be null');
      return null;
    }
  }

  static Future<SettingsEstudante> getSettingsFirestore(String settingsId) async {
    if (settingsId != null) {
      return Firestore.instance
          .collection('settings')
          .document(settingsId)
          .get()
          .then((documentSnapshot) => SettingsEstudante.fromDocument(documentSnapshot));
    } else {
      print('no firestore settings available');
      return null;
    }
  }

  static Future<String> storeUserLocal(UserEstudante user) async {

    String storeUser = userToJson(user);
    return user.id;
  }

  static Future<String> storeSettingsLocal(SettingsEstudante settings) async {

    String storeSettings = settingsToJson(settings);
    
    return settings.settingsId;
  }

  static Future<User> getCurrentFirebaseUser() async {
    User currentUser = await FirebaseAuth.instance.currentUser;
    print(currentUser);
    return currentUser;
  }

  static Future<UserEstudante> getUserLocal() async {


    User currentUser = await FirebaseAuth.instance.currentUser;
    UserEstudante user = await getUserFirestore(currentUser.uid);
    return user;
  }

  // static Future<SettingsEstudante> getSettingsLocal() async {
  //   User currentUser = await FirebaseAuth.instance.currentUser;
  //   SettingsEstudante user = await getUserFirestore(currentUser.uid);
  // }

  static Future<void> signOut() async {

    await FirebaseAuth.instance.signOut();
  }

  static Future<void> forgotPasswordEmail(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  static String getExceptionText(Exception e) {
    if (e is PlatformException) {
      switch (e.message) {
        case 'There is no user record corresponding to this identifier. The user may have been deleted.':
          return 'User with this email address not found.';
          break;
        case 'The password is invalid or the user does not have a password.':
          return 'Invalid password.';
          break;
        case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
          return 'No internet connection.';
          break;
        case 'The email address is already in use by another account.':
          return 'This email address already has an account.';
          break;
        default:
          return 'Unknown error occured.';
      }
    } else {
      return 'Unknown error occured.';
    }
  }

  /*static Stream<User> getUserFirestore(String userId) {
    print("...getUserFirestore...");
    if (userId != null) {
      //try firestore
      return Firestore.instance
          .collection("users")
          .where("userId", isEqualTo: userId)
          .snapshots()
          .map((QuerySnapshot snapshot) {
        return snapshot.documents.map((doc) {
          return User.fromDocument(doc);
        }).first;
      });
    } else {
      print('firestore user not found');
      return null;
    }
  }*/

  /*static Stream<Settings> getSettingsFirestore(String settingsId) {
    print("...getSettingsFirestore...");
    if (settingsId != null) {
      //try firestore
      return Firestore.instance
          .collection("settings")
          .where("settingsId", isEqualTo: settingsId)
          .snapshots()
          .map((QuerySnapshot snapshot) {
        return snapshot.documents.map((doc) {
          return Settings.fromDocument(doc);
        }).first;
      });
    } else {
      print('no firestore settings available');
      return null;
    }
  }*/
}