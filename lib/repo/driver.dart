import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signgoogle/model/driverlatlng.dart';
import 'package:signgoogle/model/kendaraan_driver.dart';
import 'package:signgoogle/model/notif/notif_list_job.dart';
import 'package:signgoogle/model/user.dart';
import 'package:signgoogle/utils/api.dart';
import 'package:signgoogle/utils/basic_auth.dart';

class DriverRepo {
  Future<UserModel> getProfile() async {
    SharedPreferences uid = await SharedPreferences.getInstance();
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
    return UserModel.fromJson(jsonDecode(response.body)["data"]);
  }

  Future<dynamic> changeStatus(String uid, String status, String area) async {
    final data = {"uid": uid, "status": status, "geofence": area.toLowerCase()};
    var changeStausUrl =
        Uri.parse("${ApiNetwork().baseUrl}${To().onoffDriver}");
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
    return response.body;
  }

  Future<dynamic> updateLocation(String uid, String latitude, String longitude,
      String bearing, String area) async {
    print("prepare update lokasi");
    print(DateTime.now().toString());
    final data = {
      "uid": uid,
      "location": {
        "latitude": latitude,
        "longitude": longitude,
        "bearing": bearing,
        "geofence": area.toLowerCase(),
        "updated": DateTime.now().toString()
      }
    };
    var updateLocationUrl =
        Uri.parse("${ApiNetwork().baseUrl}${To().updateLocation}");
    var response = await http.post(
      updateLocationUrl,
      headers: <String, String>{
        'Authorization': basicAuth,
        'Content-Type': "application/json; charset=UTF-8",
      },
      // use for this user
      //body: jsonEncode(<String, String>{'email': user!.email.toString()}),
      body: jsonEncode(data),
    );
    return response.body;
  }

  Future<dynamic> getTransaction(String uidTransaction) async {
    final data = {"uid": uidTransaction};
    var getTransactionUrl =
        Uri.parse("${ApiNetwork().baseUrl}${To().getTransaction}");
    var response = await http.post(
      getTransactionUrl,
      headers: <String, String>{
        'Authorization': basicAuth,
        'Content-Type': "application/json; charset=UTF-8",
      },
      // use for this user
      //body: jsonEncode(<String, String>{'email': user!.email.toString()}),
      body: jsonEncode(data),
    );
    //print(response.body);
    return response.body;
  }

  Future<dynamic> acceptWithoutNego(
      UserModel userModel, NotifListJob passenger) async {
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
            "tarif": passenger.tarif,
            "bid": passenger.tarif,
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
  }

  Future<dynamic> acceptBid(UserModel userModel, NotifListJob passenger,
      String? tarif, DriverLatLng driverLatLng, UserModel user) async {
    var kendaraanDriver = jsonDecode(
        jsonDecode(userModel.dataDriver.toString())["kendaraan_driver"])[0];
    String merk = kendaraanDriver["merk"];
    String jenis = kendaraanDriver["jenis"];
    String plat_no = kendaraanDriver["plat_no"];
    print(userModel.token);
    print(passenger.token_user);

    /* final newMessageData = {
  "to": "c1sVi0P2RSS6pApJJNHjtK:APA91bGJhdTmQ2NOZFg0ClAQDKz-GPcte1nbTTmWkGZKP9SxfDmxDoWxZdeTNf3g5yS8gVKptoPsz-w7VeAGB5AwQBlEyiSzbVkFMgqklCN6A92jyzQGaWrchddXQtGsbtVI0Sq6HDLX",
  "notification": {
    "title": "bidding",
    "body": {
      "type": "proove_bid",
      "mode": "driver",
      "data": 
        [{
          "id_passenger": "cqBHquQOR7aXEHtHg5Zs8j:APA91bG0uAlsDkpPPttOjH4-OmKUb9GkGMzV509TkkTfIfQ65ZWKKGk3KM6QEYfcjdh6LByfGmZXVeu3ZAZqrvzFxqpwZXc2sqWObmmQ0IQluuaZmWWugsl3rLxLHCvyRdl_src7Qp3O",
          "nama_passenger": "paijo",
          "id_driver": "cqBHquQOR7aXEHtHg5Zs8j:APA91bG0uAlsDkpPPttOjH4-OmKUb9GkGMzV509TkkTfIfQ65ZWKKGk3KM6QEYfcjdh6LByfGmZXVeu3ZAZqrvzFxqpwZXc2sqWObmmQ0IQluuaZmWWugsl3rLxLHCvyRdl_src7Qp3O",
          "nama_driver": "paijo",
          "jarak_tujuan": "25000",
          "total_alamat": 2,
          "foto_driver": "https://cdn-icons-png.flaticon.com/512/1581/1581908.png",
          "rating_driver": "5.0",
          "kendaraan": "Toyota Grand New Avanza, L4323WO",
          "driverLatLng" : "{\"lat\": 12.345, \"lng\": 67.890}",
          "tarif": 50000,
          "bid": 40000,
          "jarak_driver": 5400,
          "waktu_jemput": 300,
          "pembayaran":"QRIS"
        }]
      
    }
  }
}; */
    final messageData = {
      "to": passenger.token_user,
      "notification": {
        "title": "bidding",
        "body": {
          "type": "proove_bid",
          "mode": "driver",
          "data": {
            "id_passenger": passenger.uid_user,
            "nama_passenger": passenger.nama_user,
            "total_alamat": passenger.total_alamat,
            "tarif": tarif == "" ? passenger.tarif : tarif,
            "bid": tarif == "" ? passenger.tarif : tarif,
            "id_driver": userModel.uid,
            "nama_driver": user.email,
            "foto_driver":
                jsonDecode(userModel.dataAccount.toString())["foto_akun"]
                    .toString(),
            "rating_driver": "",
            "kendaraan": "${merk} ${jenis} ${plat_no}",
            "driverLatLng": jsonEncode(driverLatLng),
            "jarak_tujuan": passenger.distance,
            "jarak_driver": passenger.jarak_driver,
            "waktu_jemput": passenger.waktu_jemput,
            "pembayaran": passenger.pembayaran,
            "token_driver": userModel.token,
            "token_user": passenger.token_user,
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
  }
}
