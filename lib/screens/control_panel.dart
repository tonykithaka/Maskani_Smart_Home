import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:intl/intl.dart';
import 'package:maskanismarthome/models/rooms.dart';
import 'package:maskanismarthome/models/scenes.dart';
import 'package:maskanismarthome/repository/RoomsRepo.dart';
import 'package:maskanismarthome/repository/scenes/Scenes.dart';
import 'package:maskanismarthome/screens/scene_settings.dart';
import 'package:maskanismarthome/style/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static bool showBottomDrawer = false;
  var threshold = 100;

  String UserName;
  String FieldName;
  String RoomTag;

  var scenesClass = new Scenes();
  var roomsClass = new Rooms();

  Future<String> getName(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String name = prefs.getString(key);
    setState(() {
      UserName = name.split(' ')[0];
    });

    return UserName;
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
      RoomData scenesData = await roomsClass.FetchUserRooms(user_id);
      print("data is for rooms " + scenesData.toString());
      return scenesData;
    } catch (error) {
      print(error);
    }
  }

  ViewScene(Scene sceneData) async {
//    Navigator.pushNamed(context, "/scene_setting", arguments: sceneData);

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

  ViewRoom(Room roomData) async {
    print(roomData.roomId);
    Navigator.pushNamed(context, "/room_setting", arguments: roomData);
  }

  Widget SceneCardsBuilder(BuildContext context) {
    return FutureBuilder(
        future: FetchScenes(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final ScenesData scenesData = snapshot.data;
            final List<Scene> sceneList = scenesData.scenes;

            return new Swiper(
              itemBuilder: (BuildContext context, int index) {
                Scene item = sceneList[index];
                return GestureDetector(
                  onTap: () {
                    this.ViewScene(item);
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
                          offset: Offset(0, 10), // changes position of shadow
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
                                  fit: BoxFit.cover,
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
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    item.sceneName,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Montserrat',
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 2),
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical:
                                            SizeConfig.blockSizeVertical * 2),
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
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getName('full_name');
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
                                  'Tap card to configure room devices',
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
                                    final List<Room> roomList = roomsData.rooms;
                                    return Container(
                                      height: SizeConfig.blockSizeVertical * 40,
                                      child: CarouselSlider(
                                        options: CarouselOptions(
                                          height:
                                              SizeConfig.blockSizeVertical * 35,
                                          viewportFraction: 0.5,
                                          initialPage: 0,
                                          enableInfiniteScroll: false,
                                          enlargeCenterPage: true,
                                          aspectRatio: 2.0,
                                          autoPlayAnimationDuration:
                                              Duration(milliseconds: 500),
                                          autoPlayCurve: Curves.fastOutSlowIn,
                                        ),
                                        items: roomList.map((i) {
                                          return Builder(
                                            builder: (BuildContext context) {
                                              return GestureDetector(
                                                onTap: () {
                                                  print(i.roomName);
                                                  ViewRoom(i);
                                                },
                                                child: Stack(
                                                  children: <Widget>[
                                                    Container(
                                                      height: SizeConfig
                                                              .blockSizeVertical *
                                                          35,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.2),
                                                            spreadRadius: 5,
                                                            blurRadius: 7,
                                                            offset: Offset(0,
                                                                10), // changes position of shadow
                                                          ),
                                                        ],
                                                      ),
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 0),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10)),
                                                        child: Image.network(
                                                          i.imageId,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: double.maxFinite,
                                                      decoration:
                                                          new BoxDecoration(
                                                              gradient:
                                                                  new LinearGradient(
                                                                      colors: [
                                                                        Colors
                                                                            .grey
                                                                            .withOpacity(0.0),
                                                                        Colors
                                                                            .black
                                                                            .withOpacity(0.8),
                                                                      ],
                                                                      begin: const FractionalOffset(
                                                                          0.0, 0.0),
                                                                      end: const FractionalOffset(
                                                                          0.0,
                                                                          1.0),
                                                                      stops: [
                                                                        0.0,
                                                                        1.0
                                                                      ],
                                                                      tileMode:
                                                                          TileMode
                                                                              .clamp),
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
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
                                                                fontSize: 16.0,
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
                                    );
                                  } else {
                                    // We can show the loading view until the data comes back.
                                    debugPrint('Step 1, build loading widget');
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
                                  onPressed: () {},
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
}
