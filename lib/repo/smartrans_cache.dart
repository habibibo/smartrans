import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signgoogle/model/user.dart';
import 'package:signgoogle/utils/api.dart';
import 'package:http/http.dart' as http;
import 'package:signgoogle/utils/basic_auth.dart';

class SmartransCache {
  Future<UserModel> getUserModel() async {
    SharedPreferences uid = await SharedPreferences.getInstance();
    UserModel user = UserModel();
    getUser().then((value) {
      user = UserModel.fromJson(value);
    });
    print("smart cache");
    print(jsonEncode(user));
    return user;
  }

  Future<dynamic> getUser() async {
    SharedPreferences uid = await SharedPreferences.getInstance();
    UserModel user = UserModel();
    final data = {"uid": uid.getString("uid").toString()};
    final getUserUrl = Uri.parse("${ApiNetwork().baseUrl}${To().getUser}");
    var response = await http.post(
      getUserUrl,
      headers: <String, String>{
        'Authorization': basicAuth,
        'Content-Type': "application/json; charset=UTF-8",
      },
      body: jsonEncode(data),
    );
    SharedPreferences cacheUserModel = await SharedPreferences.getInstance();
    cacheUserModel.setString(
        "userModel", jsonDecode(response.body)["data"].toString());
    return jsonDecode(response.body)["data"];
  }
}
