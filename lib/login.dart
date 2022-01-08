import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/services.dart';
import 'package:hand_stuff/homepage.dart';


import 'package:hand_stuff/services/auth.dart';
import 'package:hand_stuff/services/state_widget.dart';
import 'package:hand_stuff/services/validator.dart';
import 'package:hand_stuff/widgets/loading.dart';

class LoginPage extends StatefulWidget {
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = new TextEditingController();
  final TextEditingController _password = new TextEditingController();

  bool _autoValidate = false;
  bool _loadingVisible = false;
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'logo',
      child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 60.0,
          child: ClipOval(
            child: Image.asset(
              'assets/images/logom.png',
              fit: BoxFit.cover,
              width: 120.0,
              height: 120.0,
            ),
          )),
    );

    final namelogo = FlatButton(
      child: Text(
        'MyMatter',
        style: TextStyle(color: Colors.white,fontSize: 25),
      ),
      onPressed: () {
      },
    );

    final email = TextFormField(
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      controller: _email,
      validator: Validator.validateEmail,
      style: TextStyle(color:Colors.white),
      decoration: InputDecoration(
        labelStyle: TextStyle(
          color: Colors.white,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.email,
            color: Colors.white,
          ), // icon is 48px widget.
        ), // icon is 48px widget.
        hintText: 'Email',
        hintStyle: TextStyle(color: Colors.white),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0)
          ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 0.0),
          borderRadius: BorderRadius.circular(32.0),
        )
      ),
    );

    final password = TextFormField(
      autofocus: false,
      obscureText: true,
      controller: _password,
      validator: Validator.validatePassword,
      style: TextStyle(color:Colors.white),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.lock,
            color: Colors.white,
          ), // icon is 48px widget.
        ), // icon is 48px widget.
        hintText: 'Password',
        hintStyle: TextStyle(color: Colors.white),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0),
          ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 0.0),
          borderRadius: BorderRadius.circular(32.0),
        )

      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          _emailLogin(
              email: _email.text, password: _password.text, context: context);
        },
        padding: EdgeInsets.all(12),
        color: Theme.of(context).primaryColor,
        child: Text('SIGN IN', style: TextStyle(color: Colors.white)),
      ),
    );

    final forgotLabel = FlatButton(
      child: Text(
        'Forgot password?',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        Navigator.pushNamed(context, '/forgot-password');
      },
    );

    final signUpLabel = FlatButton(
      child: Text(
        'Criar uma conta',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        Navigator.pushNamed(context, '/signup');
      },
    );

    return Scaffold(
      body: LoadingScreen(
          child: Form(
            key: _formKey,
            autovalidate: _autoValidate,
            child: Container(
              decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          stops: [0.3, 1],
                          colors: [
                            Color(0xFF1A2980),
                            Color(0XFF26D0CE),
                          ],
                        ),
                      ),
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      logo,
                      SizedBox(height: 12.0),
                      namelogo,
                      SizedBox(height: 48.0),
                      email,
                      SizedBox(height: 24.0),
                      password,
                      SizedBox(height: 12.0),
                      loginButton,
                      forgotLabel,
                      signUpLabel
                    ],
                  ),
                ),
              ),
            ),
          ),
          inAsyncCall: _loadingVisible),
    );
  }

  Future<void> _changeLoadingVisible() async {
    setState(() {
      _loadingVisible = !_loadingVisible;
    });
  }

  void _emailLogin(
      {String email, String password, BuildContext context}) async {
    if (_formKey.currentState.validate()) {
      try {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        await _changeLoadingVisible();
        //need await so it has chance to go through error if found.
        bool status = await StateWidget.of(context).logInUser(email, password);
        if(status){
          Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (c, a1, a2) => new Home(),
                        transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                        transitionDuration: Duration(milliseconds: 400),
                      )
            );
        }

        await _changeLoadingVisible();

      } catch (e) {
        _changeLoadingVisible();
        print("Sign In Error: $e");
        String exception = Auth.getExceptionText(e);
        Flushbar(
          title: "Sign In Error",
          message: exception,
          duration: Duration(seconds: 5),
        )..show(context);
      }
    } else {
      setState(() => _autoValidate = true);
    }
  }
}