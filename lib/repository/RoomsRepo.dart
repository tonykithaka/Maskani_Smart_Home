import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:maskanismarthome/models/common.dart';
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
    var url = DotEnv().env['ROOT_API'] + "/users/fetchUserRooms";
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
      return RoomData.fromJson(jsonDecoded);
    } else {
      final responseJson = jsonDecode(response.body);
      return parseLoginJson(responseJson);
    }
  }

  Future<CommonData> registerUserRoom(
      String customer_id, String roomName, String roomImage) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString("token");
    var url = DotEnv().env['ROOT_API'] + "/users/createUserRoom";
    var response = (await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'id': customer_id,
        'imageUrl': roomImage,
        'roomName': roomName
      }),
    ));

    if (response.statusCode == 200) {
      final jsonDecoded = json.decode(response.body);
      print(jsonDecoded);
      return CommonData.fromJson(jsonDecoded);
    } else {
      final responseJson = jsonDecode(response.body);
      return CommonData.fromJson(responseJson);
    }
  }

  Future<String> uploadImage(File file) async {
    Dio dio = Dio();
    var url = DotEnv().env['CLOUDINARY_API'];
    print(url);
    FormData formData = new FormData.fromMap({
      "file": await MultipartFile.fromFile(
        file.path,
      ),
      "upload_preset": "kdamdo5d",
      "cloud_name": "dk8vuddno",
    });
    try {
      Response response = await dio.post(url, data: formData);

      var data = jsonDecode(response.toString());
      print(data['secure_url']);
      return data['secure_url'];
    } catch (e) {
      print(e);
    }
  }
}
