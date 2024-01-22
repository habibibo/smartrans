import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:signgoogle/model/user.dart';

class UserCache {
  UserModel getUserCache() {
    late UserModel userModel = UserModel();

    userModel.id = jsonDecode(cacheUser().toString())["id"];
    userModel.email = jsonDecode(cacheUser().toString())["email"];
    userModel.uid = jsonDecode(cacheUser().toString())["uid"];
    userModel.deposit = jsonDecode(cacheUser().toString())["deposit"];
    userModel.dataDriver = jsonDecode(cacheUser().toString())["data_driver"];
    userModel.dataAccount = jsonDecode(cacheUser().toString())["data_account"];
    userModel.location = jsonDecode(cacheUser().toString())["location"];
    userModel.point = jsonDecode(cacheUser().toString())["point"];
    userModel.transaction = jsonDecode(cacheUser().toString())["transaction"];
    userModel.rating = jsonDecode(cacheUser().toString())["rating"];
    userModel.token = jsonDecode(cacheUser().toString())["token"];
    return userModel;
  }

  Future<String> cacheUser() async {
    SharedPreferences cacheUser = await SharedPreferences.getInstance();
    return cacheUser.get("userModel").toString();
  }
}
