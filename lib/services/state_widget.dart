import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hand_stuff/homepage.dart';
import 'package:hand_stuff/models/settings.dart';
import 'package:hand_stuff/models/state.dart';
import 'package:hand_stuff/models/todo.dart';
import 'package:hand_stuff/services/auth.dart';


class StateWidget extends StatefulWidget {
  final StateModel state;
  final Widget child;

  StateWidget({
    @required this.child,
    this.state,
  });

  // Returns data of the nearest widget _StateDataWidget
  // in the widget tree.
  static _StateWidgetState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_StateDataWidget)
            as _StateDataWidget)
        .data;
  }

  @override
  _StateWidgetState createState() => new _StateWidgetState();
}

class _StateWidgetState extends State<StateWidget> {
  StateModel state;
  //GoogleSignInAccount googleAccount;
  //final GoogleSignIn googleSignIn = new GoogleSignIn();

  @override
  void initState() {
    super.initState();
    if (widget.state != null) {
      state = widget.state;
    } else {
      state = new StateModel(isLoading: false);
    }
  }

 
  Future<void> logOutUser() async {
    await Auth.signOut();
    setState(() {
      state.user = null;
      state.settings = null;
      state.firebaseUserAuth = null;
      state.isLoading = false;
    });
  }

  Future<bool> logInUser(email, password) async {
    print(email);
    print(password);
    String userId = await Auth.signIn(email, password);
    print('Auth.signIn:');
    User firebaseUserAuth = await Auth.getCurrentFirebaseUser();
    print('Auth.getCurrentFirebaseUser:');
    UserEstudante user = await Auth.getUserFirestore(userId);
    print('Auth.getUserFirestore:');
    SettingsEstudante settings = await Auth.getSettingsFirestore(userId);
    print('Auth.getSettingsFirestore:');

    setState(() {
      state.isLoading = false;
      state.firebaseUserAuth = firebaseUserAuth;
      state.user = user;
      state.settings = settings;
    });

    if((firebaseUserAuth != null || user != null || settings != null)) {
          return true;
    }else{
          return false;
    }

  
  }

  @override
  Widget build(BuildContext context) {
    return new _StateDataWidget(
      data: this,
      child: widget.child,
    );
  }
}

class _StateDataWidget extends InheritedWidget {
  final _StateWidgetState data;

  _StateDataWidget({
    Key key,
    @required Widget child,
    @required this.data,
  }) : super(key: key, child: child);

  // Rebuild the widgets that inherit from this widget
  // on every rebuild of _StateDataWidget:
  @override
  bool updateShouldNotify(_StateDataWidget old) => true;
}