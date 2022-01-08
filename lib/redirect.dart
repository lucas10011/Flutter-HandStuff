// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:hand_stuff/login.dart';
// import 'package:hand_stuff/models/state.dart';
// import 'package:hand_stuff/services/state_widget.dart';

// class LandingPage extends StatelessWidget {
//   final Widget widget;
//   LandingPage({this.widget});
//   StateModel appState;

//     @override
//     Widget build(BuildContext context) {
//       appState = StateWidget.of(context).state;
      

//       if (!appState.isLoading &&
//           (appState.firebaseUserAuth == null ||
//               appState.user == null ||
//               appState.settings == null)) {
//         return LoginPage();
//       } else {
//         return widget;
//     }
//   }
// }