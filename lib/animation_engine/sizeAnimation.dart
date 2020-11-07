import 'package:flutter/material.dart';

class SizeAnimation extends StatefulWidget {
  Widget child;
  SizeAnimation(this.child);
  @override
  _SizeAnimationState createState() => _SizeAnimationState();
}

class _SizeAnimationState extends State<SizeAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _widthAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller = new AnimationController(
        duration: new Duration(milliseconds: 2000), vsync: this);

    _widthAnimation = new Tween(begin: 1.4, end: 1.2).animate(
        new CurvedAnimation(
            parent: _controller,
            curve: Interval(0.5, 1.0, curve: Curves.ease)));

    _controller.addListener(() {
      this.setState(() {});
    });

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        height: double.maxFinite,
        width: MediaQuery.of(context).size.width,
        child: ScaleTransition(
          scale: _widthAnimation,
          alignment: Alignment.center,
          child: widget.child,
        ));
  }
}
