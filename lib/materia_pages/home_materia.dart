
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:hand_stuff/authwidget.dart';
import 'package:hand_stuff/login.dart';
import 'package:hand_stuff/materia_pages/materia_crud/materia_add.dart';
import 'package:hand_stuff/materia_pages/screens/historico.dart';
import 'package:hand_stuff/materia_pages/screens/matters.dart';
import 'package:hand_stuff/materia_pages/screens/membros.dart';
import 'package:hand_stuff/models/state.dart';
import 'package:hand_stuff/models/todo.dart';
import 'package:hand_stuff/services/auth.dart';
import 'package:hand_stuff/services/state_widget.dart';
import 'package:hand_stuff/widgets/background.dart';
import 'package:hand_stuff/widgets/drawer.dart';
import 'package:hand_stuff/widgets/fancybutton.dart';
import 'package:hand_stuff/widgets/loading.dart';
import 'package:hand_stuff/widgets/poparg.dart';
import 'dart:async';



class HomeMateria extends StatefulWidget{
  final String token;
  final String grupocodigo;
  HomeMateria({this.grupocodigo,this.token});


  @override
  _HomeMateriaState createState() => _HomeMateriaState(token: token, grupocodigo: grupocodigo,);
}
class _HomeMateriaState extends State<HomeMateria>{
  final String token;
  final String grupocodigo;
 _HomeMateriaState({this.token,this.grupocodigo});
 
    StateModel appState;
    Future checkId;
    final databaseReference = Firestore.instance;
    int _selectedIndex = 0;

    Future future; 
    List mattersList = [];
    Future listnotificacao;
   
    double opacityButton = 1.0;
    bool disableButton = false;

    bool myprivillege;

    bool _isLoading = true;
    bool _loadingVisible = false;


     TextEditingController _code=new TextEditingController();

  void _onItemTapped(int index) {
      if(index > 0){
        setState(() {
        opacityButton = 0.0;
        disableButton = true;
        _selectedIndex = index;
        }); 
      }else{
        setState(() {
        opacityButton = 1.0;
        disableButton = false;
        _selectedIndex = index;
        });
      } 
      
  }


  @override
  void initState() {
    super.initState();
    checkId = verificaId();
    checkId.then((userObject){ 
      if(userObject != null){
        future = getDataMateria(userObject.id);
        future.then((value){
          setState(() {
            mattersList = value;
            _isLoading = false;
          });
          print(value);
          }); 
        checkPrivillege(userObject.id);
        listnotificacao = _listaNotificacao(userObject.id);
      }
    });

  }

////////////////FUNCOES
 Future verificaId() async {
    UserEstudante userLocal = await Auth.getUserLocal();
    if(userLocal != null){
        await databaseReference.collection('grupos').document(grupocodigo).collection('users').document(userLocal.id).updateData({
              'user_foto':userLocal.user_foto,
              'token':token
          });
    }
    return userLocal;
  }
  

  Future<List> _listaNotificacao(userid) async {

  final QuerySnapshot result = await Firestore.instance.collection('users').document('$userid').collection('grupos').document('$grupocodigo').collection('matters').getDocuments();
  final List<DocumentSnapshot> documents = result.documents;
  print(documents);

      List history = [];

      int count = 0;
      for (int i = count; i < documents.length; i++) {
        final QuerySnapshot resultado = await Firestore.instance.collection('grupos').document('$grupocodigo').collection('history').where('materia_codigo', isEqualTo: documents[i]['materia_codigo']).getDocuments();
        final List<DocumentSnapshot> documento = resultado.documents;
        documento.map((dados) => history.add(dados)).toList();
        count++;
      }

      if (count == documents.length){
       history.sort((a,b) {
        var adate = a['timestamp']; //before -> var adate = a.expiry;
        var bdate = b['timestamp']; //before -> var bdate = b.expiry;
        return bdate.compareTo(adate); //to get the order other way just switch `adate & bdate`
        });
        return history;
    }

}



  Future getDataMateria(userid) async{


      final QuerySnapshot result = await Firestore.instance.collection('users').document('$userid').collection('grupos').document('$grupocodigo').collection('matters').getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
    
      print(documents);
      List matters = [];  

      int count = 0;
      for (int i = count; i < documents.length; i++) {
        print(documents[i]['materia_codigo']);
        final QuerySnapshot resultado = await Firestore.instance.collection('grupos').document('$grupocodigo').collection('matters').where('materia_codigo', isEqualTo: documents[i]['materia_codigo']).getDocuments();


        resultado.docs.forEach((element) { 

          var data = element.data();
              matters.add(data);
        });


        

          
          
        count++;
      }

      if (count == documents.length){
        print(matters);
        return matters;
      }
  
  }

Future checkPrivillege(userid) async {
  final QuerySnapshot result = await databaseReference.collection('grupos').document('$grupocodigo').collection('users').where('id', isEqualTo: userid).getDocuments();
  final List<DocumentSnapshot> documents = result.documents;
  var myprivillegedata = documents[0].data();
  if (myprivillegedata['user_grupo_privi'] != false ){
  setState(() {
     myprivillege = myprivillegedata['user_grupo_privi'];
   });
  }else{
    myprivillege = false;
  }

}

  add(StateModel appStateFunction){
  final userid = appStateFunction?.firebaseUserAuth?.uid ?? '';
   return Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (c, a1, a2) =>new MateriaAdd(grupocodigo: "$grupocodigo", userid: "$userid",token:"$token",function:addDataMatter),
                          transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                          transitionDuration: Duration(milliseconds: 400),
                        ),
                      );
  }




