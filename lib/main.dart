
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hand_stuff/homepage.dart';
import 'package:hand_stuff/login.dart';
import 'package:hand_stuff/login_pages/reset-password.page.dart';
import 'package:hand_stuff/login_pages/signup.page.dart';
import 'package:hand_stuff/redirect.dart';
import 'package:hand_stuff/services/state_widget.dart';

const debug = true;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //flutter downloader nao tem suporte no flutter web
  // await FlutterDownloader.initialize(debug: debug);
  await Firebase.initializeApp();
  StateWidget stateWidget = new StateWidget(
    child: new MyApp(),
  );
  

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
    .then((_) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
      runApp(stateWidget);
    });
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'MyMatter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'SpaceMono'),
      // home: HomePage(),
      routes: {
        '/': (context) => LoginPage(),
        '/signup': (context) => SignUpScreen(),
        '/reset': (context) => ResetPasswordPage(),
        '/sigin': (context) => LoginPage()

      },
    );
  }
}






