// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:hand_stuff/horario_pages/arquivo_crud/formatpdfclass.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:mlkit/mlkit.dart';
// import 'package:path/path.dart' as path;
// class DetailWidget extends StatefulWidget  {

//   File _file;
//   String _scannerType;
//   Function uploadPdf;

//   DetailWidget(this._file, this._scannerType,this.uploadPdf);

//   @override
//   State<StatefulWidget> createState() {
//     return _DetailState();
//   }
// }

// class _DetailState extends State<DetailWidget> {

//   FirebaseVisionTextDetector textDetector = FirebaseVisionTextDetector.instance;
//   FirebaseVisionBarcodeDetector barcodeDetector = FirebaseVisionBarcodeDetector.instance;
//   List<VisionText> _currentTextLabels = <VisionText>[];
//   List<VisionBarcode> _currentBarcodeLabels = <VisionBarcode>[];
//   TextEditingController _code=new TextEditingController();
//   TextEditingController _index=new TextEditingController();
//   TextEditingController _type=new TextEditingController();


//   List<Map> _listTextPdf = [];

//   bool editing = false;

//    List<String> formatacao = <String>['Header1','Header2','Paragraph','Column',];

//   @override
//   void initState() {
//     super.initState();
//     Timer(Duration(milliseconds: 1000), () {
//       this.analyzeLabels();
//     });
//   }

//   void analyzeLabels() async {
//     try {
//       List<VisionText> currentLabels;
//       List<Map> currentList = [];
      
//       currentLabels = await textDetector.detectFromPath(widget._file.path);
//       currentLabels.forEach((f){
//         currentList.add({'type':2,'stringPdf':f.text});
//       });
        
//       setState(() {
//         _currentTextLabels = currentLabels;
//         _listTextPdf = currentList;
//       });
    
//     } catch (e) {
//       print(e.toString());
//     }
//   }

//   changeEditing(){
//     print('oi');
//     if(editing){
//       setState(() {
//         editing = false;
//       });
//     }else{
//       editing = true;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           backgroundColor: Color(0xFF1A2980),
//           centerTitle: true,
//           title: Text('MyMatter - PDF'),
//         ),
//         body: Stack(
//           children: <Widget>[
//             Column(children: <Widget>[
//               buildImage(context),
//               buildTextList(_listTextPdf), 
//             ],
//           ),
         
//         ]),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Color(0xFF1A2980),
//         child: ImageIcon(
//                     AssetImage("assets/images/pdf.png",),
//                     color: Colors.white
//                ),
//         onPressed: () async {
         
//         String pdfPath = await ConvertPdf.convert(_listTextPdf);
//         File file = new File(pdfPath);
//         String namefile = path.basename(file.path);
//         print(namefile);
//         print(pdfPath);
//         widget.uploadPdf(namefile,pdfPath);
//         Navigator.pop(context);
        
//         },
//       ),
        
//         );
//   }

//   Widget buildImage(BuildContext context) {
//     return
//         Expanded(
//             flex: 2,
//           child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.black
//               ),
//               child: Center(
//                 child: widget._file == null
//                     ? Text('No Image')
//                     : FutureBuilder<Size>(
//                   future: _getImageSize(Image.file(widget._file, fit: BoxFit.fitWidth)),
//                   builder: (BuildContext context, AsyncSnapshot<Size> snapshot) {
//                     if (snapshot.hasData) {
//                       return Container(
//                           foregroundDecoration:TextDetectDecoration(_currentTextLabels, snapshot.data),
//                           child: Image.file(widget._file, fit: BoxFit.fitWidth));
//                     } else {
//                       return CircularProgressIndicator();
//                     }
//                   },
//                 ),
//               )
//           ),
//         );

//   }



//   Widget buildTextList(List<Map> texts) {
//     if (texts.length == 0) {
//       return Expanded(
//         flex: 1,
//         child: Center(child: Text('No text detected', style: Theme.of(context).textTheme.subhead),
//       ));
//     }
//     return Expanded(
//       flex: 1,
//       child: Container(
//         child: ListView.builder(
//             padding: const EdgeInsets.all(1.0),
//             itemCount: texts.length,
//             itemBuilder: (context, i) {
//               return _buildTextRow(texts[i]['stringPdf'],i,texts[i]['type']);
//             }),
//       ),
//     );
//   }

//   Widget _buildTextRow(text,i,type) {
//     return Dismissible(  
//   // Show a red background as the item is swiped away.
//       direction: DismissDirection.endToStart,
//       background: Container(
//         alignment: Alignment.centerRight,
//         child:Icon(Icons.delete,color: Colors.white,),color: Colors.red),
//       key: Key(UniqueKey().toString()), 
//       onDismissed: (direction) { 
//         setState(() {
//            _currentTextLabels.removeAt(i);
//            _listTextPdf.removeAt(i);
//         });
//       },
//         child: ListTile(
//         onTap: ()=>_showDialog(text,i,type),
//         title: Text("$text"),
//         dense: true,
//       ),
//   );
// }


//   Future<Size> _getImageSize(Image image) {
//     Completer<Size> completer = Completer<Size>();
//     image.image.resolve(ImageConfiguration()).addListener(ImageStreamListener((ImageInfo info, bool _) => completer.complete(
//             Size(info.image.width.toDouble(), info.image.height.toDouble()))));
//     return completer.future;
//   }

