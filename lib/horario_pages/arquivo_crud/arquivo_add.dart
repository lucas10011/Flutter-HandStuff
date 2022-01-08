import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hand_stuff/horario_pages/arquivo_crud/buttons_arquivo.dart';
import 'package:hand_stuff/horario_pages/arquivo_crud/scan_mymatter.dart';
import 'package:hand_stuff/login.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:path/path.dart' as path;

class UploadMultipleFiles extends StatefulWidget {
    final String cdgrupo;
    final String cdmateria;
    final String currentUserId;
    final String datetime;
    final String descricao;
    final Function function;

  UploadMultipleFiles({this.cdgrupo, this.cdmateria,this.currentUserId,this.datetime,this.descricao,this.function});
 
  @override
  UploadMultipleFilesState createState() => UploadMultipleFilesState(cdgrupo: cdgrupo,cdmateria: cdmateria,currentUserId: currentUserId,datetime: datetime,descricao: descricao,function: function);
}
 
class UploadMultipleFilesState extends State<UploadMultipleFiles> {
    final String cdgrupo;
    final String cdmateria;
    final String currentUserId;
    final String datetime;
    final String descricao;
    final Function function;
  UploadMultipleFilesState({this.cdgrupo, this.cdmateria,this.currentUserId,this.datetime,this.descricao,this.function});
  static const String CAMERA_SOURCE = 'CAMERA_SOURCE';
  static const String GALLERY_SOURCE = 'GALLERY_SOURCE';
  String _path;
  Map<String, String> _paths;
  List<String> _extension;
  FileType _pickType;
  bool _multiPick = true;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  List<firebase_storage.UploadTask> _tasks = <firebase_storage.UploadTask>[];
  
  int _countupload = 0;

  final databaseReference = Firestore.instance;

  String materiacodigo = DateTime.now().toString();
  String date = DateFormat("yyyy-MM-dd").format(DateTime.now()).toString();

  String horariotimestamp = DateTime.now().millisecondsSinceEpoch.toString();

// SharedPreferences prefs;

bool dataexist = false;
bool scanbutton = false;

var _questionIndex = 0;


List _tamanho = [];

createDirectory() async {

   final QuerySnapshot result = await databaseReference.collection('grupos').document('$cdgrupo').collection('matters').document('$cdmateria').collection('datas').where('horario_date', isEqualTo: '$datetime').getDocuments();
   final List<DocumentSnapshot> documents = result.documents;

   bool status = false;
    
      if(documents.isNotEmpty){
          if(widget.descricao != ''){
            await databaseReference.collection('grupos').document('$cdgrupo').collection('matters').document('$cdmateria').collection('datas').document('$datetime').updateData({
              'horario_descricao' :'$descricao',             
              'horarios_timestamp':'$horariotimestamp',
            }).then((data){
              status = true;
            }).catchError((err) {
              Fluttertoast.showToast(msg: err.toString());
             print(err.toString());
            });
          }else{
            await databaseReference.collection('grupos').document('$cdgrupo').collection('matters').document('$cdmateria').collection('datas').document('$datetime').updateData({
                'horarios_timestamp':'$horariotimestamp',            
              }).then((data){
                status = true;
              }).catchError((err) {
                Fluttertoast.showToast(msg: err.toString());
                 print(err.toString());
              });
          }
          
      }else{
          await databaseReference.collection('grupos').document('$cdgrupo').collection('matters').document('$cdmateria').collection('datas').document('$datetime').setData({
                'grupo_codigo' : '$cdgrupo',
                'materia_codigo' : '$cdmateria',
                'horario_date' :'$datetime',
                'horario_timestamp' :'$horariotimestamp',
                'horario_descricao' :'$descricao',             

            }).then((data) async {
              final QuerySnapshot resultsucess = await databaseReference.collection('grupos').document('$cdgrupo').collection('matters').document('$cdmateria').collection('datas').where('horario_date', isEqualTo: '$datetime').getDocuments();
              final List<DocumentSnapshot> documentssucess = resultsucess.documents;
              function(documentssucess[0]);
              status = true;
            }).catchError((err) {
              Fluttertoast.showToast(msg: err.toString());
               print(err.toString());
            });
      }
      return status;
}

// removeIntent() async {
//   prefs = await SharedPreferences.getInstance();
//   prefs.setStringList('intent', []);
//   print('Intent removed');
// }

// Future<bool> checkIntent() async{

//   prefs = await SharedPreferences.getInstance();

//   List list =  prefs.getStringList('intent');
//   List list2 = ['content://0@media/external/images/media/23869','content://0@media/external/images/media/23857','content://0@media/external/images/media/23856','content://0@media/external/images/media/23855'];

//   if (list != null){
//     if(list.isNotEmpty){
//       list.forEach((f) async { 
//         String namefile;
//         var absolutepath = await FlutterAbsolutePath.getAbsolutePath(f);
//         File file = new File(absolutepath);
//         namefile = path.basename(file.path);

//         print(absolutepath);
//         print(namefile);
//         upload(namefile, absolutepath,false);
        
//       });

//       return true;
      
//     }else{
//       return false;
//     }
//   }else{
//     return false;
//   }

// }

  
void initState(){
   super.initState();
  // double x = 100;
  // double y = 100;
  // double z = 465;
  // for (var i = 0; i < 365; i++){
  //   print("Inteligencia:${x+=0.5}, Agilidade:${y+=0.5}, Força: ${z-=1} ");
  // }

}

