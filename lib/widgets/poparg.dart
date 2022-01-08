import 'package:flutter/material.dart';

class PopArg{
  static popmensagem(context,title,subtitle){
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
                          title: Text(title),
                          content: Text(subtitle),
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
}