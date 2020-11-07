import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:maskanismarthome/models/common.dart';
import 'package:maskanismarthome/models/scenes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Scenes {
  ScenesData parseLoginJson(final response) {
    final jsonDecoded = json.decode(response);
    return ScenesData.fromJson(jsonDecoded);
  }

  Future<ScenesData> FetchUserScenes(String customer_id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString("token");
    var url = DotEnv().env['ROOT_API'] + "/users/fetchCustomerScenes";
    var response = (await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'customer_id': customer_id,
      }),
    ));

    if (response.statusCode == 200) {
      final jsonDecoded = json.decode(response.body);
      var test = ScenesData.fromJson(jsonDecoded).scenes;
      return ScenesData.fromJson(jsonDecoded);
    } else {
      final responseJson = jsonDecode(response.body);
      return parseLoginJson(responseJson);
    }
  }

  Future<CommonData> UpdateSceneData(String SceneId, String SceneName,
      String SceneStatus, String StartTime, String EndTime) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString("token");
    final String user_id = prefs.getString("user_id");
    var url = DotEnv().env['ROOT_API'] + "/users/UpdateSceneData";
    var response = (await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'customer_id': user_id,
        'scene_id': SceneId,
        'scene_name': SceneName,
        'scene_status': SceneStatus,
        'start_time': StartTime,
        'end_time': EndTime
      }),
    ));

    if (response.statusCode == 200) {
      final jsonDecoded = json.decode(response.body);
      print(jsonDecoded);
//      var test = CommonData.fromJson(jsonDecoded).scenes;
      return CommonData.fromJson(jsonDecoded);
    } else {
      final responseJson = jsonDecode(response.body);
//      return parseLoginJson(responseJson);
      return CommonData.fromJson(responseJson);
    }
  }
}
