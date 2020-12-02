import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:maskanismarthome/models/user_information.dart';
import 'package:maskanismarthome/models/users.dart';

class Users {
  //Sign In
  Future<LoginData> SignIn(String email, String password) async {
    Map jsonMap = {"email": email, "password": password};
    var url = DotEnv().env['ROOT_API'] + "/users/login";

    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(jsonMap)));
    HttpClientResponse response = await request.close();
    // todo - you should check the response.statusCode
    if (response.statusCode == 200) {
      var reply = await response.transform(utf8.decoder).join();
      return parseLoginJson(reply);
    } else {
      var reply = await response.transform(utf8.decoder).join();
      return parseLoginJson(reply);
    }
  }

  //Sign Up
  Future<SignUpData> SignUp(String full_name, String email, String phone_number,
      String password) async {
    Map jsonMap = {
      "full_name": full_name,
      "email_address": email,
      "password": password,
      "phone_number": phone_number
    };
    var url = DotEnv().env['ROOT_API'] + "/users/createUser";

    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(jsonMap)));
    HttpClientResponse response = await request.close();
    // todo - you should check the response.statusCode
    if (response.statusCode == 200) {
      var reply = await response.transform(utf8.decoder).join();
      return parseSignUpJson(reply);
    } else {
      var reply = await response.transform(utf8.decoder).join();
      return parseSignUpJson(reply);
    }
  }

  //Fetch user information
  Future<UserInfo> FetchUserInfo(String user_id) async {
    Map jsonMap = {"user_id": user_id};
    var url = DotEnv().env['ROOT_API'] + "/users/fetchUserInformation";

    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(jsonMap)));
    HttpClientResponse response = await request.close();
    // todo - you should check the response.statusCode

    if (response.statusCode == 200) {
      var reply = await response.transform(utf8.decoder).join();
      return parseUserInfoJson(reply);
      httpClient.close();
    } else {
      var reply = await response.transform(utf8.decoder).join();
      print(reply);
      return parseUserInfoJson(reply);
    }
  }

  LoginData parseLoginJson(final response) {
    final jsonDecoded = json.decode(response);
    return LoginData.fromJson(jsonDecoded);
  }

  SignUpData parseSignUpJson(final response) {
    final jsonDecoded = json.decode(response);
    return SignUpData.fromJson(jsonDecoded);
  }

  UserInfo parseUserInfoJson(final response) {
    final jsonDecoded = json.decode(response);
    return UserInfo.fromJson(jsonDecoded);
  }
}
