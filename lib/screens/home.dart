import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maskanismarthome/screens/about.dart';
import 'package:maskanismarthome/screens/control_panel.dart';
import 'package:maskanismarthome/style/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

//import 'about.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var UserName = 'Antony';
  Widget ViewPage = ControlPanel();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getName('full_name');
  }

  logOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }

  Future<String> getName(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String name = prefs.getString(key);
    print(name);
    setState(() {
      UserName = name.split(' ')[0];
    });

    return UserName;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SizeConfig().init(context);
    return Scaffold(
        backgroundColor: Color(0xFF222222),
        body: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                  left: SizeConfig.blockSizeHorizontal * 7.0,
                  top: SizeConfig.blockSizeVertical * 8.0,
                  bottom: SizeConfig.blockSizeVertical * 5.0),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Row(
                      children: <Widget>[
                        Image.asset(
                          'assets/avatar@2x.png',
                          height: 50.0,
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Hello, $UserName',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 20.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            )
                          ],
                        ))
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          setState(() {
                            ViewPage = ControlPanel();
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: SizeConfig.blockSizeVertical * 2.0,
                              horizontal: SizeConfig.blockSizeHorizontal * 2),
                          child: Text(
                            'Control Panel',
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 17.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            ViewPage = About();
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: SizeConfig.blockSizeVertical * 2.0,
                              horizontal: SizeConfig.blockSizeHorizontal * 2),
                          child: Text(
                            'Profile',
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 17.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: SizeConfig.blockSizeVertical * 2.0,
                              horizontal: SizeConfig.blockSizeHorizontal * 2),
                          child: Text(
                            'About',
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 17.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: SizeConfig.blockSizeVertical * 2.0,
                              horizontal: SizeConfig.blockSizeHorizontal * 2),
                          child: Text(
                            'Company',
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 17.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: SizeConfig.blockSizeVertical * 2.0,
                              horizontal: SizeConfig.blockSizeHorizontal * 2),
                          child: Text(
                            'Contact Us',
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 17.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                  Container(
                      child: InkWell(
                    onTap: () {
                      logOut();
                      Navigator.pushReplacementNamed(context, "/logout");
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.power_settings_new,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                        Container(
                          width: 1.0,
                          height: 20.0,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                        Text(
                          'Log Out',
                          style: TextStyle(
                              fontSize: 18.0,
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                              fontWeight: FontWeight.w800),
                        )
                      ],
                    ),
                  ))
                ],
              ),
            ),
            ViewPage
          ],
        ));
  }
}
