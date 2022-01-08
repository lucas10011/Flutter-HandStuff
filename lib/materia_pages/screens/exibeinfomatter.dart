import 'dart:math';

import 'package:animator/animator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'dart:ui' as ui;

class ExibeInfoMatter extends StatefulWidget {
  final String token;
  final String index;
  final String nomematter;
  final String codigomatter;
  final String codigogrupo;
  final String currentUserId;
  final int indexList;
  final Function function;
  
  ExibeInfoMatter({this.token,this.nomematter,this.codigomatter,this.index,this.codigogrupo,this.currentUserId,this.indexList,this.function});

  @override
  _ExibeInfoMatterState createState() => _ExibeInfoMatterState(token: token,index: index,nomematter: nomematter,codigomatter: codigomatter,codigogrupo: codigogrupo,currentUserId: currentUserId, indexList: indexList,function: function);
}

class _ExibeInfoMatterState extends State<ExibeInfoMatter> {
  final String token;
  final String index;
  final String nomematter;
  final String codigomatter;
  final String codigogrupo;
  final String currentUserId;
  final int indexList;
  final Function function;
_ExibeInfoMatterState({this.token,this.nomematter,this.codigomatter,this.index,this.codigogrupo,this.currentUserId,this.indexList,this.function});

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


Future exitMatter(userid,documentmatter,documentgrupo,token) async{
              

              try{
                await Firestore.instance.collection('grupos').document('$documentgrupo').collection('matters').document('$documentmatter').collection('users').document(userid).delete().then((onValue){
                });
                try{
                  await Firestore.instance.collection('users').document('$userid').collection('grupos').document('$documentgrupo').collection('matters').document(documentmatter).delete();
                  return true;
                }catch(e){

                  return false;
                }   
              }catch(e){
                return false;
              }
        

       

}

popExit(context,userid,documentmatter,documentgrupo,token){
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
                        title: Text('Tem certeza que deseja sair?'),
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                          OutlineButton(
                            color: Colors.red,
                            textColor: Colors.red,
                            borderSide: BorderSide(color: Colors.red),
                            shape: StadiumBorder(),
                            child: Text('Sair'),
                            onPressed: () async {
                                await exitMatter('$userid','$documentmatter','$documentgrupo','$token');
                                
                            },
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

_logoanimation(){
  return Animator(
      tween:Tween<double>(begin: 0, end: 2*pi),
      duration: Duration(seconds: 2),
      curve: Curves.elasticIn,
      cycles: 0,
      builder: (anim) => Transform.rotate(
        angle: anim.value,
        child: Hero(
                tag:'logomymatter$index',
                child: Container(
                  width: 200,
                  height: 200,
                  child: Image.asset('assets/images/mymattericon.png'),
                      ),
                ),
    )
  );
}


_infomatterWidget(){
 return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
                    _logoanimation(),  
                    new Text("$nomematter",style:TextStyle(fontWeight: FontWeight.bold,color: Color(0xFF1A2980),fontSize: 20,)),
                    Padding(padding: EdgeInsets.all(5)),
                    new Text('Código',style:TextStyle(fontWeight: FontWeight.bold,color: Color(0xFF1A2980),fontSize: 15,)),           
                    FlatButton(
                      shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                      splashColor: Colors.blueAccent,
                      color: Color(0xFF1A2980),
                      onPressed:(){
                            Clipboard.setData(new ClipboardData(text: '$codigogrupo:$codigomatter'));
                            _scaffoldKey.currentState.showSnackBar(SnackBar
                              (content: Text('Código copiado $codigogrupo:$codigomatter')));
                          },
              
                        child: new Text("$codigogrupo:$codigomatter",style:TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 20,))
                      ),
                      Padding(padding: EdgeInsets.all(15),
                      ),
                      Text("Toque para copiar o código",style:TextStyle(color: Color(0xFF1A2980),fontSize: 15,fontStyle: FontStyle.italic))
                      ]
                    ),
                  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
        key: _scaffoldKey,
        body: Container(
          decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.3, 1],
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0XFFFFFFFF),
                  ],
                ),
              ),
            child: _infomatterWidget()
                ),
                 floatingActionButton: FloatingActionButton.extended(
                    onPressed: () {
                      popExit(context,currentUserId,codigomatter,codigogrupo,token);
                    },
                    label: Text('Sair'),
                    icon: Icon(Icons.exit_to_app),
                    backgroundColor: Colors.red,
                  ),
                  floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
              );
  }
}



class MattersDetailsAnimator extends StatefulWidget {
  final Map matter;
  final String token;
  final String index;
  final String currentUserId;
  final int indexList;
  final Function function;
  
