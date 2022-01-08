import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hand_stuff/chat_pages/const.dart';
import 'package:hand_stuff/user_pages/user_profile.dart';



class ListUsersGroup extends StatefulWidget {
  final String currentUserId;
  final bool myprivillege;
  final String currentGroupId;

  ListUsersGroup({Key key, @required this.currentUserId,@required this.myprivillege,@required this.currentGroupId}) : super(key: key);

  @override
  State createState() => ListUsersGroupState(currentUserId: currentUserId, myprivillege:myprivillege, currentGroupId:currentGroupId );
}

class ListUsersGroupState extends State<ListUsersGroup>{
  ListUsersGroupState({Key key, @required this.currentUserId,@required this.myprivillege,@required this.currentGroupId});
  final String currentGroupId;
  final bool myprivillege;
  final String currentUserId;
  final databaseReference = Firestore.instance;


  bool isLoading = false;
  List<Choice> choices = const <Choice>[
    const Choice(title: 'Settings', icon: Icons.settings),
    const Choice(title: 'Log out', icon: Icons.exit_to_app),
  ];



  void _boxuser(user){
      TextStyle _nameTextStyle = TextStyle(
      color: Colors.black,
      fontSize: 28.0,
      fontWeight: FontWeight.w700,
    );
    TextStyle _privillege = TextStyle(color: greyColor,fontSize: 12.0, fontStyle: FontStyle.italic,fontWeight: FontWeight.w500);
 
  _banMember(userid,grupocodigo) async {
    Navigator.pop(context);
    await databaseReference.collection('grupos').document('$grupocodigo').collection('users').document('$userid').updateData({
      'user_ban': true,
    });
    await databaseReference.collection('users').document('$userid').collection('grupos').document('$grupocodigo').updateData({
      'user_ban': true,
    });
    
    }

    _desbanMember(userid,grupocodigo) async {
    Navigator.pop(context);
    await databaseReference.collection('grupos').document('$grupocodigo').collection('users').document('$userid').updateData({
      'user_ban': false,
    });
    await databaseReference.collection('users').document('$userid').collection('grupos').document('$grupocodigo').updateData({
      'user_ban': false,
    });
    
    }
    
    showGeneralDialog(
            barrierColor: Colors.black.withOpacity(0.5),
            transitionBuilder: (context, a1, a2, widget) {
                return Transform.scale(
                  scale: a1.value,
                  child: Opacity(
                    opacity: a1.value,
                    child: AlertDialog(
                      shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(200.0)),
                        content:Container(
                          height: 250,
                          width: 250,
                          child: Column(children: <Widget>[
                              Material(
                                    child: Image.network(user['user_foto'],fit: BoxFit.cover,
                                          width: 90.0,
                                          height: 90.0,
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
                                    borderRadius: BorderRadius.all(Radius.circular(45.0)),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                                  user['user_grupo_privi'] ? Text('Admin', style: _privillege,) : Text('Membro', style: _privillege,),                                
                                  Padding(
                                    padding: const EdgeInsets.only(top:30.0,bottom: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Flexible(child: Container(child: new Text("${user['user_nome']}",overflow: TextOverflow.ellipsis, style: _nameTextStyle,),))
                                        
                                      ],
                                    ),
                                  ),
                                
                                 myprivillege 
                                  ? user['user_ban'] 
                                    ?InkWell( 
                                      splashColor: Colors.green[200],
                                      onTap:(){
                                        _desbanMember(user['id'],currentGroupId);
                                      },
                                      child:Text('Retirar banimento',style: TextStyle(color: Colors.green),) ,)

                                    :currentUserId != user['id']
                                      ?InkWell( 
                                      splashColor: Colors.red[200],
                                      onTap:(){
                                        _banMember(user['id'],currentGroupId);
                                      },
                                      child:Text('Banir do grupo',style: TextStyle(color: Colors.red),) ,)
                                      :Container() 
                                  : Container()
                              
                            ],),
                        ),
                      
                        
                      ),
                    ),
                  );
              },
              transitionDuration: Duration(milliseconds: 200),
              barrierDismissible: true,
              barrierLabel: '',
              context: context,
              pageBuilder: (context, animation1, animation2) {} 
              );
          }

buildItemMember(document){
  return GestureDetector(
                onLongPress: () {
                    _boxuser(document);
                    },
                child: Column(
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UserProfilePage(currentUserId: "${widget.currentUserId}",otherUserId:document.documentID)));
                          },
                          child: Container(
                            padding: EdgeInsets.all(2), 
                            child: Material(      
                              child: Image.network(document['user_foto'],fit: BoxFit.cover,
                                          width: 80.0,
                                          height: 80.0,
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
                              borderRadius: BorderRadius.all(Radius.circular(50.0)),
                              clipBehavior: Clip.hardEdge,
                              elevation: 5,           
                          ),
                        ),
                      ),
                      Flexible(child: Container(color: Colors.blue[600],constraints: BoxConstraints(minWidth: 0, maxWidth:100),child:Text('${document['user_nome'].split(" ")[0]}',overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.white),),))
                      
                      
                  ],
                ),
            );
}

