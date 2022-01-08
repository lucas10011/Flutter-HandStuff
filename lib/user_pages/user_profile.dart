import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hand_stuff/chat_pages/chat.dart';
import 'package:hand_stuff/models/todo.dart';
import 'package:hand_stuff/services/auth.dart';
import 'package:hand_stuff/user_pages/fancybuttonprofile.dart';
import 'package:image_picker/image_picker.dart';



class UserProfilePage extends StatefulWidget {
  final String otherToken;
  final String currentUserId;
  final String otherUserId;

  UserProfilePage({this.currentUserId,this.otherUserId,this.otherToken});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> with SingleTickerProviderStateMixin{

final themeColor = Color(0xfff5a623);
final primaryColor = Color(0xff203152);
final greyColor = Color(0xffaeaeae);
final greyColor2 = Color(0xffE8E8E8);

  bool _changestatus = false;
  bool _myProfile = true;

  TextEditingController controllerStatus;
  TextEditingController controllerDescricao;



  String id;
  String status;
  String descricao;
  String photoUrl;

  String idprofile;
  String imageprofile;

  bool isLoading = false;
  File avatarImageFile;

  Animation animation;
  Animation animation2;
  Animation animation3;
  Animation animation4;
  Animation transformationAnim;
  AnimationController animationController;

  final FocusNode focusNodeNickname = new FocusNode();
  final FocusNode focusNodeAboutMe = new FocusNode();

  @override
  void initState() {
    super.initState();
    if(widget.currentUserId == widget.otherUserId){
        print(widget.currentUserId);
        print(widget.otherUserId);
        print("mesmo usuario");
        readLocal();
    }else{
      print(widget.currentUserId);
      print(widget.otherUserId);
      print("usuario diferente");
      setState(() {
       _myProfile = false; 
      });
    }

  animationController = AnimationController(duration: Duration(seconds: 3), vsync: this);
  
  animation = Tween(begin: 0.0, end:180.0).animate(CurvedAnimation(
    parent: animationController, curve: Curves.ease));
  
  animation2 = Tween(begin: -1.0, end:0.0).animate(CurvedAnimation(
    parent: animationController, curve: Curves.ease));

  animation3 = Tween(begin: 1.0, end:0.0).animate(CurvedAnimation(
    parent: animationController, curve: Curves.ease));

  transformationAnim = BorderRadiusTween(
    begin:BorderRadius.circular(125.0),
    end: BorderRadius.circular(0.0)).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.ease
      )
    );
  
  animationController.forward();
  }


  @override
void dispose() {
  animationController.dispose();
  super.dispose();
}

changeStatus(){
  if (_changestatus == false){
    setState(() {
      _changestatus = true;
    });
  }else{
    setState(() {
      _changestatus = false;
    });
  }
}
 Future verificaId() async {
    UserEstudante userLocal = await Auth.getUserLocal();
    return userLocal;
  }

  void readLocal() async {
    UserEstudante userLocal = await Auth.getUserLocal();
    id = userLocal.id;
    status = userLocal.user_status;
    descricao = userLocal.user_descricao;
    photoUrl =  userLocal.user_foto;

    controllerStatus = new TextEditingController(text: status);
    controllerDescricao = new TextEditingController(text: descricao);
    // Force refresh input
    setState(() {});
  }

  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
    }
    uploadFile();
  }

  Future uploadFile() async {
    String fileName = id;
    firebase_storage.Reference reference = firebase_storage.FirebaseStorage.instance.ref().child('users/$fileName/$fileName');
    firebase_storage.UploadTask uploadTask = reference.putFile(avatarImageFile);
    firebase_storage.TaskSnapshot storageTaskSnapshot;
    uploadTask.then((value) {
      if (value.state.index == 2) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          photoUrl = downloadUrl;
          Firestore.instance
              .collection('users')
              .document(id)
              .updateData({'user_status': status, 'user_descricao': descricao, 'user_foto': photoUrl}).then((data) async {
            
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: "Upload success");
          }).catchError((err) {
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: err.toString());
          });
        }, onError: (err) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: 'This file is not an image');
        });
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: 'This file is not an image');
      }
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      print(err.toString());
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  void handleUpdateData() {

    

    focusNodeNickname.unfocus();
    focusNodeAboutMe.unfocus();

    setState(() {
      isLoading = true;
    });

    Firestore.instance
        .collection('users')
        .document(widget.currentUserId)
        .updateData({'user_status': status, 'user_descricao': descricao}).then((data) async {

      setState(() {
        isLoading = false;
      });
      setState(() {});
      Fluttertoast.showToast(msg: "Update success");
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: err.toString());
    });


  }





 Future _getDadosUser() async {

  
   if(_myProfile == true){
     idprofile = widget.currentUserId;
   }else{
     idprofile = widget.otherUserId; 
   }

    final QuerySnapshot result =
          await Firestore.instance.collection('users').where('id', isEqualTo: idprofile).getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
    print(documents[0]['user_nome']);

    


    return documents;
      
  }

 Future<int> _getElogiosUser() async {

  final QuerySnapshot result = await Firestore.instance.collection('elogios').where('user_id', isEqualTo: idprofile).getDocuments();
  final List<DocumentSnapshot> documents = result.documents;

  return documents.length; 
}

