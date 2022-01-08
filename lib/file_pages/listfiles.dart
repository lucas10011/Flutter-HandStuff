// import 'dart:isolate';
import 'dart:ui';

// import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hand_stuff/widgets/circleprogress.dart';
import 'package:intl/intl.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';


const debug = true;

class FilesMateria extends StatefulWidget {
  
  String cdgrupo;
  String cdmateria;
  String date;

  String currentUserId;

  
  FilesMateria({this.cdgrupo, this.cdmateria, this.date, this.currentUserId, });

  @override
  _FilesMateriaState createState() => new _FilesMateriaState();
}

class _FilesMateriaState extends State<FilesMateria> with TickerProviderStateMixin{
  final databaseReference = Firestore.instance;
  List<_TaskInfo> _tasks;
  List<_ItemHolder> _items;
  bool _isLoading;
  bool _isLoadingName;
  bool _permissionReady;
  String _localPath;

 
  // ReceivePort _port = ReceivePort();
  
  double _height;


  TextEditingController _newname=new TextEditingController();

  AnimationController controller;
  AnimationController controller2;
  Animation<double> animation;
  double _position;



   final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    
    //  FlutterDownloader.registerCallback((id, status, progress) {
    //   print(
    //       'Download task ($id) is in status ($status) and process ($progress)');
    //   final task = _tasks.firstWhere((task) => task.taskId == id);
    //   setState(() {
    //     task?.status = status;
    //     task?.progress = progress;
    //   });
    // });

    super.initState();

    // _bindBackgroundIsolate();

    // FlutterDownloader.registerCallback(downloadCallback);

    _isLoading = false;
    _permissionReady = false;

    _prepare();
   
 
  }


  @override
  void dispose() {
    // _unbindBackgroundIsolate();
    super.dispose();
  }

  // void _bindBackgroundIsolate() {
  //   bool isSuccess = IsolateNameServer.registerPortWithName(
  //       _port.sendPort, 'downloader_send_port');
  //   if (!isSuccess) {
  //     _unbindBackgroundIsolate();
  //     _bindBackgroundIsolate();
  //     return;
  //   }
  //   _port.listen((dynamic data) {
  //     if (debug) {
  //       print('UI Isolate Callback: $data');
  //     }
  //     String id = data[0];
  //     DownloadTaskStatus status = data[1];
  //     int progress = data[2];

  //     final task = _tasks?.firstWhere((task) => task.taskId == id);
  //     if (task != null) {
  //       setState(() {
  //         task.status = status;
  //         task.progress = progress;
  //       });
  //     }
  //   });
  // }

  // void _unbindBackgroundIsolate() {
  //   IsolateNameServer.removePortNameMapping('downloader_send_port');
  // }

  // static void downloadCallback(
  //     String id, DownloadTaskStatus status, int progress) {
  //   if (debug) {
  //     print(
  //         'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
  //   }
  //   final SendPort send =
  //       IsolateNameServer.lookupPortByName('downloader_send_port');
  //   send.send([id, status, progress]);
  // }

 
 


_formataName(name){
    var urlsplit = name.split('%2F');
    var namefile = urlsplit[3].split('?');
    return namefile[0];
}
_dataformatada(date){
    DateTime todayDate = DateTime.parse(date);
    String formattedDate = DateFormat('dd/MM/yyyy').format(todayDate);
    return formattedDate;
  }

_changename(cdgrupo,cdmateria,date,nometoken,tokenfile,name,index) async {
  var urlsplit = nometoken.split('%2F');
   var namefile = urlsplit[3].split('?');
   var fileextension = namefile[0].split('.');

    setState(() {
           _isLoadingName = true;
        });

      await Firestore.instance.collection('grupos').document('$cdgrupo').collection('matters').document('$cdmateria').collection('datas').document('$date').collection('files').document('$tokenfile').updateData({
        'name': '${_newname.text}.${fileextension[1]}'
      }).then((value){
        Fluttertoast.showToast(msg: "Nome alterado para ${_newname.text}");
        _items[index].namefile = '${_newname.text}.${fileextension[1]}';
        setState(() {
           _isLoadingName = false;
        });
        return true;
      }).catchError((e){
        Fluttertoast.showToast(msg: "$e");
        setState(() {
           _isLoadingName = false;
        });
        return false;
      });
      
     
}

