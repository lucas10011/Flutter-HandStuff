import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hand_stuff/homepage.dart';
import 'package:hand_stuff/models/state.dart';
import 'package:hand_stuff/services/state_widget.dart';
import 'package:hand_stuff/widgets/popmensagem.dart';

class GrupoAdd extends StatefulWidget {
  final String token;
  final Function function;
  GrupoAdd({this.token,this.function});

  @override
  _GrupoAddState createState() => _GrupoAddState(token: token,function: function);
}

class _GrupoAddState extends State<GrupoAdd> {
  final String token;
  final Function function;
_GrupoAddState({this.token,this.function});
final _formKey = GlobalKey<FormState>();

StateModel appState;

final databaseReference = Firestore.instance;

bool _isLoading = false;
String msg='';



TextEditingController  cname=new TextEditingController();
  

 _loading(StateModel appStateFunction) async{
        setState(() {
          _isLoading = true;
        });
        await _addGroup(appStateFunction);

        setState(() {
          _isLoading = false;
        });

        return _redirecionamento();
              
}

_redirecionamento(){
  Navigator.pop(context);
} 

_addGroup(StateModel appStateFunction) async {

final currentUserId = appState?.firebaseUserAuth?.uid ?? '';

final nomeLocal = appState?.user?.user_nome ?? '';
final photoLocal = appState?.user?.user_foto ?? '';

var codigo = DateTime.now().millisecondsSinceEpoch.toString();
await databaseReference.collection('grupos').document(codigo).setData({
            'grupo_codigo': codigo,
            'grupo_nome': cname.text,
            'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
          }).then((data) async {
              await databaseReference.collection('grupos').document(codigo).collection('users').document("$currentUserId").setData({
              'user_grupo_privi': true,
              'user_nome': '$nomeLocal',
              'id':'$currentUserId',
              'user_foto':'$photoLocal',
              'token':'$token',
              'user_ban':false,
              }).then((data) async {
                await databaseReference.collection('users').document('$currentUserId').collection('grupos').document(codigo).setData({
                'grupo_codigo': codigo,
                'user_ban':false,
                  }).then((data) async {
                              Fluttertoast.showToast(msg: "Grupo Adicionado com sucesso");             
                              function(cname.text,codigo);

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




}




//Widgets



_loadingWidget(){

  return Center(child:Column(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[Text('Criando Grupo...'),CircularProgressIndicator()],)); 

}

_formGrupoWidget(StateModel appStateFunction){
  return Expanded(
        child: ListView(children: <Widget>[
                Container(
                          width: 200,
                          height: 200,
                          alignment: Alignment(0.0, 1.15),
                          decoration: new BoxDecoration(
                            
                            image: new DecorationImage(
                              image: AssetImage("assets/images/group-picture.png"),
                              fit: BoxFit.fitHeight,
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              stops: [0.3, 1],
                              colors: [
                                Color(0xFFFFFFF),
                                Color(0XFFFFFFF),
                              ],
                            )
                          ),
                          
                          child: Container(
                            height: 56,
                            width: 56,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                stops: [0.3, 1.0],
                                colors: [
                                  Color(0xFF1A2980),
                                  Color(0XFF26D0CE),
                                ],
                              ),
                              border: Border.all(
                                width: 4.0,
                                color: const Color(0xFFFFFFFF),
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(56),
                              ),
                            ),
                            child: SizedBox.expand(
                              child: FlatButton(
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                onPressed: () {},
                              ),
                            ),
                          ),
                        ),
                        
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'This field must not be empty';
                              }
                            },
                            maxLength: 25,
                            // autofocus: true,
                            keyboardType: TextInputType.emailAddress,
                            controller: cname,
                            decoration: InputDecoration(
                              labelText: "Nome",
                              labelStyle: TextStyle(
                                color: Colors.black38,
                                fontWeight: FontWeight.w400,
                                fontSize: 20,
                            ),
                         ),
                                style: TextStyle(fontSize: 20),
                              ),
              ),
              Container(
                padding: EdgeInsets.all(30),
                child: Container(
                height: 60,
                alignment: Alignment.centerLeft,
                decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                      Radius.circular(16),
                    ),
                  gradient: LinearGradient(
                    colors: <Color>[
                      Color(0xFF1A2980),
                      Color(0xFF1A2980),
                      Color(0xFF1A2980),
                    ],
                  ),
                ),
                child: SizedBox.expand(
                  child: FlatButton(
                    splashColor: Colors.blueAccent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Criar",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  onPressed: (){
                    if (_formKey.currentState.validate()) {
                      _loading(appStateFunction);
                  }
                      
                    },
                ),
              ),
            ),   
          )

         

        ],),
      );
}



  @override
  Widget build(BuildContext context) {
  var size = MediaQuery.of(context).size;
  final double itemWidth = (size.width - 26);
  final double itemHeight = (size.height);

  appState = StateWidget.of(context).state;
  
    return Scaffold(
      appBar: new AppBar(
        title: const Text('MyMatter'),
        backgroundColor: Color(0xFF1A2980),
      ),
      body: Form(
        key: _formKey,
        child: Container(
        color: Color(0xFF1A2980),
          child: Center(
            child:Container(
            width: itemWidth,
            height: itemHeight,
            child: Material(
              elevation: 5.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24.0)),
                ),
            
                child: Column(
                  children: <Widget>[
                        SizedBox(height: itemHeight / 8, ),
                       _isLoading ? _loadingWidget() : _formGrupoWidget(appState)                 
                  ],
                ),
              ),
            ),
          ),
        )
    )
    );
  }
}