Future<int> _getPostsUser() async {

  final QuerySnapshot result = await Firestore.instance.collection('posts').where('user_id', isEqualTo: idprofile).getDocuments();
  final List<DocumentSnapshot> documents = result.documents;

  return documents.length; 
}



  Widget _buildCoverImage(Size screenSize) {
    return Container(
      height: screenSize.height / 2.6,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/aurora.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProfileImage(BuildContext context,datauser) {
  return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget child) {
    return Center(
      child:Container(
        padding: EdgeInsets.all(10),
                child: Center(
                  child: isLoading ? Container(height: 90, width: 90, child: CircularProgressIndicator(),): Stack(
                    children: <Widget>[
                      (avatarImageFile == null)   
                          ? _myProfile 
                            ? (datauser[0]['user_foto'] != ''
                              ? new ClipRRect(
                                  borderRadius: new BorderRadius.circular(90.0),
                                  child: Image.network(datauser[0]['user_foto'],fit: BoxFit.cover,
                                          width: 180.0,
                                          height: 180.0,
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
                              : Icon(
                                  Icons.account_circle,
                                  size: 180.0,
                                  color: greyColor,
                                ))
                              : datauser[0]['user_foto'] != '' 
                                ? new ClipRRect(
                                  borderRadius: new BorderRadius.circular(90.0),
                                  child: Image.network(datauser[0]['user_foto'],fit: BoxFit.cover,
                                          width: 180.0,
                                          height: 180.0,
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
                          : Icon(
                                  Icons.account_circle,
                                  size: 180.0,
                                  color: greyColor,
                                )
                                
                          : Material(
                              child: Image.file(
                                avatarImageFile,
                                width: 180.0,
                                height: 180.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(90.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                     _myProfile ? IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          color: primaryColor.withOpacity(0.1),
                        ),
                        onPressed: _myProfile ? getImage : (){},
                        padding: EdgeInsets.all(60.0),
                        splashColor: Colors.transparent,
                        highlightColor: greyColor,
                        iconSize: 40.0,
                      ) : Container(),

                      
                    ],
                  ),
                ),
                width: animation.value,
                height: animation.value,
                margin: EdgeInsets.all(0.0),
              ),
        );
      });
  }

  Widget _buildFullName(BuildContext context,datauser) {
    TextStyle _nameTextStyle = TextStyle(
      fontFamily: 'Roboto',
      color: Colors.black,
      fontSize: 28.0,
      fontWeight: FontWeight.w700,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(child: Container(child: new Text("${datauser[0]['user_nome']}",overflow: TextOverflow.ellipsis, style: _nameTextStyle,),))
        
      ],
    );
  }





  _statusWidget(datauser){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child:datauser[0]['user_status'] == '' 
            
            ?Text("Coloque um status",textAlign: TextAlign.center,style: TextStyle(
                fontFamily: 'Spectral',
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.w300,
              ))

              :Text(
              "${datauser[0]['user_status']}",
              style: TextStyle(
                fontFamily: 'Spectral',
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
      ],
    );
  }


  _statusFormField(){
    return TextField(
              maxLength: 30,
              keyboardType: TextInputType.emailAddress,
              controller: controllerStatus,
              onChanged: (value) {
                          status = value;
                        },
              decoration: new InputDecoration(
                hintText: "Status",
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                ),
              ),
              style: TextStyle(fontSize: 20,color: Colors.black),
            );
  }


  _descricaoWidget(bioTextStyle,datauser){
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.all(8.0),
      child: datauser[0]['user_descricao'] == '' ? Text("Coloque uma descriçao",textAlign: TextAlign.center,
        style: bioTextStyle,):Text(
        "${datauser[0]['user_descricao']}",
        textAlign: TextAlign.center,
        style: bioTextStyle,
      ),
    );
  }


  _descricaoFormField(bioTextStyle){
    return TextField(
              maxLength: 200,
              keyboardType: TextInputType.multiline,
              maxLines: 5,
              controller:controllerDescricao,
              onChanged: (value) {
                          descricao = value;
                        },
              decoration: new InputDecoration(
                hintText: "Digite uma descricao",
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                ),
              ),
              style: TextStyle(fontSize: 20,color: Colors.black),
            );
  }


  Widget _buildStatus(BuildContext context,datauser) {
    return  _changestatus ?  _statusFormField() :  _statusWidget(datauser);
  
  }


   Widget _buildDescricao(BuildContext context,datauser){

     TextStyle bioTextStyle = TextStyle(
      fontFamily: 'Spectral',
      fontWeight: FontWeight.w400,//try changing weight to w500 if not thin
      fontStyle: FontStyle.italic,
      color: Color(0xFF799497),
      fontSize: 16.0,
    );

    return  _changestatus ?  _descricaoFormField(bioTextStyle) : _descricaoWidget(bioTextStyle,datauser);
  
  }

  _animationStatItem(int elogios,style){
    Animation _animation = IntTween(begin: 0, end:elogios).animate(CurvedAnimation(
    parent: animationController, curve: Curves.easeOut));

    return Text(_animation.value.toString(),style: style,);
  }

  _animationPostItem(int post,style){
    Animation _animation = IntTween(begin: 0, end:post).animate(CurvedAnimation(
    parent: animationController, curve: Curves.easeOut));

    return Text(_animation.value.toString(),style: style,);
  }

  _buildStatItem() {
    final double width = MediaQuery.of(context).size.width;

    TextStyle _statLabelTextStyle = TextStyle(
      fontFamily: 'Roboto',
      color: Colors.black,
      fontSize: 16.0,
      fontWeight: FontWeight.w200,
    );

    TextStyle _statCountTextStyle = TextStyle(
      color: Colors.black54,
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
              new FutureBuilder(
                future: _getElogiosUser(),
                builder: (context,snapshot){
                  if(snapshot.hasError)
                    print(snapshot.error);
                  return snapshot.hasData
                  ?AnimatedBuilder(
                    animation: animationController,
                    builder: (BuildContext context, Widget child){
                    return _animationStatItem(snapshot.data,_statCountTextStyle);
                      })
                    :Container(height: 16,);
                },
              ),
            Text(
              'Elogios',
              style: _statLabelTextStyle,
            ),
          ],
        ),Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new FutureBuilder(
                future: _getPostsUser(),
                builder: (context,snapshot){
                  if(snapshot.hasError)
                    print(snapshot.error);
                  return snapshot.hasData
                  ?AnimatedBuilder(
                    animation: animationController,
                    builder: (BuildContext context, Widget child){
                    return _animationPostItem(snapshot.data,_statCountTextStyle);
                      })
                    :Container(height: 16,);
                },
              ),
            Text(
              'Posts',
              style: _statLabelTextStyle,
            ),
          ],
        )
      ],
    );
  }

  Widget _buildStatContainer(BuildContext context,datauser) {
    return Container(
      height: 60.0,
      margin: EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        color: Color(0xFFEFF4F7),
      ),
      child:_buildStatItem()  
    );
  }

   _buildBio(context,datauser) {
    
    return _buildDescricao(context,datauser);
  }

  Widget _buildSeparator(Size screenSize) {
    return Container(
      width: screenSize.width / 1.6,
      height: 2.0,
      color: Colors.black54,
      margin: EdgeInsets.only(top: 4.0),
    );
  }

  Widget _buildGetInTouch(BuildContext context, datauser) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(
            child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: EdgeInsets.only(top: 8.0),    
            child: Container(child: new Text("Fale com ${datauser[0]['user_nome'].split(" ")[0]},",overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Roboto', fontSize: 16.0),),),
          ),
        ),
      ],
    );
  }

  Widget _buttonChat(context,datauser){
      return RawMaterialButton(
                          onPressed: () {
                            Navigator.push(context,MaterialPageRoute(
                                builder: (context) => Chat(
                                      peerId: widget.otherUserId,
                                      peerAvatar: datauser[0]['user_foto'],
                                      currentUserId: widget.currentUserId,

                                    )));
                          },
                          child: new Icon(
                            Icons.message,
                            color: Colors.white,
                            size: 30.0,
                          ),
                          shape: new CircleBorder(),
                          elevation: 2.0,
                          fillColor:Color(0xFF1A2980),
                          padding: const EdgeInsets.all(15.0),
                        );

  }


