
import 'package:animator/animator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:hand_stuff/grupo_pages/grupo_crud/grupo_add.dart';
import 'package:hand_stuff/home_pages.dart/screens/itemlist.dart';
import 'package:hand_stuff/login.dart';
import 'package:hand_stuff/models/state.dart';
import 'package:hand_stuff/models/todo.dart';
import 'package:hand_stuff/services/auth.dart';
import 'package:hand_stuff/services/state_widget.dart';
import 'package:hand_stuff/widgets/background.dart';
import 'package:hand_stuff/widgets/drawer.dart';
import 'package:hand_stuff/widgets/fancybuttonsimple.dart';
import 'package:hand_stuff/widgets/intentshared.dart';
import 'package:hand_stuff/widgets/loading.dart';
import 'package:hand_stuff/widgets/notfound.dart';
import 'package:hand_stuff/widgets/poparg.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

import 'package:path/path.dart' as path;

class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  static const platform = const MethodChannel('app.channel.shared.data');
 
  final databaseReference = Firestore.instance;
  StateModel appState;
  bool _loadingVisible = false;

  String photoLocal;
  String nomeLocal;
  bool _isLoading = true;
  bool animationAdd = false;
  TextEditingController _code=new TextEditingController();

  Future<List> _getSharedData() async => await platform.invokeMethod('getSharedData');

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  // final notifications = FlutterLocalNotificationsPlugin();

  String tokenUser;
  Future checkId;
  Future future;
  List grupos; 
  List paths = [];
  List pathscontent = [];
  List<String> pathstest = ['content://com.whatsapp.provider.media/item/177009','content://com.whatsapp.provider.media/item/177009','content://com.whatsapp.provider.media/item/177009'];
  double heightvalue = 70;
  bool expanded = false;
  List<Widget> _widgetShareList = <Widget>[
        
  ];

teste()async{
  appState =  StateWidget.of(context).state;
}
  @override
  void initState() {
  super.initState();
  checkId = verificaId();
  checkId.then((userObject){
    if(userObject != null){
     
      print("Usuario buscado$userObject");
      future = getData(userObject.id);
      future.then((value){
        setState(() {
          grupos = value;
          print(value);
        });
    });
    
    _firebaseMessaging.getToken().then((token) {
      print('token: $token');
      setState(() {
        tokenUser = token;
      });
      Firestore.instance.collection('users').document(userObject.id).updateData({'token': token});
    }).catchError((err) {
      
      Flushbar(
          title: "Sign In Error",
          message: err.message.toString(),
          duration: Duration(seconds: 5),
        )..show(context);
    });
    //  registerNotification();
    //  configLocalNotification();
    
    }   
  });
    
}


  Future verificaId() async {
    UserEstudante userLocal = await Auth.getUserLocal();
    
    return userLocal;
  }

  // void _initReceiveIntent() async {
  //   prefs = await SharedPreferences.getInstance();
  //   await prefs.setStringList('intent', []);
  //   SystemChannels.lifecycle.setMessageHandler((msg) {
  //       if (msg.contains('resumed')) {
  //           _getSharedData().then((d) {
  //               if (d.isEmpty) return;

  //           });
  //       }
  //   });
  //   var data = await _getSharedData();
  //   if(data.isEmpty){
  //     await prefs.setStringList('intent', []);
  //     setState(() {
  //       paths = data;
  //     });
  //   }else{
  //     print(data);
  //     var newlistcontent = new List<String>.from(data);
  //     await prefs.setStringList('intent', newlistcontent);
  //     setState(() {
  //       paths = data;
  //       _widgetShareList.add(SharedIntent(page:"um grupo",icon:false, iconpath:"assets/images/group-picture.png", ));
  //     });
  //   }            
  // }

