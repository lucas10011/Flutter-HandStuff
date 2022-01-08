import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hand_stuff/models/state.dart';
import 'package:hand_stuff/services/state_widget.dart';

class FancyFab extends StatefulWidget {
  final Function addmatter;
  final Function entermatter;

  FancyFab({@required this.addmatter, @required this.entermatter,});
  @override
  _FancyFabState createState() => _FancyFabState(addmatter: addmatter,entermatter: entermatter);
}

class _FancyFabState extends State<FancyFab>with SingleTickerProviderStateMixin {

  final Function addmatter;
  final Function entermatter;
  _FancyFabState({@required this.addmatter, @required this.entermatter});

  StateModel appState;

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


  Widget add(StateModel appStateFunction) {
    return Container(
      child: FloatingActionButton(
        backgroundColor: Color(0xFF1A2980),
        heroTag: 'btn2',
        onPressed: ()=>addmatter(appStateFunction),
        tooltip: 'Add',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget enter(StateModel appStateFunction) {
    return Container(
      child: FloatingActionButton(
        backgroundColor: Color(0xFF1A2980),
        heroTag: 'btn3',
        onPressed: ()=> entermatter(appStateFunction),
        tooltip: 'MyMatterIn',
        child: ImageIcon(
               AssetImage("assets/images/mymattericon.png"),
                    color: Colors.white
               ),
      ),
    );
  }

  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        heroTag: 'btn4',
        backgroundColor: _buttonColor.value,
        onPressed: animate,
        tooltip: 'Toggle',
        child: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: _animateIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    appState = StateWidget.of(context).state;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 2.0,
            0.0,
          ),
          child: add(appState),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value,
            0.0,
          ),
          child: enter(appState),
        ),
        toggle(),
      ],
    );
  }
}