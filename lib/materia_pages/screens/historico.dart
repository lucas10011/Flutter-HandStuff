import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hand_stuff/widgets/notfound.dart';
import 'package:intl/intl.dart';


class ListaHistorico extends StatefulWidget {
  final Future list;
  final String currentUserId;
  final String grupocodigo;
  ListaHistorico({this.currentUserId,this.grupocodigo,this.list});

  @override
  _ListaHistoricoState createState() => _ListaHistoricoState();
}

class _ListaHistoricoState extends State<ListaHistorico> {

bool _isValue = true;

 





////////////////////////////////////Widgets


_notifiListWidget(dataSnapshot){
    return ItemListNotifi(list: dataSnapshot,);
}

_notifiloadingWidget(){
    return new Center(child:_isValue ? Column(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[Text('Buscando por Notificações...'),CircularProgressIndicator()],) : Text('')); 
}




  @override
  Widget build(BuildContext context) {
  var size = MediaQuery.of(context).size;
  final double itemWidth = (size.width - 20);
  final double itemHeight = (size.height);
    return Column(children: <Widget>[

      Expanded(child:
            FutureBuilder(
              future: widget.list,
              builder: (context,snapshot){
                if(snapshot.hasError)
                  print(snapshot.error);
                return snapshot.hasData
                    ?_notifiListWidget(snapshot.data)
                    :_notifiloadingWidget();
              },
          )
        ,)

    ],);
  }
}

class ItemListNotifi extends StatefulWidget{

  final List list;
  ItemListNotifi({this.list});

  @override
  _ItemListNotifiState createState() => _ItemListNotifiState();
}

class _ItemListNotifiState extends State<ItemListNotifi> {

  

_nomegrupo(grupocodigo) async {
  final QuerySnapshot result = await Firestore.instance.collection('grupos').where('grupo_codigo', isEqualTo: '$grupocodigo').getDocuments();
  final List<DocumentSnapshot> document = result.documents;
  return document[0]['grupo_nome'];
}


Future _checkMatter(grupocodigo,mattercodigo) async {
  return _futureNameMatter('$grupocodigo','$mattercodigo');  
}

Future _checkGrupo(grupocodigo) async {
  return _nomegrupo('$grupocodigo');   
}


_futureNameMatter(grupocodigo,mattercodigo) async {


  final QuerySnapshot result = await Firestore.instance.collection('grupos').document('$grupocodigo').collection('matters').where('materia_codigo', isEqualTo: '$mattercodigo').getDocuments();
  final List<DocumentSnapshot> documents = result.documents;

  return documents[0]['materia_nome'];
}

/////////////////Box com informaçoesdogrupo

  _infogrupo(nomegrupo,nomemateria,local,hora,descricao,namefile){

  return showGeneralDialog(
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
                          title: Text("Notificação"),
                          content: Container(
                            constraints: BoxConstraints(minHeight: 100, maxHeight:300),    
                            width: 300,
                            child: Column(
                              mainAxisSize:MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[    
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                Text("Grupo"),

                              new FutureBuilder(
                                future: _checkGrupo('$nomegrupo'),
                                builder: (context,snapshot){
                                  if(snapshot.hasError)
                                    print(snapshot.error);
                                  return snapshot.hasData
                                      ?Text('${snapshot.data}')
                                      :Center(child: CircularProgressIndicator(),);
                                },
                              )
                               ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                Text("Matter"),
                                new FutureBuilder(
                                future: _checkMatter('$nomegrupo','$nomemateria'),
                                builder: (context,snapshot){
                                  if(snapshot.hasError)
                                    print(snapshot.error);
                                  return snapshot.hasData
                                      ?Text('${snapshot.data}')
                                      :Center(child: CircularProgressIndicator(),);
                                },
                              ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                Text("Arquivo"),
                                Flexible(child: Container(child: new Text('$namefile', overflow: TextOverflow.ellipsis,)))
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                Text("Local"),
                                Text(_localformatado("$local")),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                Text("Hora"),
                                Text(DateFormat('dd MMM kk:mm').format(DateTime.fromMillisecondsSinceEpoch(int.parse('$hora')))),
                                ],
                              ),
                             
                                
                                
                               Column(
                                    children: <Widget>[
                                      Text('Descricao:'),
                                      
                                      SizedBox(
                                        height: 125,
                                        child: ListView(children: <Widget>[
                                          Text("$descricao",overflow: TextOverflow.visible,),
                                        ],),
                                      )
                                      
                                    ],
                                  ),
                               
                                
                              
                            ],),
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('Ok'),
                              onPressed: () {
                                  Navigator.of(context).pop();
                                
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



/////////////////Funcao
  _dataformatada(date){
    DateTime todayDate = DateTime.parse(date);
    String formattedDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(todayDate);
    return formattedDate;
  }

  _localformatado(date){
    DateTime todayDate = DateTime.parse(date);
    String formattedDate = DateFormat('dd/MM/yyyy').format(todayDate);
    return formattedDate;
  }

_nomeArquivo(nome){
       
  return Container(child: new Text(nome, overflow: TextOverflow.ellipsis,));
}

Widget _typeImage(name){
  String extensiontype = name.split('.').last;

  if(extensiontype == 'gif'  || extensiontype == 'jpg' || extensiontype == 'png' || extensiontype == 'jpeg' ){

    return ImageIcon(
            AssetImage("assets/images/icon-image.png",),
                  color: Colors.blueAccent,
                  size: 50
            );

  }else if(extensiontype == 'avi' || extensiontype == 'mpg ' || extensiontype == 'mov' || extensiontype == 'mp4'){

    return ImageIcon(
            AssetImage("assets/images/video-file.png",),
                  color: Colors.blueAccent,
                  size: 50
            );

  }else if(extensiontype == 'pdf'){

    return ImageIcon(
            AssetImage("assets/images/pdf.png",),
                  color: Colors.blueAccent,
                  size: 50
            );

  }else if(extensiontype == 'doc'){

    return ImageIcon(
            AssetImage("assets/images/materia-picture.png",),
                  color: Colors.blueAccent,
                  size: 50
            );

  }

  print(extensiontype);

  return ImageIcon(
            AssetImage("assets/images/file.png",),
                  color: Colors.blueAccent,
                  size: 50
            );
  
}

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return widget.list.isEmpty 
      ?NotFound(msg: 'Nenhum notificação encontrada...',image:'mymattericon') 
      :ListView.builder(
        padding: const EdgeInsets.only(left: 20.0,top:0,right: 20,),
        itemCount: widget.list==null?0:widget.list.length,
      
        itemBuilder: (context,i){
            return GestureDetector(
                onTap: (){_infogrupo(widget.list[i]['grupo_codigo'],widget.list[i]['materia_codigo'],widget.list[i]['horario_date'],widget.list[i]['timestamp'],widget.list[i]['horario_descricao'],widget.list[i]['name']);},
                  child: Container(
                    child: Card(
                      elevation: 5,
                      margin: EdgeInsets.all(5),
                      child: Column(children: <Widget>[
                        ListTile(
                        leading: _typeImage(widget.list[i]['name']),
                        title: _nomeArquivo(widget.list[i]['name']),
                        subtitle: Text(DateFormat('dd MMM kk:mm').format(DateTime.fromMillisecondsSinceEpoch(int.parse(widget.list[i]['timestamp'])))),
                      ),
                      ],)
                    ),
                  ),
                
           
            );
        },
      );

  }
}
