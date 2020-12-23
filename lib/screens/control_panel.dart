import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:maskanismarthome/models/common.dart';
import 'package:maskanismarthome/models/hubs.dart';
import 'package:maskanismarthome/models/rooms.dart';
import 'package:maskanismarthome/models/scenes.dart';
import 'package:maskanismarthome/repository/Dialogs.dart';
import 'package:maskanismarthome/repository/RoomsRepo.dart';
import 'package:maskanismarthome/repository/devices/HubsRepo.dart';
import 'package:maskanismarthome/repository/scenes/Scenes.dart';
import 'package:maskanismarthome/screens/scene_settings.dart';
import 'package:maskanismarthome/style/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweetalert/sweetalert.dart';

class ControlPanel extends StatefulWidget {
  @override
  _ControlPanelState createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  double xOffset = 0.0;
  double yOffset = 0.0;
  double scaleFactor = 1;
  double containerRadius = 0.0;
  double spreadRadius = 0.0;
  double blurRadius = 0.0;
  bool isDrawerOpen = false;
  List<Color> _colors = [Color(0xff444444), Color(0xFF292929)];

  final linkHubFormKey = new GlobalKey<FormState>();
  final sceneDetailsFormKey = new GlobalKey<FormState>();
  final roomDetailsFormKey = new GlobalKey<FormState>();

  var hubIdController = TextEditingController();
  var sceneNameController = TextEditingController();
  var roomNameController = TextEditingController();

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  static bool showBottomDrawer = false;
  var threshold = 100;

  String UserName;
  String FieldName;
  String RoomTag;
  String hubId;
  String user_id;
  String final_message;
  String roomName;
  String sceneName;

  var scenesClass = new Scenes();
  var roomsClass = new Rooms();
  var hubsClass = new Hubs();

