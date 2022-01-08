import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hand_stuff/file_pages/listfiles.dart';
import 'package:hand_stuff/redirect.dart';
import 'package:hand_stuff/widgets/notfound.dart';
import 'package:intl/intl.dart';

class ListaHorario extends StatefulWidget {
  final String cdmateria;
  final String cdgrupo;
  final String currentUserId;  
  final List list;
  final Function function;
ListaHorario({ this.cdmateria, this.cdgrupo,this.currentUserId,this.list,this.function});

  @override
  _ListaHorarioState createState() => _ListaHorarioState(cdmateria: cdmateria,cdgrupo: cdgrupo,currentUserId: currentUserId,list: list,function: function);
}

class _ListaHorarioState extends State<ListaHorario> {
  final String cdmateria;
  final String cdgrupo;
  final String currentUserId;  
  final List list;
  final Function function;
_ListaHorarioState({ this.cdmateria, this.cdgrupo,this.currentUserId,this.list,this.function});

   @override
  void initState() {
    super.initState();
  }

Future<bool> getPrivillege() async{

      final QuerySnapshot result = await Firestore.instance.collection('grupos').document('$cdgrupo').collection('matters').document('$cdmateria').collection('users').where('id', isEqualTo: currentUserId).getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      return documents[0]['user_matter_privi'];   
}

_dataformatada(date){
    DateTime todayDate = DateTime.parse(date);
    String formattedDate = DateFormat('dd/MM/yyyy').format(todayDate);
    return formattedDate;
  }



popDeletar(context,cdgrupo,cdmateria,date,indexList)async{
  bool sucess;
  var teste = await showGeneralDialog(
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
                                  sucess = false;
                                },
                              ),           
                              new FutureBuilder(
                                future:Firestore.instance.collection('grupos').document('$cdgrupo').collection('matters').document('$cdmateria').collection('users').where('id', isEqualTo: currentUserId).getDocuments(),
                                builder: (context,snapshot){
                                  if(snapshot.hasError)
                                    print(snapshot.error);
                                  return snapshot.hasData
                                  ? OutlineButton(
                                        color: Colors.red,
                                        textColor: Colors.red,
                                        borderSide: BorderSide(color: Colors.red),
                                        shape: StadiumBorder(),
                                        child: Text('Deletar'),
                                        onPressed: snapshot.data.documents[0]['user_matter_privi'] 
                                        ? () {
                                            Firestore.instance.collection('grupos').document('$cdgrupo').collection('matters').document('$cdmateria').collection('datas').document('$date').collection('files').getDocuments().then((snapshot) {
                                                String storageUrl = "$cdgrupo/$cdmateria/$date";
                                                for (DocumentSnapshot doc in snapshot.documents) {
                                                      doc.reference.delete();
                                                      FirebaseStorage.instance.ref().child('$storageUrl/${doc['name']}').delete().then((_) => print('Successfully deleted $storageUrl/${doc['name']} storage item' ));
                                                    }
                                              Firestore.instance.collection('grupos').document('$cdgrupo').collection('matters').document('$cdmateria').collection('datas').document(date).delete();
                                              Navigator.pop(context);
                                              function(indexList);
                                              sucess = true;
                                            
                                          }).catchError((err) {
                                            Fluttertoast.showToast(msg: err.toString());
                                            sucess = true;
                                            return false;
                                          });
                                        } 
                                      :null
                                      )
                                  :SizedBox(width:10 ,height: 10,);
                                },
                              )
                            ],
                          )
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
            
            return sucess;
          }



_buildHorario(){
  return list.isEmpty
  ?NotFound(msg: 'Nenhum post encontrado...',image: 'icon-image',)
  :ListView.builder(
                      key:Key(UniqueKey().toString()),
                      padding: EdgeInsets.only(top:0,left: 20,right: 20),
                      itemBuilder: (context, index) => 
                      GestureDetector(
                        onLongPress: (){
                            popDeletar(context,'${widget.cdgrupo}','${widget.cdmateria}',list[index]['horario_date'],index);
      
                        },
                        child: BuildHorario(document:list[index],index:index,currentUserId:widget.currentUserId,privillege:true,data:_dataformatada(list[index]['horario_date']))),
                      itemCount: list.length,
                    );
     
}


  @override
  Widget build(BuildContext context) {
    return _buildHorario();
  }
}



class BuildHorario extends StatefulWidget {
    final DocumentSnapshot document;
    final int index;
    final String currentUserId;
    final bool privillege;
    final String data;

    BuildHorario({this.document,this.index,this.currentUserId,this.privillege,this.data});
  @override
  _BuildHorarioState createState() => _BuildHorarioState(document:document,index:index,currentUserId:currentUserId,privillege:privillege,data:data);
}

class _BuildHorarioState extends State<BuildHorario> with SingleTickerProviderStateMixin {
    final DocumentSnapshot document;
    final int index;
    final String currentUserId;
    final bool privillege;
    final String data;
    _BuildHorarioState({this.document, this.index,this.currentUserId,this.privillege,this.data});

    Animation animation;
    AnimationController animationController;

       @override
  void initState() {
    super.initState();

  animationController = AnimationController(duration: Duration(seconds: 2), vsync: this);
  
  animation = Tween(begin: index.isEven ? -1.0 : 1.0, end:0.0).animate(CurvedAnimation(
    parent: animationController, curve: Curves.ease));

  
  animationController.forward();
  }

  @override
void dispose() {
  animationController.dispose();
  super.dispose();
  print("$document");
}


  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return AnimatedBuilder(
            animation: animationController,
            builder: (BuildContext context, Widget child){
            return Transform(
              transform:Matrix4.translationValues(animation.value  * width, 0.0, 0.0),
              child:Container(
                decoration: BoxDecoration(
                borderRadius: new BorderRadius.circular(25.0),
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.3, 1],
                    colors: [
                     Colors.indigo[500],
                     Colors.indigo[300],
                      ],
                    )
              ),
                padding: const EdgeInsets.only(bottom: 10),
                child: FlatButton(
                  shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(25.0)),
                  splashColor: Colors.blueAccent,
                  onPressed:()=> 
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (c, a1, a2) => FilesMateria(cdgrupo:document['grupo_codigo'], cdmateria:document['materia_codigo'], date:document['horario_date'], currentUserId: currentUserId),
                        transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                        transitionDuration: Duration(milliseconds: 400),
                      )
                    ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(5),
                                  child: Hero(
                                    tag:'logohorario${document['horario_date']}',
                                      child: Container(
                                        width: 70,
                                        height: 70,
                                        child: Image.asset('assets/images/icon-imagewhite.png', fit: BoxFit.cover, width:70,height: 70 ,),
                                    ),
                                ),
                              ),
                          Text(data,style: TextStyle(color: Colors.white,fontSize: 24.0,)),
                        ],
                      ),
                      // Padding(padding: EdgeInsets.all(8),),
                      // Text('Descrição:',style: TextStyle(color: Colors.black54,fontSize: 20.0,fontWeight: FontWeight.bold,)),
                      // Text('${document['horario_descricao']}',style: TextStyle(fontSize: 20,color: Colors.black))
                      ],),
              
                      ),
                    ));
                  });

  }
}