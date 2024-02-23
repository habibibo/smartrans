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
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signgoogle/bloc/auth/auth_bloc.dart';
import 'package:signgoogle/component/popup_loading.dart';
import 'package:signgoogle/main.dart';
import 'package:signgoogle/model/driverlatlng.dart';
import 'package:signgoogle/model/location.dart';
import 'package:signgoogle/model/notif/notif_list_job.dart';
import 'package:signgoogle/model/user.dart';
import 'package:signgoogle/repo/driver.dart';
import 'package:signgoogle/screen/driver/berkas_driver.dart';
import 'package:signgoogle/screen/driver/history.dart';
import 'package:signgoogle/screen/driver/live_tracking.dart';
import 'package:signgoogle/screen/driver/profile.dart';
import 'package:signgoogle/screen/driver/wallet.dart';
import 'package:signgoogle/screen/passenger/ride.dart';
//import 'package:signgoogle/screens/home/member/member_home.dart';
import 'package:signgoogle/screen/driver/side_menu.dart';
import 'package:signgoogle/repo/Authentication.dart';
import 'package:signgoogle/utils/SmartransColor.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:signgoogle/utils/api.dart';
import 'package:signgoogle/utils/basic_auth.dart';
import 'package:signgoogle/utils/mapbox.dart';
import 'package:timelines/timelines.dart';

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
  DriverHome({Key? key, required this.userModel, required this.isDriver})
      : super(key: key);
  //GoogleSignInAccount? user;
  UserModel userModel;
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
              userModel: widget.userModel,
              isDriver: widget.isDriver,
            ),
          ),
        ));
  }
}