  bool checkEditDelete;
  String sceneAction;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.FetchHubDetails();
    getName('full_name');
    checkToken();
  }

  checkToken() async {
    final SharedPreferences prefs = await _prefs;
    String token = prefs.getString("token");
    bool hasExpired = JwtDecoder.isExpired(token);
    if (hasExpired) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();
    }
  }

  Future<String> getName(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String name = prefs.getString(key);
    setState(() {
      UserName = name.split(' ')[0];
    });

    return UserName;
  }

  //Confirm hub is linked to user account
  FetchHubDetails() async {
    final SharedPreferences prefs = await _prefs;
    String user_id = prefs.getString("user_id");
    try {
      HubData hubData = await hubsClass.FetchHubDetails(user_id);
      if (hubData.success == 0) {
        _addHubDialog();
      } else {}
    } catch (error) {
      print(error);
    }
  }

  // Validate and link user with hub
  validateHubRegistration(BuildContext context) async {
    final SharedPreferences prefs = await _prefs;
    if (hubIdController.text.isEmpty) {
      print('No validation');
    } else {
      print('Validating login form...');
      if (linkHubFormKey.currentState.validate()) {
        print("Validation successfull");
        linkHubFormKey.currentState.save();
        this.hubId = hubIdController.text;
        String userId = prefs.getString("user_id");

        LinkHubWithUser(context, userId, hubId);
      }
    }
  }

  //Pick sceneimage

  LinkHubWithUser(BuildContext context, String userId, String hubId) async {
    final SharedPreferences prefs = await _prefs;
    try {
      Dialogs.showLoadingDialog(context, _keyLoader); //invoking login
      HubData hubData = await hubsClass.LinkHubWithUser(userId, hubId);
      if (hubData.success == 1) {
        Navigator.pop(context);
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        SweetAlert.show(context,
            subtitle: hubData.message, style: SweetAlertStyle.success);
      } else if (hubData.success == 0) {
        Navigator.pop(context);
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        // SweetAlert.show(context,
        //     subtitle: hubData.message, style: SweetAlertStyle.error);

        SweetAlert.show(context,
            title: "Sorry!",
            subtitle: hubData.message,
            style: SweetAlertStyle.error,
            showCancelButton: false, onPress: (bool isConfirm) {
          if (isConfirm) {
            FetchHubDetails();
            return false;
          }
        });
      }
    } catch (error) {
      print(error);
    }
  }

  FetchScenes() async {
    final SharedPreferences prefs = await _prefs;
    String user_id = prefs.getString("user_id");
    try {
      ScenesData scenesData = await scenesClass.FetchUserScenes(user_id);
      return scenesData;
    } catch (error) {
      print(error);
    }
  }

  FetchRooms() async {
    final SharedPreferences prefs = await _prefs;
    String user_id = prefs.getString("user_id");
    try {
      RoomData roomsData = await roomsClass.FetchUserRooms(user_id);
      return roomsData;
    } catch (error) {
      print(error);
    }
  }

  ViewScene(Scene sceneData, bool checkEditDelete, String sceneAction) async {
    if (sceneData.status == 'No state') {
      _dialogSceneCall(context, sceneData, checkEditDelete, sceneAction);
    } else {
      Navigator.of(context).push(PageRouteBuilder(
        fullscreenDialog: true,
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return SceneSettings(sceneData: sceneData);
        },
        transitionsBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation, Widget child) {
          return FadeTransition(
            opacity:
                animation, // CurvedAnimation(parent: animation, curve: Curves.elasticInOut),
            child: child,
          );
        },
      ));
    }
  }

  EditScene(Scene sceneData, bool checkEditDelete, String sceneAction) async {
    if (sceneData.status == 'No state') {
      SweetAlert.show(context,
          subtitle: 'Sorry, this card cannot be edited or removed.',
          style: SweetAlertStyle.error);
    } else {
      _dialogSceneCall(context, sceneData, checkEditDelete, sceneAction);
    }
  }

  ViewRoom(Room roomData) async {
    print(roomData.roomId);
    Navigator.pushNamed(context, "/room_setting", arguments: roomData);
  }

  Widget SceneCardsBuilder(BuildContext context) {
    return FutureBuilder(
        future: FetchScenes(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return CircularProgressIndicator();
          } else if (snapshot.connectionState == ConnectionState.done) {
            final ScenesData scenesData = snapshot.data;
            final List<Scene> sceneList = scenesData.scenes.reversed.toList();

            return Column(
              children: [
                new Swiper(
                  itemBuilder: (BuildContext context, int index) {
                    Scene item = sceneList[index];
                    return GestureDetector(
                      onTap: () {
                        this.ViewScene(item, false, 'View');
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 10), // changes position of shadow
                            ),
                          ],
                        ),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Stack(
                              children: [
                                Container(
                                  height: double.maxFinite,
                                  child: Hero(
                                    tag: Text('hello' + item.sceneId),
                                    child: Image.network(
                                      item.imageUrl,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: double.maxFinite,
                                  decoration: new BoxDecoration(
                                    gradient: new LinearGradient(
                                        colors: [
                                          Colors.grey.withOpacity(0.0),
                                          Colors.black.withOpacity(0.8),
                                        ],
                                        begin: const FractionalOffset(0.0, 0.0),
                                        end: const FractionalOffset(0.0, 1.0),
                                        stops: [0.0, 1.0],
                                        tileMode: TileMode.clamp),
                                  ),
                                  padding: EdgeInsets.only(
                                      bottom: SizeConfig.blockSizeVertical * 3),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              onTap: () {
                                                EditScene(item, true, 'Edit');
                                              },
                                              child: Container(
                                                height: SizeConfig
                                                        .blockSizeHorizontal *
                                                    20,
                                                width: double.maxFinite,
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                      left: SizeConfig
                                                              .blockSizeHorizontal *
                                                          5),
                                                  height: SizeConfig
                                                          .blockSizeHorizontal *
                                                      20,
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Icon(
                                                    Icons.edit_outlined,
                                                    color: Colors.white,
                                                    size: 25.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              onTap: () {
                                                EditScene(item, true, 'Delete');
                                              },
                                              child: Container(
                                                height: SizeConfig
                                                        .blockSizeHorizontal *
                                                    20,
                                                width: double.maxFinite,
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                      right: SizeConfig
                                                              .blockSizeHorizontal *
                                                          5),
                                                  height: SizeConfig
                                                          .blockSizeHorizontal *
                                                      20,
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.white,
                                                    size: 30.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            item.sceneName.toUpperCase(),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Montserrat',
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: 2),
                                          ),
                                          Container(
                                            margin: EdgeInsets.symmetric(
                                                vertical: SizeConfig
                                                        .blockSizeVertical *
                                                    2),
                                            height: 0.5,
                                            width: 20.0,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            item.status,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Montserrat',
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 1),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )),
                      ),
                    );
                  },
                  itemCount: sceneList.length,
                  itemWidth: 250.0,
                  itemHeight: 400.0,
                  layout: SwiperLayout.TINDER,
                ),
                InkWell(
                    onTap: () {
                      setState(() {});
                    },
                    child: Container(
                        height: SizeConfig.blockSizeHorizontal * 15,
                        alignment: Alignment.center,
                        width: double.maxFinite,
                        child: Text(
                          'Tap here to Refresh Scenes',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF222222),
                            fontSize: 15.0,
                          ),
                        )))
              ],
            );
          } else {
            return Container(
                height: double.maxFinite,
                alignment: Alignment.center,
                child: CircularProgressIndicator());
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double heightDrawer = MediaQuery.of(context).size.height -
        (SizeConfig.blockSizeVertical * 40) +
        SizeConfig.blockSizeVertical * 10;
    double width = MediaQuery.of(context).size.width;
    return AnimatedContainer(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Color(0xFFF8F7F8),
        borderRadius: BorderRadius.circular(containerRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: spreadRadius,
            blurRadius: blurRadius,
            offset: Offset(0, 10), // changes position of shadow
          ),
        ],
        image: DecorationImage(
          image: AssetImage("assets/Welcome_Background@2x.png"),
          fit: BoxFit.fitWidth,
          alignment: Alignment.bottomCenter,
          colorFilter: new ColorFilter.mode(
              Colors.black.withOpacity(0.2), BlendMode.dstATop),
        ),
      ),
      transform: Matrix4.translationValues(xOffset, yOffset, 0)
        ..scale(scaleFactor),
      duration: Duration(milliseconds: 250),
      curve: Curves.decelerate,
      child: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockSizeHorizontal * 8,
                  vertical: 50.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      isDrawerOpen
                          ? InkWell(
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
                                        offset: Offset(
                                            3, 6), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios,
                                    size: 20,
                                  )),
                              onTap: () {
                                setState(() {
                                  xOffset = 0.0;
                                  yOffset = 0.0;
                                  scaleFactor = 1.0;
                                  isDrawerOpen = false;
                                  containerRadius = 0.0;
                                  spreadRadius = 0.0;
                                  blurRadius = 0.0;
                                });
                              },
                            )
                          : InkWell(
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
                                        offset: Offset(
                                            3, 6), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.menu,
                                    size: 20,
                                  )),
                              onTap: () {
                                setState(() {
                                  xOffset = 200.0;
                                  yOffset = 200.0;
                                  scaleFactor = 0.6;
                                  isDrawerOpen = true;
                                  containerRadius = 0.0;
                                  spreadRadius = 7.0;
                                  blurRadius = 12.0;
                                });
                              }),
                      Text(
                        'Control panel',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 20.0,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF222222)),
                      ),
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
                                  offset: Offset(
                                      3, 6), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.help,
                              size: 20,
                            )),
                        onTap: () {
                          _dialogHelpCall(context);
                        },
                      )
                    ],
                  ),
                  Container(
                    width: double.maxFinite,
                    padding: EdgeInsets.only(
                        top: SizeConfig.blockSizeVertical * 7,
                        bottom: SizeConfig.blockSizeVertical * 1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '${new DateFormat.yMMMMd().format(new DateTime.now())}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15.0),
                            ),
                            SizedBox(
                              height: 4.0,
                            ),
                            Text(
                              'Hello, $UserName',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 28.0),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 3,
                  ),
                  Container(
                    transform: Matrix4.translationValues(
                        0.0, SizeConfig.blockSizeVertical * 2, 0.0),
                    width: double.maxFinite,
                    child: Text(
                      'Scenes',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 18.0,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  SceneCardsBuilder(context),
                ],
              ),
            ),
          ),
          AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              bottom: (showBottomDrawer)
                  ? 0
                  : -(MediaQuery.of(context).size.height -
                      (SizeConfig.blockSizeVertical * 40)),
              child: GestureDetector(
                onPanEnd: (details) {
                  if (details.velocity.pixelsPerSecond.dy > threshold) {
                    this.setState(() {
                      showBottomDrawer = false;
                    });
                  } else if (details.velocity.pixelsPerSecond.dy < -threshold) {
                    this.setState(() {
                      showBottomDrawer = true;
                    });
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: Container(
                    height: heightDrawer,
                    width: width,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: _colors,
                            begin: FractionalOffset.topLeft,
                            end: FractionalOffset.bottomRight),
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    child: Column(
                      children: <Widget>[
                        Container(
                            width: double.maxFinite,
                            padding: EdgeInsets.symmetric(
                                vertical: SizeConfig.blockSizeVertical * 1),
                            height: SizeConfig.blockSizeVertical * 70,
                            child: Column(children: <Widget>[
                              Icon(
                                Icons.keyboard_arrow_up,
                                color: Color(
                                  0xFFF7F7F7,
                                ),
                                size: 30.0,
                              ),
                              Text('Rooms',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFfF7F7F7))),
                              SizedBox(
                                height: SizeConfig.blockSizeVertical * 4,
                              ),
                              Container(
                                child: Text(
                                  'Tap card to configure room',
                                  style: TextStyle(
                                      color: Color(0xFFF8F7F8),
                                      fontFamily: 'Montserrat',
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w300),
                                ),
                              ),
                              SizedBox(
                                height: SizeConfig.blockSizeVertical * 3,
                              ),
                              FutureBuilder(
                                future: FetchRooms(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    final RoomData roomsData = snapshot.data;
                                    final List<Room> roomList =
                                        roomsData.rooms.reversed.toList();
                                    return Column(
                                      children: [
                                        Container(
                                          height:
                                              SizeConfig.blockSizeVertical * 38,
                                          child: CarouselSlider(
                                            options: CarouselOptions(
                                              height:
                                                  SizeConfig.blockSizeVertical *
                                                      35,
                                              viewportFraction: 0.5,
                                              initialPage: 0,
                                              enableInfiniteScroll: false,
                                              enlargeCenterPage: true,
                                              aspectRatio: 2.0,
                                              autoPlayAnimationDuration:
                                                  Duration(milliseconds: 500),
                                              autoPlayCurve:
                                                  Curves.fastOutSlowIn,
                                            ),
                                            items: roomList.map((i) {
                                              return Builder(
                                                builder:
                                                    (BuildContext context) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      //check room data
                                                      if (i.roomName ==
                                                          'ADD ROOM') {
                                                        _dialogRoomCall(
                                                            context);
                                                      } else {
                                                        ViewRoom(i);
                                                      }
                                                    },
                                                    child: Stack(
                                                      children: <Widget>[
                                                        Container(
                                                          height: SizeConfig
                                                                  .blockSizeVertical *
                                                              35,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.2),
                                                                spreadRadius: 3,
                                                                blurRadius: 5,
                                                                offset: Offset(
                                                                    0,
                                                                    5), // changes position of shadow
                                                              ),
                                                            ],
                                                          ),
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      0),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            10)),
                                                            child:
                                                                Image.network(
                                                              i.imageUrl,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          width:
                                                              double.maxFinite,
                                                          decoration:
                                                              new BoxDecoration(
                                                                  gradient:
                                                                      new LinearGradient(
                                                                          colors: [
                                                                            Colors.grey.withOpacity(0.0),
                                                                            Colors.black.withOpacity(0.8),
                                                                          ],
                                                                          begin: const FractionalOffset(
                                                                              0.0,
                                                                              0.0),
                                                                          end: const FractionalOffset(
                                                                              0.0,
                                                                              1.0),
                                                                          stops: [
                                                                            0.0,
                                                                            1.0
                                                                          ],
                                                                          tileMode: TileMode
                                                                              .clamp),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              10))),
                                                          padding: EdgeInsets.only(
                                                              bottom: SizeConfig
                                                                      .blockSizeVertical *
                                                                  3),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              Text(
                                                                i.roomName
                                                                    .toUpperCase(),
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontFamily:
                                                                        'Montserrat',
                                                                    fontSize:
                                                                        16.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    letterSpacing:
                                                                        2),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                        InkWell(
                                            onTap: () {
                                              setState(() {});
                                            },
                                            child: Container(
                                                height: SizeConfig
                                                        .blockSizeHorizontal *
                                                    15,
                                                alignment: Alignment.center,
                                                width: double.maxFinite,
                                                child: Text(
                                                  'Tap here to Refresh Rooms',
                                                  style: TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    fontWeight: FontWeight.w300,
                                                    color: Color(0xFFCCCCCC),
                                                    fontSize: 15.0,
                                                  ),
                                                )))
                                      ],
                                    );
                                  } else {
                                    return CircularProgressIndicator();
                                  }
                                },
                              ),
                              Container(
                                child: RaisedButton(
                                  elevation: 20,
                                  padding: EdgeInsets.only(
                                      top: 15.0,
                                      bottom: 15.0,
                                      left: 25.0,
                                      right: 25.0),
                                  shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(10.0),
                                  ),
                                  color: Color(0xFF191919),
                                  onPressed: () {
                                    _dialogRoomCall(context);
                                  },
                                  child: Text('ADD ROOM',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontFamily: 'Montserrat',
                                          letterSpacing: 1.0,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w300)),
                                ),
                              ),
                            ]))
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  _addHubDialog() async {
    await showDialog<String>(
      barrierDismissible: false,
      context: context,
      child: new Container(
        padding: EdgeInsets.all(0.0),
        child: new AlertDialog(
          contentPadding: EdgeInsets.all(0.0),
          backgroundColor: Colors.grey[200],
          content: new Container(
            height: SizeConfig.blockSizeVertical * 30,
            padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: SizeConfig.blockSizeVertical * 2,
                    horizontal: SizeConfig.safeBlockHorizontal * 7,
                  ),
                  child: Text(
                    'Please input the Hub Code to link your app and the hub',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[900]),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.safeBlockHorizontal * 7),
                  child: Form(
                    key: linkHubFormKey,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage(
                            "assets/text_background.png",
                          ),
                        ),
                      ),
                      child: TextFormField(
                        controller: hubIdController,
                        validator: (val) => val.length == 0 || val == ""
                            ? "Enter your Hub ID"
                            : null,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            fontSize: 15.0),
                        decoration: InputDecoration(
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.transparent, width: 1.0),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            contentPadding: EdgeInsets.all(15.0),
                            hintText: 'Hub ID',
                            hintStyle: TextStyle(
                                letterSpacing: 0,
                                fontFamily: 'Montserrat',
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600),
                            prefixIcon: const Icon(
                              Icons.important_devices,
                              color: Color(0xFF222222),
                              size: 15.0,
                            ),
                            prefixIconConstraints: BoxConstraints(
                              minWidth: 30,
                              minHeight: 25,
                            ),
                            fillColor: Colors.transparent,
                            filled: true),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Container(
                  width: double.maxFinite,
                  alignment: Alignment.bottomRight,
                  child: InkWell(
                    onTap: () {
                      validateHubRegistration(context);
                    },
                    child: FractionallySizedBox(
                      widthFactor: 0.5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            bottomRight: Radius.circular(4.0)),
                        child: Container(
                          padding: EdgeInsets.all(20.0),
                          color: Color(0xFF222222),
                          alignment: Alignment.center,
                          child: Text('Submit'.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Montserrat',
                                  letterSpacing: 1.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _dialogSceneCall(BuildContext context, Scene sceneData,
      bool checkEditDelete, String sceneAction) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return _addSceneDialog(
              sceneData: sceneData,
              checkEditDelete: checkEditDelete,
              sceneAction: sceneAction);
        });
  }

  Future<void> _dialogRoomCall(BuildContext context) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return _addRoomDialog();
        });
  }

  Future<void> _dialogHelpCall(BuildContext context) {
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return _helpDialog();
        });
  }
}