_deletefile(cdgrupo,cdmateria,date,nometoken,tokenfile,name,index,itemWidth) async {
  

    setState(() {
           _isLoadingName = true;
        });

  

     var urlsplit = nometoken.split('%2F');
     var namefile = urlsplit[3].split('?');
    
    print(nometoken);
    print(namefile);


    String storageUrl = "$cdgrupo/$cdmateria/$date/${namefile[0]}";
           
    await Firestore.instance.collection('grupos').document('$cdgrupo').collection('matters').document('$cdmateria').collection('datas').document('$date').collection('files').document('$tokenfile').delete().then((response){

        FirebaseStorage.instance.ref().child('$storageUrl').delete().then((_) => 
          _removeSingleItems(index,_items[index],itemWidth)
        );

        

    });
          
    

  
      
     
}

editFile(cdgrupo,cdmateria,date,nometoken,tokenfile,name,index,itemWidth){
  var urlsplit = nometoken.split('%2F');
   var namefile = urlsplit[3].split('?');
   var fileextension = namefile[0].split('.');
  print(fileextension);
  return showGeneralDialog(
            barrierColor: Colors.black.withOpacity(0.5),
            transitionBuilder: (context, a1, a2, widget) {
                return Transform.scale(
                  scale: a1.value,
                  child: Opacity(
                    opacity: a1.value,
                    child: AlertDialog(
                        shape: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0)),
                          title: Text("Renomear Arquivo"),
                          content: TextField(
                          controller: _newname,
                          decoration: InputDecoration(
                            suffixText:".${fileextension[1]}" ,
                            hintText: "$name"
                            ),
                          
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('Deletar',style: TextStyle(color: Colors.red),),
                              onPressed: () async {
                                Navigator.of(context).pop();
                                await _deletefile(cdgrupo,cdmateria,date,nometoken,tokenfile,name,index,itemWidth);   
                              },
                            ),
                             FlatButton(
                              child: Text('Renomear'),
                              onPressed: () async {
                                Navigator.of(context).pop();
                                await _changename(cdgrupo,cdmateria,date,nometoken,tokenfile,name,index);
                                
                              
                              },
                            ),
                          ],
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


Widget itemBuild(index,item,itemWidth){
  Color foreground = Colors.red;

  
    if ((item.task.progress /100) >= 0.8) {
      foreground = Colors.green;
    } else if ((item.task.progress /100) >= 0.4) {
      foreground = Colors.orange;
    }

    Color background = foreground.withOpacity(0.2);
  return new Container(  
              width: double.infinity,
              height:120.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.3, 1],
                  colors: [
                   Colors.indigo[500],
                   Colors.indigo[300],
                    ],
                  ),
                
              ),
              child:Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                    // InkWell(
                    //   onTap: item.task.status ==
                    //           DownloadTaskStatus.complete
                    //       ? () {
                    //           Fluttertoast.showToast(msg: "Abrindo");
                    //           _openDownloadedFile(item.task)
                    //               .then((success) {
                    //             if (!success) {
                    //               Scaffold.of(context)
                    //                   .showSnackBar(SnackBar(
                    //                       content: Text(
                    //                           'Cannot open this file')));
                    //             }
                    //           });
                    //         }
                    //       : null,
                    //     child:Row(children: <Widget>[
                    //       SizedBox(width: 5,),
                    //       Stack(children: <Widget>[
                    //        item.img 
                    //        ? GestureDetector(
                    //                   onTap: item.task.status == DownloadTaskStatus.complete ? null : (){
                                        
                    //                     Navigator.of(context).push(
                    //                         new MaterialPageRoute(
                    //                             builder: (BuildContext context) => new ExibeImagem(imagedirectory: item.name,tag: item.token)),
                    //                         );
                    //                   },
                    //                   child: new ClipRRect(
                    //                     borderRadius: item.task.status == DownloadTaskStatus.complete ? BorderRadius.circular(70.0) : item.task.status ==DownloadTaskStatus.running ||item.task.status == DownloadTaskStatus.paused ?BorderRadius.circular(70.0) : BorderRadius.circular(0.0),
                    //                     child: Image.network(item.name,fit: BoxFit.cover,
                    //                           width: 120.0,
                    //                           height: 120.0,
                    //                           loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                    //                           if (loadingProgress == null) return child;
                    //                             return Center(
                    //                               child: CircularProgressIndicator(
                    //                               value: loadingProgress.expectedTotalBytes != null ? 
                    //                                     loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                    //                                     : null,
                    //                               ),
                    //                             );
                    //                           },
                    //                         ),       
                    //                     )
                    //                 )
                    //           : new ClipRRect(
                    //                     borderRadius: item.task.status == DownloadTaskStatus.complete ? BorderRadius.circular(70.0) : item.task.status ==DownloadTaskStatus.running ||item.task.status == DownloadTaskStatus.paused ?BorderRadius.circular(70.0) : BorderRadius.circular(0.0),
                    //                     child: Material(child: Image.asset("assets/images/materia-picture.png",fit: BoxFit.cover)),       
                    //                     ),
                                
                            
                    //         item.task.status == DownloadTaskStatus.complete
                    //         ? Positioned(child: CircleProgressBar(backgroundColor: background,foregroundColor: foreground,value:(item.task.progress /100),),)
                    //         : item.task.status ==DownloadTaskStatus.running ||item.task.status == DownloadTaskStatus.paused
                    //             ? Positioned(child: CircleProgressBar(backgroundColor: background,foregroundColor: foreground,value:(item.task.progress /100),),)
                    //             : Container(),
                    //         item.task.status == DownloadTaskStatus.complete 
                    //               ?new Positioned(
                    //                       left:  48.0,
                    //                       right: 0.0,
                    //                       bottom: 48.0,
                    //                       child:Text("${item.task.progress}%"),
                                              
                    //                     )
                    //               :item.task.status == DownloadTaskStatus.running ||item.task.status == DownloadTaskStatus.paused
                    //                   ? new Positioned(
                    //                       left: 48.0,
                    //                       right: 0.0,
                    //                       bottom: 48.0,
                    //                       child:Text("${item.task.progress}%"),
                                              
                    //                     )
                    //                   : new Container()
                            

                    //       ],),

                    //        Container(
                    //          constraints: BoxConstraints(minWidth: 100, maxWidth:(itemWidth - 250)),
                    //          child: new Text(
                    //             "${item.namefile}",
                    //             style: TextStyle(color: Colors.white),
                    //             maxLines: 2,
                    //             softWrap: true,
                    //             overflow:
                    //                 TextOverflow.ellipsis,
                      
                    //           ),
                    //        ),
        
                    //     ],)
                    //   ),
                      Row(children: <Widget>[
                          // new Padding(
                          //   padding:
                          //       const EdgeInsets.only(
                          //           left: 8.0),
                          //   child: _buildActionForTask(
                          //       item.task),
                          // ),
                          new Padding(
                            padding:
                                const EdgeInsets.only(
                                    left: 8.0),
                            child: IconButton(
                              icon: Icon(Icons.edit,color: Colors.white),
                              tooltip: 'Edit',
                              onPressed: () {
                                editFile(widget.cdgrupo,widget.cdmateria,widget.date,item.name,item.token,item.namefile,index,itemWidth);
                              },
                            ),
                          ),
                      ],)
                          

              ],)
            );
}

