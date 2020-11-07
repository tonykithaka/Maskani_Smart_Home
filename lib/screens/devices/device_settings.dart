import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_circular_slider/flutter_circular_slider.dart';
import 'package:maskanismarthome/models/rooms.dart';
import 'package:maskanismarthome/style/size_config.dart';

class DeviceSettings extends StatefulWidget {
  @override
  _DeviceSettingsState createState() => _DeviceSettingsState();
}

class _DeviceSettingsState extends State<DeviceSettings> {
  List<Color> _colors = [Color(0xffFFFFFF), Color(0xFFC1C1C1)];
  Color textColor = Color(0xFF333333);

  bool showWindow = false;
  bool toggleValue = false;
  bool toggleLightsValue = false;
  String windowStatus;
  String lightsStatus;
  String switchOne;
  String switchTwo;
  String switchThree;

  ShowContentContainer() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        this.showWindow = true;
      });
    });
  }

  ShowDeviceContainer(String deviceTitle) {
    switch (deviceTitle) {
      case 'Air Conditioner':
        {
          return TemperatureContainer();
        }
        break;

      case 'Curtains':
        {
          return CurtainDevices();
        }
        break;

      case 'Lights':
        {
          return LightDevices();
        }
        break;

      case 'Power Outlets':
        {
          return PowerDevices();
        }
        break;

      default:
        {
          return null;
        }
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    ShowContentContainer();
    setInitTemperature();
  }

  void _shuffle() {
    setState(() {
      initTime = 20;
      endTime = 30;
      inBedTime = initTime;
      outBedTime = endTime;
    });
  }

  setInitTemperature() {
    setState(() {
      initTime = 20;
      endTime = 30;
      inBedTime = initTime;
      outBedTime = endTime;
    });
  }

  Navigate() {
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
  }

  Widget TemperatureContainer() {
    return Stack(
      children: <Widget>[
        Container(
          alignment: Alignment.centerRight,
          child: Image.asset(
            'assets/temperature_bg.png',
            height: SizeConfig.blockSizeVertical * 60,
          ),
        ),
        Column(
          children: <Widget>[
            Container(
              width: double.maxFinite,
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockSizeHorizontal * 8,
                  vertical: SizeConfig.blockSizeVertical * 2),
              child: Text(
                'Drag the knobs to set temperature threshold.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 13.0),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Container(
              padding: EdgeInsets.all(20.0),
              child: DoubleCircularSlider(50, initTime, endTime,
                  height: 300.0,
                  width: 300.0,
                  baseColor: Color(0xFF333333),
                  selectionColor: baseColor,
                  handlerColor: Colors.white,
                  onSelectionChange: _updateLabels,
                  sliderStrokeWidth: 20.0,
                  child: Padding(
                    padding: const EdgeInsets.all(42.0),
                    child: Center(
                        child: Container(
                      width: SizeConfig.blockSizeVertical * 50,
                      height: SizeConfig.blockSizeVertical * 50,
                      decoration: new BoxDecoration(
                        color: Color(0xFF333333),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Current Temp.',
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                fontSize: 15.0),
                          ),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical * 2,
                          ),
                          Text(
                            '24' + ' C',
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                fontSize: 50.0),
                          ),
                        ],
                      ),
                    )),
                  )),
            ),
            SizedBox(
              height: SizeConfig.blockSizeVertical * 3,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _formatBedTime('MINIMUM', inBedTime),
              _formatBedTime('MAXIMUM', outBedTime),
            ]),
          ],
        ),
      ],
    );
  }

  Widget CurtainDevices() {
    return Stack(
      children: <Widget>[
        Container(
          alignment: Alignment.centerRight,
          child: Image.asset(
            'assets/window_bg.png',
            height: SizeConfig.blockSizeVertical * 50,
          ),
        ),
        Column(
          children: <Widget>[
            Container(
              width: double.maxFinite,
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockSizeHorizontal * 8,
                  vertical: SizeConfig.blockSizeVertical * 2),
              child: Text(
                'Flip switch to Open / Close curtains.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 13.0),
              ),
            ),
            SizedBox(
              height: SizeConfig.blockSizeVertical * 5,
            ),
            Container(
                padding: EdgeInsets.symmetric(
                    vertical: SizeConfig.blockSizeVertical * 15),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Center(
                          child: Text(
                        'Closed',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            fontSize: 20.0),
                      )),
                    ),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: toggleButton,
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          height: SizeConfig.blockSizeVertical * 7,
                          width: SizeConfig.blockSizeHorizontal * 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                SizeConfig.blockSizeVertical * 3.5),
                            color: toggleValue
                                ? Color(0xFF191919)
                                : Color(0xFF191919),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset:
                                    Offset(0, 5), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Stack(
                            children: <Widget>[
                              AnimatedPositioned(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.ease,
                                top: SizeConfig.blockSizeVertical * 1,
                                left: toggleValue
                                    ? SizeConfig.blockSizeHorizontal * 20
                                    : 0,
                                right: toggleValue
                                    ? 0
                                    : SizeConfig.blockSizeHorizontal * 20,
                                child: toggleValue
                                    ? Icon(
                                        Icons.check_circle_outline,
                                        color: Color(0xFFD4D4D4),
                                        size: SizeConfig.blockSizeVertical * 5,
                                        key: UniqueKey(),
                                      )
                                    : Icon(
                                        Icons.remove_circle_outline,
                                        color: Color(0xFFD4D4D4),
                                        size: SizeConfig.blockSizeVertical * 5,
                                        key: UniqueKey(),
                                      ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                          child: Text(
                        'Open',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            fontSize: 20.0),
                      )),
                    ),
                  ],
                )),
            SizedBox(
              height: SizeConfig.blockSizeVertical * 5,
            ),
            Expanded(
              flex: 1,
              child: Text(
                'Window is $windowStatus.',
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 20.0),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget LightDevices() {
    return Stack(
      children: <Widget>[
        Container(
          alignment: Alignment.centerRight,
          child: Image.asset(
            'assets/lights_bg.png',
            height: SizeConfig.blockSizeVertical * 50,
          ),
        ),
        Column(
          children: <Widget>[
            Container(
              width: double.maxFinite,
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockSizeHorizontal * 8,
                  vertical: SizeConfig.blockSizeVertical * 2),
              child: Text(
                'Flip switch to turn On / Off lights.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 13.0),
              ),
            ),
            SizedBox(
              height: SizeConfig.blockSizeVertical * 5,
            ),
            Container(
                padding: EdgeInsets.symmetric(
                    vertical: SizeConfig.blockSizeVertical * 15),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Center(
                          child: Text(
                        'On',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            fontSize: 20.0),
                      )),
                    ),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: toggleLightsButton,
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          height: SizeConfig.blockSizeVertical * 7,
                          width: SizeConfig.blockSizeHorizontal * 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                SizeConfig.blockSizeVertical * 3.5),
                            color: toggleLightsValue
                                ? Color(0xFF191919)
                                : Color(0xFF191919),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset:
                                    Offset(0, 5), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Stack(
                            children: <Widget>[
                              AnimatedPositioned(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.ease,
                                top: SizeConfig.blockSizeVertical * 1,
                                left: toggleLightsValue
                                    ? SizeConfig.blockSizeHorizontal * 20
                                    : 0,
                                right: toggleLightsValue
                                    ? 0
                                    : SizeConfig.blockSizeHorizontal * 20,
                                child: toggleLightsValue
                                    ? Icon(
                                        Icons.check_circle_outline,
                                        color: Color(0xFFD4D4D4),
                                        size: SizeConfig.blockSizeVertical * 5,
                                        key: UniqueKey(),
                                      )
                                    : Icon(
                                        Icons.remove_circle_outline,
                                        color: Color(0xFFD4D4D4),
                                        size: SizeConfig.blockSizeVertical * 5,
                                        key: UniqueKey(),
                                      ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                          child: Text(
                        'Off',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            fontSize: 20.0),
                      )),
                    ),
                  ],
                )),
            SizedBox(
              height: SizeConfig.blockSizeVertical * 5,
            ),
            Expanded(
              flex: 1,
              child: Text(
                'Lights $lightsStatus.',
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 20.0),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget PowerDevices() {
    return Stack(
      children: <Widget>[
        Container(
          alignment: Alignment.centerRight,
          child: Image.asset(
            'assets/Power_Outlets_bg.png',
            height: SizeConfig.blockSizeVertical * 50,
          ),
        ),
        Column(
          children: <Widget>[
            Container(
              width: double.maxFinite,
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockSizeHorizontal * 8,
                  vertical: SizeConfig.blockSizeVertical * 2),
              child: Text(
                'Flip switch to turn On / Off devices.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 13.0),
              ),
            ),
            SizedBox(
              height: SizeConfig.blockSizeVertical * 2,
            ),
            Container(
                padding: EdgeInsets.symmetric(
                    vertical: SizeConfig.blockSizeVertical * 0,
                    horizontal: SizeConfig.blockSizeHorizontal * 8),
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Row(
                        children: <Widget>[
                          Container(
                            child: Text('Switch 1',
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18.0)),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical * 2,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'On',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20.0),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: toggleLightsButton,
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            height: SizeConfig.blockSizeVertical * 7,
                            width: SizeConfig.blockSizeHorizontal * 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  SizeConfig.blockSizeVertical * 3.5),
                              color: toggleLightsValue
                                  ? Color(0xFF191919)
                                  : Color(0xFF191919),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(
                                      0, 5), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Stack(
                              children: <Widget>[
                                AnimatedPositioned(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                  top: SizeConfig.blockSizeVertical * 1,
                                  left: toggleLightsValue
                                      ? SizeConfig.blockSizeHorizontal * 20
                                      : 0,
                                  right: toggleLightsValue
                                      ? 0
                                      : SizeConfig.blockSizeHorizontal * 20,
                                  child: toggleLightsValue
                                      ? Icon(
                                          Icons.check_circle_outline,
                                          color: Color(0xFFD4D4D4),
                                          size:
                                              SizeConfig.blockSizeVertical * 5,
                                          key: UniqueKey(),
                                        )
                                      : Icon(
                                          Icons.remove_circle_outline,
                                          color: Color(0xFFD4D4D4),
                                          size:
                                              SizeConfig.blockSizeVertical * 5,
                                          key: UniqueKey(),
                                        ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Off',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical * 4,
                    ),
                    Container(
                      width: double.maxFinite,
                      height: 1.0,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical * 4,
                    ),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Container(
                            child: Text('Switch 2',
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18.0)),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical * 2,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'On',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20.0),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: toggleLightsButton,
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            height: SizeConfig.blockSizeVertical * 7,
                            width: SizeConfig.blockSizeHorizontal * 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  SizeConfig.blockSizeVertical * 3.5),
                              color: toggleLightsValue
                                  ? Color(0xFF191919)
                                  : Color(0xFF191919),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(
                                      0, 5), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Stack(
                              children: <Widget>[
                                AnimatedPositioned(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                  top: SizeConfig.blockSizeVertical * 1,
                                  left: toggleLightsValue
                                      ? SizeConfig.blockSizeHorizontal * 20
                                      : 0,
                                  right: toggleLightsValue
                                      ? 0
                                      : SizeConfig.blockSizeHorizontal * 20,
                                  child: toggleLightsValue
                                      ? Icon(
                                          Icons.check_circle_outline,
                                          color: Color(0xFFD4D4D4),
                                          size:
                                              SizeConfig.blockSizeVertical * 5,
                                          key: UniqueKey(),
                                        )
                                      : Icon(
                                          Icons.remove_circle_outline,
                                          color: Color(0xFFD4D4D4),
                                          size:
                                              SizeConfig.blockSizeVertical * 5,
                                          key: UniqueKey(),
                                        ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Off',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical * 4,
                    ),
                    Container(
                      width: double.maxFinite,
                      height: 1.0,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical * 4,
                    ),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Container(
                            child: Text('Switch 3',
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18.0)),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical * 2,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'On',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20.0),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: toggleLightsButton,
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            height: SizeConfig.blockSizeVertical * 7,
                            width: SizeConfig.blockSizeHorizontal * 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  SizeConfig.blockSizeVertical * 3.5),
                              color: toggleLightsValue
                                  ? Color(0xFF191919)
                                  : Color(0xFF191919),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(
                                      0, 5), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Stack(
                              children: <Widget>[
                                AnimatedPositioned(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                  top: SizeConfig.blockSizeVertical * 1,
                                  left: toggleLightsValue
                                      ? SizeConfig.blockSizeHorizontal * 20
                                      : 0,
                                  right: toggleLightsValue
                                      ? 0
                                      : SizeConfig.blockSizeHorizontal * 20,
                                  child: toggleLightsValue
                                      ? Icon(
                                          Icons.check_circle_outline,
                                          color: Color(0xFFD4D4D4),
                                          size:
                                              SizeConfig.blockSizeVertical * 5,
                                          key: UniqueKey(),
                                        )
                                      : Icon(
                                          Icons.remove_circle_outline,
                                          color: Color(0xFFD4D4D4),
                                          size:
                                              SizeConfig.blockSizeVertical * 5,
                                          key: UniqueKey(),
                                        ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Off',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical * 4,
                    ),
                    Container(
                      width: double.maxFinite,
                      height: 1.0,
                      color: Colors.black.withOpacity(0.5),
                    )
                  ],
                )),
          ],
        ),
      ],
    );
  }

  toggleButton() {
    setState(() {
      toggleValue = !toggleValue;
      toggleValue ? windowStatus = 'Open' : windowStatus = 'Closed';
    });
  }

  toggleLightsButton() {
    setState(() {
      toggleLightsValue = !toggleLightsValue;
      toggleLightsValue ? lightsStatus = 'On' : lightsStatus = 'Off';
    });
  }

  final baseColor = Color.fromRGBO(255, 255, 255, 0.3);

  int initTime = 0;
  int endTime = 0;

  int inBedTime;
  int outBedTime;

  _updateLabels(int init, int end, int test) {
    print(end);
    setState(() {
      inBedTime = init;
      outBedTime = end;
    });
  }

  Widget RoomSelector() {
    return Container(
      height: SizeConfig.blockSizeVertical * 7,
      width: double.maxFinite,
      alignment: Alignment.center,
      child: Text(
        'LIVING ROOM',
        style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            fontSize: 18.0,
            letterSpacing: 1.0),
      ),
    );
  }

  Widget TopBar(BuildContext context, DeviceSettingsData args) {
    return Container(
      height: SizeConfig.blockSizeVertical * 10,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 8,
          vertical: SizeConfig.blockSizeVertical * 2),
      margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 4),
      width: double.maxFinite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(args.deviceTitle,
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20.0,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF222222))),
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
    );
  }

  Widget _formatBedTime(String pre, int time) {
    return Column(
      children: [
        Text(pre,
            style: TextStyle(
                color: Color(0xFF222222),
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                fontSize: 16.0,
                letterSpacing: 2.0)),
        SizedBox(height: SizeConfig.blockSizeVertical * 1),
        Text(
          '${time}' + ' C',
          style: TextStyle(
              color: Color(0xFF222222),
              fontSize: 35.0,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final DeviceSettingsData args = ModalRoute.of(context).settings.arguments;
    print(args.deviceTitle);
    double maxHeight = MediaQuery.of(context).size.height;
    double maxWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
          child: Material(
        child: Stack(
          children: <Widget>[
            Container(
              child: Hero(
                tag: 'containerBackground',
                child: Material(
                  child: Container(
                    width: maxWidth,
                    height: maxHeight,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: _colors,
                            begin: FractionalOffset.topLeft,
                            end: FractionalOffset.bottomRight)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        TopBar(context, args),
                        RoomSelector(),
                        Expanded(
                          child: Container(
                            width: double.maxFinite,
                            child: ShowDeviceContainer(args.deviceTitle),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    Navigate();
                                  });
                                },
                                child: Container(
                                  padding:
                                      EdgeInsets.only(top: 25.0, bottom: 25.0),
                                  alignment: Alignment.center,
                                  child: Text('BACK',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontFamily: 'Montserrat',
                                          letterSpacing: 1.0,
                                          color: textColor,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: RaisedButton(
                                elevation: 10,
                                padding: EdgeInsets.only(
                                    top: 25.0,
                                    bottom: 25.0,
                                    left: 25.0,
                                    right: 25.0),
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.only(
                                      topLeft: Radius.circular(20.0)),
                                ),
                                color: Color(0xFF191919),
                                onPressed: () {},
                                child: Text('SAVE SETTINGS',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'Montserrat',
                                        letterSpacing: 1.0,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w300)),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
