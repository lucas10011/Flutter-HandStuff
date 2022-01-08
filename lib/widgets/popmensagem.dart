import 'package:flutter/material.dart';

class PopMensagem {

 static popmensagem(context,title,subtitle){
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
                        title: Text('$title'),
                        content: Text('$subtitle'),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('Ok'),
                            onPressed: () {
                                 Navigator.pop(context);
                            },
                          )
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
}