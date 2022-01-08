import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:hand_stuff/chat_pages/home_chat.dart';
import 'package:hand_stuff/models/state.dart';
import 'package:hand_stuff/services/state_widget.dart';
import 'package:hand_stuff/user_pages/user_profile.dart';
import 'package:animator/animator.dart';

class DrawerCustom extends StatefulWidget {
   final String currentUserId;
  DrawerCustom({this.currentUserId});
  @override
  _DrawerCustomState createState() => _DrawerCustomState(currentUserId:currentUserId);
}

class _DrawerCustomState extends State<DrawerCustom> {
  final String currentUserId;
  _DrawerCustomState({this.currentUserId});

  Stream<QuerySnapshot> messages;
  StateModel appState;

  @override
  void initState() {
    // userInfo();
    setState(() {
      messages = Firestore.instance.collection('users').document("$currentUserId").collection('messages').where('read', isEqualTo: false).snapshots();
    });
    super.initState();
  }

void _logout()  {
  Flushbar(
          title: "Logout...",
          message: "",
          duration: Duration(seconds: 1),
        )..show(context);
     StateWidget.of(context).logOutUser();
     Navigator.popUntil(context, ModalRoute.withName('/'));
     
  }


 Widget buildImage(photouser){
    return Animator(
      tween:Tween<double>(begin: 0.8,end: 1.4),
      curve: Curves.elasticOut,
      cycles: 0,
      builder: (anim) => Transform.scale(
            scale: anim.value,
            child: photouser != null
                ? new ClipRRect(
                          borderRadius: new BorderRadius.circular(40.0),
                          child: Image.network(photouser,fit: BoxFit.cover,
                                  width: 60.0,
                                  height: 60.0,
                                  loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                                  if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null ? 
                                            loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                            : null,
                                      ),
                                    );
                                  },
                                ),      
                      )
                      
                  : new SizedBox(width: 60.0,
                                  height: 60.0,)
          ),
    );
    
  }

 Widget buildName(nameuser){
    return Text(
      "$nameuser",
      style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w500));
  }

 Widget buildEmail(emailuser){
    return Text(
      "$emailuser",
      style: TextStyle(
          color: Colors.white,
          fontSize: 13.0,
          fontWeight: FontWeight.w500));
  }

  Widget buildMessages(){
    return ListTile(
      leading: Icon(
        Icons.chat_bubble,
        color: Theme.of(context).primaryColor
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
        Text("Mensagens"),
        new StreamBuilder(
          stream: messages,
          builder:(context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Container(
                    ),
                  );
                } else {
                  return Stack(children: <Widget>[
                    snapshot.data.documents.length != 0 ?  new Container(
                          padding: EdgeInsets.all(5),
                          decoration: new BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                          ),
                          child: Text(
                              '${snapshot.data.documents.length}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                          ),
                        ): new Container()
                  ],);                                    
                  }
                }
              ),
            ],
          ),
        onTap: (){
          Navigator.pop(context);
          return Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (c, a1, a2) => new HomeMessages(currentUserId: "$currentUserId"),
                          transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                          transitionDuration: Duration(milliseconds: 400),
                        ),
                      );
        },
      );
  }

  Widget buildProfile(){
    return ListTile(
                  leading: Icon(
                    Icons.person,
                    color: Theme.of(context).primaryColor
                  ),
                  title:
                    Text("Meu perfil"), 
                    onTap: (){
                      Navigator.pop(context);
                      return Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (c, a1, a2) => new UserProfilePage(currentUserId: "$currentUserId", otherUserId: "$currentUserId",),
                          transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                          transitionDuration: Duration(milliseconds: 400),
                        ),
                      );
                    },
                  );
  }

  Widget buildLogout(){
    return ListTile(
                  leading: Icon(
                    Icons.exit_to_app,
                    color: Theme.of(context).primaryColor
                  ),
                  title:
                    Text("Logout"), 
                    onTap: (){
                      _logout();
                    },
                  );
  }
  
  @override
  Widget build(BuildContext context) {
    appState = StateWidget.of(context).state;

    final email = appState?.firebaseUserAuth?.email ?? '';
    final nome = appState?.user?.user_nome ?? '';
    final foto = appState?.user?.user_foto ?? '';

    return Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image:  AssetImage('assets/images/aurora.png'))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                buildImage(foto),
                buildName(nome),
                buildEmail(email),
              ])),

              buildMessages(),
              buildProfile(),
              buildLogout(),            
          ],
        ),
      );
  }
}