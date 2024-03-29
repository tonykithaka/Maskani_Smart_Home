import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:maskanismarthome/models/hubs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Hubs {
  HubData parseHubsJson(final response) {
    final jsonDecoded = json.decode(response);
    print(HubData.fromJson(jsonDecoded));
    return HubData.fromJson(jsonDecoded);
  }

  Future<HubData> FetchHubDetails(String customer_id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString("token");
    var url = DotEnv().env['ROOT_API'] + "/users/fetchHubByClientId";
    var response = (await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'id': customer_id,
      }),
    ));

    if (response.statusCode == 200) {
      final jsonDecoded = json.decode(response.body);
      return HubData.fromJson(jsonDecoded);
    } else {
      final responseJson = jsonDecode(response.body);
      return parseHubsJson(responseJson);
    }
  }

  Future<HubData> LinkHubWithUser(String customer_id, String hubId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString("token");
    var url = DotEnv().env['ROOT_API'] + "/users/linkUserWithHub";
    var response = (await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{'id': customer_id, 'hubId': hubId}),
    ));

    if (response.statusCode == 200) {
      print(response.body);
      final jsonDecoded = json.decode(response.body);
      return HubData.fromJson(jsonDecoded);
    } else {
      final responseJson = jsonDecode(response.body);
      return parseHubsJson(responseJson);
    }
  }
}
