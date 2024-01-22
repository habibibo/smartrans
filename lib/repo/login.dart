import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signgoogle/model/user.dart';
import 'package:signgoogle/repo/Authentication.dart';
import 'package:signgoogle/utils/api.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:signgoogle/utils/basic_auth.dart';

class LoginRepo {
  Future<bool> login(GoogleSignInAccount user) async {
    bool _isSigningIn = false;
    SharedPreferences cacheUserModel = await SharedPreferences.getInstance();
    AuthRepository authRepository = AuthRepository();
    var apiUrl = Uri.parse("${ApiNetwork().baseUrl}${To().login}");

    try {
      var response = await http.post(
        apiUrl,
        headers: <String, String>{
          'Authorization': basicAuth,
          'Content-Type': "application/json; charset=UTF-8",
        },
        // use for this user
        body: jsonEncode(<String, String>{'email': user!.email.toString()}),
      );
      print("sign params");
      //print(response.body);
      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          print("Data is empty");
        }

        var data = json.decode(response.body);
        print(data);
        String messageData = data['message'];
        print("messageData ${messageData}");
        if (messageData != "notfound") {
          final UserModel userModel = UserModel(
              id: data["data"]["id"],
              uid: data["data"]["uid"],
              email: data["data"]["email"],
              token: await FirebaseMessaging.instance.getToken(),
              dataAccount: data["data"]["data_account"],
              rating: data["data"]["rating"],
              dataDriver: data["data"]["data_driver"],
              location: data["data"]["location"],
              created: data["data"]["created"],
              deposit: data["data"]["deposit"],
              transaction: data["data"]["transaction"],
              point: data["data"]["point"]);
          cacheUserModel.setString("userModel", jsonEncode(userModel));
          updateUser(data["data"]);
          print("cache user model");
          print(cacheUserModel.get("userModel"));
          return true;
        } else {
          final registerData = {
            "email": user.email,
            "username": user.email,
            "name": user.displayName,
            "photoUrl": user.photoUrl,
            "token": await FirebaseMessaging.instance.getToken(),
            "countrycode": "62",
            "phoneno": "0",
            "verified_wa": 0,
            "verified_sms": 0
          };
          var registerUrl =
              Uri.parse("${ApiNetwork().baseUrl}${To().registerUser}");
          var registerUser = await http.post(
            registerUrl,
            headers: <String, String>{
              'Authorization': basicAuth,
              'Content-Type': "application/json; charset=UTF-8",
            },
            // use for this user
            //body: jsonEncode(<String, String>{'email': user!.email.toString()}),
            body: jsonEncode(registerData),
          );
          var registerUserResponse = jsonDecode(registerUser.body);
          final UserModel userModel = UserModel(
              id: registerUserResponse["data"]["id"],
              uid: registerUserResponse["data"]["uid"],
              email: registerUserResponse["data"]["email"],
              token: registerUserResponse["data"]["token"],
              dataAccount: registerUserResponse["data"]["data_account"],
              rating: registerUserResponse["data"]["rating"],
              dataDriver: registerUserResponse["data"]["data_driver"],
              location: registerUserResponse["data"]["location"],
              created: registerUserResponse["data"]["created"],
              deposit: registerUserResponse["data"]["deposit"],
              transaction: registerUserResponse["data"]["transaction"],
              point: registerUserResponse["data"]["point"]);
          cacheUserModel.setString("userModel", jsonEncode(userModel));
          print(cacheUserModel.get("userModel"));
          return true;
        }
      } else {
        await authRepository.signOutFromGoogle();
        print('Failed to fetch data: ${response.statusCode}');
        return false;
      }
    } catch (error) {
      await authRepository.signOutFromGoogle();
      print('Error: $error');
      return false;
    }
  }

  Future<void> updateUser(var userData) async {
    final data = {
      "id": userData["id"],
      "uid": userData["uid"],
      "email": userData["email"],
      "token": await FirebaseMessaging.instance.getToken(),
      "data_account": userData["data_account"],
      "rating": userData["rating"],
      "data_driver": userData["data_driver"],
      "location": userData["location"],
      "created": userData["created"],
      "deposit": userData["deposit"],
      "transaction": userData["transaction"],
      "point": userData["point"]
    };
    var updateUrl = Uri.parse("${ApiNetwork().baseUrl}${To().updateUser}");
    await http.post(
      updateUrl,
      headers: <String, String>{
        'Authorization': basicAuth,
        'Content-Type': "application/json; charset=UTF-8",
      },
      // use for this user
      //body: jsonEncode(<String, String>{'email': user!.email.toString()}),
      body: jsonEncode(data),
    );
    SharedPreferences cacheUserModel = await SharedPreferences.getInstance();
    cacheUserModel.setString("userModel", jsonEncode(data));
    print(userData["data_driver"]);
  }
}