class _addSceneDialog extends StatefulWidget {
  final Scene sceneData;
  final bool checkEditDelete;
  final String sceneAction;

  const _addSceneDialog(
      {Key key, this.sceneData, this.checkEditDelete, this.sceneAction})
      : super(key: key);

  @override
  __addSceneDialogState createState() => __addSceneDialogState();
}

class __addSceneDialogState extends State<_addSceneDialog> {
  File _sceneImage;
  bool checkImage = false;
  bool checkEditDelete = false;
  String sceneAction;

  String roomName;
  String sceneName;

  final linkHubFormKey = new GlobalKey<FormState>();
  final sceneDetailsFormKey = new GlobalKey<FormState>();
  final roomDetailsFormKey = new GlobalKey<FormState>();

  var hubIdController = TextEditingController();
  var sceneNameController = TextEditingController();
  var roomNameController = TextEditingController();

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  var scenesClass = new Scenes();
  var roomsClass = new Rooms();
  var controlPanel = new _ControlPanelState();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    CheckScene(widget.sceneData, widget.checkEditDelete, widget.sceneAction);
  }

  CheckScene(Scene scene, bool checkEditDelete, String sceneAction) {
    if (scene.sceneName != 'ADD SCENE') {
      setState(() {
        sceneNameController.text = scene.sceneName;
        this.checkEditDelete = checkEditDelete;
        this.sceneAction = sceneAction;
      });
      print('Scene Action' + this.sceneAction);
      print('CheckDelete Action' + this.checkEditDelete.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: EdgeInsets.all(0.0),
      child: new AlertDialog(
        contentPadding: EdgeInsets.all(0.0),
        backgroundColor: Colors.grey[200],
        content: SingleChildScrollView(
          child: new Container(
            height: this.checkImage || checkEditDelete
                ? SizeConfig.blockSizeVertical * 78
                : SizeConfig.blockSizeVertical * 50,
            padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: SizeConfig.blockSizeVertical * 2,
                    horizontal: SizeConfig.safeBlockHorizontal * 7,
                  ),
                  child: Text(
                    "Please enter Scene Name e.g. 'Im Home' and attach your favourite scene image.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[900]),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.safeBlockHorizontal * 7),
                  child: Form(
                    key: sceneDetailsFormKey,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 5.0),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: AssetImage(
                                "assets/text_background.png",
                              ),
                            ),
                          ),
                          child: TextFormField(
                            controller: sceneNameController,
                            validator: (val) => val.length == 0 || val == ""
                                ? "Enter your Scene Name e.g, 'Im Home'"
                                : null,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                                fontSize: 15.0),
                            decoration: InputDecoration(
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.transparent, width: 1.0),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                ),
                                contentPadding: EdgeInsets.all(15.0),
                                hintText: "Enter Scene Name",
                                hintStyle: TextStyle(
                                    letterSpacing: 0,
                                    fontFamily: 'Montserrat',
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600),
                                prefixIcon: const Icon(
                                  Icons.scanner,
                                  color: Color(0xFF222222),
                                  size: 15.0,
                                ),
                                prefixIconConstraints: BoxConstraints(
                                  minWidth: 30,
                                  minHeight: 25,
                                ),
                                fillColor: Colors.transparent,
                                filled: true),
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 5.0),
                              child: InkWell(
                                onTap: () {
                                  pickScenePhoto(ImageSource.camera);
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(vertical: 5.0),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.center,
                                        width:
                                            SizeConfig.blockSizeHorizontal * 12,
                                        height:
                                            SizeConfig.blockSizeHorizontal * 12,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8.0)),
                                            border: Border.all(
                                                width: 2.0,
                                                color: Color(0xFF222222))),
                                        child: Icon(Icons.camera_alt,
                                            size: 20, color: Color(0xFF222222)),
                                      ),
                                      SizedBox(
                                        height:
                                            SizeConfig.blockSizeHorizontal * 5,
                                      ),
                                      Text(
                                        'Take Photo',
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 13.0,
                                            color: Color(0xff222222)
                                                .withOpacity(0.9),
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 5.0),
                              child: InkWell(
                                onTap: () {
                                  var test =
                                      pickScenePhoto(ImageSource.gallery);
                                  print(test.toString());
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(vertical: 5.0),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.center,
                                        width:
                                            SizeConfig.blockSizeHorizontal * 12,
                                        height:
                                            SizeConfig.blockSizeHorizontal * 12,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8.0)),
                                            border: Border.all(
                                                width: 2.0,
                                                color: Color(0xFF222222))),
                                        child: Icon(Icons.image,
                                            size: 20, color: Color(0xFF222222)),
                                      ),
                                      SizedBox(
                                        height:
                                            SizeConfig.blockSizeHorizontal * 5,
                                      ),
                                      Text(
                                        'Attach Photo',
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 13.0,
                                            color: Color(0xff222222)
                                                .withOpacity(0.9),
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        checkImage
                            ? Container(
                                height: SizeConfig.blockSizeVertical * 30,
                                width: SizeConfig.blockSizeHorizontal * 40,
                                child: checkImage
                                    ? Image.file(
                                        _sceneImage,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset('assets/im_home.png'),
                              )
                            : checkEditDelete
                                ? Image.network(
                                    widget.sceneData.imageUrl,
                                    fit: BoxFit.cover,
                                    height: SizeConfig.blockSizeVertical * 30,
                                    width: SizeConfig.blockSizeHorizontal * 40,
                                  )
                                : SizedBox(height: 0)
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Container(
                  width: double.maxFinite,
                  alignment: Alignment.bottomRight,
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.all(20.0),
                            color: Colors.transparent,
                            alignment: Alignment.center,
                            child: Text('Cancel'.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Montserrat',
                                    letterSpacing: 1.0,
                                    color: Color(0xFF222222),
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            validateSceneRegistration(
                                context,
                                widget.sceneData.sceneId,
                                this.sceneAction,
                                this.checkEditDelete);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                bottomRight: Radius.circular(4.0)),
                            child: Container(
                              padding: EdgeInsets.all(20.0),
                              color: Color(0xFF222222),
                              alignment: Alignment.center,
                              child: Text('Submit'.toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: 'Montserrat',
                                      letterSpacing: 1.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500)),
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
      ),
    );
  }

  //Select photo
  Future<bool> pickScenePhoto(ImageSource source) async {
    final _picker = ImagePicker();
    PickedFile selectedPhoto = await _picker.getImage(source: source);

    setState(() {
      this.checkImage = true;
      this._sceneImage = File(selectedPhoto.path);
    });

    return this.checkImage;
  }

  ShowLoadingDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Center(
                  child: Column(children: [
                    Opacity(
                      child: Image.asset(
                        'assets/loader.gif',
                        colorBlendMode: BlendMode.multiply,
                      ),
                      opacity: 1,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Please Wait...",
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.7),
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                          fontSize: 18.0),
                    )
                  ]),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Validate and register new scene
  validateSceneRegistration(BuildContext context, String sceneId,
      String sceneAction, bool checkEditDelete) async {
    final SharedPreferences prefs = await _prefs;
    ShowLoadingDialog(context);
    if (sceneNameController.text.isEmpty) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      SweetAlert.show(context,
          subtitle: "Please enter the room name e.g. 'Living Room'",
          style: SweetAlertStyle.error);
    } else {
      if (sceneDetailsFormKey.currentState.validate()) {
        sceneDetailsFormKey.currentState.save();
        this.sceneName = sceneNameController.text;
        String userId = prefs.getString("user_id");

        if ((_sceneImage != null) || (widget.sceneData.imageUrl != null)) {
          if (checkEditDelete) {
            if (sceneAction == 'Edit') {
              try {
                if (_sceneImage == null) {
                  setState(() {
                    _sceneImage = widget.sceneData.imageUrl as File;
                  });
                }
                String sceneUrl = await scenesClass.uploadImage(_sceneImage);
                CommonData sceneData = await editUserScene(
                    context, userId, this.sceneName, sceneId, sceneUrl);
                if (sceneData.success == 1) {
                  controlPanel.FetchScenes();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  SweetAlert.show(context,
                      subtitle:
                          "Scene updated successfully, please click refresh list and tap the scene to configure.",
                      style: SweetAlertStyle.success);
                } else {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  SweetAlert.show(context,
                      subtitle: "Sorry, scene could not be created.",
                      style: SweetAlertStyle.error);
                }
              } catch (e) {
                Navigator.of(context).pop();
                SweetAlert.show(context,
                    subtitle:
                        "Sorry an error occured while uploading image, please try again.",
                    style: SweetAlertStyle.error);
              }
            } else if (sceneAction == 'Delete') {
              try {
                // String sceneUrl = await scenesClass.uploadImage(_sceneImage);
                CommonData sceneData = await deleteUserScene(
                    context, userId, this.sceneName, sceneId);
                if (sceneData.success == 1) {
                  controlPanel.FetchScenes();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  SweetAlert.show(context,
                      subtitle: sceneData.message,
                      style: SweetAlertStyle.success);
                } else {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  SweetAlert.show(context,
                      subtitle: "Sorry, scene could not be created.",
                      style: SweetAlertStyle.error);
                }
              } catch (e) {
                Navigator.of(context).pop();
                SweetAlert.show(context,
                    subtitle:
                        "Sorry an error occured while uploading image, please try again.",
                    style: SweetAlertStyle.error);
              }
            }
          } else {
            try {
              String sceneUrl = await scenesClass.uploadImage(_sceneImage);
              CommonData sceneData = await registerUserScene(
                  context, userId, this.sceneName, sceneUrl);
              if (sceneData.success == 1) {
                controlPanel.FetchScenes();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                SweetAlert.show(context,
                    subtitle:
                        "Scene created successfully, please click refresh list and tap the scene to configure.",
                    style: SweetAlertStyle.success);
              } else {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                SweetAlert.show(context,
                    subtitle: "Sorry, scene could not be created.",
                    style: SweetAlertStyle.error);
              }
            } catch (e) {
              Navigator.of(context).pop();
              SweetAlert.show(context,
                  subtitle:
                      "Sorry an error occured while uploading image, please try again.",
                  style: SweetAlertStyle.error);
            }
          }
        } else {
          Navigator.of(context).pop();
          SweetAlert.show(context,
              subtitle: "Please select an Photo to upload",
              style: SweetAlertStyle.error);
        }
      }
    }
  }

  Future<CommonData> registerUserScene(BuildContext context, String userId,
      String sceneName, String sceneImage) async {
    try {
      CommonData sceneData =
          await scenesClass.registerUserScene(userId, sceneName, sceneImage);
      if (sceneData.success == 1) {
        return sceneData;
      } else {
        return sceneData;
      }
    } catch (error) {
      print(error);
    }
  }

  Future<CommonData> editUserScene(BuildContext context, String userId,
      String sceneName, String sceneId, String sceneImage) async {
    try {
      CommonData sceneData = await scenesClass.editUserScene(
          userId, sceneName, sceneId, sceneImage);
      if (sceneData.success == 1) {
        return sceneData;
      } else {
        return sceneData;
      }
    } catch (error) {
      print(error);
    }
  }

  Future<CommonData> deleteUserScene(BuildContext context, String userId,
      String sceneName, String sceneId) async {
    try {
      CommonData sceneData =
          await scenesClass.deleteUserScene(userId, sceneName, sceneId);
      if (sceneData.success == 1) {
        return sceneData;
      } else {
        return sceneData;
      }
    } catch (error) {
      print(error);
    }
  }
}

