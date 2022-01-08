import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hand_stuff/home_pages.dart/screens/exibeinfo.dart';
import 'package:hand_stuff/materia_pages/home_materia.dart';
import 'package:hand_stuff/redirect.dart';
import 'package:hand_stuff/widgets/notfound.dart';

class ItemListGrupo extends StatefulWidget{

  final List list;
  final String userid;
  final Function refreshData;
  ItemListGrupo({this.list,this.userid,this.refreshData});

  @override
  _ItemListGrupoState createState() => _ItemListGrupoState(userid: userid,list: list,refreshData:refreshData);
}

class _ItemListGrupoState extends State<ItemListGrupo> with SingleTickerProviderStateMixin{
  final List list;
  final String userid;
  final Function refreshData;
  _ItemListGrupoState({this.list,this.userid,this.refreshData});

Animation animation;
Animation delayedAnimation;
Animation muchdelayedAnimation;
AnimationController animationController;

@override
void initState(){
  super.initState();
  animationController = AnimationController(duration: Duration(seconds: 3), vsync: this);
  
  animation = Tween(begin: 1.0, end:0.0).animate(CurvedAnimation(
    parent: animationController, curve: Curves.ease));

  delayedAnimation = Tween(begin: -1.0, end:0.0).animate(CurvedAnimation(
    parent: animationController, 
    curve: Interval(0.5, 1.0, curve: Curves.fastOutSlowIn)));
  muchdelayedAnimation = Tween(begin: -1.0, end:0.0).animate(CurvedAnimation(
  parent: animationController, 
  curve: Interval(0.8, 1.0, curve: Curves.fastOutSlowIn)));


  delayedAnimation = BorderRadiusTween(
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

Future getQtdMatters(codigo) async {
    final QuerySnapshot countmatters = await Firestore.instance.collection('grupos').document('$codigo').collection('matters').getDocuments();
    return countmatters.documents.length;
  }

Future getQtdUsers(codigo) async {
    final QuerySnapshot countusers = await Firestore.instance.collection('grupos').document('$codigo').collection('users').getDocuments();
    return countusers.documents.length;
  }

//////////////////////////////////////////////Widgets//////////////////////////////////////
///

_qtdMatters(qtd){
  return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: 1000),  
      child:Container(
            child: Text(
                  'Matters: $qtd',style:TextStyle(
            
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,//try changing weight to w500 if not thin
                    color: Colors.black,
                    fontSize: 12.0
                ),
              ),
        ),
      );
}

_qtdUsers(qtd){
  final double width = MediaQuery.of(context).size.width;
  
  return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget child){
      return Transform(
            transform:Matrix4.translationValues(animation.value * width, 0.0, 0.0),
            child: Text(
                  'Membros: $qtd',style:TextStyle(
            
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,//try changing weight to w500 if not thin
                    color: Colors.black,
                    fontSize: 12.0
                ),
              ),
          );
      });
}

_itemRow(index){
    var size = MediaQuery.of(context).size;
    final double itemWidth = (size.width);

  return Padding(
    padding: const EdgeInsets.all(0),
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
                     Colors.indigo[600],
                     Colors.indigo[400],
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
                        widget.list[index]['grupo_nome'],
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

                   Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (c, a1, a2) => HomeMateria(grupocodigo: list[index]['grupo_codigo'],token:list[0]['token']),
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
                      pageBuilder: (c, a1, a2) =>new GruposDetailsAnimator(grupo:list[index],currentUserId: userid,function: refreshData,indexList:index),
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
                                tag:'logogrupo${widget.list[index]['grupo_codigo']}',
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    child: Image.asset("assets/images/group-picture.png"),
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
          return list.length == 0 
          ?NotFound(msg: 'Entre ou crie algum grupo e comece a postar/guardar',image: 'group-picture',)
          :ListView.builder(
            itemCount: list.length,
            itemBuilder: (context,i){
              return Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: _itemRow(i)
                
                );
         
      },
    );
  }
}

