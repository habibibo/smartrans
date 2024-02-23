import 'dart:convert';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_country_code_picker/flutter_country_code_picker.dart';
import 'package:logo_n_spinner/logo_n_spinner.dart';
import 'package:phonecodes/phonecodes.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signgoogle/bloc/auth/auth_bloc.dart';
import 'package:signgoogle/bloc/passenger/passenger_bloc.dart';
import 'package:signgoogle/component/popup_loading.dart';
import 'package:signgoogle/main.dart';
import 'package:signgoogle/model/user.dart';
import 'package:signgoogle/repo/passenger.dart';
import 'package:signgoogle/repo/login.dart';
import 'package:signgoogle/screen/passenger/home.dart';
import 'package:signgoogle/screen/passenger/profile.dart';
import 'package:signgoogle/utils/SmartransColor.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:signgoogle/utils/api.dart';
import 'package:signgoogle/utils/basic_auth.dart';

class ProfileEdit extends StatelessWidget {
  UserModel userModel;
  ProfileEdit({Key? key, required this.userModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProfileEditScreen(userModel: userModel),
    );
  }
}

class ProfileEditScreen extends StatefulWidget {
  UserModel userModel;
  ProfileEditScreen({Key? key, required this.userModel}) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  TextEditingController dateBirthController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  PassengerBloc passengerBloc = PassengerBloc();

  String? phoneInit = "";
  String countryCode = "";
  String foto_akun = "";
  String dateBirth = "";
  var jsonUserModel = "";
  @override
  void initState() {
    super.initState();
    //BlocProvider.of<PassengerBloc>(context).getUser();
    jsonUserModel = jsonEncode(widget.userModel.toJson());
    widget.userModel = widget.userModel;
    if (widget.userModel.dataAccount == null) {
      countryCode = "";
      foto_akun = "";
    } else {
      jsonUserModel = jsonEncode(widget.userModel.toJson());

      usernameController.text =
          jsonDecode(jsonDecode(jsonUserModel)["data_account"])["username"];
      dateBirthController.text = jsonDecode(
          jsonDecode(jsonUserModel)["data_account"])["tanggal_lahir"];
      countryCode =
          jsonDecode(jsonDecode(jsonUserModel)["data_account"])["phone"]
              ["countrycode"];

      phoneController.text =
          jsonDecode(jsonDecode(jsonUserModel)["data_account"])["phone"]
              ["phoneno"];
      foto_akun =
          jsonDecode(jsonDecode(jsonUserModel)["data_account"])["foto_akun"];
      if (countryCode[0] != "+") {
        countryCode = "+${countryCode}";
      }
      print(Countries.findByDialCode("${countryCode}").first.flag);
      /* print(
          "${phoneInit} ${dateBirth} ${countryCode} ${foto_akun} ${accountStatus} ${accountMode} ${userName}"); */
    }
    //BlocProvider.of<PassengerBloc>(context).getUser();

    // passengerBloc.add(PassengerStart());

    /* var jsonUserModel = jsonEncode(widget.userModel.toJson());
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
        jsonDecode(jsonDecode(jsonUserModel)["data_account"])["foto_akun"]; */
    //print(jsonDecode(widget.userModel.dataAccount.toString())["phone"]
    //    ["phoneno"]);
    print(foto_akun);
  }

  showText(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            width: double.infinity,
            color: Colors.grey,
            height: 100,
            child: TextField(
              autofocus: true,
              onSubmitted: (value) {
                phoneController.text = value;

                Navigator.pop(context);
              },
            ),
          );
        });
  }

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

  @override
  Widget build(BuildContext context) {
    /* BlocBuilder<PassengerBloc, PassengerState>(
      builder: (context, state) {
        if (state is PassengerLoadingState) {
          return PopupLoading();
        }
        if (state is GetUserModel) {
          
        } */

    return Scaffold(
      body: Container(
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
                      right: 15,
                      top: 10,
                      bottom: 10,
                    ),
                    child: Column(
                      children: [
                        Container(
                            child: ListTile(
                          leading: Container(
                            decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(50)),
                            //child: Icon(Icons.person),
                            child: IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PassengerHome(
                                                userModel: widget.userModel,
                                                isDriver: false,
                                              )));
                                },
                                icon: Icon(
                                  Icons.arrow_back,
                                  size: 28,
                                )),
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Data pribadi",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          child: TextField(
                            controller: usernameController,
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.person_2),
                                labelText: "Nama"),
                          ),
                        ),
                        Container(
                          child: TextField(
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.calendar_month),
                                labelText: "Tanggal Lahir"),
                            controller: dateBirthController,
                            readOnly: true,
                            onTap: () async {
                              DateTime? dateTime = await showDatePicker(
                                  initialEntryMode:
                                      DatePickerEntryMode.calendarOnly,
                                  onDatePickerModeChange: (value) {
                                    // setState(() {
                                    dateBirthController.text = value.toString();
                                    // });
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
                                // setState(() {
                                dateBirthController.text = formattedDate;
                                //   });
                              }
                            },
                          ),
                        ),
                        Container(
                          child: Row(
                            children: [
                              Container(
                                width: 120,
                                child: CountryCodePicker(
                                  onChanged: (value) {
                                    countryCode = value.dialCode.toString();
                                  },
                                  // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                  initialSelection: countryCode == ""
                                      ? "ID"
                                      : Countries.findByDialCode(countryCode)
                                          .first
                                          .code,
                                  //favorite: const ['+62', 'ID'],
                                  // flag can be styled with BoxDecoration's `borderRadius` and `shape` fields
                                  flagDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                ),
                              ),
                              Container(
                                width: 200,
                                child: TextField(
                                  controller: phoneController,
                                  keyboardType: TextInputType.phone,
                                ),
                              ),
                            ],
                          ),
                        ),
                        MaterialButton(
                            shape: const StadiumBorder(),
                            color: Colors.blueAccent,
                            minWidth: double.infinity,
                            child: Text("Simpan perubahan"),
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
                              print(countryCode);
                              showDialog(
                                  barrierDismissible: false,
                                  context: (context),
                                  builder: (context) {
                                    return LogoandSpinner(
                                      imageAssets:
                                          'images/loadingsmartrans.png',
                                      reverse: false,
                                      arcColor: primaryColor,
                                      spinSpeed: Duration(milliseconds: 500),
                                    );
                                  });

                              final dataAccount =
                                  "{\"mode\": [\"pelanggan\"], \"phone\": {\"phoneno\": \"${phoneController.text}\", \"countrycode\": \"${countryCode.toString()}\", \"verified_wa\": \"0\", \"verified_sms\": \"0\"}, \"username\": \"${usernameController.text}\", \"foto_akun\": \"${foto_akun}\", \"active_mode\": \"pelanggan\", \"status_akun\": 1, \"tanggal_lahir\": \"${dateBirthController.text}\"}";
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
                              LoginRepo().updateUser(userData).then((value) {
                                if (value["status"] == "ok") {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();

                                  QuickAlert.show(
                                      context: context,
                                      type: QuickAlertType.success,
                                      text: 'Data berhasil di edit',
                                      autoCloseDuration: Duration(seconds: 2));
                                } else {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();

                                  QuickAlert.show(
                                      context: context,
                                      type: QuickAlertType.error,
                                      text: 'Data gagal disimpan',
                                      autoCloseDuration: Duration(seconds: 2));
                                }
                              });
                            })
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
    //},
    //);
  }

  @override
  void dispose() {
    //PassengerBloc().close();
    phoneController.dispose();
    super.dispose();
  }
}