buildAdmin(document){
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.all(8),
      itemCount: document.length,
      itemBuilder: (BuildContext context, int index) {

          return buildItemMember(document[index]);
             
      }
    ); 
}


buildMember(document){
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.all(8),
      itemCount: document.length,
      itemBuilder: (BuildContext context, int index) {

          return buildItemMember(document[index]);        
      }
    ); 
}

buildBans(document){
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.all(8),
      itemCount: document.length,
      itemBuilder: (BuildContext context, int index) {
          return buildItemMember(document[index]);           
      }
    ); 
}
_buildRootListView(List documents){

      var admin = []; 
      var membros = [];
      var banidos = [];
      int count = 0;
    for (int index = 0; index < documents.length; index++) {
   
      if (documents[index]['user_grupo_privi'] == true){
        admin.add(documents[index]);
      }else if(documents[index]['user_grupo_privi'] == false && documents[index]['user_ban'] == false){
        membros.add(documents[index]);
      }else{
        banidos.add(documents[index]);
      }
    count++;
    }
      return Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10,bottom: 20.0),
                  child: Column(children: <Widget>[
                      Text('Admin',style: TextStyle(color: Colors.white),),
                      Container(
                      height: 130,
                      child:buildAdmin(admin)
                      )
                  ],
              ),
                );
                
              } else if (index == 1) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(children: <Widget>[
                      Text('Membros',style: TextStyle(color: Colors.white),),
                      Container(
                      height: 130,
                      child:buildMember(membros)
                      )
                  ],
              ),
                );
                //future builder
              } else {
                  return Padding(
                     padding: const EdgeInsets.only(bottom: 20.0),
                    child: myprivillege != null
                        ? myprivillege ? Column(children: <Widget>[
                            Text('Banidos'),
                            Container(
                            height: 130,
                            child:buildBans(banidos)
                            )
                        ],
                    ): Container()
                  :Container());//Stream builder
              }
            },
            itemCount: 3,
          ),
        );
  
}
body(){
    return Column(
      children: <Widget>[
         StreamBuilder(
          stream: Firestore.instance.collection('grupos').document('${widget.currentGroupId}').collection('users').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                ),
              );
            } else {
                return _buildRootListView(snapshot.data.documents);                
                    }
                  },
        
            ),
      ],
    );
}
  @override
  Widget build(BuildContext context) {
    return body();
 
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    if (document['id'] == currentUserId) {
      return Container();
    } else {
      return Container(
        child: FlatButton(
          child: Row(
            children: <Widget>[
              SizedBox(
               child: Material(
                  child: 
                  document['user_foto'] != null 
                  ? document['user_foto'] != ''
                      ? Image.network(document['user_foto'],fit: BoxFit.cover,
                                          width: 50.0,
                                          height: 50.0,
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
                                        )
                      : 
                      Icon(
                          Icons.account_circle,
                          size: 50.0,
                          color: greyColor,
                        )
                        :
                        Icon(
                          Icons.account_circle,
                          size: 50.0,
                          color: greyColor,
                        ),
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  clipBehavior: Clip.hardEdge,
                ),
              ),
              Flexible(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          '${document['user_nome']}',
                          style: TextStyle(color: primaryColor),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      ),
                      Container(
                        child: Text(
                          '',
                          style: TextStyle(color: primaryColor),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                      )
                    ],
                  ),
                  margin: EdgeInsets.only(left: 20.0),
                ),
              ),
            ],
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UserProfilePage(currentUserId: "${widget.currentUserId}",otherUserId:document.documentID)));
          },
          padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
        decoration: BoxDecoration(
                     gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.3, 1],
                      colors: [
                        Color(0xFFccddff),
                        Color(0XFFe6eeff),
                        ],
                          ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF1A2980),
                          blurRadius: 10.0, // has the effect of softening the shadow
                          spreadRadius: 1.0, // has the effect of extending the shadow
                          offset: Offset(
                            2.0, // horizontal, move right 10
                            2.0, // vertical, move down 10
                          ),
                        )
                      ],
                        borderRadius: BorderRadius.all(
                      Radius.circular(16),
                    ),
                  ),
      );
    }
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}