  MattersDetailsAnimator({this.matter,this.token,this.index,this.currentUserId,this.indexList,this.function});
  @override
  _MatterDetailsAnimator createState() => new _MatterDetailsAnimator(matter:matter,token: token,index: index,currentUserId: currentUserId, indexList: indexList,function: function);
}

class _MatterDetailsAnimator extends State<MattersDetailsAnimator>
  with SingleTickerProviderStateMixin {
  final Map matter;
  final String token;
  final String index;
  final String currentUserId;
  final int indexList;
  final Function function;
  
  _MatterDetailsAnimator({this.matter,this.token,this.index,this.currentUserId,this.indexList,this.function});   
  AnimationController _controller;


  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new MatterDetailsPage(
      matter:matter,
      token: token, 
      index: index, 
      currentUserId: currentUserId, 
      indexList: indexList, 
      function: function,
      controller: _controller,
    );
  }
}

class MatterDetailsEnterAnimation {
  MatterDetailsEnterAnimation(this.controller)
      : backdropOpacity = new Tween(begin: 0.5, end: 1.0).animate(
          new CurvedAnimation(
            parent: controller,
            curve: new Interval(
              0.000,
              0.500,
              curve: Curves.ease,
            ),
          ),
        ),
        backdropBlur = new Tween(begin: 0.0, end: 5.0).animate(
          new CurvedAnimation(
            parent: controller,
            curve: new Interval(
              0.000,
              0.800,
              curve: Curves.ease,
            ),
          ),
        ),
        avatarSize = new Tween(begin: 0.0, end: 1.0).animate(
          new CurvedAnimation(
            parent: controller,
            curve: new Interval(
              0.100,
              0.400,
              curve: Curves.elasticOut,
            ),
          ),
        ),
        nameOpacity = new Tween(begin: 0.0, end: 1.0).animate(
          new CurvedAnimation(
            parent: controller,
            curve: new Interval(
              0.350,
              0.450,
              curve: Curves.easeIn,
            ),
          ),
        ),
        locationOpacity = new Tween(begin: 0.0, end: 0.85).animate(
          new CurvedAnimation(
            parent: controller,
            curve: new Interval(
              0.500,
              0.600,
              curve: Curves.easeIn,
            ),
          ),
        ),
        dividerWidth = new Tween(begin: 0.0, end: 225.0).animate(
          new CurvedAnimation(
            parent: controller,
            curve: new Interval(
              0.650,
              0.750,
              curve: Curves.fastOutSlowIn,
            ),
          ),
        ),
        biographyOpacity = new Tween(begin: 0.0, end: 0.85).animate(
          new CurvedAnimation(
            parent: controller,
            curve: new Interval(
              0.750,
              0.900,
              curve: Curves.easeIn,
            ),
          ),
        ),
        videoScrollerXTranslation = new Tween(begin: 60.0, end: 0.0).animate(
          new CurvedAnimation(
            parent: controller,
            curve: new Interval(
              0.830,
              1.000,
              curve: Curves.ease,
            ),
          ),
        ),
        videoScrollerOpacity = new Tween(begin: 0.0, end: 1.0).animate(
          new CurvedAnimation(
            parent: controller,
            curve: new Interval(
              0.830,
              1.000,
              curve: Curves.fastOutSlowIn,
            ),
          ),
        );

  final AnimationController controller;
  final Animation<double> backdropOpacity;
  final Animation<double> backdropBlur;
  final Animation<double> avatarSize;
  final Animation<double> nameOpacity;
  final Animation<double> locationOpacity;
  final Animation<double> dividerWidth;
  final Animation<double> biographyOpacity;
  final Animation<double> videoScrollerXTranslation;
  final Animation<double> videoScrollerOpacity;
}

class MatterDetailsPage extends StatelessWidget {
  MatterDetailsPage({
    @required this.matter,
    @required this.token,
    @required this.index,
    @required this.currentUserId,
    @required this.indexList,
    @required this.function, 
    @required AnimationController controller,
  }) : animation = new MatterDetailsEnterAnimation(controller);

