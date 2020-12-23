import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:maskanismarthome/models/common.dart';
import 'package:maskanismarthome/models/powerDevices.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PowerDeviceSettings {
  PowerInfo parsePowerInfoJson(final response) {
    final jsonDecoded = json.decode(response);
    print(PowerInfo.fromJson(jsonDecoded));
    return PowerInfo.fromJson(jsonDecoded);
  }

  CommonData parseCommonDataJson(final response) {
    final jsonDecoded = json.decode(response);
    print(CommonData.fromJson(jsonDecoded));
    return CommonData.fromJson(jsonDecoded);
  }

  //Fetch Power Device Settings
  Future<PowerInfo> FetchPowerDeviceSettings(String sceneId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString("token");
    var url = DotEnv().env['ROOT_API'] + "/users/fetchSceneDeviceSettings";
    var response = (await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'sceneId': sceneId,
      }),
    ));

    if (response.statusCode == 200) {
      final jsonDecoded = json.decode(response.body);
      return PowerInfo.fromJson(jsonDecoded);
    } else {
      final responseJson = jsonDecode(response.body);
      return parsePowerInfoJson(responseJson);
    }
  }

  //Fetch Power Device Settings
  Future<CommonData> updatePowerDevicesSettings(
      String sceneId,
      bool switchOne,
      bool switchTwo,
      bool switchThree,
      bool toggleLightsValue,
      bool toggleCurtainsValue) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString("token");
    var url = DotEnv().env['ROOT_API'] + "/users/updatePowerDeviceSettings";
    var response = (await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'sceneId': sceneId,
        'switchOne': switchOne.toString(),
        'switchTwo': switchTwo.toString(),
        'switchThree': switchThree.toString(),
        'toggleLightsValue': toggleLightsValue.toString(),
        'toggleCurtainsValue': toggleCurtainsValue.toString()
      }),
    ));

    if (response.statusCode == 200) {
      final jsonDecoded = json.decode(response.body);
      return CommonData.fromJson(jsonDecoded);
    } else {
      final responseJson = jsonDecode(response.body);
      return parseCommonDataJson(responseJson);
    }
  }
}
