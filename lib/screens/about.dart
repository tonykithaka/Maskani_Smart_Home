import 'package:flutter/material.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  double xOffset = 0.0;
  double yOffset = 0.0;
  double scaleFactor = 1;
  double containerRadius = 0.0;
  bool isDrawerOpen = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
      decoration: BoxDecoration(
        color: Colors.brown,
        borderRadius: BorderRadius.circular(containerRadius),
      ),
      transform: Matrix4.translationValues(xOffset, yOffset, 0)
        ..scale(scaleFactor),
      duration: Duration(milliseconds: 250),
      curve: Curves.decelerate,
      child: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
          Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  isDrawerOpen
                      ? IconButton(
                          icon: Icon(Icons.arrow_back_ios),
                          onPressed: () {
                            setState(() {
                              xOffset = 0.0;
                              yOffset = 0.0;
                              scaleFactor = 1.0;
                              isDrawerOpen = false;
                              containerRadius = 0.0;
                            });
                          },
                        )
                      : IconButton(
                          icon: Icon(Icons.menu),
                          onPressed: () {
                            setState(() {
                              xOffset = 200.0;
                              yOffset = 200.0;
                              scaleFactor = 0.6;
                              isDrawerOpen = true;
                              containerRadius = 30.0;
                            });
                          })
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
