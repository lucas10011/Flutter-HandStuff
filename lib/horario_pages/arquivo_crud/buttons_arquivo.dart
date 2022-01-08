
import 'package:flutter/material.dart';

class FancyFabArquivo extends StatefulWidget {
  final Function addfile;
  final Function scanfile;
  final int tipo;

  FancyFabArquivo({@required this.addfile, @required this.scanfile,@required this.tipo});
  @override
  _FancyFabArquivoState createState() => _FancyFabArquivoState(addfile: addfile,scanfile: scanfile,tipo:tipo);
}

class _FancyFabArquivoState extends State<FancyFabArquivo>with SingleTickerProviderStateMixin {
  final Function addfile;
  final Function scanfile;
  final int tipo;
  _FancyFabArquivoState({@required this.addfile, @required this.scanfile,@required this.tipo});

  static const String CAMERA_SOURCE = 'CAMERA_SOURCE';
  static const String GALLERY_SOURCE = 'GALLERY_SOURCE';

  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;

  @override
  initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: Color(0xFF1A2980),
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }


  Widget addbutton() {
    return Container(
      child:RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: EdgeInsets.all(12),
        color: Colors.blue,
        onPressed: () => addfile(),
        child: tipo == 0
        ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
                Text('Galeria',style: TextStyle(color: Colors.white),),
                Icon(Icons.photo_album, color: Colors.white,)
              ],)
        : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
                Text('Camera',style: TextStyle(color: Colors.white),),
                Icon(Icons.photo_camera, color: Colors.white,)
              ],)
        
      ),
    );
  }

  Widget scanbutton() {
    return Container(
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: EdgeInsets.all(12),
        color: Colors.blue,
        onPressed: () =>  tipo == 0 ? scanfile(GALLERY_SOURCE) : scanfile(CAMERA_SOURCE),
        child: tipo == 0 
          ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
                Text('Scan',style: TextStyle(color: Colors.white),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.photo_album, color: Colors.white,),
                    Icon(Icons.add, color: Colors.white, size: 10,),
                    ImageIcon(
                        AssetImage("assets/images/pdf.png",),
                        color: Colors.white
                    ),
                    
                  ],
                )
              ],)
          :Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
                Text('Scan',style: TextStyle(color: Colors.white),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.photo_camera, color: Colors.white,),
                    Icon(Icons.add, color: Colors.white, size: 10,),
                    ImageIcon(
                        AssetImage("assets/images/pdf.png",),
                        color: Colors.white
                    ),
                    
                  ],
                )
              ],)
      ),
    );
  }
  

  Widget toggle() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: animate,
        padding: EdgeInsets.all(12),
        color:  _buttonColor.value,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
         tipo == 0 ? Text('Album',style: TextStyle(color: Colors.white),) : Text('Foto',style: TextStyle(color: Colors.white),),
          AnimatedIcon(
          color: Colors.white,
          icon: AnimatedIcons.add_event,
          progress: _animateIcon,
        )
        ],),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 2.85,
            0.0,
          ),
          child: addbutton(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 1.55,
            0.0,
          ),
          child: scanbutton(),
        ),
        toggle(),
      ],
    );
  }
}