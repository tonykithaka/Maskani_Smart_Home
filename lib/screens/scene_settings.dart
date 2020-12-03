import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maskanismarthome/models/common.dart';
import 'package:maskanismarthome/models/rooms.dart';
import 'package:maskanismarthome/models/scenes.dart';
import 'package:maskanismarthome/repository/Dialogs.dart';
import 'package:maskanismarthome/repository/RoomsRepo.dart';
import 'package:maskanismarthome/repository/scenes/Scenes.dart';
import 'package:maskanismarthome/style/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweetalert/sweetalert.dart';

class SceneSettings extends StatefulWidget {
  final Scene sceneData;
  const SceneSettings({Key key, this.sceneData}) : super(key: key);

  @override
  _SceneSettingsState createState() => _SceneSettingsState();
}

class _SceneSettingsState extends State<SceneSettings> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  CarouselController buttonCarouselController = CarouselController();
  double iconSize = SizeConfig.blockSizeHorizontal * 7;
  bool isSwitched;
  bool showWindow = false;

  Scene _sceneData;
  String backgroundImage;
  var buttonFunction;

  var sceneClass = new Scenes();

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  var roomsClass = new Rooms();

  List<Color> _colors = [Color(0xffFFFFFF), Color(0xFFC1C1C1)];
  Color textColor = Color(0xFF333333);

  @override
  void initState() {
    super.initState();
    this.backgroundImage = 'assets/timer.png';
    ShowContentContainer();
    _sceneData = widget.sceneData;
    this.buttonFunction = 'Go home';
  }

