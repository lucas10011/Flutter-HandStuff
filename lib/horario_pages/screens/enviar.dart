import 'package:flutter/material.dart';
import 'package:hand_stuff/horario_pages/arquivo_crud/arquivo_add.dart';
import 'package:hand_stuff/widgets/intentshared.dart';
import 'package:intl/intl.dart';


class FileMenu extends StatefulWidget {


final String cdgrupo;
final String cdmateria;
final String currentUserId;
final Function function;

FileMenu({this.cdgrupo, this.cdmateria,this.currentUserId,this.function});

  @override
  _FileMenuState createState() => _FileMenuState(cdgrupo: cdgrupo,cdmateria: cdmateria,currentUserId: currentUserId,function: function);
}

class _FileMenuState extends State<FileMenu> {
  final String cdgrupo;
  final String cdmateria;
  final String currentUserId;
  final Function function;
_FileMenuState({this.cdgrupo, this.cdmateria,this.currentUserId,this.function});

  TextEditingController descricao=new TextEditingController();

  DateTime _dateTime = DateTime.now();




   _dataformatada(date){
    DateTime todayDate = DateTime.parse(date);
    String formattedDate = DateFormat('dd/MM/yyyy').format(todayDate);
    return formattedDate;
  }




_inputDescricao(){
  return TextField(
              maxLength: 400,
              textAlign: TextAlign.center,
              //autofocus: true,
              keyboardType: TextInputType.text,
              controller: descricao,
              decoration: InputDecoration(
                hintStyle: TextStyle(color: Colors.white),
                hintText: 'Coloque uma descrição',
                labelStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                ),
              ),
              style: TextStyle(fontSize: 20,color: Colors.white),
            );
}


_botaoAdicionar(){
  return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          DateTime todayDate = DateTime.parse(_dateTime.toString());
          String formattedDate = DateFormat('yyyy-MM-dd').format(todayDate);
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (c, a1, a2) =>new UploadMultipleFiles(cdgrupo:"${widget.cdgrupo}", cdmateria:"${widget.cdmateria}", currentUserId: "${widget.currentUserId}", datetime:"$formattedDate",descricao:"${descricao.text}",function:function),
            transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
            transitionDuration: Duration(milliseconds: 400),
          )
        );
        },
        padding: EdgeInsets.all(12),
        color: Theme.of(context).primaryColor,
        child: Text('Criar post', style: TextStyle(color: Colors.white)),
      ),
    );  
           
}

_botaoDataPicker(){
  return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
            showDatePicker(
                          context: context,
                          initialDate: _dateTime == null ? DateTime.now() : _dateTime,
                          firstDate: DateTime(2001),
                          lastDate: DateTime(2021)
                        ).then((date) {
                          setState(() {
                            _dateTime = date;
                          });
                        });
        },
        padding: EdgeInsets.all(12),
        color: Theme.of(context).primaryColor,
        child: Text(_dateTime == null ? 'Selecione uma data' :_dataformatada(_dateTime.toString()),style: TextStyle(fontSize: 25,color: Colors.white),),
      ),
    );  
           
}

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Column(
      children: <Widget>[
      Expanded(
        child: ListView(children: <Widget>[
        SharedIntent(page:"uma data",icon:true, iconpath:"", ),
        SizedBox(height: (height / 17),),
        _inputDescricao(),
        _botaoDataPicker(),
           
            SizedBox(height: (height / 14),),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
               _botaoAdicionar()
              ],
            )
      ],),
      )
    ],
  );
  }
}