_profileWidgets(datauser,screenSize){
  return Center(
      child: ListView(
                  children: <Widget>[
                    SizedBox(height: screenSize.height / 8.4),
                    _buildProfileImage(context,datauser)
                   ,
                    _buildFullName(context,datauser),
                    _buildStatus(context,datauser),
                    _buildStatContainer(context,datauser),
                    _buildBio(context,datauser),
                    _buildSeparator(screenSize),
                    SizedBox(height: 10.0),
                    _buildGetInTouch(context,datauser),
                    SizedBox(height: 8.0),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
                    
                    _myProfile ?Container() : _buttonChat(context,datauser)
                    ],)

                  ],
                ),
  );
}

 _profileBody(datauser,screenSize){
   return Stack(
        children: <Widget>[
          _buildCoverImage(screenSize),
          SafeArea(
            child: _profileWidgets(datauser,screenSize),
          ),
        ],
      );
 }
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: FutureBuilder(
              future: _getDadosUser(),
              builder: (context,snapshot){
                if(snapshot.hasError)
                  print(snapshot.error);
                return snapshot.hasData
                    ?_profileBody(snapshot.data,screenSize) :Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[CircularProgressIndicator(),Text('Carregando'),],),);
            },
          ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton:_myProfile ? FancyFabProfile(change: changeStatus,save:handleUpdateData) : Container()); 
      
  }
}