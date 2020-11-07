import 'dart:async';

import 'package:flutter/material.dart';

class FadeIn extends StatefulWidget {
  Widget child;
  final int delay;
  FadeIn({@required this.child, this.delay});

  @override
  _FadeInState createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _FadeInAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _animationController = new AnimationController(
        duration: new Duration(milliseconds: 500), vsync: this);

    _FadeInAnimation = new Tween(begin: 1.0, end: 0.0).animate(
        new CurvedAnimation(
            parent: _animationController, curve: Curves.decelerate));

    _animationController.addListener(() {
      this.setState(() {});
    });

    if (widget.delay == null) {
      _animationController.forward();
    } else {
      Timer(Duration(milliseconds: widget.delay), () {
        _animationController.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        height: double.maxFinite,
        width: MediaQuery.of(context).size.width,
        child: Opacity(
          opacity: _animationController.value,
          child: widget.child,
        ));
  }
}

class FadeOut extends StatefulWidget {
  Widget child;
  final int delay;
  FadeOut({@required this.child, this.delay});

  @override
  _FadeOutState createState() => _FadeOutState();
}

class _FadeOutState extends State<FadeOut> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _FadeOutAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _animationController = new AnimationController(
      duration: new Duration(milliseconds: 500),
      vsync: this,
    );

    _FadeOutAnimation =
        new Tween(begin: 0.0, end: 1.0).animate(_animationController);

    _animationController.addListener(() {
      this.setState(() {});
    });

    print(_FadeOutAnimation);

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (widget.delay == null) {
          _animationController.reverse();
        } else {
          Timer(Duration(milliseconds: widget.delay), () {
            _animationController.reverse();
          });
        }
      } else if (status == AnimationStatus.dismissed) {
        if (widget.delay == null) {
          _animationController.reverse();
        } else {
          Timer(Duration(milliseconds: widget.delay), () {
            _animationController.reverse();
          });
        }
      }
    });

    if (widget.delay == null) {
      _animationController.forward();
    } else {
      Timer(Duration(milliseconds: widget.delay), () {
        _animationController.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        height: double.maxFinite,
        width: MediaQuery.of(context).size.width,
        child: FadeTransition(
          opacity: _animationController,
          child: widget.child,
//          duration: Duration(milliseconds: 1 - 00),
        ));
  }
}
