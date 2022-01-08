import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hand_stuff/authwidget.dart';
import 'package:hand_stuff/horario_pages/screens/enviar.dart';
import 'package:hand_stuff/horario_pages/screens/marcarevento.dart';
import 'package:hand_stuff/horario_pages/screens/posts.dart';
import 'package:hand_stuff/models/state.dart';
import 'package:hand_stuff/models/todo.dart';
import 'package:hand_stuff/services/auth.dart';
import 'package:hand_stuff/services/state_widget.dart';
import 'package:hand_stuff/widgets/background.dart';
import 'package:hand_stuff/widgets/drawer.dart';
import 'package:hand_stuff/widgets/loading.dart';
import 'dart:async';





class HorarioHome extends StatefulWidget{
  
 final String cdmateria;
 final String cdgrupo;
 final String token;

HorarioHome({this.cdmateria, this.cdgrupo,this.token});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _HorarioHomeState(cdmateria:cdmateria,cdgrupo:cdgrupo,token:token);
  }
}
class _HorarioHomeState extends State<HorarioHome>{

 final String cdmateria;
 final String cdgrupo;
 final String token;

_HorarioHomeState({this.cdmateria, this.cdgrupo,this.token});

final databaseReference = Firestore.instance;
 StateModel appState;
 Future checkId;
 Future future;

Future futureHorario;
List horarioList = [];

bool _isLoading = true;

List verifylist = [];

bool _loadingVisible = false;
  
  @override
  void initState() { 
    // readLocal();
    // checkIntentValue();

checkId = verificaId();
  checkId.then((userObject){ 
    if(userObject != null){
        future = Firestore.instance.collection('grupos').document('$cdgrupo').collection('matters').document('$cdmateria').collection('datas').orderBy('horario_date', descending: true).getDocuments();
        future.then((value){
          setState(() {
            horarioList = value.documents;
            _isLoading = false;
          });
          print(value);
        });
    }
  });

    super.initState();
    
  }

  Future verificaId() async {
    UserEstudante userLocal = await Auth.getUserLocal();
    return userLocal;
  }



refreshData(indexList){
    print(indexList);
    setState(() {
      horarioList.removeAt(indexList);
    });
    
}

addData(horarioInsert){
  setState(() {
    horarioList.add(horarioInsert);
    horarioList.sort((a,b) {
        var adate = a['horario_date']; //before -> var adate = a.expiry;
        var bdate = b['horario_date']; //before -> var bdate = b.expiry;
        return bdate.compareTo(adate); //to get the order other way just switch `adate & bdate`
        }); 
  });
}


int _selectedIndex = 0;
void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
  });
}
//////////////////////Widgets

 
  _bottomnavigationWidget(){
    return BottomNavigationBar(
        backgroundColor: Color(0xFF1A2980),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: ImageIcon(
               AssetImage("assets/images/icon-imagewhite.png"),
                    color: Colors.white
               ),
            title: Text('Posts',style: TextStyle(color: Colors.white),),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_upload,color: Colors.white,),
            title: Text('Enviar',style: TextStyle(color: Colors.white),),
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
               AssetImage("assets/images/calendariconwhite.png"),
                    color: Colors.white
               ),
            title: Text('Marcar evento',style: TextStyle(color: Colors.white),),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      );
  }
 

  @override
  Widget build(BuildContext context) {
      var size = MediaQuery.of(context).size;
      final double itemWidth = (size.width - 26);
      final double itemHeight = (size.height);
      appState = StateWidget.of(context).state;
      final userId = appState?.firebaseUserAuth?.uid ?? '';

      
      List<Widget> _widgetOptions = <Widget>[
            
        _isLoading == false ? ListaHorario(cdmateria: cdmateria, cdgrupo: cdgrupo, currentUserId: userId,list: horarioList,function: refreshData,) : Center(child: CircularProgressIndicator(),),
        FileMenu(cdmateria: cdmateria, cdgrupo: cdgrupo,currentUserId: userId,function:addData),
        CalendarViewApp(cdmateria: cdmateria, cdgrupo: cdgrupo),
        
      ];

    
    // TODO: implement build
    return Scaffold(
         appBar: AppBar(
            title: Row(children: <Widget>[
              new Text("MyMatter"),
              Container(
                padding: EdgeInsets.all(5),
                      child: Hero(
                        tag:'logogrupo$cdgrupo',
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
                        tag:'logomymatter$cdmateria',
                          child: Container(
                            width: 40,
                            height: 40,
                            child: Image.asset("assets/images/logom.png"),
                        ),
                    ),
                  )
            ],),
            backgroundColor: Color(0xFF1A2980),
          ),
          body: LoadingScreen(
              inAsyncCall: _loadingVisible,
              child: Background(
              widget: AnimatedSwitcher(
                          duration: Duration(milliseconds: 400),
                          child: _widgetOptions.elementAt(_selectedIndex)),),
          ),

          bottomNavigationBar: _bottomnavigationWidget(),
          drawer: DrawerCustom(currentUserId: userId,),
    );
   
  }
}






