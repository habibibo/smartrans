import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:currency_textfield/currency_textfield.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_sliding_drawer/flutter_sliding_drawer.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logo_n_spinner/logo_n_spinner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signgoogle/bloc/auth/auth_bloc.dart';
import 'package:signgoogle/main.dart';
import 'package:signgoogle/model/driverlatlng.dart';
import 'package:signgoogle/model/notif/notif_list_job.dart';
import 'package:signgoogle/model/user.dart';
import 'package:signgoogle/repo/driver.dart';
import 'package:signgoogle/screen/driver/berkas_driver.dart';
import 'package:signgoogle/screen/driver/history.dart';
import 'package:signgoogle/screen/driver/profile.dart';
import 'package:signgoogle/screen/driver/wallet.dart';
import 'package:signgoogle/screen/passenger/ride.dart';
//import 'package:signgoogle/screens/home/member/member_home.dart';
import 'package:signgoogle/screen/driver/side_menu.dart';
import 'package:signgoogle/repo/Authentication.dart';
import 'package:signgoogle/utils/SmartransColor.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/* int id = 0;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

/* const MethodChannel platform =
    MethodChannel('dexterx.dev/flutter_local_notifications_example'); */

const String portName = 'notification_send_port';

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

String? selectedNotificationPayload;

/// A notification action which triggers a url launch event
const String urlLaunchActionId = 'id_1';

/// A notification action which triggers a App navigation event
const String navigationActionId = 'id_3';

/// Defines a iOS/MacOS notification category for text input actions.
const String darwinNotificationCategoryText = 'textCategory';

/// Defines a iOS/MacOS notification category for plain actions.
const String darwinNotificationCategoryPlain = 'plainCategory';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
} */

class DriverHome extends StatefulWidget {
  DriverHome({Key? key, required this.user, required this.isDriver})
      : super(key: key);
  GoogleSignInAccount? user;
  final bool isDriver;
  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  late AuthRepository authRepository = AuthRepository();
  late GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<bool> getDriverHome() async {
    //final AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);
    //authBloc.add(GoingDriver());
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => getDriverHome(),
        child: MaterialApp(
          home: BlocProvider(
            create: (context) => AuthBloc(
                authRepository: authRepository, navigatorKey: navigatorKey)
              ..add(AppStarted()),
            child: DriverHomeScreen(
              user: widget.user,
              isDriver: widget.isDriver,
            ),
          ),
        ));
  }
}

class DriverHomeScreen extends StatefulWidget {
  DriverHomeScreen({Key? key, required this.user, required this.isDriver})
      : super(key: key);
  GoogleSignInAccount? user;
  final bool isDriver;

  @override
  _DriverHomeScreenState createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  //late User _user;
  late AuthRepository authRepository = AuthRepository();
  late GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  String? _token;
  String? initialMessage;
  //FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool isOnline = false;
  String isOnlineText = "Offline";
  int _page = 0;
  late PageController _pageController;
  int id = 0;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late UserModel userModel = UserModel();
  bool recDesp = false;
  var dataAtual = new DateTime.now();
  final rupiah = NumberFormat.simpleCurrency(locale: 'id_ID');
  TextEditingController dateBirthController = TextEditingController();
  List<NotifListJob> listJobs = [];
  List<NotifListJob> listJobs2 = [];
  late int lengthListJobs2 = 0;
  String listJobString = "";
  var width, height;
  int testIndex = 0;
  DriverRepo driverRepo = DriverRepo();
  late NotifListJob notifListJob;
  double currentLat = 0;
  double currentLng = 0;
  late bool serviceEnabled;
  late LocationPermission permission;

