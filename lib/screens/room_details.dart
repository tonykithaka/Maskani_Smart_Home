import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:maskanismarthome/models/rooms.dart';
import 'package:maskanismarthome/style/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoomDetails extends StatefulWidget {
  @override
  _RoomDetailsState createState() => _RoomDetailsState();
}

class _RoomDetailsState extends State<RoomDetails> {
  List<Color> _colors = [Color(0xffFFFFFF), Color(0xFFC1C1C1)];
  Color textColor = Color(0xFF333333);
  double iconSize = SizeConfig.blockSizeHorizontal * 7;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool isSwitched;
  bool showWindow = false;
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  //Navigate back to home
  Navigate() {
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    ShowContentContainer();
  }

  //Showing page Content Drawer
  ShowContentContainer() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        this.showWindow = true;
      });
    });
  }

  //Change device settings
  ViewRoomDevice(String deviceName, Room roomData) async {
    final SharedPreferences prefs = await _prefs;
    Navigator.pushNamed(context, "/temperature_setting",
        arguments: RoomDevice(
          deviceName,
          roomData,
        ));
  }

  @override
  Widget build(BuildContext context) {
    //Styles
    var maxHeight = MediaQuery.of(context).size.height;
    var maxWidth = MediaQuery.of(context).size.width;

    final Room argument = ModalRoute.of(context).settings.arguments;
    print(argument.imageUrl);
    return SingleChildScrollView(
      child: Material(
        child: Container(
          color: Colors.grey,
          height: maxHeight,
          width: maxWidth,
          child: Stack(
            children: <Widget>[
              Container(
                height: maxHeight,
                width: maxWidth,
                child: Hero(
                  tag: Text('hello' + argument.roomId),
                  child: Image.network(
                    argument.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              AnimatedOpacity(
                duration: Duration(milliseconds: 300),
                opacity: (showWindow) ? 1.0 : 0.0,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                  child: Container(color: Colors.white.withOpacity(0)),
                ),
              ),
              AnimatedPositioned(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.fastOutSlowIn,
                  bottom: 0,
                  right:
                      showWindow ? 0 : -(SizeConfig.blockSizeHorizontal * 90),
                  width: SizeConfig.blockSizeHorizontal * 85,
                  child: Column(children: <Widget>[
                    Container(
                      width: double.maxFinite,
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.blockSizeHorizontal * 8,
                          vertical: SizeConfig.blockSizeVertical * 2),
                      child: Text(
                        'Room Settings',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: textColor,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Hero(
                        tag: 'containerBackground',
                        child: Container(
                            alignment: Alignment.bottomRight,
                            height: SizeConfig.blockSizeVertical * 75,
                            width: double.maxFinite,
                            child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20.0)),
                                child: Container(
                                  width: double.maxFinite,
                                  height: double.maxFinite,
//                                    color: Color(0xFF292929),
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          SizeConfig.blockSizeHorizontal * 0,
                                      vertical:
                                          SizeConfig.blockSizeVertical * 0),
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          colors: _colors,
                                          begin: FractionalOffset.topLeft,
                                          end: FractionalOffset.bottomRight)),
                                  child: Stack(
                                    children: <Widget>[
                                      Container(
                                        width: double.maxFinite,
                                        height: double.maxFinite,
                                        alignment: Alignment.centerRight,
                                        child: Image.asset(
                                          'assets/settings.png',
                                          alignment: Alignment.centerRight,
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 15.0,
                                                horizontal: SizeConfig
                                                        .blockSizeHorizontal *
                                                    8),
                                            width: double.maxFinite,
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Container(
                                                      padding: EdgeInsets.symmetric(
                                                          vertical: SizeConfig
                                                                  .blockSizeVertical *
                                                              1.5),
                                                      child: Text(
                                                        argument.roomName
                                                            .toUpperCase(),
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Montserrat',
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: textColor,
                                                            fontSize: 20.0,
                                                            letterSpacing: 1.0),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        print(
                                                            'This is editing ' +
                                                                argument
                                                                    .roomName);
                                                      },
                                                      child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        height: SizeConfig
                                                                .blockSizeHorizontal *
                                                            8,
                                                        width: SizeConfig
                                                                .blockSizeHorizontal *
                                                            8,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5.0)),
                                                            border: Border.all(
                                                                width: 1.5,
                                                                color: Color(
                                                                    0xFF222222))),
                                                        child: Icon(Icons.edit,
                                                            size: 18,
                                                            color: Color(
                                                                0xFF222222)),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: SizeConfig
                                                          .blockSizeVertical *
                                                      2,
                                                ),
                                                Container(
                                                  width: double.maxFinite,
                                                  height: 2.0,
                                                  color: textColor
                                                      .withOpacity(0.3),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: SizeConfig
                                                        .blockSizeHorizontal *
                                                    8),
                                            child: Column(
                                              children: <Widget>[
                                                GestureDetector(
                                                  onTap: () {
                                                    ViewRoomDevice(
                                                        'Air Conditioner',
                                                        argument);
                                                  },
                                                  child: Container(
                                                      child: Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: Image.asset(
                                                          'assets/temperature.png',
                                                          height: iconSize,
                                                          alignment: Alignment
                                                              .centerLeft,
                                                        ),
                                                        flex: 1,
                                                      ),
                                                      Expanded(
                                                          child: Text(
                                                            'Air Conditioner',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontSize: 17.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                letterSpacing:
                                                                    1.0),
                                                          ),
                                                          flex: 4)
                                                    ],
                                                  )),
                                                ),
                                                SizedBox(
                                                  height: SizeConfig
                                                          .blockSizeHorizontal *
                                                      7,
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    ViewRoomDevice(
                                                        'Curtains', argument);
                                                  },
                                                  child: Container(
                                                      child: Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: Image.asset(
                                                          'assets/curtains.png',
                                                          height: iconSize,
                                                          alignment: Alignment
                                                              .centerLeft,
                                                        ),
                                                        flex: 1,
                                                      ),
                                                      Expanded(
                                                          child: Text(
                                                            'Curtains',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontSize: 17.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                letterSpacing:
                                                                    1.0),
                                                          ),
                                                          flex: 4)
                                                    ],
                                                  )),
                                                ),
                                                SizedBox(
                                                  height: SizeConfig
                                                          .blockSizeHorizontal *
                                                      7,
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    ViewRoomDevice(
                                                        'Lights', argument);
                                                  },
                                                  child: Container(
                                                      child: Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: Image.asset(
                                                          'assets/light.png',
                                                          height: iconSize,
                                                          alignment: Alignment
                                                              .centerLeft,
                                                        ),
                                                        flex: 1,
                                                      ),
                                                      Expanded(
                                                          child: Text(
                                                            'Lights',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontSize: 17.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                letterSpacing:
                                                                    1.0),
                                                          ),
                                                          flex: 4)
                                                    ],
                                                  )),
                                                ),
                                                SizedBox(
                                                  height: SizeConfig
                                                          .blockSizeHorizontal *
                                                      7,
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    ViewRoomDevice(
                                                        'Power Outlets',
                                                        argument);
                                                  },
                                                  child: Container(
                                                      child: Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: Image.asset(
                                                          'assets/power.png',
                                                          height: iconSize,
                                                          alignment: Alignment
                                                              .centerLeft,
                                                        ),
                                                        flex: 1,
                                                      ),
                                                      Expanded(
                                                          child: Text(
                                                            'Power Outlets',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontSize: 17.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                letterSpacing:
                                                                    1.0),
                                                          ),
                                                          flex: 4)
                                                    ],
                                                  )),
                                                )
                                              ],
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      showWindow = false;
                                                      Navigate();
                                                    });
                                                  },
                                                  child: Container(
                                                    child: Text('',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            fontFamily:
                                                                'Montserrat',
                                                            letterSpacing: 1.0,
                                                            color: textColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600)),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: RaisedButton(
                                                  elevation: 10,
                                                  padding: EdgeInsets.only(
                                                      top: 25.0,
                                                      bottom: 25.0,
                                                      left: 25.0,
                                                      right: 25.0),
                                                  shape:
                                                      new RoundedRectangleBorder(
                                                    borderRadius:
                                                        new BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    20.0)),
                                                  ),
                                                  color: Color(0xFF191919),
                                                  onPressed: () {
                                                    showWindow = false;
                                                    Navigate();
//                                      SaveSceneSettings(arguments);
                                                  },
                                                  child: Text('BACK',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontFamily:
                                                              'Montserrat',
                                                          letterSpacing: 1.0,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w300)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ))))
                  ])),
              _topBar(context)
            ],
          ),
        ),
      ),
    );
  }
}

Widget _topBar(BuildContext context) {
  return Material(
    color: Colors.black.withOpacity(0),
    child: Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 8,
          vertical: SizeConfig.blockSizeVertical * 2),
      margin: EdgeInsets.symmetric(vertical: SizeConfig.blockSizeVertical * 4),
      width: double.maxFinite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          InkWell(
            child: Container(
                width: SizeConfig.blockSizeHorizontal * 10,
                height: SizeConfig.blockSizeHorizontal * 10,
                padding: EdgeInsets.all(0),
                decoration: BoxDecoration(
                  color: Color(0xFFF8F7F8),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: Offset(3, 6), // changes position of shadow
                    ),
                  ],
                ),
                child: Icon(
                  Icons.help,
                  size: 18,
                )),
            onTap: () {},
          )
        ],
      ),
    ),
  );
}
