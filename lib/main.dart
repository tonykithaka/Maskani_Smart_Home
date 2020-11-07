import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:maskanismarthome/screens/devices/device_settings.dart';
import 'package:maskanismarthome/screens/home.dart';
import 'package:maskanismarthome/screens/room_details.dart';
import 'package:maskanismarthome/screens/welcome.dart';

import 'animation_engine/pageSlideTransition.dart';

Future main() async {
  await DotEnv().load('.env');
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    routes: {
      '/': (context) => Welcome(),
      '/home': (context) => SlideInTransition(child: Home()),
      '/logout': (context) => SlideInTransition(child: Welcome()),
//      '/scene_setting': (context) => SceneSettings(Scene),
      '/room_setting': (context) => RoomDetails(),
      '/device_setting': (context) => DeviceSettings()
    },
  ));
}
