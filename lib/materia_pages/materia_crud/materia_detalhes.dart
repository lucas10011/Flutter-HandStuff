// import 'package:flutter/material.dart';


// import 'package:hand_stuff/homepage.dart';
// import 'package:hand_stuff/login.dart';
// import 'package:hand_stuff/materia_pages/materia_crud/materia_edit.dart';
// import 'package:http/http.dart' as http;
// import 'package:hand_stuff/main.dart';

// class Details extends StatefulWidget {
//   List list;
//   int index;

//   Details({this.list, this.index});

//   @override
//   _DetailsState createState() => _DetailsState();
// }

// class _DetailsState extends State<Details> {

//   void deleteData()
//   {
//     var url="${Urls.BASE_API_URL}/deletedata.php";

//     http.post(url,
//         body:{
//              'group_id':"${widget.list[widget.index]['group_id']}"
//             });
//   }

//   void confirm()
//   {
//     AlertDialog alertDialog=new AlertDialog(
//       content: Text("Are you sure you want to delete this record ${widget.list[widget.index]['group_nome']}"),
//       actions: <Widget>[
//         new RaisedButton(
//           child: Text("Ok Delete",style: new TextStyle(color: Colors.black),),
//           onPressed: (){
//             deleteData();
//             Navigator.of(context).push(
//               new MaterialPageRoute(
//                   builder: (BuildContext context)=>new Home(),
//               )
//             );
//           },

//           color: Colors.red,
//         ),
//         new RaisedButton(
//           child: Text("CANCEL",style: new TextStyle(color: Colors.black),),
//           color: Colors.green,
//           onPressed: (){
//             Navigator.of(context).pop();
//           },
//         ),
//       ],
//     );
    
//     showDialog(context: context,child: alertDialog);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: new AppBar(
//         title: new Text("${widget.list[widget.index]['group_nome']}"),
//       ),
//       body: new Container(
//         padding: EdgeInsets.all(20.0),
//         child: new Center(
//           child: new Column(
//             children: <Widget>[
//               new Text(
//                 widget.list[widget.index]['group_id'],
//                 style: new TextStyle(fontSize: 20.0),
//               ),
//               new Text(
//                 widget.list[widget.index]['group_nome'],
//                 style: new TextStyle(fontSize: 20.0),
//               ),

//               new Row(
//                 mainAxisAlignment: MainAxisAlignment.center  ,
//                 children: <Widget>[

//                   RaisedButton(
//                     child: Text("EDIT"),
//                     color: Colors.green,
//                     onPressed: ()=> Navigator.of(context).push(
//                       new MaterialPageRoute(
//                         builder: (BuildContext context)=>new EditData(list:widget.list,index:widget.index),
//                       )
//                     ),
//                   ),
//                   RaisedButton(
//                     child: Text("DELETE"),
//                     color: Colors.red,
//                     onPressed: ()=> confirm(),
//                   ),
//                 ],
//               )

//             ],
//           ),
//         ),
//       ),

//     );
//   }
// }