  uploadToFirebase() async {
    if(_paths != null){
      if (_multiPick) {
        try{
          var create = await createDirectory();
          if(create){
            _paths.forEach((fileName, filePath) => {
            print(filePath),
            upload(fileName, filePath, false)
            });
          }
          
        }on PlatformException catch (e){
            print("Nao selecionou nenhum arquivo/uploadToFirebase" + e.toString());
        }
      

    } else {
      String fileName = _path.split('/').last;
      String filePath = _path;
      upload(fileName, filePath, false);
      }
    }

    
    
  }


  upload(fileName, filePath,camera) {
    var file = File(filePath);
    var bytes = file.lengthSync();

    if(bytes < 8000000 ){  
      _extension[0] = fileName.toString().split('.').last;
      firebase_storage.Reference storageRef =
          firebase_storage.FirebaseStorage.instance.ref().child('$cdgrupo/$cdmateria/$datetime/$fileName');
      final firebase_storage.UploadTask uploadTask = storageRef.putFile(
        File(filePath),
      camera ? firebase_storage.SettableMetadata(contentType: 'image/png',) : firebase_storage.SettableMetadata(
          contentType: '$_pickType/$_extension',
        ),
      );
      setState(() {
        _tamanho.add(bytes);
        _tasks.add(uploadTask);
      });
    }else{
       Fluttertoast.showToast(msg: "Tamanho máximo de 8mb por arquivo/imagem/video");
    }
  }

  uploadPdf(fileName, filePath) async{
    var create = await createDirectory();
  if(create){
    var file = File(filePath);
    var bytes = file.lengthSync();

      if(bytes < 8000000 ){  
        _extension[0] = fileName.toString().split('.').last;
        firebase_storage.Reference storageRef =
            firebase_storage.FirebaseStorage.instance.ref().child('$cdgrupo/$cdmateria/$datetime/$fileName');
        final firebase_storage.UploadTask uploadTask = storageRef.putFile(
          File(filePath),
          firebase_storage.SettableMetadata(
            contentType: 'null/pdf',
          ),
        );
        setState(() {
          _tamanho.add(bytes);
          _tasks.add(uploadTask);
        });
      }else{
        Fluttertoast.showToast(msg: "Tamanho máximo de 8mb por arquivo/imagem/video");
      }
    }
  }
 
  /*
  dopDown() {
    return DropdownButton(
      hint: new Text('Selecione o tipo'),
      value: _pickType,
      items: <DropdownMenuItem>[
        
        new DropdownMenuItem(
          child: new Text('Audio'),
          value: FileType.AUDIO,
        ),
        new DropdownMenuItem(
          child: new Text('Image'),
          value: FileType.IMAGE,
        ),
        new DropdownMenuItem(
          child: new Text('Video'),
          value: FileType.VIDEO,
        ),
        new DropdownMenuItem(
          child: new Text('Any'),
          value: FileType.ANY,
        ),
      ],
      onChanged: (value) => setState(() {
            _pickType = value;
          }),
    );
  }
*/
  openFileExplorer() async {
    try {
      _path = null;
      if (_multiPick) {
        try{
          _paths = await FilePicker.getMultiFilePath(
          type: _pickType, allowedExtensions: _extension);
          print(_paths);
        }on PlatformException catch (e){
            print("Nao selecionou nenhum arquivo" + e.toString());
        }
        
      } else {
        try{
          _path = await FilePicker.getFilePath(
          type: _pickType, allowedExtensions: _extension);
        }on PlatformException catch (e){
            print("Nao selecionou nenhum arquivo" + e.toString());
        }       
      }
      uploadToFirebase();
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;
  }


getImageFromCamera() async {
    print('testedecamera');
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image.length() == null ){
    print("Sem data");
    }else{
     var imagePath = image.path;
     var imageName = image.path.split("/").last;
      DateTime todayDate = DateTime.now();
      String namefile = DateFormat('yyyyMMddhhmmss').format(todayDate);
    
      print(imagePath);
      upload('$namefile.png', imagePath, true);

    }
  }
 

 
  onPickImageSelected(String source) async {
    var imageSource;
    if (source == CAMERA_SOURCE) {
      imageSource = ImageSource.camera;
    } else {
      imageSource = ImageSource.gallery;
    }
    
    try {
      final file =
          await ImagePicker.pickImage(source: imageSource);
      if (file == null) {
        throw Exception('File is not available');
      }


      // Navigator.push(
      //   context,
      //   new MaterialPageRoute(builder: (context) => DetailWidget(file, TEXT_SCANNER,uploadPdf)),
      // );
      
    } catch(e) {
      print(e.toString());
    }
  }

 
  String _bytesTransferred(firebase_storage.TaskSnapshot snapshot) {
    double progressPercent = snapshot.bytesTransferred/snapshot.totalBytes;
    var porcentagem = '${(progressPercent * 100).toStringAsFixed(2)} % ';
    return porcentagem;
  }
 
