import 'package:flutter/material.dart';


class ButtonAnimated extends StatefulWidget {
 final double width;
 final double height;
 final double widthimage;
 final double heightimage;
 final Color color1;                 
 final Color color2;
 final BorderRadiusGeometry borderRadius; 
  ButtonAnimated({this.width,this.height,this.widthimage,this.heightimage,this.color1,this.color2,this.borderRadius});
  @override
  _ButtonAnimatedState createState() => _ButtonAnimatedState(width: width,height: height,widthimage: widthimage,color1: color1,color2: color2,borderRadius: borderRadius);
}

class _ButtonAnimatedState extends State<ButtonAnimated> {
  double width;
  double height;
  double widthimage;
  double heightimage;
  Color color1;                 
  Color color2;
  BorderRadiusGeometry borderRadius; 
  _ButtonAnimatedState({this.width,this.height,this.widthimage,this.heightimage,this.color1,this.color2,this.borderRadius});
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
              padding: EdgeInsets.all(16),
              width: width,
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.3, 1],
                  colors: [color1,color2],
                ),
                boxShadow: [
                    BoxShadow(
                      color: Color(0xFF1A2980),
                      blurRadius: 10.0, // has the effect of softening the shadow
                      spreadRadius: 1.0, // has the effect of extending the shadow
                      offset: Offset(
                        2.0, // horizontal, move right 10
                        2.0, // vertical, move down 10
                      ),
                    )
                  ],
                borderRadius: borderRadius,
              ),
              // Define how long the animation should take.
              duration: Duration(seconds: 1),
              // Provide an optional curve to make the animation feel smoother.
              curve: Curves.fastOutSlowIn,
              child: AnimatedContainer(
                  duration: Duration(seconds: 1),
                  curve: Curves.fastOutSlowIn,
                  width: widthimage, 
                  height: heightimage,
                  child: Column(
                  children: <Widget>[
                    new Image.asset('assets/images/entrar.png',scale: 2.0,fit: BoxFit.cover,),
                    Flexible(child: Text('Entrar',overflow: TextOverflow.ellipsis,))
                  ],
                ),
              ),
            );
  }
}