// initialValue(text,index,type) {
//    _code = TextEditingController(text: text);
//    _index = TextEditingController(text: index.toString());
//    _type = TextEditingController(text: type.toString());
// }
// changeValue(text,index,type){
//    _code = TextEditingController(text: text);
//    _index = TextEditingController(text: index.toString());
//    _type = TextEditingController(text: type.toString());
//   print(text);
//   print(index);
//   print(type);
// }

// _showDialog(text,i,type) async {
//   initialValue(text,i,type);
//   await showGeneralDialog(
//               barrierColor: Colors.black.withOpacity(0.5),
//               transitionBuilder: (context, a1, a2, widget) {
//                 final curvedValue = Curves.easeInOutBack.transform(a1.value) -   1.0;
//                   return Transform(
//                     transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
//                     child: Opacity(
//                       opacity: a1.value,
//                       child: AlertDialog(
//                         shape: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(16.0)),
//                           title: Text("Edit text"),
//                           content: SingleChildScrollView(
//                             scrollDirection: Axis.vertical,
//                             child: Container(
//                               width: MediaQuery.of(context).size.width * 0.9,
//                               height: MediaQuery.of(context).size.height * 0.9,
//                               child: new MyDialogContent(formatacao: formatacao,text:text,type:type,indexList:i,changeValue:changeValue)),
//                           ),
//                           actions: <Widget>[
//                             FlatButton(
//                               child: Text('Salvar'),
//                               onPressed: () {
//                                 var iNew = int.parse(_index.text);
//                                 setState(() {
//                                     _listTextPdf[iNew]['stringPdf'] = _code.text;
//                                   _listTextPdf[iNew]['type'] = int.parse(_type.text);
//                                 });
//                                 Navigator.pop(context);
//                               },
//                             )
//                           ],
//                         ),
//                       ),
//                     );
//                 },
//                 transitionDuration: Duration(milliseconds: 300),
//                 barrierDismissible: true,
//                 barrierLabel: '',
//                 context: context,
//                 pageBuilder: (context, animation1, animation2) {} 
//                 );
//   }
 
// }



// class TextDetectDecoration extends Decoration {
//   final Size _originalImageSize;
//   final List<VisionText> _texts;
//   TextDetectDecoration(List<VisionText> texts, Size originalImageSize)
//       : _texts = texts,
//         _originalImageSize = originalImageSize;

//   @override
//   BoxPainter createBoxPainter([VoidCallback onChanged]) {
//     return _TextDetectPainter(_texts, _originalImageSize);
//   }
// }

// class _TextDetectPainter extends BoxPainter {
//   final List<VisionText> _texts;
//   final Size _originalImageSize;
//   _TextDetectPainter(texts, originalImageSize)
//       : _texts = texts,
//         _originalImageSize = originalImageSize;

//   @override
//   void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
//     final paint = Paint()
//       ..strokeWidth = 2.0
//       ..color = Colors.red
//       ..style = PaintingStyle.stroke;

//     final _heightRatio = _originalImageSize.height / configuration.size.height;
//     final _widthRatio = _originalImageSize.width / configuration.size.width;
//     for (var text in _texts) {
//       final _rect = Rect.fromLTRB(
//           offset.dx + text.rect.left / _widthRatio,
//           offset.dy + text.rect.top / _heightRatio,
//           offset.dx + text.rect.right / _widthRatio,
//           offset.dy + text.rect.bottom / _heightRatio);
//       canvas.drawRect(_rect, paint);
//     }
//     canvas.restore();
//   }
// }



// const String TEXT_SCANNER = 'TEXT_SCANNER';
// const String BARCODE_SCANNER = 'BARCODE_SCANNER';



// class MyDialogContent extends StatefulWidget {
//   MyDialogContent({
//     Key key,
//     this.formatacao,
//     this.text,
//     this.type,
//     this.indexList,
//     this.changeValue,
//   }): super(key: key);

//   final List<String> formatacao;
//   final String text;
//   final int type;
//   final int indexList;
//   final Function changeValue;

//   @override
//   _MyDialogContentState createState() => new _MyDialogContentState();
// }

// class _MyDialogContentState extends State<MyDialogContent> {
//   int _selectedIndex = 2;

//   TextEditingController _codeDialog=new TextEditingController();
//   TextEditingController _typeDialog=new TextEditingController();

//   @override
//   void initState(){
//     super.initState();
//     _selectedIndex = widget.type;
//     _codeDialog = TextEditingController(text: widget.text);
//     _typeDialog = TextEditingController(text: widget.formatacao[2]);
//   }

//   _getContent(){
//     if (widget.formatacao.length == 0){
//       return new Container();
//     }

//   _listGenerate(){
//     return new ListView.builder(
//           shrinkWrap: true,
//          itemCount: widget.formatacao.length,
//         itemBuilder: (BuildContext context, int index){
//           return new RadioListTile<int>(
//             value: index,
//             groupValue: _selectedIndex,
//             title: new Text(widget.formatacao[index]),
//             onChanged: (int value) {
//               widget.changeValue(_codeDialog.text,widget.indexList,value);
//               _typeDialog = TextEditingController(text: value.toString());
//               setState((){
//                 _selectedIndex = value;
//               });
//             },
//           );
//         }
        
//       );
//   }

//     return new Column(
//           children: <Widget>[
//             TextField(
//                 maxLines: 9,
//                 onChanged: (value){
//                   widget.changeValue(value,widget.indexList,_typeDialog.text);
//                 },
//                 keyboardType: TextInputType.multiline,
//                 controller: _codeDialog,
//                 ),
//                Expanded(child: _listGenerate(),)
//           ]
//         );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return _getContent();
//   }
// }