class _addRoomDialog extends StatefulWidget {
  @override
  __addRoomDialogState createState() => __addRoomDialogState();
}

class __addRoomDialogState extends State<_addRoomDialog> {
  File _roomImage;
  bool checkImage = false;

  String roomName;
  String sceneName;

  final linkHubFormKey = new GlobalKey<FormState>();
  final sceneDetailsFormKey = new GlobalKey<FormState>();
  final roomDetailsFormKey = new GlobalKey<FormState>();

  var hubIdController = TextEditingController();
  var sceneNameController = TextEditingController();
  var roomNameController = TextEditingController();

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  var scenesClass = new Scenes();
  var roomsClass = new Rooms();
  var controlPanel = new _ControlPanelState();

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: EdgeInsets.all(0.0),
      child: new AlertDialog(
        contentPadding: EdgeInsets.all(0.0),
        backgroundColor: Colors.grey[200],
        content: SingleChildScrollView(
          child: new Container(
            height: this.checkImage
                ? SizeConfig.blockSizeVertical * 78
                : SizeConfig.blockSizeVertical * 50,
            padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: SizeConfig.blockSizeVertical * 2,
                    horizontal: SizeConfig.safeBlockHorizontal * 7,
                  ),
                  child: Text(
                    "Please enter Room Name e.g. 'Living Room' and attach your favourite room image.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[900]),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.safeBlockHorizontal * 7),
                  child: Form(
                    key: roomDetailsFormKey,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 5.0),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: AssetImage(
                                "assets/text_background.png",
                              ),
                            ),
                          ),
                          child: TextFormField(
                            controller: roomNameController,
                            validator: (val) => val.length == 0 || val == ""
                                ? "Enter your Room Name e.g, 'Living Room'"
                                : null,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                                fontSize: 15.0),
                            decoration: InputDecoration(
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.transparent, width: 1.0),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                ),
                                contentPadding: EdgeInsets.all(15.0),
                                hintText: "Enter Room Name",
                                hintStyle: TextStyle(
                                    letterSpacing: 0,
                                    fontFamily: 'Montserrat',
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600),
                                prefixIcon: const Icon(
                                  Icons.house,
                                  color: Color(0xFF222222),
                                  size: 15.0,
                                ),
                                prefixIconConstraints: BoxConstraints(
                                  minWidth: 30,
                                  minHeight: 25,
                                ),
                                fillColor: Colors.transparent,
                                filled: true),
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 5.0),
                              child: InkWell(
                                onTap: () {
                                  pickRoomPhoto(ImageSource.camera);
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(vertical: 5.0),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.center,
                                        width:
                                            SizeConfig.blockSizeHorizontal * 12,
                                        height:
                                            SizeConfig.blockSizeHorizontal * 12,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8.0)),
                                            border: Border.all(
                                                width: 2.0,
                                                color: Color(0xFF222222))),
                                        child: Icon(Icons.camera_alt,
                                            size: 20, color: Color(0xFF222222)),
                                      ),
                                      SizedBox(
                                        height:
                                            SizeConfig.blockSizeHorizontal * 5,
                                      ),
                                      Text(
                                        'Take Photo',
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 13.0,
                                            color: Color(0xff222222)
                                                .withOpacity(0.9),
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 5.0),
                              child: InkWell(
                                onTap: () {
                                  var test = pickRoomPhoto(ImageSource.gallery);
                                  print(test.toString());
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(vertical: 5.0),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.center,
                                        width:
                                            SizeConfig.blockSizeHorizontal * 12,
                                        height:
                                            SizeConfig.blockSizeHorizontal * 12,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8.0)),
                                            border: Border.all(
                                                width: 2.0,
                                                color: Color(0xFF222222))),
                                        child: Icon(Icons.image,
                                            size: 20, color: Color(0xFF222222)),
                                      ),
                                      SizedBox(
                                        height:
                                            SizeConfig.blockSizeHorizontal * 5,
                                      ),
                                      Text(
                                        'Attach Photo',
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 13.0,
                                            color: Color(0xff222222)
                                                .withOpacity(0.9),
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        checkImage
                            ? Container(
                                height: SizeConfig.blockSizeVertical * 30,
                                width: SizeConfig.blockSizeHorizontal * 40,
                                child: checkImage
                                    ? Image.file(
                                        _roomImage,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset('assets/im_home.png'),
                              )
                            : SizedBox(height: 0)
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Container(
                    width: double.maxFinite,
                    alignment: Alignment.bottomRight,
                    child: Container(
                      width: double.maxFinite,
                      alignment: Alignment.bottomRight,
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                padding: EdgeInsets.all(20.0),
                                alignment: Alignment.center,
                                child: Text('Cancel'.toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'Montserrat',
                                        letterSpacing: 1.0,
                                        color: Color(0xFF222222),
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                validateRoomRegistration(context);
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(4.0)),
                                child: Container(
                                  padding: EdgeInsets.all(20.0),
                                  color: Color(0xFF222222),
                                  alignment: Alignment.center,
                                  child: Text('Submit'.toUpperCase(),
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontFamily: 'Montserrat',
                                          letterSpacing: 1.0,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Clear sceneImage
  void _clearSceneImage() {
    setState(() {
      this._roomImage = null;
    });
  }

  //Select photo
  Future<bool> pickRoomPhoto(ImageSource source) async {
    _clearSceneImage();

    final _picker = ImagePicker();
    PickedFile selectedPhoto = await _picker.getImage(source: source);

    setState(() {
      this.checkImage = true;
      this._roomImage = File(selectedPhoto.path);
    });

    return this.checkImage;
  }

  ShowLoadingDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Center(
                  child: Column(children: [
                    Opacity(
                      child: Image.asset(
                        'assets/loader.gif',
                        colorBlendMode: BlendMode.multiply,
                      ),
                      opacity: 1,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Please Wait...",
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.7),
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                          fontSize: 18.0),
                    )
                  ]),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Validate and register new scene
  validateRoomRegistration(BuildContext context) async {
    final SharedPreferences prefs = await _prefs;
    ShowLoadingDialog(context);
    if (roomNameController.text.isEmpty) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      SweetAlert.show(context,
          subtitle: "Please enter the room name e.g. 'Living Room'",
          style: SweetAlertStyle.error);
    } else {
      if (roomDetailsFormKey.currentState.validate()) {
        roomDetailsFormKey.currentState.save();
        this.roomName = roomNameController.text;
        String userId = prefs.getString("user_id");

        if (_roomImage != null) {
          String roomUrl = await roomsClass.uploadImage(_roomImage);
          print(roomUrl);
          if (roomUrl != null) {
            CommonData roomData =
                await registerUserRoom(context, userId, this.roomName, roomUrl);
            if (roomData.success == 1) {
              // controlPanel.FetchScenes();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              SweetAlert.show(context,
                  subtitle:
                      "Room created successfully, please click the room card to configure.",
                  style: SweetAlertStyle.success);
            } else {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              SweetAlert.show(context,
                  subtitle: "Sorry, room could not be created.",
                  style: SweetAlertStyle.error);
            }
          } else {
            Navigator.of(context).pop();
            SweetAlert.show(context,
                subtitle:
                    "Sorry an error occurred while uploading image, please try again.",
                style: SweetAlertStyle.error);
          }
        } else {
          Navigator.of(context).pop();
          SweetAlert.show(context,
              subtitle: "Please select an Photo to upload",
              style: SweetAlertStyle.error);
        }
      }
    }
  }

  Future<CommonData> registerUserRoom(BuildContext context, String userId,
      String roomName, String roomImage) async {
    try {
      CommonData roomData =
          await roomsClass.registerUserRoom(userId, roomName, roomImage);
      if (roomData.success == 1) {
        return roomData;
      } else {
        return roomData;
      }
    } catch (error) {
      print(error);
    }
  }
}

class _helpDialog extends StatefulWidget {
  @override
  __helpDialogState createState() => __helpDialogState();
}

class __helpDialogState extends State<_helpDialog> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var contentPadding = EdgeInsets.symmetric(
      vertical: SizeConfig.blockSizeVertical * 1,
      horizontal: SizeConfig.blockSizeHorizontal * 5);

  var bigContentPadding = EdgeInsets.symmetric(
      vertical: SizeConfig.blockSizeVertical * 2,
      horizontal: SizeConfig.blockSizeHorizontal * 5);

  var contentText = TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      color: Colors.grey[800]);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: new AlertDialog(
            contentPadding: EdgeInsets.all(0.0),
            backgroundColor: Colors.white,
            content: Container(
              height: SizeConfig.blockSizeVertical * 80,
              width: SizeConfig.blockSizeHorizontal * 80,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          vertical: SizeConfig.blockSizeVertical * 2,
                          horizontal: SizeConfig.blockSizeHorizontal * 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Maskani Help Center',
                            style: TextStyle(
                                fontSize: 17.0,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w700),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 3,
                                    offset: Offset(
                                        0, 6), // changes position of shadow
                                  ),
                                ],
                              ),
                              height: SizeConfig.blockSizeVertical * 4,
                              width: SizeConfig.blockSizeVertical * 4,
                              child: Icon(Icons.close),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                        margin: contentPadding,
                        height: 1.0,
                        color: Color(0xFF222222)),
                    Container(
                      padding: contentPadding,
                      child: Column(
                        children: [
                          Text(
                              'Welcome to Maskani Smart Home Automation. To start up, you need to link you App '
                              'to the Control hub. That is done by entering the Hub Code on the box to the form'
                              ' that pops up and looks as shown below.',
                              style: contentText),
                          SizedBox(height: SizeConfig.blockSizeVertical * 2),
                          Image.asset('assets/hubRegiestration.png',
                              width: SizeConfig.blockSizeHorizontal * 60),
                          SizedBox(height: SizeConfig.blockSizeVertical * 2),
                        ],
                      ),
                    ),
                    Container(
                        margin: contentPadding,
                        height: 1.0,
                        color: Color(0xFF222222)),
                    Container(
                      padding: contentPadding,
                      child: Column(
                        children: [
                          Text(
                              'First, you need to create a scene. A scene is a period in which the hub will '
                              'react in relation to the time set. If the time set equals the current time, the '
                              'hub triggers the sensors and the devices attached according to the specifications set.'
                              'To set up a scene, please Tap on the card shown below, it is the first car that '
                              'you will see when you sign in for the first time. Fill in the form on the Popup by '
                              'adding the scene name and attaching your favourite photo of the scene, click submit '
                              'to save and the scene will be created, Tap the widget "Tap here to Refresh scenes" for '
                              'you scene to appear, click the scene to edit the scene details. You can also swipe Left '
                              'or Right to find your Scene card',
                              style: contentText),
                          SizedBox(height: SizeConfig.blockSizeVertical * 2),
                          Image.asset('assets/add_scene_screenshot.png',
                              width: SizeConfig.blockSizeHorizontal * 60),
                          SizedBox(height: SizeConfig.blockSizeVertical * 2),
                        ],
                      ),
                    ),
                    Container(
                        margin: contentPadding,
                        height: 1.0,
                        color: Color(0xFF222222)),
                    Container(
                      padding: contentPadding,
                      child: Column(
                        children: [
                          Text(
                              'Secondly, you need to add a room. To do this, drag the bottom black part of the Control Panel upwards to reveal the rooms Widget',
                              style: contentText),
                          SizedBox(height: SizeConfig.blockSizeVertical * 2),
                          Image.asset('assets/roomsWidget.png',
                              width: SizeConfig.blockSizeHorizontal * 60),
                          SizedBox(height: SizeConfig.blockSizeVertical * 2),
                          Text(
                              "Click the 'ADD ROOM' to create a Room e.g. Living Room. Fill up the Pop Up form by adding a "
                              "Room Name and Attach your Favourite Image of the room. Click Submit to save. You can now tap "
                              "the Widget 'Tap Here to Refresh Rooms' and your newly created room will appear.",
                              style: contentText),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }
}
