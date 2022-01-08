import 'package:flutter/material.dart';

class NotFound extends StatelessWidget {

final String msg;
final String image;
  NotFound({this.msg,this.image});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            color: Color(0xFF1A2980),
            child: Text(msg,style: TextStyle(color: Colors.white),)),
          
          
          Image.asset("assets/images/$image.png", width: 150, height: 150,),
          SizedBox(
            height: 35,
          )
        ],
        
      ),
    );
  }
}