//  Showing page Content Drawer
  ShowContentContainer() {
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        this.showWindow = true;
      });
    });
  }

  //Navigate Back to Control Panel
  Navigate() {
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
  }

  printScene(Scene scene) {
    print(scene.endTime);
  }

  //Change device settings
  ConfigureDeviceDevice(String deviceTitle, String sceneId) async {
    final SharedPreferences prefs = await _prefs;
    RoomData roomData = await this.FetchRooms();
    List<Room> roomList = roomData.rooms;
    setState(() {
      this.backgroundImage = 'assets/timer.png';
      this.buttonFunction = 'Go home';
    });
    if (roomData.success == 1) {
      Navigator.pushNamed(context, "/device_setting",
          arguments: DeviceSettingsData(deviceTitle, sceneId, roomList));
    }
  }

  SaveSceneSettings(Scene scene) async {
    String SceneId = scene.sceneId;
    String SceneName = scene.sceneName;
    String SceneStatus = scene.status;
    String StartTime = scene.startTime;
    String Endtime = scene.endTime;
    String ImageUrl = scene.imageUrl;
    try {
      Dialogs.showLoadingDialog(context, _keyLoader); //invoking login
      CommonData sceneData = await sceneClass.UpdateSceneData(
          SceneId, SceneName, SceneStatus, StartTime, Endtime, ImageUrl);

      if (sceneData.success == 1) {
        print(sceneData.message);
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        SweetAlert.show(context,
            subtitle: sceneData.message, style: SweetAlertStyle.success);
      } else {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        SweetAlert.show(context,
            subtitle: sceneData.message, style: SweetAlertStyle.error);
      }
    } catch (error) {
      print(error);
    }
  }

  FetchRooms() async {
    final SharedPreferences prefs = await _prefs;
    String user_id = prefs.getString("user_id");
    try {
      RoomData scenesData = await roomsClass.FetchUserRooms(user_id);
      return scenesData;
    } catch (error) {
      print(error);
    }
  }

  validateCurrentPage(int index, BuildContext context) {
    print(index);
    if (index == 0) {
      setState(() {
        this.backgroundImage = 'assets/timer.png';
        this.buttonFunction = 'Go home';
      });
    } else {
      setState(() {
        this.backgroundImage = 'assets/settings.png';
        this.buttonFunction = 'Got to timer';
      });
    }
  }

  navigateToTimer() {
    buttonCarouselController.previousPage(
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  TimerCard(Scene arguments) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal * 7),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: double.maxFinite,
                child: Text(
                  'Tap clock to start and end time for a scene.',
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      fontSize: 13.0),
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical * 8,
              ),
              Text('Start Time',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                    color: textColor,
                    fontSize: 15.0,
                  )),
              SizedBox(
                height: SizeConfig.blockSizeVertical * 1,
              ),
              InkWell(
                child: Text(arguments.startTime.substring(0, 5),
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        color: textColor,
                        fontSize: 60.0,
                        letterSpacing: 0.0)),
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (BuildContext builder) {
                        return Container(
                          height:
                              MediaQuery.of(context).copyWith().size.height / 3,
                          color: Color(0XFFeeeeee),
                          padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.blockSizeHorizontal * 10,
                              vertical: SizeConfig.blockSizeVertical * 5),
                          child: CupertinoDatePicker(
                            initialDateTime: DateTime.now(),
                            onDateTimeChanged: (DateTime newdate) {
//                                                        print(newdate);
                              String formattedTime =
                                  DateFormat.Hm().format(newdate);
                              print(formattedTime);
                              setState(() {
                                arguments.startTime = formattedTime.toString();
                              });
                            },
                            use24hFormat: true,
                            maximumDate: new DateTime(2021, 12, 30),
                            minimumYear: 2018,
                            maximumYear: 2021,
                            minuteInterval: 1,
                            mode: CupertinoDatePickerMode.time,
                          ),
                        );
                      });
                },
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical * 2,
              ),
              Text('End Time',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                    color: textColor,
                    fontSize: 15.0,
                  )),
              SizedBox(
                height: SizeConfig.blockSizeVertical * 1,
              ),
              InkWell(
                child: Text(arguments.endTime.substring(0, 5),
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        color: textColor,
                        fontSize: 60.0,
                        letterSpacing: 0.0)),
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (BuildContext builder) {
                        return Container(
                          height:
                              MediaQuery.of(context).copyWith().size.height / 3,
                          color: Color(0XFFeeeeee),
                          padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.blockSizeHorizontal * 10,
                              vertical: SizeConfig.blockSizeVertical * 5),
                          child: CupertinoDatePicker(
                            initialDateTime: DateTime.now(),
                            onDateTimeChanged: (DateTime newdate) {
//                                                        print(newdate);
                              String formattedTime =
                                  DateFormat.Hm().format(newdate);
                              print(formattedTime);
                              setState(() {
                                arguments.endTime = formattedTime.toString();
                              });
                            },
                            use24hFormat: true,
                            maximumDate: new DateTime(2021, 12, 30),
                            minimumYear: 2018,
                            maximumYear: 2021,
                            minuteInterval: 1,
                            mode: CupertinoDatePickerMode.time,
                          ),
                        );
                      });
                },
              ),
            ],
          ),
        ),
        SizedBox(height: SizeConfig.blockSizeVertical * 5),
        InkWell(
          onTap: () {
            FetchRooms();
            buttonCarouselController.nextPage(
                duration: Duration(milliseconds: 500),
                curve: Curves.decelerate);
          },
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 5.0),
            width: double.maxFinite,
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  width: SizeConfig.blockSizeHorizontal * 12,
                  height: SizeConfig.blockSizeHorizontal * 12,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      border: Border.all(width: 2.0, color: Color(0xFF222222))),
                  child: Icon(Icons.edit, size: 20, color: Color(0xFF222222)),
                ),
                SizedBox(
                  height: SizeConfig.blockSizeHorizontal * 5,
                ),
                Text(
                  'Tap to configure rooms and devices.',
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13.0,
                      color: Color(0xff222222).withOpacity(0.9),
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  DeviceCard(Scene arguments) {
    return Container(
      width: double.maxFinite,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockSizeHorizontal * 7),
        child: Column(
          children: <Widget>[
            Container(
              width: double.maxFinite,
              child: Text(
                'Tap device to configure.',
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 14.0),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(
              height: SizeConfig.blockSizeVertical * 13,
            ),
            GestureDetector(
              onTap: () {
                ConfigureDeviceDevice('Air Conditioner', arguments.sceneId);
              },
              child: Container(
                  child: Row(
                children: <Widget>[
                  Expanded(
                    child: Image.asset(
                      'assets/temperature.png',
                      height: iconSize,
                      alignment: Alignment.centerLeft,
                    ),
                    flex: 1,
                  ),
                  Expanded(
                      child: Text(
                        'Air Conditioner',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700),
                      ),
                      flex: 4)
                ],
              )),
            ),
            SizedBox(
              height: SizeConfig.blockSizeHorizontal * 5,
            ),
            InkWell(
              onTap: () {
                ConfigureDeviceDevice('Curtains', arguments.sceneId);
              },
              child: Container(
                  child: Row(
                children: <Widget>[
                  Expanded(
                    child: Image.asset(
                      'assets/curtains.png',
                      height: iconSize,
                      alignment: Alignment.centerLeft,
                    ),
                    flex: 1,
                  ),
                  Expanded(
                      child: Text(
                        'Curtains',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700),
                      ),
                      flex: 4)
                ],
              )),
            ),
            SizedBox(
              height: SizeConfig.blockSizeHorizontal * 5,
            ),
            InkWell(
              onTap: () {
                ConfigureDeviceDevice('Lights', arguments.sceneId);
              },
              child: Container(
                  child: Row(
                children: <Widget>[
                  Expanded(
                    child: Image.asset(
                      'assets/light.png',
                      height: iconSize,
                      alignment: Alignment.centerLeft,
                    ),
                    flex: 1,
                  ),
                  Expanded(
                      child: Text(
                        'Lights',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700),
                      ),
                      flex: 4)
                ],
              )),
            ),
            SizedBox(
              height: SizeConfig.blockSizeHorizontal * 5,
            ),
            InkWell(
              onTap: () {
                ConfigureDeviceDevice('Power Outlets', arguments.sceneId);
              },
              child: Container(
                  child: Row(
                children: <Widget>[
                  Expanded(
                    child: Image.asset(
                      'assets/power.png',
                      height: iconSize,
                      alignment: Alignment.centerLeft,
                    ),
                    flex: 1,
                  ),
                  Expanded(
                      child: Text(
                        'Power Outlets',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700),
                      ),
                      flex: 4)
                ],
              )),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Scene arguments = _sceneData;
    if (arguments != null) {
      bool isSwitched = (arguments.status == 'Inactive') ? false : true;
      return Scaffold(
        body: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      color: Color(0xFF222222),
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 10), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Material(
                      child: Stack(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height,
                            width: double.maxFinite,
                            child: Hero(
                              tag: Text('hello' + arguments.sceneId),
                              child: Image.network(
                                arguments.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          AnimatedOpacity(
                            duration: Duration(milliseconds: 300),
                            opacity: (showWindow) ? 1.0 : 0.0,
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                              child:
                                  Container(color: Colors.white.withOpacity(0)),
                            ),
                          ),
                          AnimatedPositioned(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.fastOutSlowIn,
                            bottom: 0,
                            right: showWindow
                                ? 0
                                : -(SizeConfig.blockSizeHorizontal * 90),
                            width: SizeConfig.blockSizeHorizontal * 85,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  width: double.maxFinite,
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          SizeConfig.blockSizeHorizontal * 8,
                                      vertical:
                                          SizeConfig.blockSizeVertical * 2),
                                  child: Text(
                                    'Scene Settings',
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
                                  child: Material(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20.0)),
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
                                              horizontal: SizeConfig
                                                      .blockSizeHorizontal *
                                                  0,
                                              vertical:
                                                  SizeConfig.blockSizeVertical *
                                                      0),
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                  colors: _colors,
                                                  begin:
                                                      FractionalOffset.topLeft,
                                                  end: FractionalOffset
                                                      .bottomRight)),
                                          child: Stack(
                                            children: <Widget>[
                                              Container(
                                                height: double.maxFinite,
                                                width: double.maxFinite,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Image.asset(
                                                  this.backgroundImage,
                                                  alignment:
                                                      Alignment.centerRight,
                                                ),
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
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
                                                              child: Text(
                                                                arguments
                                                                    .sceneName,
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Montserrat',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color:
                                                                        textColor,
                                                                    fontSize:
                                                                        20.0,
                                                                    letterSpacing:
                                                                        1.0),
                                                              ),
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: <
                                                                  Widget>[
                                                                Switch(
                                                                  value:
                                                                      isSwitched,
                                                                  onChanged:
                                                                      (value) {
                                                                    if (value =
                                                                        true) {
                                                                      setState(
                                                                          () {
                                                                        print("If positive :: " +
                                                                            value.toString());
                                                                        arguments.status =
                                                                            'Active';
                                                                      });
                                                                    } else if (value =
                                                                        false) {
                                                                      setState(
                                                                          () {
                                                                        print("If negative :: " +
                                                                            value.toString());
                                                                        arguments.status =
                                                                            'Inactive';
                                                                      });
                                                                    }
                                                                    setState(
                                                                        () {
                                                                      isSwitched =
                                                                          !isSwitched;
                                                                    });
                                                                  },
                                                                  activeTrackColor:
                                                                      Colors
                                                                          .lightGreenAccent,
                                                                  activeColor:
                                                                      Colors
                                                                          .green,
                                                                ),
                                                                Text(
                                                                  arguments
                                                                      .status,
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Montserrat',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    color:
                                                                        textColor,
                                                                    fontSize:
                                                                        15.0,
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: SizeConfig
                                                                  .blockSizeVertical *
                                                              2,
                                                        ),
                                                        Container(
                                                          width:
                                                              double.maxFinite,
                                                          height: 2.0,
                                                          color: textColor
                                                              .withOpacity(0.3),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  CarouselSlider(
                                                    carouselController:
                                                        buttonCarouselController,
                                                    items: [
                                                      TimerCard(arguments),
                                                      DeviceCard(arguments)
                                                    ].map((i) {
                                                      return Builder(
                                                        builder: (BuildContext
                                                            context) {
                                                          return SingleChildScrollView(
                                                            child: Container(
                                                                constraints:
                                                                    BoxConstraints(
                                                                        minWidth:
                                                                            double
                                                                                .infinity),
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                margin: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            5.0),
                                                                child: i),
                                                          );
                                                        },
                                                      );
                                                    }).toList(),
                                                    options: CarouselOptions(
                                                        height: SizeConfig
                                                                .blockSizeVertical *
                                                            50,
                                                        viewportFraction: 1,
                                                        enableInfiniteScroll:
                                                            false,
                                                        initialPage: 0,
                                                        onPageChanged:
                                                            (index, reason) {
                                                          this.validateCurrentPage(
                                                              index, context);
                                                        }),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              showWindow =
                                                                  false;
                                                              if (this.buttonFunction ==
                                                                  'Go home') {
                                                                Navigate();
                                                              } else {
                                                                navigateToTimer();
                                                                setState(() {
                                                                  this.showWindow =
                                                                      true;
                                                                });
                                                              }
                                                            });
                                                          },
                                                          child: Container(
                                                            child: Text('BACK',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    fontFamily:
                                                                        'Montserrat',
                                                                    letterSpacing:
                                                                        1.0,
                                                                    color:
                                                                        textColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600)),
                                                          ),
                                                        ),
                                                      ),
                                                      RaisedButton(
                                                        elevation: 10,
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 25.0,
                                                                bottom: 25.0,
                                                                left: 25.0,
                                                                right: 25.0),
                                                        shape:
                                                            new RoundedRectangleBorder(
                                                          borderRadius:
                                                              new BorderRadius
                                                                      .only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          20.0)),
                                                        ),
                                                        color:
                                                            Color(0xFF191919),
                                                        onPressed: () {
                                                          SaveSceneSettings(
                                                              arguments);
                                                        },
                                                        child: Text(
                                                            'SAVE SETTINGS',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                fontFamily:
                                                                    'Montserrat',
                                                                letterSpacing:
                                                                    1.0,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300)),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              _topBar(context)
            ],
          ),
        ),
      );
    }
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
