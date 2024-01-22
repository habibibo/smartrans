import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:signgoogle/utils/api.dart';
import 'package:http/http.dart' as http;
import 'package:signgoogle/utils/basic_auth.dart';

class Payment_Method {
  Future<void> getPaymentMethod(
      String service, String total, String area) async {
    final data = {"service": service, "total": total, "area": area};
    var paymentMethodUrl =
        Uri.parse("${ApiNetwork().baseUrl}${To().updateUser}");
    final response = await http.post(
      paymentMethodUrl,
      headers: <String, String>{
        'Authorization': basicAuth,
        'Content-Type': "application/json; charset=UTF-8",
      },
      // use for this user
      //body: jsonEncode(<String, String>{'email': user!.email.toString()}),
      body: jsonEncode(data),
    );
    //SharedPreferences cacheUserModel = await SharedPreferences.getInstance();
    //cacheUserModel.setString("userModel", jsonEncode(data));
    print(response.body);
  }
}
