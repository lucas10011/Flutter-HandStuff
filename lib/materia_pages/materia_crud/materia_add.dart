import 'dart:convert';
import 'dart:io';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hand_stuff/homepage.dart';

import 'package:hand_stuff/login.dart';
import 'package:hand_stuff/materia_pages/home_materia.dart';
import 'package:hand_stuff/widgets/popmensagem.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
class MateriaAdd extends StatefulWidget {
  final String token;
  final String grupocodigo;
  final String userid;
  final Function function;
  MateriaAdd({this.grupocodigo,this.userid,this.token,this.function});

  @override
  _MateriaAddState createState() => _MateriaAddState(token: token,grupocodigo: grupocodigo,userid: userid,function: function);
}

class _MateriaAddState extends State<MateriaAdd> {
  final String token;
  final String grupocodigo;
  final String userid;
  final Function function;
  _MateriaAddState({this.grupocodigo,this.userid,this.token,this.function});

final _formKey = GlobalKey<FormState>();

final databaseReference = Firestore.instance;

bool _isLoading = false;
String msg='';

TextEditingController  cname=new TextEditingController();
TextEditingController  cdescricao=new TextEditingController();


var materiacodigo = DateTime.now().millisecondsSinceEpoch.toString();

_addMateria() async {
  

  var date = DateFormat("yyyy-MM-dd").format(DateTime.now()).toString();


  await databaseReference.collection('grupos').document('$grupocodigo').collection('matters').document("$materiacodigo").setData({
            'grupo_codigo': '$grupocodigo',
            'materia_codigo': '$materiacodigo',
            'materia_date': '$date',
            'materia_descricao': cdescricao.text,
            'materia_nome': cname.text,
            'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
          }).then((data) async {
              await databaseReference.collection('grupos').document('$grupocodigo').collection('matters').document("$materiacodigo").collection('users').document("$userid").setData({
              'id':"$userid",
              'token': '$token',
              'user_matter_privi': true,
              'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),

              }).then((data) async {

                 await databaseReference.collection('users').document('$userid').collection('grupos').document('$grupocodigo').collection('matters').document(materiacodigo).setData({
                'materia_codigo': materiacodigo,
                  }).then((data) async {
                              Fluttertoast.showToast(msg: "Materia adicionada com sucesso");
                              function(cname.text,materiacodigo,grupocodigo);
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

  _loading() async{

    setState(() {
      _isLoading = true;
    });
    await _addMateria();

    setState(() {
      _isLoading = false;
    });

    return _redirecionamento();

  }

  _redirecionamento(){
      Navigator.pop(context);       
  }



  ///////////////////widgets
  
  _loadingWidget(){

  return Center(child:Column(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[Text('Criando Matter...'),CircularProgressIndicator()],)); 

}

_formMateriaWidget(){
  return Expanded(
        child: ListView(children: <Widget>[
                Container(
                          width: 200,
                          height: 200,
                          alignment: Alignment(0.0, 1.15),
                          decoration: new BoxDecoration(
                            
                            image: new DecorationImage(
                              image: AssetImage("assets/images/mymattericon.png"),
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
                  maxLength: 30,
                  keyboardType: TextInputType.emailAddress,
                  controller: cname,
                  decoration: InputDecoration(
                    labelText: "Matter Nome",
                    labelStyle: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                    ),
                  ),
                  style: TextStyle(fontSize: 20),
                )
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child:TextFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return 'This field must not be empty';
                  }
                },
                keyboardType: TextInputType.emailAddress,
                controller: cdescricao,
                decoration: InputDecoration(
                  labelText: "Descrição",
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
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                     await _loading();
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
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Criar matter"),
        backgroundColor: Color(0xFF1A2980),
      ),
      body:Form(
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
                       _isLoading ? _loadingWidget() : _formMateriaWidget()
                     
                   
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