Future getData(currentUserId) async{
  
  // Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
  // tokenUser = await _firebaseMessaging.getToken();
  final QuerySnapshot result = await Firestore.instance.collection('users').document("$currentUserId").collection('grupos').where('user_ban', isEqualTo: false).getDocuments();
  final List<DocumentSnapshot> documents = result.documents;
 
  List gruposget = [];
  if(documents.isEmpty ){
    return gruposget;
  }


  int count = 0;
  for (int i = count; i < documents.length; i++) {
   
    String grupoCodigo;
    String grupoNome;

    
    final QuerySnapshot resultado = await Firestore.instance.collection('grupos').where('grupo_codigo', isEqualTo: documents[i]['grupo_codigo']).getDocuments();
    grupoCodigo = resultado.documents[0]['grupo_codigo'];
    grupoNome =  resultado.documents[0]['grupo_nome'];
     
    
    
    gruposget.add({'grupo_nome': grupoNome,'grupo_codigo': grupoCodigo,'token':tokenUser});
    count++;
  }

  if (count == documents.length){
     print(gruposget);
     return gruposget;
  }
     
}

  // void registerNotification() {
  //     _firebaseMessaging.requestNotificationPermissions();
  //     _firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
  //       print('onMessage: $message');
        
  //       showIconNotification(
  //           context,
  //           notifications,
  //           type:message['data']['type'].toString(),
  //           icon:message['data']['image'].toString(),
  //           title:message['data']['type'] == '1' ? message['notification']['title'].toString() : _dataformatada(message['notification']['title']),
  //           body: message['notification']['body'].toString(),
  //           id: 40,
  //       );
  //       return;
  //     }, onResume: (Map<String, dynamic> message) {
  //       print('onResume: $message');
  //       return;
  //     }, onLaunch: (Map<String, dynamic> message) {
  //       print('onLaunch: $message');
  //       return;
  //     });
  //   }

  
  // void configLocalNotification() {
  //   AndroidInitializationSettings settingsAndroid = AndroidInitializationSettings('app_icon');
  //   IOSInitializationSettings settingsIOS = IOSInitializationSettings(
  //       onDidReceiveLocalNotification: (id, title, body, payload) => onSelectNotification(payload));

  //   notifications.initialize(
  //       InitializationSettings(android:settingsAndroid,iOS:settingsIOS),
  //       onSelectNotification: onSelectNotification);
  // }


  // Future onSelectNotification(String payload) async => await Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => LoginPage()),
  //   );


  
  Future<String> saveImage(BuildContext context, String image) {
  final completer = Completer<String>();

  NetworkImage(image).resolve(ImageConfiguration()).addListener(ImageStreamListener((ImageInfo imageInfo, bool _) async {
    final byteData =
        await imageInfo.image.toByteData(format: ImageByteFormat.png);
    final pngBytes = byteData.buffer.asUint8List();

    final fileName = pngBytes.hashCode;
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(pngBytes);

    completer.complete(filePath);
  }));

  return completer.future;
}


// Future<NotificationDetails> _icon(BuildContext context, String icon) async {
//     final iconPath = await saveImage(context, icon);

//     final androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       'big text channel id',
//       'big text channel name',
//       'big text channel description',
//       icon: iconPath,
//       playSound: true,
//       enableVibration: true,
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//     return NotificationDetails(android: androidPlatformChannelSpecifics, iOS:null);

    
    
//   }

  // Future showIconNotification(
  //   BuildContext context,
  //   FlutterLocalNotificationsPlugin notifications, {
  //   @required String title,
  //   @required String body,
  //   @required String icon,
  //   @required String type,
  //   int id = 0,
  // }) async =>
  //     notifications.show(id, title, body, await _icon(context, icon));



Future shareContentList() async {
    List namefiles = [];
    paths.forEach((f) async { 
        String namefile;
        var absolutepath = await FlutterAbsolutePath.getAbsolutePath(f);
        File file = new File(absolutepath);
        namefile = path.basename(file.path);
        namefiles.add(namefile);
      });
      return namefiles;
  }
  
 void expandShareContainer(){
    if(expanded == false){
      setState(() {
        expanded = true;
        heightvalue = 300;
      });
    }else{
      setState(() {
        expanded = false;
        heightvalue = 70;
      });
    }
  }



_dataformatada(date){
  DateTime todayDate = DateTime.parse(date);
  String formattedDate = DateFormat('dd/MM/yyyy').format(todayDate);
  return formattedDate;
}

void refreshData(indexList){
      print('refreshdata:$indexList');
      setState(() {
        grupos.removeAt(indexList);
      });

  }

void addData(gruponome,grupocodigo){
    var grupoInsert = {'grupo_nome':gruponome,'grupo_codigo':grupocodigo,'token':tokenUser};
    print(grupoInsert);
    setState(() {
        grupos.add(grupoInsert);
      });
  }

Future<void> _changeLoadingVisible() async {
    setState(() {
      _loadingVisible = !_loadingVisible;
    });
  }
  _entrar(currentUserId,StateModel appStateFunction) async {

      final QuerySnapshot result = await Firestore.instance.collection('grupos').where('grupo_codigo', isEqualTo: _code.text).getDocuments();
      final List<DocumentSnapshot> documents = result.documents;

      if (documents.isNotEmpty){
      final QuerySnapshot checkban = await Firestore.instance.collection('grupos').document(_code.text).collection('users').where('id', isEqualTo: currentUserId).getDocuments();
      final List<DocumentSnapshot> documentscheck = checkban.documents;

        if(documentscheck.isEmpty){
          nomeLocal = appStateFunction?.user?.user_nome ?? '';
          photoLocal = appStateFunction?.user?.user_foto ?? '';
          databaseReference.collection('grupos').document(_code.text).collection('users').document("$currentUserId").setData({'user_grupo_privi': false,'user_nome': '$nomeLocal','id':"$currentUserId",'user_foto':'$photoLocal','token':"$tokenUser",'user_ban':false,});
          databaseReference.collection('users').document("$currentUserId").collection('grupos').document(_code.text).setData({'grupo_codigo': _code.text,'user_ban':false});
          var gruposEnter = {'grupo_nome':documents[0]['grupo_nome'], 'grupo_codigo':documents[0]['grupo_codigo'], 'token': tokenUser};
          setState(() {
            grupos.add(gruposEnter);
          });
          Flushbar(
              title: "Sucesso",
              message: "Usuario adicionado ao grupo",
              duration: Duration(seconds: 3),
            )..show(context);
          return true;
        }else{
          if(documentscheck[0]['user_ban'] != false){
            print('Usuario removido');
            Flushbar(
              title: "Error",
              message: "Usuario banido",
              duration: Duration(seconds: 3),
            )..show(context);
            return false;
          }
        }     
      }else{
        Flushbar(
              title: "Error",
              message: "Grupo nao encontrado",
              duration: Duration(seconds: 3),
            )..show(context);
       
        return false;
      }
}