class DriverHomeScreen extends StatefulWidget {
  DriverHomeScreen({Key? key, required this.userModel, required this.isDriver})
      : super(key: key);
  //GoogleSignInAccount? user;
  UserModel userModel;
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
  //late UserModel userModel = UserModel();
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
  String area = "";
  String latestArea = "";
  String bearing = "";
  String foto_akun = "";
  late bool serviceEnabled;
  late LocationPermission permission;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    WidgetsFlutterBinding.ensureInitialized();
    final jsonUserModel = jsonEncode(widget.userModel.toJson());
    foto_akun =
        jsonDecode(jsonDecode(jsonUserModel)["data_account"])["foto_akun"];
    _pageController = PageController(initialPage: _page);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      var dataBody = jsonDecode(
          jsonEncode(jsonDecode(message.notification!.body.toString())));
      print('Got a message whilst in the foreground!');
      //print('Message data: ${dataBody["mode"]}');
      if (dataBody["type"].toString() == "new_transactions") {
        messageConversion(dataBody, message.notification!.title.toString());
        print("from driver home");
      } else if (dataBody["type"].toString() == "proove_bid") {
        print("to live tracking driver");
        liveTrackingDriver(dataBody, message.notification!.title.toString());
      } else if (dataBody["type"].toString() == "passenger_assign") {
        pickUpPassenger(dataBody, message.notification!.title.toString());
      }
    });
    getToken();
    loadOrder();
    //getUserCache();

    //subscribeT
    //opics();
  }

  void pickUpPassenger(var messageData, String title) {
    var responseTransaction =
        driverRepo.getTransaction(messageData["data"]["uid"]);
    responseTransaction.then((value) async {
      print("data transaction");
      var decodeData = jsonDecode(value)["data"];
      List<dynamic> locationPassengers =
          jsonDecode(decodeData["rute"])["location"];
      List<Location> parseLocation = [];
      for (int i = 0; i <= locationPassengers.length - 1; i++) {
        parseLocation.add(Location(
            address: locationPassengers[i]["address"],
            lat: locationPassengers[i]["lat"],
            lng: locationPassengers[i]["lng"]));
      }
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => LiveTrackingDriver(
                  locationPassenger: parseLocation,
                  currentLat: currentLat,
                  currentLng: currentLng,
                  orderDetail: decodeData.toString())));
    });
  }

  Future<void> liveTrackingDriver(var messageData, String title) async {
    print(messageData);
  }

  /* Future<void> subscribeTopics() async {
    await FirebaseMessaging.instance.subscribeToTopic("topics/surabaya");
  } */

  Future<void> _getCurrentLocation() async {
    /* showDialog(
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
    Future.delayed(Duration(seconds: 6), () {
      Navigator.of(context, rootNavigator: true).pop();
    }); */
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
    var apiUrl = Uri.parse(
        "https://api.mapbox.com/geocoding/v5/mapbox.places/${position.longitude},${position.latitude}.json?language=id&access_token=sk.eyJ1IjoiYmlib2hhYmliIiwiYSI6ImNscG5tMGtsYzBwN2UybW9icGk2ZzY5emcifQ.UneRCntojkFKhKCdEQKosg");

    try {
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        // get location from api user
        SharedPreferences uid = await SharedPreferences.getInstance();
        final dataBody = {"uid": uid.getString("uid").toString()};
        final getUserUrl = Uri.parse("${ApiNetwork().baseUrl}${To().getUser}");
        var responseLocation = await http.post(
          getUserUrl,
          headers: <String, String>{
            'Authorization': basicAuth,
            'Content-Type': "application/json; charset=UTF-8",
          },
          body: jsonEncode(dataBody),
        );
        UserModel user =
            UserModel.fromJson(jsonDecode(responseLocation.body)["data"]);
        var lastLocation = jsonDecode(user.location.toString());

        setState(() {
          //if (data["features"][0]["context"][3]["text_id"] == "Sidoarjo") {
          //  area = "surabaya";
          //} else {
          area = data["features"][0]["context"][3]["text_id"];
          //}

          currentLat = position.latitude;
          currentLng = position.longitude;
          if (user.location == null) {
            latestArea = area;
            driverRepo.updateLocation(
                uid.getString("uid").toString(),
                currentLat.toString(),
                currentLng.toString(),
                "0",
                area.toLowerCase());
          } else {
            latestArea = lastLocation["geofence"];
          }
        });

        print(data["features"][0]["context"][3]["text_id"]);
        print("latest area : ${latestArea}");
        final newCurrentLocation = {
          "bearing": "0",
          "updated": DateTime.now().toString(),
          "geofence": area.toLowerCase(),
          "latitude": currentLat,
          "longitude": currentLng,
        };
        print(uid.getString("uid").toString());
        driverRepo.changeStatus(
            uid.getString("uid").toString(), "off", latestArea.toLowerCase());
        driverRepo.updateLocation(
            uid.getString("uid").toString(),
            currentLat.toString(),
            currentLng.toString(),
            "0",
            area.toLowerCase());

        // print(data["place_name"]);
        //getUserCache();
      } else {
        throw Exception('Failed to load suggestions');
      }
    } catch (error) {
      print('Error: $error');
    }
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
    var responseTransaction =
        driverRepo.getTransaction(messageData["data"]["uid"]);
    responseTransaction.then((value) async {
      print("data transaction");
      var decodeData = jsonDecode(value)["data"];
      print(jsonDecode(jsonDecode(value)["data"]["transaction"])["nowlater"]);
      //print(jsonDecode(value)["data"]["customer"]["nama"]);
      //print(jsonDecode(value)["data"]["customer"]["phone"]);
      String nowLater =
          jsonDecode(jsonDecode(value)["data"]["transaction"])["nowlater"]
              .toString();
      double latUser = double.parse(
          jsonDecode(jsonDecode(value)["data"]["rute"])["location"][0]["lat"]);
      double lngUser = double.parse(
          jsonDecode(jsonDecode(value)["data"]["rute"])["location"][0]["lng"]);
      var distanceDriver =
          Geolocator.distanceBetween(currentLat, currentLng, latUser, lngUser);
      print(jsonDecode(decodeData["rute"])["location"]);

      /*  List<Location> locationList = [];

      List<dynamic> jsonList = jsonDecode(decodeData["rute"])["location"];
      print(jsonList[0]);
      for (int i = 0; i <= jsonList.length - 1; i++) {
        locationList.add(Location(
            address: jsonList[i]["address"],
            lat: jsonList[i]["lat"],
            lng: jsonList[i]["lng"]));
      } */
      /* print("hasil for");
      final cutFirstChar =
          jsonEncode(jsonDecode(decodeData["rute"])["location"]).substring(0);
      final sanitized = jsonDecode(decodeData["rute"])["location"];

      print(
          "sanitized ${jsonDecode(jsonEncode(jsonDecode(decodeData["rute"])["location"]))[0]['address']}"); */

      NotifListJob nofitListJob = NotifListJob(
          uid_transaction: decodeData["uid"].toString(),
          uid_user: decodeData["uid_user"].toString(),
          nama_user: messageData["data"]["nama_user"].toString(),
          distance: messageData["data"]["distance"].toString(),
          total_alamat: messageData["data"]["total_alamat"].toString(),
          tarif: messageData["data"]["tarif"].toString(),
          location: //"",
              jsonEncode(jsonDecode(decodeData["rute"])["location"]).toString(),
          jarak_driver: (distanceDriver / 1000).toStringAsFixed(2),
          waktu_jemput: nowLater == "1" ? "Sekarang" : nowLater.toString(),
          pembayaran: messageData["data"]["pembayaran"].toString(),
          waktu_pickup: jsonDecode(
              jsonDecode(value)["data"]["transaction"])["waktu_pickup"],
          isOpen: true,
          token_user: messageData["data"]["token_user"]);
      print("conversion notif");
      print(jsonEncode(nofitListJob));
      if (existingJsonString != null) {
        List<dynamic> existingList = jsonDecode(existingJsonString.toString());
        List<NotifListJob> existingJobs =
            existingList.map((map) => NotifListJob.fromJson(map)).toList();

        // Add new jobs to existing jobs
        //addListJobs(messageData);
        listJobs.clear();
        listJobs.add(nofitListJob);
        existingJobs.addAll(listJobs);

        // Convert the combined list to JSON
        List<Map<String, dynamic>> combinedJsonList =
            existingJobs.map((job) => job.toJson()).toList();

        String combinedJsonString = jsonEncode(combinedJsonList);
        List<NotifListJob> decodedJobList =
            combinedJsonList.map((map) => NotifListJob.fromJson(map)).toList();
        if (mounted) {
          setState(() {
            //listJobs2 = decodedJobList;
            listJobs2.addAll(listJobs);
            lengthListJobs2 = listJobs2.length;
          });
        }

        // Update SharedPreferences with the combined data
        await driverCache.setString("listJob", combinedJsonString);
      } else {
        //addListJobs(messageData);
        listJobs.clear();
        listJobs.add(nofitListJob);
        // If no existing data, store the new jobs directly as JSON
        List<Map<String, dynamic>> newJsonList =
            listJobs.map((job) => job.toJson()).toList();

        String newJsonString = jsonEncode(newJsonList);
        List<NotifListJob> decodedJobList =
            newJsonList.map((map) => NotifListJob.fromJson(map)).toList();
        if (mounted) {
          setState(() {
            //listJobs2 = decodedJobList;
            listJobs2.addAll(listJobs);
            lengthListJobs2 = listJobs2.length;
          });
        }

        await driverCache.setString("listJob", newJsonString);
      }
    });

    /* if (existingJsonString != null) {
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
    } */

    //driverCache.getString("listJob"));
  }

  Future<void> getUserCache() async {
    /*
    SharedPreferences cacheUser = await SharedPreferences.getInstance();
     Uri getTrafficeUrl = Uri.parse(
        "https://api.mapbox.com/directions/v5/mapbox/driving/${currentLng}%2C${currentLat}%3B${currentLng}%2C${currentLat}?alternatives=true&geometries=geojson&language=en&overview=full&steps=true&access_token=${accessTokenMapBox}");
    var getTraffice = await http.get(getTrafficeUrl); 
    setState(() {
      userModel.id =
          jsonDecode(cacheUser.get("userModel").toString())["id"].toString();
      userModel.email =
          jsonDecode(cacheUser.get("userModel").toString())["email"].toString();
      userModel.uid =
          jsonDecode(cacheUser.get("userModel").toString())["uid"].toString();
      userModel.deposit =
          jsonDecode(cacheUser.get("userModel").toString())["deposit"]
              .toString();
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
          jsonDecode(cacheUser.get("userModel").toString())["rating"]
              .toString();
      userModel.token =
          jsonDecode(cacheUser.get("userModel").toString())["token"].toString();
      dateBirthController.text =
          jsonDecode(userModel.dataAccount.toString())["tanggal_lahir"];

      latestArea = jsonDecode(jsonDecode(
          cacheUser.get("userModel").toString())["location"])["geofence"];
      bearing = jsonDecode(getTraffice.body)["routes"][0]["legs"][0]["steps"][0]
              ["intersections"][0]["bearings"][0]
          .toString();  
          
    });
    //print(jsonDecode(getTraffice.body));
    //print("lokasi");
    //print(jsonDecode(cacheUser.get("userModel").toString())["location"]);
    print("latest area : ${latestArea}");
    final newCurrentLocation = {
      "bearing": "0",
      "updated": DateTime.now().toString(),
      "geofence": area.toLowerCase(),
      "latitude": currentLat,
      "longitude": currentLng,
    };

    driverRepo.changeStatus(userModel.uid.toString(), "off", latestArea);
    Future.delayed(Duration(seconds: 1), () async {
      driverRepo.updateLocation(userModel.uid.toString(), currentLat.toString(),
          currentLng.toString(), "0", area);
      setState(() {
        userModel.location = jsonEncode(newCurrentLocation);
        cacheUser.setString("userModel", jsonEncode(userModel));
      });
    });
    */
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
          "Order baru dari ${message['data']['nama_user']} , total tujuan ${double.parse(message['data']['distance']) / 1000}km, dengan tarif Rp ${message['data']['tarif']}",
          notificationDetails,
          payload: 'item x');
    }
  }

