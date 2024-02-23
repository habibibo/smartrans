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
import 'package:signgoogle/repo/Authentication.dart';
import 'package:signgoogle/repo/passenger.dart';
import 'package:signgoogle/repo/login.dart';
import 'package:signgoogle/screen/driver/home.dart';
import 'package:signgoogle/screen/passenger/profile_edit.dart';
import 'package:signgoogle/utils/SmartransColor.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:signgoogle/utils/api.dart';
import 'package:signgoogle/utils/basic_auth.dart';

class ProfileScreen extends StatefulWidget {
  //UserModel userModel;
  ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController dateBirthController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  PassengerBloc passengerBloc = PassengerBloc();

  String? phoneInit = "";
  String countryCode = "";
  String foto_akun = "";
  String dateBirth = "";
  String accountStatus = "";
  String accountMode = "";
  String userName = "";
  var jsonUserModel = "";
  @override
  void initState() {
    super.initState();
    //BlocProvider.of<PassengerBloc>(context).getUser();
    /* jsonUserModel = jsonEncode(snapshot.data!.toJson());
    snapshot.data! = snapshot.data!;
    if (snapshot.data!.dataAccount == null) {
      dateBirthController.text = "";
      countryCode = "";
      phoneController.text = "";
      foto_akun = "";
    } else {
      jsonUserModel = jsonEncode(snapshot.data!.toJson());
      print(jsonDecode(jsonDecode(jsonUserModel)["data_account"])["phone"]
          ["countrycode"]);

      dateBirthController.text = jsonDecode(
          jsonDecode(jsonUserModel)["data_account"])["tanggal_lahir"];
      countryCode =
          jsonDecode(jsonDecode(jsonUserModel)["data_account"])["phone"]
              ["countrycode"];
      print(Countries.findByDialCode("${countryCode}").first.flag);
      phoneController.text =
          jsonDecode(jsonDecode(jsonUserModel)["data_account"])["phone"]
              ["phoneno"];
      foto_akun =
          jsonDecode(jsonDecode(jsonUserModel)["data_account"])["foto_akun"];
    } */
    //BlocProvider.of<PassengerBloc>(context).getUser();

    // passengerBloc.add(PassengerStart());

    /* var jsonUserModel = jsonEncode(snapshot.data!.toJson());
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
    //print(jsonDecode(snapshot.data!.dataAccount.toString())["phone"]
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
    UserModel user = UserModel.fromJson(jsonDecode(response.body)["data"]);
    print("from passenger profile ${jsonEncode(user)}");
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

    return Container(
      margin: EdgeInsets.only(top: 30, left: 5, right: 5),
      child: FutureBuilder(
          future: getProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return PopupLoading();
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Unable to load data"),
              );
            } else {
              if (snapshot.data!.dataAccount == null) {
                dateBirthController.text = "";
                countryCode = "";
                phoneController.text = "";
                foto_akun = "";
              } else {
                print("data account exist");
                jsonUserModel = jsonEncode(snapshot.data!.toJson());

                phoneInit = jsonDecode(
                            jsonDecode(jsonUserModel)["data_account"])["phone"]
                        ["phoneno"]
                    .toString();
                dateBirth = jsonDecode(
                    jsonDecode(jsonUserModel)["data_account"])["tanggal_lahir"];
                countryCode = jsonDecode(
                        jsonDecode(jsonUserModel)["data_account"])["phone"]
                    ["countrycode"];
                foto_akun = jsonDecode(
                    jsonDecode(jsonUserModel)["data_account"])["foto_akun"];
                accountStatus =
                    jsonDecode(jsonDecode(jsonUserModel)["data_account"])[
                            "status_akun"]
                        .toString();
                accountMode =
                    jsonDecode(jsonDecode(jsonUserModel)["data_account"])[
                            "active_mode"]
                        .toString();
                userName = jsonDecode(
                    jsonDecode(jsonUserModel)["data_account"])["username"];
                if (countryCode[0] != "+") {
                  countryCode = "+${countryCode}";
                }
                print(
                    "${phoneInit} ${dateBirth} ${countryCode} ${foto_akun} ${accountStatus} ${accountMode} ${userName}");
              }
              /* return Container(
                child: Text("sdfsd"),
              ); */
              return Column(
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
                                  child: foto_akun == ""
                                      ? Icon(
                                          Icons.account_circle,
                                          size: 40,
                                        )
                                      : Image.network(
                                          "https://asset.smartrans.id/uploads/${foto_akun}"),
                                ),
                              ),
                              title: Text(snapshot.data!.email.toString()),
                              trailing: Material(
                                shape: StadiumBorder(),
                                elevation: 5,
                                color: Colors.white,
                                child: IconButton(
                                    color: Colors.blue,
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ProfileEdit(
                                                  userModel: snapshot.data!)));
                                    },
                                    icon: Icon(Icons.edit)),
                              ),
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
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              child: Row(
                                children: [
                                  Container(
                                      padding: EdgeInsets.only(left: 15),
                                      child: Icon(Icons.person_2)),
                                  Container(
                                      padding: EdgeInsets.only(left: 25),
                                      child: Text(userName == ""
                                          ? "Nama belum di isi"
                                          : userName)),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              child: Row(
                                children: [
                                  Container(
                                      padding: EdgeInsets.only(left: 15),
                                      child: Icon(Icons.calendar_month)),
                                  Container(
                                      padding: EdgeInsets.only(left: 25),
                                      child: Text(dateBirth == ""
                                          ? "Tanggal lahir belum di isi"
                                          : dateBirth)),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 104,
                                  child: CountryCodePicker(
                                    enabled: false,
                                    alignLeft: true,
                                    padding: const EdgeInsets.all(0),
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
                                Text(phoneInit! == ""
                                    ? "No Handphone belum di isi"
                                    : phoneInit!),
                              ],
                            ),
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
                                  "Data akun",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              child: Row(
                                children: [
                                  Container(
                                      padding: EdgeInsets.only(left: 15),
                                      child: Icon(Icons.card_membership)),
                                  Container(
                                      padding: EdgeInsets.only(left: 25),
                                      child: Text(accountMode == "pelanggan"
                                          ? "Pelanggan"
                                          : "Driver")),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Container(
                                    padding: EdgeInsets.only(left: 15),
                                    child: Icon(
                                      Icons.circle,
                                      size: 28,
                                      color: accountStatus == "1"
                                          ? Colors.lightGreen
                                          : Colors.grey,
                                    )),
                                Container(
                                    padding: EdgeInsets.only(left: 25),
                                    child: Text(accountStatus == "1"
                                        ? "Aktif"
                                        : "Tidak aktif")),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MaterialButton(
                          minWidth: 120,
                          shape: StadiumBorder(),
                          color: primaryColor,
                          child: Text("Go to DRIVER"),
                          onPressed: () {
                            showDialog(
                                barrierDismissible: false,
                                context: (context),
                                builder: (context) {
                                  return LogoandSpinner(
                                    imageAssets: 'images/loadingsmartrans.png',
                                    reverse: false,
                                    arcColor: primaryColor,
                                    spinSpeed: Duration(milliseconds: 500),
                                  );
                                });

                            final dataAccount =
                                "{\"mode\": [\"driver\"], \"phone\": {\"phoneno\": \"${phoneInit}\", \"countrycode\": \"${countryCode}\", \"verified_wa\": \"0\", \"verified_sms\": \"0\"}, \"username\": \"${userName}\", \"foto_akun\": \"${foto_akun}\", \"active_mode\": \"driver\", \"status_akun\": 1, \"tanggal_lahir\": \"${dateBirth}\"}";
                            final userData = {
                              "id": snapshot.data!.id,
                              "uid": snapshot.data!.uid,
                              "email": snapshot.data!.email,
                              "token": snapshot.data!.token,
                              "data_account": dataAccount,
                              "rating": snapshot.data!.rating,
                              "data_driver": snapshot.data!.dataDriver,
                              "location": snapshot.data!.location,
                              "created": snapshot.data!.created,
                              "deposit": snapshot.data!.deposit,
                              "transaction": snapshot.data!.transaction,
                              "point": snapshot.data!.point
                            };
                            LoginRepo().updateUser(userData).then((value) {
                              if (value["status"] == "ok") {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();

                                QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.success,
                                    text: 'Beralih ke mode driver',
                                    autoCloseDuration: Duration(seconds: 2));
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DriverHome(
                                            //user: widget.user,
                                            userModel: snapshot.data!,
                                            isDriver: true)));
                              } else {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();

                                QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.error,
                                    text: 'Gagal pindah mode',
                                    autoCloseDuration: Duration(seconds: 2));
                              }
                            });
                          }),
                      MaterialButton(
                        minWidth: 120,
                        shape: StadiumBorder(),
                        color: Colors.grey,
                        child: Text("Logout"),
                        onPressed: () async {
                          final AuthRepository authRepository =
                              AuthRepository();
                          final GlobalKey<NavigatorState> navigatorKey =
                              GlobalKey();
                          SharedPreferences userCache =
                              await SharedPreferences.getInstance();
                          await userCache.clear();
                          await authRepository.signOutFromGoogle();
                          Future.delayed(Duration(seconds: 2), () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: ((context) => MyApp(
                                        authRepository: authRepository,
                                        navigatorKey: navigatorKey))));
                          });
                        },
                      )
                    ],
                  )
                ],
              );
            }
          }),
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