void _removeSingleItems(index,itemholder,itemWidth) {

   setState(() {
     _items.removeAt(index);
   }); 
    // This builder is just so that the animation has something
    // to work with before it disappears from view since the original
    // has already been deleted.
    AnimatedListRemovedItemBuilder builder = (context, animation) {
      // A method to build the Card widget.
      Widget singleitembuild = itemBuild(index,itemholder,itemWidth);

      return _buildwidgetanimation(singleitembuild, animation);
    };
    _listKey.currentState.removeItem(index, builder);
  }

_buildwidgetanimation(Widget item, Animation animation){
  return SizeTransition(
      sizeFactor: animation,
      child: item,
    );
}

_buildWidgets(List<_ItemHolder> items,itemWidth) {
    var listwidget = items
        .asMap()
        .map((index, item) =>
            MapEntry(index, item.task == null
                        ? new Container()
                        : itemBuild(index,item,itemWidth)))
        .values
        .toList();
   return AnimatedList(
      key: _listKey,
      initialItemCount: listwidget.length,
      itemBuilder: (context, index, animation) {
              return _buildwidgetanimation(listwidget[index], animation);
            },
      
    );
}

Future<bool> _willPopCallback() async {
  // try{
  //   if (myBanner != null){
  //   await myBanner?.dispose();
  //   return true;
  //   }
  //  return true;
  // }catch(e){
  //   print(e.toString());
  //   return false;
  // }
  return true;
    
}
  @override
  Widget build(BuildContext context) {
      var size = MediaQuery.of(context).size;
      final double itemWidth = (size.width - 26);
      final double itemHeight = (size.height);
    return  WillPopScope(
          onWillPop: _willPopCallback,
          child: new Scaffold(
          appBar: new AppBar(
            // title: new Text("${widget.list[widget.index]['materia_nome']}"),
             title:Row(children: <Widget>[
              new Text('MyMatter'),
              Container(
                padding: EdgeInsets.all(5),
                      child: Hero(
                        tag:'logogrupo${widget.cdgrupo}',
                          child: Container(
                            width: 40,
                            height: 40,
                            child: Image.asset("assets/images/group-picturewhite.png"),
                        ),
                    ),
                  ),
                Container(
                   padding: EdgeInsets.all(5),
                      child: Hero(
                        tag:'logomymatter${widget.cdmateria}',
                          child: Container(
                            width: 40,
                            height: 40,
                            child: Image.asset("assets/images/logom.png"),
                        ),
                    ),
                  ),
                  Container(
                   padding: EdgeInsets.all(5),
                      child: Hero(
                        tag:'logohorario${widget.date}',
                          child: Container(
                            width: 40,
                            height: 40,
                            child: Image.asset("assets/images/icon-imagewhite.png"),
                        ),
                    ),
                  )
            ],),
             backgroundColor: Color(0xFF1A2980),
          ),
          body: Container(
            color:Color(0xFF1A2980),
            height: double.infinity,
            width: double.infinity,
            child: Center(
              child: AnimatedContainer(
                duration: Duration(seconds: 1),
                curve: Curves.fastOutSlowIn,
                height: itemHeight,
                width: itemWidth,
                child: Material(
                    elevation: 5,
                    child: Builder(
                      builder: (context) => _isLoading
                          ? new Center(
                              child: new CircularProgressIndicator(),
                            )
                          : _permissionReady
                              ? Column(children: <Widget>[
                                Text(_dataformatada("${widget.date}"),style: TextStyle(fontSize: 30),),
                                Text('Arquivos',style: TextStyle(fontSize: 20),),
                                Expanded(child: _buildWidgets(_items,itemWidth),
                                )
                              ],)
                              : new Container(
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.symmetric(horizontal: 24.0),
                                          child: Text(
                                            'Please grant accessing storage permission to continue -_-',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.blueGrey, fontSize: 18.0),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 32.0,
                                        ),
                                        FlatButton(
                                            onPressed: () {
                                              _checkPermission().then((hasGranted) {
                                                setState(() {
                                                  _permissionReady = hasGranted;
                                                });
                                              });
                                            },
                                            child: Text(
                                              'Mostrar Arquivos',
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.0),
                                            ))
                                      ],
                                    ),
                                  ),
                                )),
                ),
              ),
            ),
          ),
        ),
    );
    
  }

  // Widget _buildActionForTask(_TaskInfo task) {

  //   if (task.status == DownloadTaskStatus.undefined) {
  //     return new RawMaterialButton(
  //       onPressed: () {
  //         _requestDownload(task);
  //          if(widget.currentUserId != task.user_id){
  //             _like(task.token,task.user_id);
  //         }
  //       },
  //       child: widget.currentUserId != task.user_id ? Image.asset('assets/images/applouse.png',scale: 2.0, width: 40.0, height: 40.0):Icon(Icons.file_download,color: Colors.green,),
  //       shape: new CircleBorder(),
  //       constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
  //     );
  //   } else if (task.status == DownloadTaskStatus.running) {
  //     return new RawMaterialButton(
  //       onPressed: () {
  //         _pauseDownload(task);
  //       },
  //       child: new Icon(
  //         Icons.pause,
  //         color: Colors.red,
  //       ),
  //       shape: new CircleBorder(),
  //       constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
  //     );
  //   } else if (task.status == DownloadTaskStatus.paused) {
  //     return new RawMaterialButton(
  //       onPressed: () {
  //         _resumeDownload(task);
  //       },
  //       child: new Icon(
  //         Icons.play_arrow,
  //         color: Colors.green,
  //       ),
  //       shape: new CircleBorder(),
  //       constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
  //     );
  //   } else if (task.status == DownloadTaskStatus.complete) {
  //     return new RawMaterialButton(
  //       onPressed: () {
  //         setState(() {
  //           task.status = DownloadTaskStatus.undefined;
  //         });                    
  //       },
  //       child:  Icon(Icons.refresh,color: Colors.white),
        
  //       shape: new CircleBorder(),
  //       constraints: new BoxConstraints(minHeight: 60.0, minWidth: 60.0),
  //     );
  //   } else if (task.status == DownloadTaskStatus.canceled) {
  //     return new Text('Canceled', style: new TextStyle(color: Colors.red));
  //   } else if (task.status == DownloadTaskStatus.failed) {
  //     return Row(
  //       mainAxisSize: MainAxisSize.min,
  //       mainAxisAlignment: MainAxisAlignment.end,
  //       children: [
  //         new Text('Failed', style: new TextStyle(color: Colors.red)),
  //         RawMaterialButton(
  //           onPressed: () {
  //             _retryDownload(task);
  //           },
  //           child: Icon(
  //             Icons.refresh,
  //             color: Colors.green,
  //           ),
  //           shape: new CircleBorder(),
  //           constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
  //         )
  //       ],
  //     );
  //   } else {
  //     return null;
  //   }
  // }

  // void _requestDownload(_TaskInfo task) async {
  //   task.taskId = await FlutterDownloader.enqueue(
  //       url: task.link,
  //       savedDir: _localPath,
  //       showNotification: true,
  //       openFileFromNotification: false);
  // }

  // void _cancelDownload(_TaskInfo task) async {
  //   await FlutterDownloader.cancel(taskId: task.taskId);
  // }

  // void _pauseDownload(_TaskInfo task) async {
  //   await FlutterDownloader.pause(taskId: task.taskId);
  // }

  // void _resumeDownload(_TaskInfo task) async {

  //       task.taskId = await FlutterDownloader.enqueue(
  //       url: task.link,
  //       savedDir: _localPath,
  //       showNotification: true,
  //       openFileFromNotification: false);
 
  // }

  void _like(token,useridliked) async{
     var timestamp = DateTime.now().millisecondsSinceEpoch.toString();
     await databaseReference.collection('elogios').document('$token:$timestamp').setData({
                                'id':'$token:$timestamp',
                                'timestamp':timestamp,
                                'token':token,
                                'user_id':'$useridliked',
                                'user_idfrom':widget.currentUserId,
                                'createdAt': DateTime.now(),  
                              }).then((data) async {
                                Fluttertoast.showToast(msg: 'Elogiado');
                                return true;
                              
                              }).catchError((err) {
                                Fluttertoast.showToast(msg: err.toString());
                                return false;
                              });


    print(token);
  }

  // void _retryDownload(_TaskInfo task) async {
  //   String newTaskId = await FlutterDownloader.retry(taskId: task.taskId);
  //   task.taskId = newTaskId;
  // }

  // Future<bool> _openDownloadedFile(_TaskInfo task) {
  //   return FlutterDownloader.open(taskId: task.taskId);
  // }

  Future<bool> _checkPermission() async {
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.android) {
      PermissionStatus permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);
      if (permission != PermissionStatus.granted) {
        Map<PermissionGroup, PermissionStatus> permissions =
            await PermissionHandler()
                .requestPermissions([PermissionGroup.storage]);
        if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

   _getconexao() async {
    print("${widget.cdgrupo}");
    print("${widget.cdmateria}");
    print("${widget.date}");

  final QuerySnapshot result = await Firestore.instance.collection('grupos').document('${widget.cdgrupo}').collection('matters').document('${widget.cdmateria}').collection('datas').document('${widget.date}').collection('files').getDocuments();
  final List<DocumentSnapshot> documents = result.documents;
 
      return documents;
  }

  Future<bool> _prepare() async {
    
    try {

    // final tasks = await FlutterDownloader.loadTasks();
    
    
    List<DocumentSnapshot>  dados = await _getconexao();

     

  
    List<Map<String,String>> listdados = dados.map((DocumentSnapshot file){ 

      var dadosdata = file.data();
    
    return {'name': '${dadosdata['link']}', 'token': '${dadosdata['token']}', 'user_id':'${dadosdata['user_id']}', 'namefile':'${dadosdata['name']}'};
    
    }).toList();

   
    int count = 0;
    _tasks = [];
    _items = [];

   _tasks.addAll(listdados.map((dado) =>_TaskInfo(name: dado['name'], link:dado['name'], token:dado['token'], user_id:dado['user_id'], namefile: dado['namefile'])));


    for (int i = count; i < _tasks.length; i++) {
      bool imgtype;
      var _extension = _tasks[i].namefile.toString().split('.').last;
      if(_extension == 'png' || _extension == 'jpeg' || _extension == 'jpg'){
          imgtype = true;
      }else{
        imgtype = false;
      }
      _items.add(_ItemHolder(img: imgtype, name: _tasks[i].name, task: _tasks[i],token:_tasks[i].token, user_id:_tasks[i].user_id, namefile:_tasks[i].namefile ));
      count++;
    }

   
    // tasks?.forEach((task) {
    //   for (_TaskInfo info in _tasks) {
    //     if (info.link == task.url) {
    //       info.taskId = task.taskId;
    //       info.status = task.status;
    //       info.progress = task.progress;
    //     }
    //   }
    // });

    _permissionReady = await _checkPermission();

    _localPath = (await _findLocalPath()) + '/Download';

    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    return true;
  }catch(e){
    print(e.toString());
    return false;
  }

    
  }


  Future<String> _findLocalPath() async {
    final platform = Theme.of(context).platform;
    final directory = platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }
}

