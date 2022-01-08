import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';

import 'package:path/path.dart' as path;

class SharedIntent extends StatefulWidget {
  final String page;
  final bool icon;
  final String iconpath;
  SharedIntent({this.page,this.icon,this.iconpath});
  @override
  _SharedIntentState createState() => _SharedIntentState(page:page, icon:icon,iconpath:iconpath );
}

class _SharedIntentState extends State<SharedIntent> {
  final String page;
  final bool icon;
  final String iconpath;
  _SharedIntentState({this.page,this.icon,this.iconpath});



  List<String> paths = [];

  List<Widget> _widgetList = <Widget>[
        
  ];

  double _width = 0;

  double heightvalue = 70;

  bool expanded = false;




@override
initState(){

  super.initState();
}

Widget chooseIcon(){
  if(icon){
    return Icon(Icons.cloud_upload,color: Colors.white);
  }
   return ImageIcon(
                   AssetImage(iconpath),
                    color: Colors.white
                  );
}

Widget shareIntent(bool expanded){
    return Dismissible(  
  // Show a red background as the item is swiped away.
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        child:Icon(Icons.delete,color: Colors.white,),color: Colors.red),
      key: Key(UniqueKey().toString()), 
      onDismissed: (direction) async { 

      },
      child: AnimatedContainer(
          // Use the properties stored in the State class.
          padding: EdgeInsets.all(2),
          width: double.infinity,
          height: heightvalue, 
          duration:Duration(milliseconds: 500),
          child: FlatButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                chooseContentShare(expanded),
                chooseIcon()
                           
              ],
            ),

            onPressed: (){
              expandShareContainer();
            },
            padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          ),
          decoration: BoxDecoration(
                       gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0.3, 1],
                        colors: [
                          Colors.green[600],
                          Colors.green[300],
                          ],
                            ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green,
                            blurRadius: 10.0, // has the effect of softening the shadow
                            spreadRadius: 1.0, // has the effect of extending the shadow
                            offset: Offset(
                              2.0, // horizontal, move right 10
                              2.0, // vertical, move down 10
                            ),
                          )
                        ],
                          
                    ),
        ),
    );
  }

  chooseContentShare(bool expanded){
    if(expanded){
      return new FutureBuilder(
                  future: shareContentList(),
                  builder: (context,snapshot){
                    if(snapshot.hasError)
                      print(snapshot.error);
                    return snapshot.hasData
                        ?Expanded(child: 
                          ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (context,i){
                              return Text('${snapshot.data[i]}',style: TextStyle(color: Colors.white));    
                                  },
                                ),)
                        :CircularProgressIndicator();
                  },
                );
      }else{
        return  Text( 'Selecione $page',style: TextStyle(color: Colors.white),);
      }
               
  }

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

  expandShareContainer(){
    if(expanded == false){
      setState(() {
        expanded = true;
        heightvalue = 300;
         _widgetList[0] =  shareIntent(expanded); 
      });
    }else{
      setState(() {
        expanded = false;
        heightvalue = 70;
        _widgetList[0] =  shareIntent(expanded);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return  _widgetList.isNotEmpty ? _widgetList.elementAt(0) : Container();
  }
}