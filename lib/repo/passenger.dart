import 'dart:convert';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:signgoogle/model/driverlatlng.dart';
import 'package:signgoogle/model/location.dart';
import 'package:signgoogle/model/user.dart';
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

  Future<dynamic> assign(
      String uidTransaction, String tarif, String uidDriver) async {
    final data = {
      "uid": uidTransaction,
      "price_deal": tarif,
      "uid_driver": uidDriver
    };
    String resultRes = "";
    var changeStausUrl =
        Uri.parse("${ApiNetwork().baseUrl}${To().assignTransaction}");
    var response = await http.post(
      changeStausUrl,
      headers: <String, String>{
        'Authorization': basicAuth,
        'Content-Type': "application/json; charset=UTF-8",
      },
      // use for this user
      //body: jsonEncode(<String, String>{'email': user!.email.toString()}),
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  Future<dynamic> assignDriver(
      String uidTransaction, String tarif, String uidDriver) async {
    final messageData = {
      "to": uidDriver,
      "notification": {
        "title": "passenger assign",
        "body": {
          "type": "passenger_assign",
          "mode": "driver",
          "data": {
            "uid": uidTransaction,
          }
        }
      }
    };
    var response = await http.post(
      Uri.parse(ApiNetwork().sendFCM),
      headers: <String, String>{
        'Authorization':
            'key=AAAA6aaLav4:APA91bFvl-M6_aJ203ILj-nvJzvbP2w9w46aISycMVjnjEI1WYZrcXRJ-hLrj7C7HlL0pmYRShiPnuAZnHlkiMR7e2rOH0I1av9Nwk1g2BUv8O0HV4b4A4xrxN-sCF8ii4ifr5NZbFf-',
        'Content-Type': "application/json; charset=UTF-8",
      },
      // use for this user
      body: json.encode(messageData),
      encoding: Encoding.getByName('utf-8'),
    );
    return jsonDecode(response.body);
  }

  Future<dynamic> changeStatusTransaction(
      String uidTransaction, String status) async {
    final data = {"uid": uidTransaction, "statusnew": status};
    String resultRes = "";
    var changeStausUrl =
        Uri.parse("${ApiNetwork().baseUrl}${To().updateStatusTransaction}");
    var response = await http.post(
      changeStausUrl,
      headers: <String, String>{
        'Authorization': basicAuth,
        'Content-Type': "application/json; charset=UTF-8",
      },
      // use for this user
      //body: jsonEncode(<String, String>{'email': user!.email.toString()}),
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  /* Future<dynamic> assignDriver(
      UserModel userModel,
      List<Location> locationPassenger,
      String? orderDetail,
      DriverLatLng driverLatLng,
      String driverDetail) async {
    var kendaraanDriver =
        jsonDecode(userModel.dataDriver.toString())["kendaraan_driver"][0];

    final messageData = {
      "to": jsonDecode(driverDetail)["token_driver"],
      "notification": {
        "title": "bidding",
        "body": {
          "type": "proove_bid",
          "mode": "passenger",
          "data": {
            "id_passenger": userModel.uid,
            "nama_passenger":
                jsonDecode(userModel.dataAccount.toString())["username"],
            "id_driver": jsonDecode(driverDetail)["uid_driver"],
            "nama_driver": jsonDecode(driverDetail)["nama_driver"],
            "order_detail": orderDetail,
            "token_driver": jsonDecode(driverDetail)["token_driver"],
            "token_user": userModel.token,
          }
        }
      }
    };

    var response = await http.post(
      Uri.parse(ApiNetwork().sendFCM),
      headers: <String, String>{
        'Authorization':
            'key=AAAA6aaLav4:APA91bFvl-M6_aJ203ILj-nvJzvbP2w9w46aISycMVjnjEI1WYZrcXRJ-hLrj7C7HlL0pmYRShiPnuAZnHlkiMR7e2rOH0I1av9Nwk1g2BUv8O0HV4b4A4xrxN-sCF8ii4ifr5NZbFf-',
        'Content-Type': "application/json; charset=UTF-8",
      },
      // use for this user
      body: json.encode(messageData),
      encoding: Encoding.getByName('utf-8'),
    );
    print(response.body);
  } */

  /* Future<dynamic> assignToDriver(
      UserModel userModel, NotifListJob passenger, String? tarif) async {
    var kendaraanDriver =
        jsonDecode(userModel.dataDriver.toString())["kendaraan_driver"][0];
    String merk = kendaraanDriver["merk"];
    String jenis = kendaraanDriver["jenis"];
    String plat_no = kendaraanDriver["plat_no"];
    print(passenger);
    final messageData = {
      "to": userModel.token,
      "notification": {
        "title": "bidding",
        "body": {
          "type": "proove_bid",
          "mode": "passenger",
          "data": {
            "id_passenger": passenger.uid_user,
            "nama_passenger": passenger.nama_user,
            "id_driver": userModel.uid,
            "nama_driver":
                jsonDecode(userModel.dataAccount.toString())["username"],
            "jarak_tujuan": passenger.distance,
            "total_alamat": passenger.total_alamat,
            "foto_driver":
                jsonDecode(userModel.dataAccount.toString())["foto_akun"],
            "rating_driver":
                jsonDecode(userModel.rating.toString())["rating_driver"],
            "kendaraan": "${merk} ${jenis} ${plat_no}",
            "tarif": tarif == "" ? passenger.tarif : tarif,
            "bid": tarif == "" ? passenger.tarif : tarif,
            "jarak_driver": passenger.jarak_driver,
            "waktu_jemput": passenger.waktu_jemput,
            "pembayaran": passenger.pembayaran
          }
        }
      }
    };

    var response = await http.post(
      Uri.parse(ApiNetwork().sendFCM),
      headers: <String, String>{
        'Authorization':
            'key=AAAA6aaLav4:APA91bFvl-M6_aJ203ILj-nvJzvbP2w9w46aISycMVjnjEI1WYZrcXRJ-hLrj7C7HlL0pmYRShiPnuAZnHlkiMR7e2rOH0I1av9Nwk1g2BUv8O0HV4b4A4xrxN-sCF8ii4ifr5NZbFf-',
        'Content-Type': "application/json; charset=UTF-8",
      },
      // use for this user
      body: json.encode(messageData),
      encoding: Encoding.getByName('utf-8'),
    );
    print(response.body);
  } */
}