class _TaskInfo {
  final String name;
  final String link;
  final String token;
  final String user_id;
  final String namefile;

  String taskId;
  int progress = 0;
  // DownloadTaskStatus status = DownloadTaskStatus.undefined;

  _TaskInfo({this.name, this.link, this.token, this.user_id,this.namefile});
}

class _ItemHolder {
  final bool img;
  final String name;
  final String token;
  final _TaskInfo task;
  final String user_id;
  String namefile;

  _ItemHolder({this.img, this.name, this.task,this.token,this.user_id,this.namefile});
}


class ExibeImagem extends StatelessWidget {
  final String tag;
  final String imagedirectory;
  
  ExibeImagem({this.imagedirectory,this.tag});

@override
Widget build(BuildContext context) {
  return ZoomableWidget(
      child: Container(
        child: Hero(
                  tag: tag,
                  child: Image.network(imagedirectory,fit: BoxFit.fill,
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
        ),
                ),
  );
  }
}


class ZoomableWidget extends StatefulWidget {
  final Widget child;

  const ZoomableWidget({Key key, this.child}) : super(key: key);
  @override
  _ZoomableWidgetState createState() => _ZoomableWidgetState();
}

class _ZoomableWidgetState extends State<ZoomableWidget> {
  Matrix4 matrix = Matrix4.identity();

