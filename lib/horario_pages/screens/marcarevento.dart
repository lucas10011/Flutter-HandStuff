import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class CalendarViewApp extends StatefulWidget {

  final String cdmateria;
  final String cdgrupo;

CalendarViewApp({ this.cdmateria, this.cdgrupo});

  @override
  _CalendarViewAppState createState() => _CalendarViewAppState(cdmateria:cdmateria,cdgrupo:cdgrupo);
}

class _CalendarViewAppState extends State<CalendarViewApp> {
  final databaseReference = Firestore.instance;

  final String cdmateria;
  final String cdgrupo;

_CalendarViewAppState({ this.cdmateria, this.cdgrupo});

  TextEditingController _evento=new TextEditingController();

  bool _isLoading = false;


// void displayBanner() {
//     myBanner
//       ..load()
//       ..show(
//         anchorOffset: 56,
//         anchorType: AnchorType.bottom,
//       );
//   }



@override
  void initState() {
    // displayBanner();
    super.initState();
  }


  
@override
  void dispose() {
    // myBanner?.dispose();
    super.dispose();
  }
  
_dataformatada(date){
    DateTime todayDate = DateTime.parse(date);
    String formattedDate = DateFormat('dd/MM/yyyy').format(todayDate);
    return formattedDate;
  }

 Future _registraEvento(eventodata) async {

     await databaseReference.collection('grupos').document('${widget.cdgrupo}').collection('matters').document('${widget.cdmateria}').collection('calendario').document(eventodata).setData({
                'calendario_date': eventodata,
                'calendario_evento':_evento.text,
                'grupo_codigo':'${widget.cdgrupo}',
                'materia_codigo':'${widget.cdmateria}'

                  }).then((data) async {
                              Fluttertoast.showToast(msg: "Evento adicionado com sucesso");
                              return true;
                            }).catchError((err) {
                              Fluttertoast.showToast(msg: err.toString());
                              return false;
                            });

}

Future _deletaEvento(eventodata) async {

     await databaseReference.collection('grupos').document('${widget.cdgrupo}').collection('matters').document('${widget.cdmateria}').collection('calendario').document(eventodata).delete().then((data) async {
                              Fluttertoast.showToast(msg: "Evento deletado com sucesso");
                              return true;
                            }).catchError((err) {
                              Fluttertoast.showToast(msg: err.toString());
                              return false;
                            });

}


  void _marcaevento(eventodata){
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
                          title: Text(_dataformatada(eventodata)),
                          content: TextField(
                          maxLength: 200,
                          maxLines: 5,
                          keyboardType: TextInputType.multiline,
                          controller: _evento,
                          decoration: InputDecoration(hintText: "Digite o evento"),
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('Salvar'),
                              onPressed: () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                Navigator.pop(context); 
                                var registraevento = await _registraEvento(eventodata);
                                setState(() {
                                  _isLoading = false;
                                });                   

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

  _editEvento(context,date,evento){
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
                        title: Text(_dataformatada('$date')),
                        content: Text('$evento'),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('Deletar',style: TextStyle(color: Colors.red),),
                            onPressed: () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                Navigator.pop(context); 
                                await _deletaEvento(date);
                                setState(() {
                                  _isLoading = false;
                                });                   

                              },
                          ),
                          FlatButton(
                            child: Text('Ok'),
                            onPressed: () {
                                 Navigator.pop(context);
                            },
                          ),
                        ],
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
  

_syleNotEvent(){
       return BoxDecoration(
                       gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0.3, 1],
                        colors: [
                          Color(0xFFccddff),
                          Color(0XFFe6eeff),
                          ],
                            ),
                        
                    );
}

_syleEvent(){
  return new BoxDecoration(
      color:Colors.greenAccent, 
      border: new Border.all(color: Colors.white));
}

_buildDays(datatime,List jsoneventos){
  var date = DateFormat("yyyy-MM-dd").format(datatime).toString();
  if(jsoneventos.isNotEmpty){
          return new InkWell(
                        onTap: (){
                          jsoneventos[0]['$date'] != null ? _editEvento(context,date,jsoneventos[0]['$date']) : _marcaevento(date); 
                          },
                        child: new Container(
                          decoration: jsoneventos[0]['$date'] != null ? _syleEvent()  : _syleNotEvent()
                          ,child: new Text(
                            datatime.day.toString(),style: TextStyle(color: Colors.black)
                          ),
                        ),
                      );
  

    }else{
        return new InkWell(
                      onTap: (){
                        _marcaevento(date);                        
                        },
                      child: new Container(
                        decoration: _syleNotEvent(),
                        child: new Text(
                          datatime.day.toString(),style: TextStyle(color: Colors.black),
                        ),
                      ),
                    );
    }
  

}


_calendarioWidget(jsoneventos){
  return new Container(
          margin: new EdgeInsets.symmetric(
            horizontal: 5.0,
            vertical: 10.0,
          ),
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              new Calendar(
                onSelectedRangeChange: (range) =>
                    print("Range is ${range.item1}, ${range.item2}"),
                isExpandable: true,
                dayBuilder: (BuildContext context, DateTime datatimestamp) {
                  return _buildDays(datatimestamp,jsoneventos);
                },
              ),
            ],
          ),
        );
}


Future _getEvento() async {

  Map datas = {
    'datas': 'datas'
  };

  List dataArray = [];

  final QuerySnapshot result = await databaseReference.collection('grupos').document('${widget.cdgrupo}').collection('matters').document('${widget.cdmateria}').collection('calendario').getDocuments();
  final List<DocumentSnapshot> documents = result.documents;



int count = 0;
  for (int i = count; i < documents.length; i++) {
        datas.addAll({'${documents[i]['calendario_date']}' : '${documents[i]['calendario_evento']}'});
        count++;
      }
  
  if (count == documents.length){
    dataArray.add(datas);
    print(dataArray);
    return dataArray;
  }

}


  void handleNewDate(date) {
    print("handleNewDate ${date}");
  }



  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Colors.white,
        body: _isLoading 
        ? new Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[Text('Adicionando...'),CircularProgressIndicator()],) ) 
        :FutureBuilder(
        future: _getEvento(),
        builder: (context, snapshot) {
          if(snapshot.hasError)
            print(snapshot.error);
          return snapshot.hasData
              ?_calendarioWidget(snapshot.data)
              :new Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[Text('Buscando por Datas...'),CircularProgressIndicator()],) );
        }
        ),
      );
  }
}