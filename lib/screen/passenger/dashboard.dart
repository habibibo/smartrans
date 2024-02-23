import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sliding_drawer/flutter_sliding_drawer.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:signgoogle/bloc/passenger/passenger_bloc.dart';
import 'package:signgoogle/component/popup_loading.dart';
import 'package:signgoogle/model/user.dart';
import 'package:signgoogle/screen/passenger/ride.dart';
import 'package:signgoogle/utils/SmartransColor.dart';

class DashboardPassenger extends StatefulWidget {
  UserModel userModel;
  DashboardPassenger({Key? key, required this.userModel}) : super(key: key);

  @override
  State<DashboardPassenger> createState() => _DashboardPassengerState();
}

class _DashboardPassengerState extends State<DashboardPassenger> {
  //GoogleSignInAccount? user;

  var width;
  var height;
  final slidingDrawerKey = GlobalKey<SlidingDrawerState>();
  String foto_akun = "";
  @override
  void initState() {
    print("from dashboard");
    print(jsonEncode(widget.userModel));
    final jsonUserModel = jsonEncode(widget.userModel.toJson());
    foto_akun =
        jsonDecode(jsonDecode(jsonUserModel)["data_account"])["foto_akun"];
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    //return BlocBuilder(builder: ((context, state) {
    /* if (state is PassengerLoadingState) {
        //return const PopupLoading();
        return PopupLoading();
      }
      if (state is GetUserModel) {
        return SingleChildScrollView(
          primary: false,
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    height: height * 0.280, //300,
                    //color: Color.fromARGB(255, 241, 185, 100),
                  ),
                  Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        width: double.infinity,
                        height: height * 0.24, //250,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(50),
                            bottomRight: Radius.circular(50),
                          ),
                        ),
                      )),
                  Positioned(
                    top: width * 0.10, //70
                    left: width * 0.07, //30,
                    child: Container(
                      width: width * 0.80,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    slidingDrawerKey.open();
                                  },
                                  icon: Icon(Icons.menu)),
                              Row(
                                children: [
                                  IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.notifications))
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: width * 0.07, // 30,
                    right: width * 0.07, // 30,
                    child: Container(
                      height: height * 0.16, //150,
                      width: width * 0.1, // 70,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey,
                                blurRadius: 5,
                                offset: Offset(0, 2))
                          ]),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                              left: width * 0.05,
                              top: width * 0.04,
                              bottom: width * 0.02,
                            ),
                            child: Row(children: [
                              Container(
                                padding: EdgeInsets.all(5),
                                child: Card(
                                  elevation: 5,
                                  child: Column(
                                    children: [
                                      Container(
                                          child: MaterialButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            PassengerRide(
                                                              user: user,
                                                            )));
                                              },
                                              padding: EdgeInsets.all(0.0),
                                              child: Image.asset(
                                                "images/juberRides/juber_car.png",
                                                height: 40,
                                              ))),
                                      Text("Ride"),
                                    ],
                                  ),
                                ),
                              ),
                            ]),
                          ),
                          SizedBox(
                            height: height * 0.008,
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        );
      } */
    return SingleChildScrollView(
      primary: false,
      physics: NeverScrollableScrollPhysics(),
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                width: double.infinity,
                height: height * 0.280, //300,
                //color: Color.fromARGB(255, 241, 185, 100),
              ),
              Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: double.infinity,
                    height: height * 0.24, //250,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      ),
                    ),
                  )),
              Positioned(
                top: width * 0.10, //70
                left: width * 0.07, //30,
                child: Container(
                  width: width * 0.80,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: foto_akun == ""
                                ? Icon(
                                    Icons.account_circle,
                                    size: 40,
                                  )
                                : Image.network(
                                    "https://asset.smartrans.id/uploads/${foto_akun}"),
                          ),
                          /* IconButton(
                              onPressed: () {
                                slidingDrawerKey.open();
                              },
                              icon: Icon(Icons.menu)), */
                          /* Row(
                            children: [
                              IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.notifications))
                            ],
                          ) */
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: width * 0.07, // 30,
                right: width * 0.07, // 30,
                child: Container(
                  height: height * 0.16, //150,
                  width: width * 0.1, // 70,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            blurRadius: 5,
                            offset: Offset(0, 2))
                      ]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          left: width * 0.05,
                          top: width * 0.04,
                          bottom: width * 0.02,
                        ),
                        child: Row(children: [
                          Container(
                            padding: EdgeInsets.all(5),
                            child: Card(
                              elevation: 5,
                              child: Column(
                                children: [
                                  Container(
                                      child: MaterialButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PassengerRide(
                                                          userModel:
                                                              widget.userModel,
                                                        )));
                                          },
                                          padding: EdgeInsets.all(0.0),
                                          child: Image.asset(
                                            "images/juberRides/juber_car.png",
                                            height: 40,
                                          ))),
                                  Text("Ride"),
                                ],
                              ),
                            ),
                          ),
                        ]),
                      ),
                      SizedBox(
                        height: height * 0.008,
                      ),
                      /* SelectableText(widget.userModel.uid.toString()), */
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );

    ///  }));
  }
}