  final Map matter;
  final String token;
  final String index;
  final String currentUserId;
  final int indexList;
  final Function function;
  final MatterDetailsEnterAnimation animation;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _buildAnimation(BuildContext context, Widget child) {
    return new Stack(
      fit: StackFit.expand,
      children: <Widget>[
        new Opacity(
          opacity: animation.backdropOpacity.value,
          child: new Image.asset(
            "assets/images/mymattericon.png",
            fit: BoxFit.cover,
          ),
        ),
        new BackdropFilter(
          filter: new ui.ImageFilter.blur(
            sigmaX: animation.backdropBlur.value,
            sigmaY: animation.backdropBlur.value,
          ),
          child: new Container(
            color: Colors.black.withOpacity(0.5),
            child: _buildContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return new SingleChildScrollView(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildAvatar(),
          _buildInfo(),
          _buildCodigo(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return new Transform(
      transform: new Matrix4.diagonal3Values(
        animation.avatarSize.value,
        animation.avatarSize.value,
        1.0,
      ),
      alignment: Alignment.center,
      child: new Container(
        width: 110.0,
        height: 110.0,
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
          border: new Border.all(color: Colors.white30),
        ),
        margin: const EdgeInsets.only(top: 32.0, left: 16.0),
        padding: const EdgeInsets.all(3.0),
        child: new ClipOval(
          child: Animator(
                  tween:Tween<double>(begin: 0, end: 2*pi),
                  duration: Duration(seconds: 2),
                  curve: Curves.elasticOut,
                  cycles: 0,
                  builder: (anim) => Transform.rotate(
                    angle: anim.value,
                    child: new Image.asset("assets/images/logom.png"),
                )
              ),
        ),
      ),
    );
  }
  

  Widget _buildInfo() {
    return new Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Text(
            matter['materia_nome'],
            style: new TextStyle(
              color: Colors.white.withOpacity(animation.nameOpacity.value),
              fontWeight: FontWeight.bold,
              fontSize: 30.0,
            ),
          ),
          new Container(
            color: Colors.white.withOpacity(0.85),
            margin: const EdgeInsets.symmetric(vertical: 16.0),
            width: animation.dividerWidth.value,
            height: 1.0,
          ),
          new Text(
            matter['materia_descricao'],
            style: new TextStyle(
              color: Colors.white.withOpacity(animation.biographyOpacity.value),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodigo() {
    return new Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: new Transform(
        transform: new Matrix4.translationValues(
          animation.videoScrollerXTranslation.value,
          0.0,
          0.0,
        ),
        child: new Opacity(
          opacity: animation.videoScrollerOpacity.value,
          child: new SizedBox.fromSize(
            size: new Size.fromHeight(245.0),
            child: Column(children: <Widget>[

                    new Text('Código',style:TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 15,)),           
                    FlatButton(
                      shape: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(15.0)),
                      splashColor: Colors.blueAccent,
                      color: Color(0xFF1A2980),
                      onPressed:(){
                            Clipboard.setData(new ClipboardData(text: '${matter['grupo_codigo']}:${matter['materia_codigo']}'));
                            _scaffoldKey.currentState.showSnackBar(SnackBar
                              (content: Text('Código copiado ${matter['grupo_codigo']}:${matter['materia_codigo']}')));
                          },
              
                        child: new Text("${matter['grupo_codigo']}:${matter['materia_codigo']}",style:TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 20,))
                      ),
                      Padding(padding: EdgeInsets.all(15),
                      ),
                      Text("Toque para copiar o código",style:TextStyle(color: Colors.white,fontSize: 15,fontStyle: FontStyle.italic))
            ],),
          ),
        ),
      ),
    );
  }

  Future exitMatter(context,userid,documentmatter,documentgrupo,token) async{
              try{
                await Firestore.instance.collection('grupos').document('$documentgrupo').collection('matters').document('$documentmatter').collection('users').document(userid).delete().then((onValue){
                });
                try{
                  await Firestore.instance.collection('users').document('$userid').collection('grupos').document('$documentgrupo').collection('matters').document(documentmatter).delete();
                   return true;
                }catch(e){

                  print(e);
                  return false;
                }   
              }catch(e){
                print(e);
                return false;
              }    

}

popExit(context,userid,documentmatter,documentgrupo,token){
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
                        title: Text('Tem certeza que deseja sair?'),
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                          OutlineButton(
                            color: Colors.red,
                            textColor: Colors.red,
                            borderSide: BorderSide(color: Colors.red),
                            shape: StadiumBorder(),
                            child: Text('Sair'),
                            onPressed: () {
                                exitMatter(context,'$userid','$documentmatter','$documentgrupo','$token').then((onValue){
                                  function(indexList);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                });
                                
                            },
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
    return new Scaffold(
      key: _scaffoldKey,
      body: new AnimatedBuilder(
        animation: animation.controller,
        builder: _buildAnimation,
      ),
      floatingActionButton: FloatingActionButton.extended(
                    onPressed: () {
                      popExit(context,currentUserId,matter['materia_codigo'],matter['grupo_codigo'],token);
                    },
                    label: Text('Sair'),
                    icon: Icon(Icons.exit_to_app),
                    backgroundColor: Colors.red,
                  ),
                  floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

