import 'dart:async';

import 'package:flutter/material.dart';

class PageSlideTransition extends MaterialPageRoute {
  PageSlideTransition({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    Animation<Offset> customSlideAnimation =
        Tween<Offset>(begin: Offset(0.0, 1.0), end: Offset(0.0, 0.0))
            .animate(animation);
    return SlideTransition(
      position: customSlideAnimation,
      child: child,
    );
  }
}

class SlideInTransition extends StatefulWidget {
  Widget child;
  final int delay;
  SlideInTransition({@required this.child, this.delay});

  @override
  _SlideInTransitionState createState() => _SlideInTransitionState();
}

class _SlideInTransitionState extends State<SlideInTransition>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<Offset> _SlideInAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _animationController = new AnimationController(
        duration: new Duration(milliseconds: 500), vsync: this);

    _SlideInAnimation =
        new Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0))
            .animate(new CurvedAnimation(
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
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: SlideTransition(
        position: _SlideInAnimation,
        child: widget.child,
      ),
    );
  }
}