void _boxresultado(title,subtitle) {
      PopArg.popmensagem(context, title, subtitle);
  }

void _boxcodigo(currentUserId,StateModel appStateFunction){
  showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) -   1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0)),
                  title: Text("Grupo Privado"),
                  content: TextField(
                  controller: _code,
                  decoration: InputDecoration(hintText: "Cole o código do grupo"),
                  ),
                  actions: <Widget>[
                      FlatButton(
                      child: Text('Ok'),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        setState(() {
                          appStateFunction.isLoading = true;
                        });
                        await _changeLoadingVisible();

                        await _entrar(currentUserId,appStateFunction);

                        setState(() {
                          appStateFunction.isLoading = false;
                        });
                        await _changeLoadingVisible();
                        
                      },
                    )
                  ],
                ),
              ),
            );
        },
        transitionDuration: Duration(milliseconds: 300),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {} 
        );
  }

void changeAnimation(){
  if(animationAdd == false){
      setState(() {
      animationAdd = true;
    });
    }else{
      setState(() {
      animationAdd = false;
    });
    }
  }


 Widget _listGrupos(itemHeight,userId){
  return AnimatedContainer(
              duration: Duration(milliseconds: 500),
              height: animationAdd ? (itemHeight / 1.65) : (itemHeight / 1.3),
              child:grupos == null ? Center(child:Column(children: <Widget>[Text('Buscando grupos',style:TextStyle(color: Colors.white),),CircularProgressIndicator()],) ): grupos.isNotEmpty ? ItemListGrupo(list: grupos,userid: "$userId",refreshData:refreshData) : NotFound(msg: 'Entre ou crie algum grupo e comece a postar/guardar',image: 'group-picture',) 
              );
  }
 Widget _buttons(itemHeight,itemWidth,userId,StateModel appStateFunction){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
      Animator(
              tween:Tween<Offset>(begin:Offset(-2,0), end:Offset(0,0)),
              duration: Duration(seconds: 2),
              curve: Curves.bounceOut,
              repeats: 1,
              builder: (anim) => FractionalTranslation(
                translation: anim.value,
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFF1A2980),
                    borderRadius: BorderRadius.circular(20)
              ),
              width: (itemWidth / 2.3),
              child: FlatButton(
                onPressed: ()=>_boxcodigo(userId,appStateFunction),
                  child:Column(
                  children: <Widget>[
                    new Image.asset('assets/images/entrar.png',color:Colors.white,scale: 2.0,height: (itemHeight / 6.7)),
                    Text('Entrar',overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.white),)
                  ],
                ),
              ),
            ),
          )
        ),
        Animator(
          tween:Tween<Offset>(begin:Offset(2,0), end:Offset(0,0)),
          duration: Duration(seconds: 2),
          curve: Curves.bounceOut,
          repeats: 1,
          builder: (anim) => FractionalTranslation(
            translation: anim.value,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFF1A2980),
                borderRadius: BorderRadius.circular(20)
          ),
          width: (itemWidth / 2.3),
          child: FlatButton(
            onPressed: (){
            return Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (c, a1, a2) => new GrupoAdd(token:tokenUser,function:addData),
                        transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                        transitionDuration: Duration(milliseconds: 400),
                      ),
                    );
              },
              child:Column(
              children: <Widget>[
                new Image.asset('assets/images/group-picturewhite.png',scale: 2.0,height: (itemHeight / 6.7)),
                Text('Criar',overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.white),)
              ],
            ),
          ),
        ),
      )
    ),     
        ],
      );
  }

@override
Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemWidth = (size.width);
    final double itemHeight = (size.height);

    appState = StateWidget.of(context).state;
    final userId = appState?.firebaseUserAuth?.uid ?? '';
    final id = appState?.user?.id ?? '';
    print("Esse é o id$userId");
    print("Esse é o id$id");

  return Scaffold(
        appBar: AppBar(
          title: Text('MyMatter'),
          backgroundColor: Color(0xFF1A2980),
        ),
        body:LoadingScreen(
              child: Background(
              widget:ListView(
                children: <Widget>[
                    _widgetShareList.isNotEmpty 
                      ? _widgetShareList[0]
                      : Container(),
                    _listGrupos(itemHeight,userId),
                    animationAdd 
                      ? _buttons(itemHeight,itemWidth,userId,appState)
                      : Container()        
                ],
              ),
            ),
            inAsyncCall: _loadingVisible
        ),
          floatingActionButton: FancyFabSimple(function: changeAnimation,),
      
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          bottomNavigationBar: new BottomAppBar(
            color: Color(0xFF1A2980),
            child: SizedBox(height: 50,)
          ),
        drawer: DrawerCustom(currentUserId: userId),
    );
  }
}