  @override
  void initState() {
    super.initState();
    driverRepo.changeStatus(userModel.uid.toString(), "off");
    WidgetsFlutterBinding.ensureInitialized();
    _pageController = PageController(initialPage: _page);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      var dataBody = jsonDecode(
          jsonEncode(jsonDecode(message.notification!.body.toString())));
      print('Got a message whilst in the foreground!');
      //print('Message data: ${dataBody["mode"]}');
      if (dataBody["type"].toString() == "new_transactions") {
        messageConversion(dataBody, message.notification!.title.toString());
        print("from driver home");
      }
    });
    getToken();
    loadOrder();
    getUserCache();
    _getCurrentLocation();
    // subscribeTopics();
  }

  /* Future<void> subscribeTopics() async {
    await FirebaseMessaging.instance.subscribeToTopic("topics/surabaya");
  } */

  Future<void> _getCurrentLocation() async {
    print(LocationPermission.values);
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await _showLocationServiceDialog();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        await _showLocationServiceDialog();
      }
    }
    Position? position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentLat = position.latitude;
      currentLng = position.longitude;
    });
  }

  Future<void> _showLocationServiceDialog() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Lokasi Belum Diizinkan"),
          content: Text("Aktifkan lokasi dulu yaa..."),
          actions: <Widget>[
            MaterialButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> messageConversion(var messageData, String title) async {
    //_showNotification(messageData, title);
    final SharedPreferences driverCache = await SharedPreferences.getInstance();
    String? existingJsonString = driverCache.getString("listJob");
    print("message conversion");
    print(messageData);
    // addListJobs(messageData);

    if (existingJsonString != null) {
      List<dynamic> existingList = jsonDecode(existingJsonString.toString());
      List<NotifListJob> existingJobs =
          existingList.map((map) => NotifListJob.fromJson(map)).toList();

      // Add new jobs to existing jobs
      addListJobs(messageData);
      existingJobs.addAll(listJobs);

      // Convert the combined list to JSON
      List<Map<String, dynamic>> combinedJsonList =
          existingJobs.map((job) => job.toJson()).toList();

      String combinedJsonString = jsonEncode(combinedJsonList);
      List<NotifListJob> decodedJobList =
          combinedJsonList.map((map) => NotifListJob.fromJson(map)).toList();
      setState(() {
        //listJobs2 = decodedJobList;
        listJobs2.addAll(listJobs);
        lengthListJobs2 = listJobs2.length;
      });
      // Update SharedPreferences with the combined data
      await driverCache.setString("listJob", combinedJsonString);
    } else {
      addListJobs(messageData);
      // If no existing data, store the new jobs directly as JSON
      List<Map<String, dynamic>> newJsonList =
          listJobs.map((job) => job.toJson()).toList();

      String newJsonString = jsonEncode(newJsonList);
      List<NotifListJob> decodedJobList =
          newJsonList.map((map) => NotifListJob.fromJson(map)).toList();
      setState(() {
        //listJobs2 = decodedJobList;
        listJobs2.addAll(listJobs);
        lengthListJobs2 = listJobs2.length;
      });
      await driverCache.setString("listJob", newJsonString);
    }

    //driverCache.getString("listJob"));
  }

  Future<void> getUserCache() async {
    SharedPreferences cacheUser = await SharedPreferences.getInstance();
    userModel.id =
        jsonDecode(cacheUser.get("userModel").toString())["id"].toString();
    userModel.email =
        jsonDecode(cacheUser.get("userModel").toString())["email"].toString();
    userModel.uid =
        jsonDecode(cacheUser.get("userModel").toString())["uid"].toString();
    userModel.deposit =
        jsonDecode(cacheUser.get("userModel").toString())["deposit"].toString();
    userModel.dataDriver =
        jsonDecode(cacheUser.get("userModel").toString())["data_driver"]
            .toString();
    userModel.dataAccount =
        jsonDecode(cacheUser.get("userModel").toString())["data_account"]
            .toString();
    userModel.location =
        jsonDecode(cacheUser.get("userModel").toString())["location"]
            .toString();
    userModel.point =
        jsonDecode(cacheUser.get("userModel").toString())["point"].toString();
    userModel.transaction =
        jsonDecode(cacheUser.get("userModel").toString())["transaction"]
            .toString();
    userModel.rating =
        jsonDecode(cacheUser.get("userModel").toString())["rating"].toString();
    userModel.token =
        jsonDecode(cacheUser.get("userModel").toString())["token"].toString();
    dateBirthController.text =
        jsonDecode(userModel.dataAccount.toString())["tanggal_lahir"];
  }
/* 
  void showBerkasDriver() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return BerkasDriver(user: widget.user);
        });
  } */

  Future<void> _showNotification(var message, String title) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('0', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            //priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    print("driver bid");
    if (message['type'].toString() == "new_transactions") {
      await flutterLocalNotificationsPlugin.show(
          id++,
          title,
          "Order baru dari ${message['data']['nama_user']} , total tujuan ${int.parse(message['data']['distance']) / 1000}km, dengan tarif Rp ${message['data']['tarif']}",
          notificationDetails,
          payload: 'item x');
    }
  }

  void addListJobs(var messageData) {
    listJobs.clear();
    listJobs.add(NotifListJob(
      uid_user: messageData["data"]["uid_user"].toString(),
      nama_user: messageData["data"]["nama_user"].toString(),
      distance: messageData["data"]["distance"].toString(),
      total_alamat: messageData["data"]["total_alamat"].toString(),
      tarif: messageData["data"]["tarif"].toString(),
      //bid: messageData["data"]["bid"].toString(),
      jarak_driver: messageData["data"]["jarak_driver"].toString(),
      waktu_jemput: messageData["data"]["waktu_jemput"].toString(),
      pembayaran: messageData["data"]["pembayaran"].toString(),
      waktu_pickup: messageData["data"]["waktu_pickup"].toString(),
      //jam: messageData["data"]["jam"].toString(),
      //id_driver: "7468696e-6b62-4962-af40-676d61696c2e",
      //nama_driver: widget.user!.displayName.toString(),
      //foto_driver: "foto driver kosong",
      //kendaraan: "kendaraan kosong",
      //rating_driver: messageData["data"]["rating_driver"].toString(),
      isOpen: true,
      token_user: messageData["data"]["token_user"].toString(),
    ));
  }

  Future<void> loadOrder() async {
    final SharedPreferences driverCache = await SharedPreferences.getInstance();
    final String? cacheJsonString = driverCache.getString("listJob");
    /* setState(() {
          listJobString = driverCache.get("listJob").toString();
        }); */
    if (cacheJsonString != null) {
      List<dynamic> decodedList = jsonDecode(cacheJsonString);
      List<NotifListJob> decodedJobList =
          decodedList.map((map) => NotifListJob.fromJson(map)).toList();

      setState(() {
        listJobs2 = decodedJobList;
        lengthListJobs2 = listJobs2.length;
      });
    }
  }

  void showDetailJob(BuildContext context, NotifListJob message, int getIndex) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    showFlexibleBottomSheet<void>(
      minHeight: 0,
      initHeight: 0.4,
      maxHeight: 1,
      context: context,
      isSafeArea: false,
      bottomSheetColor: Colors.transparent,
      builder: (context, controller, offset) {
        return Container(
          padding: EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              )),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                message.nama_user,
                style: TextStyle(fontSize: 15),
              ),
              Text("Waktu pickup ${message.waktu_pickup}",
                  style: TextStyle(fontSize: 15)),
              Text(
                  "Jarak tujuan penumpang ${int.parse(message.distance) / 1000}km",
                  style: TextStyle(fontSize: 15)),
              Text("Total tujuan penumpang ${int.parse(message.total_alamat)}",
                  style: TextStyle(fontSize: 15)),
              Text("Tarif ${rupiah.format(int.parse(message.tarif))}",
                  style: TextStyle(fontSize: 15)),
              Text("Pembayaran ${message.pembayaran}",
                  style: TextStyle(fontSize: 15)),
              SizedBox(height: 10),
              Row(
                children: List.generate(
                    800 ~/ 10,
                    (index) => Expanded(
                          child: Container(
                            color: index % 2 == 0
                                ? Colors.transparent
                                : Colors.grey,
                            height: 2,
                          ),
                        )),
              ),
              Text("Jarak driver ${int.parse(message.jarak_driver) / 1000} km",
                  style: TextStyle(fontSize: 15)),
              Text("Waktu jemput ${int.parse(message.waktu_jemput) / 60} mnt",
                  style: TextStyle(fontSize: 15)),
              SizedBox(height: 20),
              Visibility(
                visible: message.isOpen == true ? true : false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(
                        padding: EdgeInsets.all(10),
                        color: Colors.greenAccent,
                        child: Text(
                          "Accept",
                        ),
                        onPressed: () {
                          driverRepo.acceptBid(userModel, notifListJob, "",
                              DriverLatLng(lat: currentLat, lng: currentLng));
                          //driverRepo.acceptWithoutNego(userModel, notifListJob);
                          showAccept(message, getIndex);
                        }),
                    MaterialButton(
                        padding: EdgeInsets.all(10),
                        color: Colors.blueAccent,
                        child: Text(
                          "Nego",
                        ),
                        onPressed: () {
                          showOfferingDriver(context, message, getIndex);
                        }),
                    MaterialButton(
                        padding: EdgeInsets.all(10),
                        color: Colors.grey,
                        child: Text(
                          "Decline",
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ],
                ),
              )
            ],
          ),
        );
      },
      anchors: [0, 0.5, 1],
      useRootScaffold: false,
    );
  }

  void showOfferingDriver(
      BuildContext context, NotifListJob message, int getIndex) {
    final CurrencyTextFieldController offeringController =
        CurrencyTextFieldController(
      currencySymbol: "Rp",
      thousandSymbol: ".",
      decimalSymbol: "",
      enableNegative: false,
      numberOfDecimals: 0,
    );
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    final rupiah = NumberFormat.simpleCurrency(locale: 'id_ID');
    showFlexibleBottomSheet<void>(
      minHeight: 0,
      initHeight: 0.4,
      maxHeight: 1,
      context: context,
      isSafeArea: false,
      bottomSheetColor: Colors.transparent,
      builder: (context, controller, offset) {
        return Container(
          padding: EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              )),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 90,
                width: width,
                child: TextField(
                  controller: offeringController,
                  keyboardType: TextInputType.phone,
                  onSubmitted: (value) {
                    driverRepo.acceptBid(
                        userModel,
                        notifListJob,
                        offeringController.intValue.toString(),
                        DriverLatLng(lat: currentLat, lng: currentLng));
                    showAcceptNego(offeringController.text, message, getIndex);
                  },
                ),
              ),
            ],
          ),
        );
      },
      anchors: [0, 0.5, 1],
      useRootScaffold: false,
    );
  }

  void showAcceptNego(String price, NotifListJob message, int getIndex) {
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 110,
                  child: const LogoandSpinner(
                    imageAssets: 'images/loadingsmartrans.png',
                    reverse: false,
                    arcColor: primaryColor,
                    spinSpeed: Duration(milliseconds: 500),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(15),
                        bottomRight: Radius.circular(40),
                        bottomLeft: Radius.circular(15),
                      ),
                      color: Colors.white),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Text(
                          "Response telah terkirim ke penumpang",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "dengan tarif ${price}",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
    setState(() {
      listJobs2[getIndex].isOpen = false;
    });
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pop(context);
      Navigator.pop(context);
    });
  }

  void showAccept(NotifListJob message, int getIndex) {
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 110,
                  child: const LogoandSpinner(
                    imageAssets: 'images/loadingsmartrans.png',
                    reverse: false,
                    arcColor: primaryColor,
                    spinSpeed: Duration(milliseconds: 500),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(15),
                        bottomRight: Radius.circular(40),
                        bottomLeft: Radius.circular(15),
                      ),
                      color: Colors.white),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Text(
                          "Response telah terkirim ke penumpang",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
    setState(() {
      listJobs2[getIndex].isOpen = false;
    });
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pop(context);
    });
  }

  Future<void> getToken() async {
    setState(() async {
      _token = await FirebaseMessaging.instance.getToken();
    });

    print("FCM Token: $_token");
  }

  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  final slidingDrawerKey = GlobalKey<SlidingDrawerState>();
  Future<bool> disableReturn() async {
    return false;
  }

  String format(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
  }

  Widget homeDriver() {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      primary: false,
      physics: NeverScrollableScrollPhysics(),
      //physics: ClampingScrollPhysics(),
      //height: height,
      //width: width,
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                width: double.infinity,
                height: height * 0.200, //300,
                //color: Color.fromARGB(255, 241, 185, 100),
              ),
              Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: double.infinity,
                    height: height * 0.20, //250,
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
                  height: height * 0.10, //150,
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin:
                                        EdgeInsets.only(top: 10, bottom: 10),
                                    child: Text("Saldo"),
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.account_balance_wallet),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text("Rp 350.000"),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin:
                                        EdgeInsets.only(top: 10, bottom: 10),
                                    child: Text("Today"),
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.line_axis),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text("12"),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin:
                                        EdgeInsets.only(top: 10, bottom: 11),
                                    child: Text("Status"),
                                  ),
                                  Container(
                                    height: 20,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color:
                                          isOnline ? Colors.green : Colors.grey,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.grey.shade400, //New
                                            blurRadius: 6,
                                            offset: Offset(0, 4))
                                      ],
                                    ),
                                    child: InkWell(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 2,
                                              bottom: 2,
                                              left: 10,
                                              right: 10),
                                          child: Text(
                                            isOnlineText,
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                        onTap: () {
                                          if (isOnline) {
                                            setState(() {
                                              isOnline = false;
                                              isOnlineText = "Offline";
                                              var response =
                                                  driverRepo.changeStatus(
                                                      userModel.uid.toString(),
                                                      "off");
                                              print(response);
                                            });
                                          } else {
                                            setState(() {
                                              isOnline = true;
                                              isOnlineText = "Online";
                                              var response =
                                                  driverRepo.changeStatus(
                                                      userModel.uid.toString(),
                                                      "on");
                                              print(response);
                                            });
                                          }
                                        }),
                                  ),
                                ],
                              ),
                            ),
                          ]),
                      SizedBox(
                        height: height * 0.008,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          SelectableText(_token.toString()),
          Container(
            width: width,
            height: height * 0.75,
            child: ListView.builder(
                itemCount: lengthListJobs2,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(35),
                          bottomLeft: Radius.circular(35),
                          bottomRight: Radius.circular(5),
                        ),
                        color: listJobs2[lengthListJobs2 - 1 - index].isOpen ==
                                true
                            ? Colors.lightGreen
                            : Colors.grey[100]),
                    margin: EdgeInsets.only(bottom: 5, left: 10, right: 10),
                    child: ListTile(
                      onTap: () {
                        setState(() {
                          notifListJob = listJobs2[lengthListJobs2 - 1 - index];
                        });
                        print(jsonEncode(notifListJob));
                        showDetailJob(
                            context,
                            listJobs2[lengthListJobs2 - 1 - index],
                            (lengthListJobs2 - 1 - index));
                      },
                      trailing: Padding(
                        padding: const EdgeInsets.only(top: 10, right: 10),
                        child: Icon(Icons.menu_book),
                      ),
                      leading: Padding(
                        padding: const EdgeInsets.only(top: 10, right: 10),
                        child: ClipOval(
                          child: Icon(Icons.person),
                        ),
                      ),
                      title: Text(
                          "${listJobs2[lengthListJobs2 - 1 - index].nama_user}"),
                      subtitle: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tujuan penumpang ${int.parse(listJobs2[lengthListJobs2 - 1 - index].distance) / 1000} km",
                          ),
                          Text(
                              "Tarif ${rupiah.format(int.parse(listJobs2[lengthListJobs2 - 1 - index].tarif))}"),
                          Text(
                              "Pickup : ${listJobs2[lengthListJobs2 - 1 - index].waktu_pickup}"),
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    //_allMovMes(dataFormatada);
    return WillPopScope(
      onWillPop: () => disableReturn(),
      child: SlidingDrawer(
        key: slidingDrawerKey,
        // Build content widget
        contentBuilder: (context) {
          return Scaffold(
            body: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
              if (state is Unauthenticated) {
                return MyApp(
                    authRepository: authRepository, navigatorKey: navigatorKey);
              }
              return PageView(
                controller: _pageController,
                onPageChanged: (int index) {
                  setState(() {
                    _page = index;
                  });
                },
                children: [
                  homeDriver(),
                  HistoryScreen(),
                  WalletScreen(),
                  ProfileScreen(userModel: userModel)
                ],
              );
            }),
            bottomNavigationBar: CurvedNavigationBar(
              color: Colors.white,
              buttonBackgroundColor: primaryColor,
              backgroundColor: Color.fromARGB(255, 241, 241, 241),
              key: _bottomNavigationKey,
              index: _page,
              onTap: (index) {
                setState(() {
                  _page = index;
                });
                _pageController.animateToPage(
                  index,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                );
              },
              items: [
                CurvedNavigationBarItem(
                  child: Icon(
                    Icons.home_outlined,
                    grade: 10,
                  ),
                  label: 'Home',
                ),
                CurvedNavigationBarItem(
                  child: Icon(
                    Icons.menu_book_outlined,
                    grade: 10,
                  ),
                  label: 'History',
                ),
                CurvedNavigationBarItem(
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    grade: 10,
                  ),
                  label: 'Wallet',
                ),
                CurvedNavigationBarItem(
                  child: Icon(
                    Icons.account_box,
                    grade: 10,
                  ),
                  label: 'My Account',
                ),
              ],
            ),
          );
        },
        drawerBuilder: (_) {
          return SideMenu(
              onAction: () => slidingDrawerKey.close(),
              user: widget.user,
              isDriver: widget.isDriver);
        },
      ),
    );
  }
}
