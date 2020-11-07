import 'dart:async';

import 'package:flutter/material.dart';

class SlideUpAnimation extends StatefulWidget {
  Widget child;
  final int delay;
  SlideUpAnimation({@required this.child, this.delay});
  @override
  _SlideUpAnimationState createState() => _SlideUpAnimationState();
}

class _SlideUpAnimationState extends State<SlideUpAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _slideUpAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller = new AnimationController(
        duration: new Duration(milliseconds: 2000), vsync: this);

    _slideUpAnimation = new Tween(begin: 0.0, end: -50.0).animate(
        new CurvedAnimation(
            parent: _controller,
            curve: Interval(0.5, 1.0, curve: Curves.ease)));

    _controller.addListener(() {
      this.setState(() {});
    });

    if (widget.delay == null) {
      _controller.forward();
    } else {
      Timer(Duration(milliseconds: widget.delay), () {
        _controller.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        height: double.maxFinite,
        width: MediaQuery.of(context).size.width,
        child: Transform.translate(
          offset: Offset(-0.0, _slideUpAnimation.value),
          child: widget.child,
        ));
  }
}

class SlideLeftAnimation extends StatefulWidget {
  Widget child;
  final int delay;
  SlideLeftAnimation({@required this.child, this.delay});
  @override
  _SlideLeftAnimationState createState() => _SlideLeftAnimationState();
}

class _SlideLeftAnimationState extends State<SlideLeftAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _slideLeftAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller = new AnimationController(
        duration: new Duration(milliseconds: 1000), vsync: this);

    _slideLeftAnimation = new Tween(begin: 50.0, end: 0.0).animate(
        new CurvedAnimation(parent: _controller, curve: Curves.decelerate));

    _controller.addListener(() {
      this.setState(() {});
    });

    if (widget.delay == null) {
      _controller.forward();
    } else {
      Timer(Duration(milliseconds: widget.delay), () {
        _controller.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        height: double.maxFinite,
        width: MediaQuery.of(context).size.width,
        child: Transform.translate(
          offset: Offset(_slideLeftAnimation.value, 0.0),
          child: widget.child,
        ));
  }
}
