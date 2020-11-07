import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:maskanismarthome/models/rooms.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Rooms {
  RoomData parseLoginJson(final response) {
    final jsonDecoded = json.decode(response);
    return RoomData.fromJson(jsonDecoded);
  }

  Future<RoomData> FetchUserRooms(String customer_id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString("token");
    var url = DotEnv().env['ROOT_API'] + "/users/fetchCustomerRooms";
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
      print(response.statusCode);
      final jsonDecoded = json.decode(response.body);
      print(jsonDecoded);
      return RoomData.fromJson(jsonDecoded);
    } else {
      final responseJson = jsonDecode(response.body);
      return parseLoginJson(responseJson);
    }
  }
}
