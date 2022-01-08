// import 'package:flutter/material.dart';
// import 'package:hand_stuff/homepage.dart';
// import 'package:hand_stuff/login.dart';
// import 'package:hand_stuff/main.dart';
// import 'materia_detalhes.dart';


// import 'package:http/http.dart' as http;


// class EditData extends StatefulWidget {
//   final List list;
//   final int index;


//   EditData({this.list, this.index});

//   @override
//   _EditDataState createState() => _EditDataState();
// }

// class _EditDataState extends State<EditData> {


//   TextEditingController  cuid;
//   TextEditingController  cname;
 
//   void editData() {

//     var url="${Urls.BASE_API_URL}/editdata.php";

//     http.post(url,body:{
//       "group_id":cuid.text,
//       "group_nome":cname.text,


//     });
//     print(cuid.text);
//     print(cname.text);
//   }
//     @override
//     void initState(){
//       cuid=new TextEditingController(text: widget.list[widget.index]['group_id']);
//       cname=new TextEditingController(text: widget.list[widget.index]['group_nome']);

//       super.initState();
//     }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: new AppBar(
//         title: Text("EDIT DATA"),
//       ),
//       body:Padding(
//         padding: const EdgeInsets.all(10.0),
//         child: ListView(
//           children: <Widget>[
//             new Column(
//               children: <Widget>[
//                 new TextField(
//                   controller: cuid,
//                   decoration: new InputDecoration(
//                     hintText: "UID",
//                     labelText: "UID",
//                   ),
//                 ),
//                 new TextField(
//                   controller: cname,
//                   decoration: new InputDecoration(
//                     hintText: "Name",
//                     labelText: "Name",
//                   ),
//                 ),
//                 new Padding(padding: EdgeInsets.all(10.0)),
//                 new RaisedButton(onPressed: (){
//                   editData();
//                   Navigator.of(context).push(
//                     new MaterialPageRoute(
//                         builder: (BuildContext context)=>new Home()
//                     ),
//                   );
//                 },
//                   child: new Text("EDIT  Data"),
//                   color: Colors.deepOrange,
//                 )

//               ],
//             ),
//           ],
//         ),
//       ),

//     );
//   }
// }
