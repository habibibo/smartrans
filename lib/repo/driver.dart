import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:signgoogle/model/driverlatlng.dart';
import 'package:signgoogle/model/notif/notif_list_job.dart';
import 'package:signgoogle/model/user.dart';
import 'package:signgoogle/utils/api.dart';
import 'package:signgoogle/utils/basic_auth.dart';

class DriverRepo {
  dynamic changeStatus(String uid, String status) async {
    final data = {"uid": uid, "status": status};
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
    return jsonDecode(response.body);
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
      String? tarif, DriverLatLng driverLatLng) async {
    var kendaraanDriver =
        jsonDecode(userModel.dataDriver.toString())["kendaraan_driver"][0];
    String merk = kendaraanDriver["merk"];
    String jenis = kendaraanDriver["jenis"];
    String plat_no = kendaraanDriver["plat_no"];
    print(passenger);
    final messageData = {
      "to": passenger.token_user,
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
            "driverLatLng": driverLatLng,
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
  }
}
