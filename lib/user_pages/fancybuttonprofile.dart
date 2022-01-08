import 'dart:math';

import 'package:flutter/material.dart';

class FancyFabProfile extends StatefulWidget {
  final Function change;
  final Function save;

  FancyFabProfile({@required this.change,@required this.save});
  @override
  _FancyFabProfileState createState() => _FancyFabProfileState(change:change,save:save);
}

class _FancyFabProfileState extends State<FancyFabProfile>with SingleTickerProviderStateMixin {
  final Function change;
  final Function save;
  _FancyFabProfileState({@required this.change,@required this.save});

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
      change();
      _animationController.forward();
    } else {
      change();
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }


Widget savestatus() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: Color(0xFF1A2980),
        heroTag: 'btn1',
        onPressed: save,
        tooltip: 'save',
        child: Icon(Icons.save),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value,
            0.0,
          ),
          child: savestatus(),
        ),
        toggle(),
      ],
    );
  }
}