  @override
  Widget build(BuildContext context) {
    return MatrixGestureDetector(
      onMatrixUpdate: (Matrix4 m, Matrix4 tm, Matrix4 sm, Matrix4 rm) {
        setState(() {
          matrix = m;
        });
      },
      child: Transform(
        transform: matrix,
        child: widget.child,
      ),
    );
  }
}



class ProgressCard extends StatefulWidget {
  final double progressPercent;
  ProgressCard({this.progressPercent});
  @override
  _ProgressCardState createState() => _ProgressCardState(progressPercent:progressPercent);
}

class _ProgressCardState extends State<ProgressCard> {
  double progressPercent;
  _ProgressCardState({this.progressPercent});
  @override
  Widget build(BuildContext context) {
    Color foreground = Colors.red;

  
    if (progressPercent >= 0.8) {
      foreground = Colors.green;
    } else if (progressPercent >= 0.4) {
      foreground = Colors.orange;
    }

    Color background = foreground.withOpacity(0.2);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 95,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              child: CircleProgressBar(
                backgroundColor: background,
                foregroundColor: foreground,
                value: this.progressPercent,
              ),
              onTap: () {
                final updated = ((this.progressPercent + 0.1).clamp(0.0, 1.0) *
                    100);
                setState(() {
                  this.progressPercent = updated.round() / 100;
                });
              },
              onDoubleTap: () {
                final updated = ((this.progressPercent - 0.1).clamp(0.0, 1.0) *
                    100);
                setState(() {
                  this.progressPercent = updated.round() / 100;
                });
              },
            ),
          ),
        ),
        Text("${this.progressPercent * 100}%"),
      ],
    );
  }
}