_entrarMatter(StateModel appStateFunction) async {
    final userid = appStateFunction?.firebaseUserAuth?.uid ?? '';
    
    print(userid);
    var code = _code.text;
    String mattercode;


    if(code.contains(':')){
      var codigomatter = code.split(':');
      mattercode = codigomatter[1];

      try{
        final QuerySnapshot resultgrupo = await Firestore.instance.collection('grupos').where('grupo_codigo', isEqualTo: widget.grupocodigo).getDocuments();
        final List<DocumentSnapshot> documentsgrupo = resultgrupo.documents;

      if(documentsgrupo.isNotEmpty){
        try{
        final QuerySnapshot result = await Firestore.instance.collection('grupos').document('${widget.grupocodigo}').collection('matters').where('materia_codigo', isEqualTo: mattercode).getDocuments();
        final List<DocumentSnapshot> documents = result.documents;
          if (documents.isNotEmpty){

          final nomeLocal = appStateFunction?.user?.user_nome ?? '';
          final photoLocal = appStateFunction?.user?.user_foto ?? '';

          databaseReference.collection('grupos').document('${widget.grupocodigo}').collection('matters').document(mattercode).collection('users').document('$userid').setData({'user_matter_privi': false,'id':"$userid",'token':"${widget.token}",'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),});
          databaseReference.collection('users').document("$userid").collection('grupos').document('${widget.grupocodigo}').collection('matters').document(mattercode).setData({'materia_codigo': mattercode}); 
           
        
            var mattersAdd = {'materia_nome': result.documents[0]['materia_nome'],'materia_codigo': result.documents[0]['materia_codigo'],'last_post':result.documents[0]['last_post'],'grupo_codigo': '$grupocodigo'};
    
              setState(() {
                  mattersList.add(mattersAdd);
              
                });
              return true;
          }else{
                print('Matter nao encontrado');
              
                return false;
                }
          }catch(e){
            
            return false;
          }

        }else{
          
          return false;
        }
      }catch(e){
        
        return false;
      }
      
    }else{
      
      return false;
    }


      
}

  _boxresultado(title,subtitle) {
    PopArg.popmensagem(context, title, subtitle);
  }


refreshDataMatter(indexList){
      setState(() {
        mattersList.removeAt(indexList);
      });

  }

  addDataMatter(matternome,mattercodigo,grupocodigo){
    var matterInsert = {'materia_nome': matternome,'materia_codigo': mattercodigo,'last_post':null,'grupo_codigo': grupocodigo};
    print(matterInsert);
    setState(() {
        mattersList.add(matterInsert);
      });
  }


  Future<void> _changeLoadingVisible() async {
    setState(() {
      _loadingVisible = !_loadingVisible;
    });
  }


 _boxcodigo(StateModel appStateFunction){
     showGeneralDialog(
            barrierColor: Colors.black.withOpacity(0.5),
            transitionBuilder: (context, a1, a2, widget) {
              final curvedValue = Curves.easeInOutBack.transform(a1.value) -   1.0;
                return Transform(
                  transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
                  child: Opacity(
                    opacity: a1.value,
                    child: AlertDialog(
                      shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0)),
                        title: Text("Código Matter"),
                        content: TextField(
                        controller: _code,
                        decoration: InputDecoration(hintText: "Cole o código Matter"),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('Ok'),
                            onPressed: () async {
                              Navigator.of(context).pop();
                            setState(() {
                                appStateFunction.isLoading = true;
                            });
                            await _changeLoadingVisible();

                            await _entrarMatter(appStateFunction);

                            setState(() {
                              appStateFunction.isLoading = false;
                            });
                            await _changeLoadingVisible();
                                  
                            },
                          )
                        ],
                      ),
                    ),
                  );
              },
              transitionDuration: Duration(milliseconds: 300),
              barrierDismissible: true,
              barrierLabel: '',
              context: context,
              pageBuilder: (context, animation1, animation2) {} 
              );
          }


Widget _bottomnavigationWidget(){
  return BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: ImageIcon(
               AssetImage("assets/images/mymattericon.png"),
                    color: Colors.white
               ),
            title: Text('Matter\'s',style: TextStyle(color: Colors.white),),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group,color: Colors.white),
            title: Text('Membros',style: TextStyle(color: Colors.white),),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications,color: Colors.white),
            title: Text('Histórico',style: TextStyle(color: Colors.white),),
          ),

        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
        backgroundColor: Color(0xFF1A2980),
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
    
  _isLoading ? Center(child: CircularProgressIndicator(),):ItemList(currentUserId: "$userId",token: "$token",list:mattersList,myprivillege:myprivillege,function:refreshDataMatter),  
  ListUsersGroup(currentUserId: "$userId",myprivillege:myprivillege,currentGroupId:"$grupocodigo"),
  ListaHistorico(currentUserId: "$userId",grupocodigo:"$grupocodigo",list:listnotificacao)

  ];

    // TODO: implement build
 return new Scaffold(
        appBar: new AppBar(
          title: Row(children: <Widget>[
            new Text("MyMatter"),
            Container(
               padding: EdgeInsets.all(5),
                    child: Hero(
                      tag:'logogrupo${widget.grupocodigo}',
                        child: Container(
                          width: 40,
                          height: 40,
                          child: Image.asset("assets/images/group-picturewhite.png"),
                      ),
                  ),
                )
          ],),
          backgroundColor: Color(0xFF1A2980),
        ),   
        body:LoadingScreen(
          child: Background(
            widget: AnimatedSwitcher(
                duration:Duration(milliseconds: 400),
                child:_widgetOptions.elementAt(_selectedIndex),
                ),
              ),
            inAsyncCall: _loadingVisible
        ),
        floatingActionButton:FancyFab(addmatter:add,entermatter:_boxcodigo),
        bottomNavigationBar: _bottomnavigationWidget(),
        drawer: DrawerCustom(currentUserId: userId,),
   );

    }
  }










