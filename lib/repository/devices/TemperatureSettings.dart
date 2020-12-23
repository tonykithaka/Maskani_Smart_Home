import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:maskanismarthome/models/common.dart';
import 'package:maskanismarthome/models/temperature.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TemperatureSettings {
  TemperatureInfo parsePowerInfoJson(final response) {
    final jsonDecoded = json.decode(response);
    print(TemperatureInfo.fromJson(jsonDecoded));
    return TemperatureInfo.fromJson(jsonDecoded);
  }

  CommonData parseCommonDataJson(final response) {
    final jsonDecoded = json.decode(response);
    print(CommonData.fromJson(jsonDecoded));
    return CommonData.fromJson(jsonDecoded);
  }

  //Fetch Power Device Settings
  Future<TemperatureInfo> FetchTemperatureSettings(String sceneId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString("token");
    var url = DotEnv().env['ROOT_API'] + "/users/fetchSceneTemperatureSettings";
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
      return TemperatureInfo.fromJson(jsonDecoded);
    } else {
      final responseJson = jsonDecode(response.body);
      return parsePowerInfoJson(responseJson);
    }
  }

  //Fetch Power Device Settings
  Future<CommonData> updateTemperatureSettings(
      String sceneId, int minTemp, int maxTemp) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString("token");
    var url = DotEnv().env['ROOT_API'] + "/users/updateTemperatureSettings";
    var response = (await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'sceneId': sceneId,
        'minTemp': minTemp,
        'maxTemp': maxTemp
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