  @override
  Widget build(BuildContext context) {
      var size = MediaQuery.of(context).size;
      final double itemWidth = (size.width - 26);
      final double itemHeight = (size.height);

    final List<Widget> children = <Widget>[];
    _tasks.asMap().forEach((index,firebase_storage.UploadTask task) {
      final Widget tile = UploadTaskListTile(bytes:_tamanho[index],dataexist: dataexist,cdgrupo:'$cdgrupo',cdmateria:'$cdmateria',currentUserId: '$currentUserId',datetime: '$datetime',descricao:'$descricao', databaseReference: databaseReference,
        task: task,
        onDismissed: () => setState(() => _tasks.remove(task)),
        onDownload: () => downloadFile(task.lastSnapshot.ref),
      );
      children.add(tile);
    });
 
      return new Scaffold(
        appBar: AppBar(
        title: Text('MyMatter - $datetime'),
        backgroundColor: Color(0xFF1A2980),
      ),
        key: _scaffoldKey,
        body: new Container(
          color: Color(0xFF1A2980),
          child: Center(
            child: Container(
              width: itemWidth,
              height: itemHeight,
              child: Material(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24.0))),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    //dropDown(),
                    Text('Adicione fotos/documentos/videos' ,style: TextStyle(fontSize: 20),),
                    SizedBox(
                      height: 20.0,
                    ),
                    Flexible(
                      child: ListView(
                        addAutomaticKeepAlives: true,
                        children: children,
                      ),
                    ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                    
                      _tasks.isEmpty ? FancyFabArquivo(addfile:openFileExplorer,scanfile:onPickImageSelected,tipo:0): Container(),
                      _tasks.isEmpty ? FancyFabArquivo(addfile:getImageFromCamera,scanfile:onPickImageSelected,tipo:1): Container()

                    ],),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  }
 
  Future<void> downloadFile(firebase_storage.Reference ref) async {
    final String url = await ref.getDownloadURL();
    final http.Response downloadData = await http.get(url);
    final Directory systemTempDir = Directory.systemTemp;
    final File tempFile = File('${systemTempDir.path}/tmp.jpg');
    if (tempFile.existsSync()) {
      await tempFile.delete();
    }
    await tempFile.create();
    final firebase_storage.DownloadTask task = ref.writeToFile(tempFile);
    final int byteCount = (await task.then((value) => value.totalBytes));
    var bodyBytes = downloadData.bodyBytes;
    final String name = await ref.getName();
    final String path = await ref.getPath();
    print(
      'Success!\nDownloaded $name \nUrl: $url'
      '\npath: $path \nBytes Count :: $byteCount',
    );
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        content: Image.memory(
          bodyBytes,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
 
class UploadTaskListTile extends StatefulWidget{
    final int bytes;
    final bool dataexist; 
    final String cdgrupo;
    final String cdmateria;
    final String currentUserId;
    final String datetime;
    final String descricao;
    final Firestore databaseReference;

  const UploadTaskListTile(
      {Key key,this.bytes,this.dataexist,this.cdgrupo, this.cdmateria,this.currentUserId,this.datetime,this.descricao,this.databaseReference, this.task, this.onDismissed, this.onDownload,})
      : super(key: key);
 
  final firebase_storage.UploadTask task;
  final VoidCallback onDismissed;
  final VoidCallback onDownload;

  @override
  _UploadTaskListTileState createState() => _UploadTaskListTileState();
}

class _UploadTaskListTileState extends State<UploadTaskListTile> with AutomaticKeepAliveClientMixin {





    // bool  _documentChange = widget.documentExist;

    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String date = DateFormat("yyyy-MM-dd").format(DateTime.now()).toString(); 
  



    Future<void> downloadFile(firebase_storage.Reference ref) async {
     final String url = await ref.getDownloadURL();

      var urlsplit = url.split('%2F');
      var token = urlsplit[3].split('=');
      var namefile = urlsplit[3].split('?');

      
        await widget.databaseReference.collection('grupos').document('${widget.cdgrupo}').collection('matters').document('${widget.cdmateria}').updateData({
                          'last_post': timestamp, 
                        });

        await widget.databaseReference.collection('grupos').document('${widget.cdgrupo}').collection('matters').document('${widget.cdmateria}').collection('datas').document('${widget.datetime}').collection('files').document('${token[2]}').setData({
        'token':'${token[2]}',
        'name':'${namefile[0]}',
        'link' : '$url',
        'user_id':'${widget.currentUserId}',
        'timestamp': timestamp,           
          }).then((data) async {

                await widget.databaseReference.collection('grupos').document('${widget.cdgrupo}').collection('history').document('${widget.currentUserId}:$timestamp').setData({
                  'timestamp':timestamp,
                  'name':'${namefile[0]}',
                  'grupo_codigo' : '${widget.cdgrupo}',
                  'materia_codigo' : '${widget.cdmateria}',
                  'horario_date' :'${widget.datetime}',
                  'horario_descricao' :'${widget.descricao}',
                  'user_id':'${widget.currentUserId}',
                  'user_bytes':widget.bytes
                    }).then((data) async {
                      await widget.databaseReference.collection('posts').document('${token[2]}').setData({
                          'user_id':'${widget.currentUserId}', 
                        }).then((data) async {
                          Fluttertoast.showToast(msg: "Adicionado com sucesso");
                          return true;                             
                        }).catchError((err) {
                          Fluttertoast.showToast(msg: err.toString());
                          return false;
                        });
                        
                      }).catchError((err) {
                        Fluttertoast.showToast(msg: err.toString());
                        return false;
                      });
              }).catchError((err) {
                Fluttertoast.showToast(msg: err.toString());
                return false;
              });
                                    

      return url;
    }

  String get status {
    String result;
    if (widget.task.snapshot.state.index == 2) {
        result = 'Complete';
        downloadFile(widget.task.lastSnapshot.ref);
    } 
    return result;
  }

  _progresso(progressPercent){

    return Column(children: <Widget>[
      LinearProgressIndicator(value: progressPercent),
      Text('$status: ${(progressPercent * 100).toStringAsFixed(2)} % ')
    ],);

  }

    _bytesTransferred(firebase_storage.TaskSnapshot snapshot) {
    double progressPercent = snapshot.bytesTransferred/snapshot.totalBytes;

     return  _progresso(progressPercent); 

    

    //return '${snapshot.bytesTransferred}/${snapshot.totalByteCount}';

  }


  _dismissible(context,subtitle){
    return Dismissible(
          key: Key(widget.task.hashCode.toString()),
          onDismissed: (_) => widget.onDismissed(),
          child: ListTile(
            title: Text('Upload Task #${widget.task.hashCode}'),
            subtitle: subtitle,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Offstage(
                //   offstage: !widget.task.isInProgress,
                //   child: IconButton(
                //     icon: const Icon(Icons.pause),
                //     onPressed: () => widget.task.pause(),
                //   ),
                // ),
                // Offstage(
                //   offstage: !widget.task.isPaused,
                //   child: IconButton(
                //     icon: const Icon(Icons.file_upload),
                //     onPressed: () => widget.task.resume(),
                //   ),
                // ),
                // Offstage(
                //   offstage: widget.task.isComplete,
                //   child: IconButton(
                //     icon: const Icon(Icons.cancel),
                //     onPressed: () => widget.task.cancel(),
                //   ),
                // ),
              ],
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.task.events,
      builder: (BuildContext context,
          AsyncSnapshot asyncSnapshot) {
        Widget subtitle;
        if (asyncSnapshot.hasData) {
          final firebase_storage.TaskSnapshot event = asyncSnapshot.data;
          subtitle = _bytesTransferred(event);
        } else {
          subtitle = const Text('Starting...');
        }

        
        return _dismissible(context,subtitle);
      },
    );
  }

  bool get wantKeepAlive => true;
}

