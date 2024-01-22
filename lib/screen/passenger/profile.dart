import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:logo_n_spinner/logo_n_spinner.dart';
import 'package:phonecodes/phonecodes.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:signgoogle/model/user.dart';
import 'package:signgoogle/repo/passenger.dart';
import 'package:signgoogle/repo/login.dart';
import 'package:signgoogle/utils/SmartransColor.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel userModel;
  const ProfileScreen({Key? key, required this.userModel}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController dateBirthController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  String countryCode = "";
  String foto_akun = "";

  @override
  void initState() {
    super.initState();
    var jsonUserModel = jsonEncode(widget.userModel.toJson());
    print(jsonDecode(jsonDecode(jsonUserModel)["data_account"])["phone"]
        ["countrycode"]);

    dateBirthController.text =
        jsonDecode(jsonDecode(jsonUserModel)["data_account"])["tanggal_lahir"];
    countryCode = jsonDecode(jsonDecode(jsonUserModel)["data_account"])["phone"]
        ["countrycode"];
    print(Countries.findByDialCode("+${countryCode}").first.flag);
    phoneController.text =
        jsonDecode(jsonDecode(jsonUserModel)["data_account"])["phone"]
            ["phoneno"];
    foto_akun =
        jsonDecode(jsonDecode(jsonUserModel)["data_account"])["foto_akun"];
    //print(jsonDecode(widget.userModel.dataAccount.toString())["phone"]
    //    ["phoneno"]);
    print(foto_akun);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 30, left: 5, right: 5),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  color: primaryColor),
              child: Card(
                color: primaryColor,
                child: Container(
                  padding: EdgeInsets.only(
                    left: 8,
                    right: 15,
                    top: 10,
                    bottom: 10,
                  ),
                  child: Column(
                    children: [
                      Container(
                          child: ListTile(
                        leading: ClipOval(
                          child: Container(
                            //child: Icon(Icons.person),
                            child: Image.network(foto_akun),
                          ),
                        ),
                        title: Text(widget.userModel.email.toString()),
                      )),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [Text("Data pribadi")],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: TextField(
                          decoration:
                              InputDecoration(labelText: "Tanggal Lahir"),
                          controller: dateBirthController,
                          readOnly: true,
                          onTap: () async {
                            DateTime? dateTime = await showDatePicker(
                                onDatePickerModeChange: (value) {
                                  setState(() {
                                    dateBirthController.text = value.toString();
                                  });
                                },
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1950),
                                lastDate: DateTime(2100));
                            print(dateTime);
                            if (dateTime != null) {
                              //print(dateTime);
                              String formattedDate =
                                  DateFormat('yyyy-MM-dd').format(dateTime);
                              print(formattedDate);
                              setState(() {
                                dateBirthController.text = formattedDate;
                              });
                            }
                          },
                        ),
                      ),
                      Container(
                        child: IntlPhoneField(
                          controller: phoneController,
                          initialCountryCode: Countries.findByDialCode(
                                  "+${countryCode.toString()}")
                              .first
                              .code,
                          initialValue: phoneController.text,
                          onChanged: (number) {
                            print(number.completeNumber);
                          },
                          onCountryChanged: (value) {
                            countryCode = value.dialCode;
                            print(value.dialCode);
                          },
                        ),
                      ),
                      MaterialButton(
                          shape: const StadiumBorder(),
                          color: Colors.blueAccent,
                          minWidth: double.infinity,
                          child: Text("Edit"),
                          onPressed: () {
                            print(phoneController.text);
                            /* final dataAccount = {
                    "mode": ["pelanggan"],
                    "phone": {
                      "phoneno": phoneController.text,
                      "countrycode": countryCode,
                      "verified_wa": "0",
                      "verified_sms": "0"
                    },
                    "username": widget.userModel.email,
                    "foto_akun":
                        "https://lh3.googleusercontent.com/a/ACg8ocKKzKel6U90qGca3UABAvNRkXJ_SibbN_hN_3omhloz2w",
                    "active_mode": "pelanggan",
                    "status_akun": 1,
                    "tanggal_lahir": dateBirthController.text
                  }; */
                            showDialog(
                                context: (context),
                                builder: (context) {
                                  return LogoandSpinner(
                                    imageAssets: 'images/loadingsmartrans.png',
                                    reverse: false,
                                    arcColor: primaryColor,
                                    spinSpeed: Duration(milliseconds: 500),
                                  );
                                });
                            /* QuickAlert.show(
                                context: context,
                                headerBackgroundColor: primaryColor,
                                type: QuickAlertType.loading,
                                widget: LogoandSpinner(
                                  imageAssets: 'images/loadingsmartrans.png',
                                  reverse: false,
                                  arcColor: primaryColor,
                                  spinSpeed: Duration(milliseconds: 500),
                                ),
                                autoCloseDuration: Duration(seconds: 4)); */
                            final dataAccount =
                                "{\"mode\": [\"pelanggan\"], \"phone\": {\"phoneno\": \"${phoneController.text}\", \"countrycode\": \"${countryCode}\", \"verified_wa\": \"0\", \"verified_sms\": \"0\"}, \"username\": \"${widget.userModel.email}\", \"foto_akun\": \"${foto_akun}\", \"active_mode\": \"pelanggan\", \"status_akun\": 1, \"tanggal_lahir\": \"${dateBirthController.text}\"}";
                            final userData = {
                              "id": widget.userModel.id,
                              "uid": widget.userModel.uid,
                              "email": widget.userModel.email,
                              "token": widget.userModel.token,
                              "data_account": dataAccount,
                              "rating": widget.userModel.rating,
                              "data_driver": widget.userModel.dataDriver,
                              "location": widget.userModel.location,
                              "created": widget.userModel.created,
                              "deposit": widget.userModel.deposit,
                              "transaction": widget.userModel.transaction,
                              "point": widget.userModel.point
                            };
                            LoginRepo().updateUser(userData);
                            Future.delayed(Duration(seconds: 4), () {
                              Navigator.of(context, rootNavigator: true).pop();

                              QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.success,
                                  text: 'Data berhasil di edit',
                                  autoCloseDuration: Duration(seconds: 2));
                            });
                          })
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