/*   void addListJobs(var messageData) {
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
  } */

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
    bool isEdgeIndex(int index) {
      return index == 0 || index == message.location.length + 1;
    }

    List<dynamic> newLocations = jsonDecode(message.location);
    print(newLocations.length);
    showFlexibleBottomSheet<void>(
      isDismissible: false,
      minHeight: 0,
      initHeight: 0.7,
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Card(
                  elevation: 2,
                  child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Waktu jemput",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                    "${message.waktu_jemput == 'Sekarang' ? 'Sekarang' : message.waktu_pickup}")),
                          ]))),
              SizedBox(
                height: 5,
              ),
              Card(
                  elevation: 2,
                  child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Tujuan penumpang",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                    "${double.parse(message.distance) / 1000}km")),
                          ]))),
              Card(
                  elevation: 2,
                  child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Total lokasi",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                    "${double.parse(message.total_alamat)} lokasi")),
                          ]))),
              SizedBox(height: 5),
              Card(
                  elevation: 2,
                  child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Tarif",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                    "${rupiah.format(double.parse(message.tarif))}")),
                          ]))),
              SizedBox(height: 5),
              Card(
                  elevation: 2,
                  child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Pembayaran",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text("${message.pembayaran}")),
                          ]))),
              /* Text("Waktu pickup ${message.waktu_pickup}",
                  style: TextStyle(fontSize: 15)), */
              /*   Text(
                  "Jarak tujuan penumpang ${double.parse(message.distance) / 1000}km",
                  style: TextStyle(fontSize: 15)),
              Text("Total tujuan penumpang ${double.parse(message.total_alamat)}",
                  style: TextStyle(fontSize: 15)),
              Text("Tarif ${rupiah.format(double.parse(message.tarif))}",
                  style: TextStyle(fontSize: 15)),
              Text("Pembayaran ${message.pembayaran}",
                  style: TextStyle(fontSize: 15)), */
              SizedBox(
                height: 5,
              ),
              Card(
                elevation: 2,
                child: Container(
                  padding: EdgeInsets.all(4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Titik jemput",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.circle_outlined,
                              size: 20,
                              color: Colors.green,
                            ),
                            SizedBox(width: 10),
                            Container(
                                width: MediaQuery.of(context).size.width / 1.4,
                                child:
                                    Text(newLocations[0]["address"].toString()))
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Tujuan",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      LimitedBox(
                        maxHeight: 60,
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: newLocations.length - 1,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, bottom: 5),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.circle_outlined,
                                      size: 20,
                                      color: Colors.orange,
                                    ),
                                    SizedBox(width: 10),
                                    Container(
                                      width: MediaQuery.of(context).size.width /
                                          1.4,
                                      child: Text(newLocations[index + 1]
                                              ["address"]
                                          .toString()),
                                    )
                                  ],
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),

              /*   Row(
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
              ), */
              //Text("Jarak driver ${double.parse(message.jarak_driver)} km",
              //    style: TextStyle(fontSize: 15)),
              /* Text("Waktu jemput : ${message.waktu_jemput}",
                  style: TextStyle(fontSize: 15)), */
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Visibility(
                    visible: message.isOpen == true ? true : false,
                    child: MaterialButton(
                        padding: EdgeInsets.all(10),
                        color: Colors.greenAccent,
                        child: Text("Accept"),
                        onPressed: () {
                          driverRepo.acceptBid(
                              widget.userModel,
                              notifListJob,
                              "",
                              DriverLatLng(lat: currentLat, lng: currentLng),
                              widget.userModel);
                          //driverRepo.acceptWithoutNego(userModel, notifListJob);
                          showAccept(message, getIndex);
                        }),
                  ),
                  Visibility(
                    visible: message.isOpen == true ? true : false,
                    child: MaterialButton(
                        padding: EdgeInsets.all(10),
                        color: Colors.blueAccent,
                        child: Text(
                          "Nego",
                        ),
                        onPressed: () {
                          showOfferingDriver(context, message, getIndex);
                        }),
                  ),
                  MaterialButton(
                      padding: EdgeInsets.all(10),
                      color: Colors.grey,
                      child: Text(
                        "Decline",
                      ),
                      onPressed: () {
                        setState(() {
                          listJobs2[getIndex].isOpen = false;
                        });
                        Navigator.pop(context);
                      }),
                ],
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
                        widget.userModel,
                        notifListJob,
                        offeringController.intValue.toString(),
                        DriverLatLng(lat: currentLat, lng: currentLng),
                        widget.userModel);
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
                              icon: Icon(Icons.menu)),
                          Row(
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
                                          PopupLoading();
                                          DriverRepo()
                                              .getProfile()
                                              .then((value) {
                                            if (value.dataDriver == null) {
                                              QuickAlert.show(
                                                  context: context,
                                                  type: QuickAlertType.confirm,
                                                  title:
                                                      "Data driver anda belum lengkap",
                                                  barrierDismissible: false,
                                                  confirmBtnText: "Lengkapi",
                                                  onConfirmBtnTap: () {
                                                    Navigator.of(context,
                                                            rootNavigator: true)
                                                        .pop();
                                                    Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                BerkasDriver(
                                                                    //user: widget.user,
                                                                    userModel:
                                                                        value)));
                                                  },
                                                  cancelBtnText: "Ngga dulu",
                                                  onCancelBtnTap: () =>
                                                      Navigator.of(context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop());
                                            } else {
                                              if (isOnline) {
                                                setState(() {
                                                  isOnline = false;
                                                  isOnlineText = "Offline";
                                                  var response =
                                                      driverRepo.changeStatus(
                                                          widget.userModel.uid
                                                              .toString(),
                                                          "off",
                                                          area);
                                                  print(response);
                                                });
                                              } else {
                                                setState(() {
                                                  isOnline = true;
                                                  isOnlineText = "Online";
                                                  var response =
                                                      driverRepo.changeStatus(
                                                          widget.userModel.uid
                                                              .toString(),
                                                          "on",
                                                          area);
                                                  print(response);
                                                });
                                              }
                                            }
                                          });
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
          /* SelectableText(widget.userModel.uid.toString()), */
          Container(
            width: width,
            height: height * 0.75,
            child: listJobs2.isEmpty
                ? Container()
                : ListView.builder(
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
                            color:
                                listJobs2[lengthListJobs2 - 1 - index].isOpen ==
                                        true
                                    ? Colors.lightGreen
                                    : Colors.grey[100]),
                        margin: EdgeInsets.only(bottom: 5, left: 10, right: 10),
                        child: ListTile(
                          onTap: () {
                            setState(() {
                              notifListJob =
                                  listJobs2[lengthListJobs2 - 1 - index];
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
                                "Tujuan penumpang ${double.parse(listJobs2[lengthListJobs2 - 1 - index].distance) / 1000} km",
                              ),
                              Text(
                                  "Tarif ${rupiah.format(double.parse(listJobs2[lengthListJobs2 - 1 - index].tarif))}"),
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
                  ProfileScreen()
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
            userModel: widget.userModel,
            isDriver: widget.isDriver,
            area: latestArea,
          );
        },
      ),
    );
  }
}
