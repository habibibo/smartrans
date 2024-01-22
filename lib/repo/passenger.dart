import 'dart:convert';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:signgoogle/utils/api.dart';
import 'package:signgoogle/utils/basic_auth.dart';
import 'package:http/http.dart' as http;

class PassengerRepo {
  Future<void> updateUser(var userData) async {
    final data = {
      "id": userData["id"],
      "uid": userData["uid"],
      "email": userData["email"],
      "token": await FirebaseMessaging.instance.getToken(),
      "data_account": userData["data_account"],
      "rating": userData["rating"],
      "dataDriver": userData["data_driver"],
      "location": userData["location"],
      "created": userData["created"],
      "deposit": userData["deposit"],
      "transaction": userData["transaction"],
      "point": userData["point"]
    };
    var updateUrl = Uri.parse("${ApiNetwork().baseUrl}${To().updateUser}");
    var response = await http.post(
      updateUrl,
      headers: <String, String>{
        'Authorization': basicAuth,
        'Content-Type': "application/json; charset=UTF-8",
      },
      // use for this user
      //body: jsonEncode(<String, String>{'email': user!.email.toString()}),
      body: jsonEncode(data),
    );
    print(response.body);
  }
}
