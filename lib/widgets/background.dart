import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget widget;
  Background({this.widget});
  @override
  Widget build(BuildContext context) {
  var size = MediaQuery.of(context).size;
  final double itemWidth = (size.width);
  final double itemHeight = (size.height);
    return Container(
        color: Color(0xFF1A2980),
          child: Center(
            child:CustomPaint(
              painter: ShapesPainter(),
              child: Container(
              width: itemWidth,
              height: itemHeight,
                child: widget
              ),
            ),
          ),
        );
  }
}



class ShapesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    // set the paint color to be white
    paint.color = Colors.white;
    // Create a rectangle with size and width same as the canvas
    var rect = Rect.fromLTWH(0, 0, size.width, size.height);
    // draw the rectangle using the paint
    canvas.drawRect(rect, paint);
    paint.color = Color(0xFF1A2980);
    // create a path
    var path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, 0);
    // close the path to form a bounded shape
    path.close();
    canvas.drawPath(path, paint);
    // set the color property of the paint
    paint.color = Colors.deepOrange;
    // center of the canvas is (x,y) => (width/2, height/2)
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

}