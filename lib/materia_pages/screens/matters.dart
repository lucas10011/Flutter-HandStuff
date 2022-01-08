import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hand_stuff/horario_pages/home_horario.dart';
import 'package:hand_stuff/materia_pages/home_materia.dart';
import 'package:hand_stuff/materia_pages/screens/exibeinfomatter.dart';
import 'package:hand_stuff/redirect.dart';
import 'package:hand_stuff/widgets/notfound.dart';
import 'package:intl/intl.dart';

class ItemList extends StatelessWidget{
  final String currentUserId;
  final String token;
  final List list;
  final bool myprivillege;
  final Function function;
  ItemList({this.currentUserId,this.token,this.list,this.myprivillege,this.function});


itemBuild(context,index){
  var size = MediaQuery.of(context).size;
  final double itemWidth = (size.width);
  return Padding(
    padding: const EdgeInsets.all(0.0),
    child: Stack(
        children: <Widget>[
          Positioned(
            left: 40,
             child: Container(
              width: itemWidth,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.3, 1],
                    colors: [
                     Colors.indigo,
                     Colors.indigo[300],
                      ],
                    )
              ),
              height: 100,
              padding: EdgeInsets.only(left: 60),
              child: FlatButton(
                  padding: EdgeInsets.fromLTRB(10.0, 10.0, 25.0, 10.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                    Text(
                      list[index]['materia_nome'],
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                          
                        ),
                        overflow: TextOverflow.ellipsis
                      ),                                               
                  ],
                ),

                  onPressed: () {
                     return Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (c, a1, a2) => HorarioHome(cdmateria:list[index]['materia_codigo'], cdgrupo:list[index]['grupo_codigo'],token:token),
                                    transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                                    transitionDuration: Duration(milliseconds: 400),
                                  ),
                                ); 
                  },
                ),
            ),
          ),
                  GestureDetector(
                  onTap: (){ 
                    return Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (c, a1, a2) =>new MattersDetailsAnimator(matter:list[index],currentUserId:currentUserId,token:token,indexList:index,function:function),
                                  transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                                  transitionDuration: Duration(milliseconds: 400),
                                ),
                              );
                },
                  child: Container(
                    width: 100,
                    height: 100,
                    child: Material(
                      elevation: 5,
                      child:SizedBox(
                              child: Hero(
                                tag:'logomymatter${list[index]['materia_codigo']}',
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    child: Image.asset("assets/images/mymattericon.png"),
                                ),
                            ),
                          ),
                      borderRadius: BorderRadius.all(Radius.circular(70.0)),
                      clipBehavior: Clip.hardEdge,
                    ),
                  ),
                ),
        ]
    ),
  );
}


popDeletar(context,cdgrupo,cdmateria){
    return showGeneralDialog(
            barrierColor: Colors.black.withOpacity(0.5),
            transitionBuilder: (context, a1, a2, widget) {
                return Transform.scale(
                  scale: a1.value,
                  child: Opacity(
                    opacity: a1.value,
                    child: AlertDialog(
                      shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0)),
                        title: Text('Todos arquivos serão apagados, deseja continuar?'),
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            OutlineButton(
                            color: Colors.blue,
                            textColor: Colors.blue,
                            borderSide: BorderSide(color: Colors.blue),
                            shape: StadiumBorder(),
                            child: Text('Cancelar'),
                            onPressed: () {
                              Navigator.pop(context);
                              return false;
                            },
                          ),
                          OutlineButton(
                            color: Colors.red,
                            textColor: Colors.red,
                            borderSide: BorderSide(color: Colors.red),
                            shape: StadiumBorder(),
                            child: Text('Deletar'),
                            onPressed: null
                           
                          ),
                        ],),
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


  @override
  Widget build(BuildContext context) {
     var size = MediaQuery.of(context).size;
    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 15) / 3.5;
    final double itemWidth = size.width;
    // TODO: implement build
    return list.isEmpty 
     ? NotFound(msg: 'Nenhum Matter encontrado...',image: 'mymattericon',)
     : ListView.builder(
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: itemBuild(context,index));
        });

  }
}
