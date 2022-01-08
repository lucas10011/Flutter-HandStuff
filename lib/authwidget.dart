// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:hand_stuff/login.dart';


// class AuthWidget extends StatelessWidget {
//   final Widget widget;
//   final Stream authwidgetfirebase;
//   AuthWidget({this.widget,@required this.authwidgetfirebase});

//   @override
//   Widget build(BuildContext context) {
//     print('AuthWidgtet');
//     return StreamBuilder<FirebaseUser>(
//       stream: authwidgetfirebase,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.active) {
//           FirebaseUser user = snapshot.data;
//           if (user == null) {
//             print('User == null');
//             return LoginPage();
//           }
//           return widget;
//         } else {
//           return Scaffold(
//             body: Center(
//               child: CircularProgressIndicator(),
//             ),
//           );
//         }
//       },
//     );
//   }
// }