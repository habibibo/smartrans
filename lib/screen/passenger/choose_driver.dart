//import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'dart:async';
import 'dart:convert';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:currency_textfield/currency_textfield.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_sliding_box/flutter_sliding_box.dart';
//import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:linear_timer/linear_timer.dart';
import 'package:logo_n_spinner/logo_n_spinner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signgoogle/model/driver_model.dart';
import 'package:signgoogle/model/fitur.dart';
import 'package:signgoogle/model/near_driver.dart';
import 'package:signgoogle/model/notif/notif_list_job.dart';
import 'package:signgoogle/model/payment_method.dart';
import 'package:signgoogle/screen/passenger/live_tracking.dart';
import 'package:signgoogle/screen/passenger/ride.dart';
//import 'package:jubercar/screens/home/member/choose_map.dart';
import 'package:signgoogle/utils/SmartransColor.dart';
import 'package:latlong2/latlong.dart';
//import 'package:location2/location2.dart' as location2;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:signgoogle/utils/api.dart';
import 'package:signgoogle/utils/basic_auth.dart';
//import 'package:location/location.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import 'package:flutter_map_directions/flutter_map_directions.dart'
    as flutterMapDirection;
import 'package:http/http.dart' as http;

int id = 0;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

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

const String urlLaunchActionId = 'id_1';

const String navigationActionId = 'id_3';

const String darwinNotificationCategoryText = 'textCategory';

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
}

var initializationSettingsAndroid = AndroidInitializationSettings(
    '@mpimap/ic_launcher'); // <- default icon name is @mipmap/ic_launcher
var initializationSettingsIOS = DarwinInitializationSettings();
var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

Future<void> _showCustomNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('0', 'your channel name',
          channelDescription: 'your channel description',
          importance: Importance.max,
          //priority: Priority.high,
          icon: '@drawable/icon_smartrans',
          ticker: 'ticker');
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);
  await flutterLocalNotificationsPlugin.show(
      id++,
      message.notification?.title.toString(),
      message.notification?.body.toString(),
      notificationDetails,
      payload: 'item x');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final List<flutterMapDirection.LatLng> directionLatLng = [];
  final List<Feature> features = [];
  final String getDisatance = "";
  GoogleSignInAccount? user;
  runApp(ChooseDriver(
      user: user,
      directionLatLng: directionLatLng,
      features: features,
      getDisatance: getDisatance));
  // runApp(const MyApp());
}

class ChooseDriver extends StatefulWidget {
  ChooseDriver(
      {Key? key,
      required this.user,
      required this.directionLatLng,
      required this.features,
      required this.getDisatance})
      : super(key: key);
  final List<flutterMapDirection.LatLng> directionLatLng;
  final List<Feature> features;
  final String getDisatance;
  GoogleSignInAccount? user;

  @override
  State<ChooseDriver> createState() => _ChooseDriverState();
}

class _ChooseDriverState extends State<ChooseDriver> {
  String scheduleDate =
      "${DateTime.now().year} - ${DateTime.monthsPerYear} - ${DateTime.now().day}";
  // "${DateTime.now().day} - ${DateTime.monthsPerYear} - ${DateTime.now().year}";
  String scheduleTime = "${DateTime.now().hour}.${DateTime.now().minute}";
  String paymentMethod = "";
  String promo = "Promo";
  String scheduleMethod = "";
  bool dragg = true;
  final PanelController panelController = PanelController();
  PanelState panelState = PanelState.CLOSED;
  DateTime changeDateTomorrow = DateTime.now().add(Duration(days: 1));
  DateTime changeDateSchedule = DateTime.now().add(Duration(days: 1));
  String changeTimeNow = "${DateTime.now().hour} : ${DateTime.now().minute}";
  TextEditingController _searchController = TextEditingController();
  //Location location = Location();
  final BoxController boxController = BoxController();
  //final LatLng _center = const LatLng(45.521563, -122.677433);

  //LatLng _initialCameraPosition = LatLng(0.0, 0.0);
  num lat = 0;
  num lng = 0;

  int selectedIndex = -1;
  String defaultPrice = "";
  String offerPrice = "";
  TextEditingController offerPriceController = TextEditingController();
  bool showVisibleOffer = false;
  bool hideDefaultPrice = true;
  List<bool> negoToggled =
      List.filled(20, false); // Track if "Nego" is toggled for each item
  List<String> suggestions = [];
  MapController _mapController = MapController();
  List<flutterMapDirection.LatLng> newLatLng = [];
  List<DateTime> dates = [];
  List<PaymentMethod> paymentMethods = [];

  bool visible1 = true;
  String minPrice = "";
  String maxOffer = "";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    disableDates();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      var dataBody = jsonDecode(
          jsonEncode(jsonDecode(message.notification!.body.toString())));
      print('Got a message whilst in the foreground!');
      print('Message data: ${dataBody["mode"]}');

      messageConversion(dataBody, message.notification!.title.toString());
      print("from main");
    });
    getPaymentMethod();
    //convertToDirection();
  }

  mapbox.MapboxMap? mapboxMap;

  _onMapCreated(mapbox.MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
  }

  Future<void> messageConversion(var messageData, String title) async {
    _showNotification(messageData, title);
    final SharedPreferences driverCache = await SharedPreferences.getInstance();
    String? existingJsonString = driverCache.getString("listJob");
    print(existingJsonString);
    /*  if (existingJsonString != null) {
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

    print(driverCache.getString("listJob"));
  }

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

  Future<void> _getCurrentLocation() async {
    print("data ${widget.directionLatLng.length}");
    _mapController.move(
        LatLng(widget.directionLatLng[0].latitude,
            widget.directionLatLng[0].longitude),
        18.0);
  }

  Widget showPanel(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 15),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              )),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Tipe kendaraan",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        )),
                  ],
                ),
              ),
              Container(
                height: 100,
                child: ListView.builder(
                    itemCount: widget.features.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selectedIndex != index) {
                              // Reset strike-through when another item is selected
                              selectedIndex = index;
                              negoToggled =
                                  List.filled(widget.features.length, false);
                              showVisibleOffer = false;
                              //defaultPrice = "";
                              defaultPrice = double.parse(widget
                                      .features[selectedIndex].price.price
                                      .toString())
                                  .toString();
                              minPrice = double.parse(widget
                                      .features[selectedIndex].price.minPrice
                                      .toString())
                                  .toString();
                              maxOffer = double.parse(widget
                                      .features[selectedIndex].price.maxTawar
                                      .toString())
                                  .toString();
                              print(defaultPrice);
                            } else {
                              selectedIndex =
                                  -1; // Deselect if the same item is selected again
                            }
                          });
                        },
                        child: Card(
                          color: selectedIndex == index
                              ? Colors
                                  .orange[100] // Change color for selected item
                              : Colors.white,
                          elevation: 4,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(widget.features[index].name,
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            child: selectedIndex == index
                                                ? Column(
                                                    children: [
                                                      Text(
                                                        "Rp ${widget.features[index].price.price.toString()}",
                                                        //"Rp price card",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            decoration: negoToggled[
                                                                    index]
                                                                ? TextDecoration
                                                                    .lineThrough // Apply strike-through if "Nego" is toggled
                                                                : null),
                                                      ),
                                                      Visibility(
                                                        visible:
                                                            showVisibleOffer,
                                                        child: Text(
                                                          offerPrice,
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Text(
                                                    "Rp ${widget.features[index].price.price.toString()}",
                                                    //"Rp price card",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                          ),
                                          Container(
                                            child: selectedIndex == index
                                                ? InkWell(
                                                    onTap: () {
                                                      showOffer(context, index);
                                                    },
                                                    child: Card(
                                                      elevation: 2,
                                                      color: Colors.orange,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        child: Text(
                                                          "Nego",
                                                          style: TextStyle(
                                                              fontSize: 10),
                                                        ),
                                                      ),
                                                    ),
                                                  ) // Change color for selected item
                                                : Container(),
                                          ),
                                          SizedBox(width: 10),
                                          Icon(Icons.alarm),
                                          SizedBox(width: 5),
                                          Text(
                                            "1-10 menit",
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Image.network(
                                  widget.features[index].iconUrl,
                                  height: 70,
                                  width: 40,
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  final CurrencyTextFieldController offeringController =
      CurrencyTextFieldController(
    currencySymbol: "Rp",
    thousandSymbol: ".",
    decimalSymbol: "",
    enableNegative: false,
    numberOfDecimals: 0,
  );

  void showOffer(BuildContext context, thisIndex) {
    setState(() {
      offeringController.text = "";
    });
    showFlexibleBottomSheet<void>(
        minHeight: 0,
        initHeight: 0.6,
        maxHeight: 1,
        context: context,
        isSafeArea: false,
        bottomSheetColor: Colors.transparent,
        builder: (context, controller, offset) {
          return Container(
            padding: EdgeInsets.only(left: 10, right: 10, top: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  child: TextField(
                    textAlign: TextAlign.center,
                    controller: offeringController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 25),
                    decoration: InputDecoration(),
                    onChanged: (value) {
                      offeringController.text = value;
                    },
                    autofocus: true,
                  ),
                ),
                Container(
                  child: MaterialButton(
                    onPressed: () {
                      print(offeringController.intValue);
                      if (double.parse(offeringController.intValue.toString()) <
                          double.parse(minPrice)) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "Penawaran anda terlalu rendah dari harga Rp ${minPrice}")));
                      } else {
                        /* if (double.parse(
                                offeringController.intValue.toString()) >
                            (double.parse(maxOffer) +
                                double.parse(defaultPrice))) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "Penawaran anda melampau batas tertinggi dari harga Rp ${double.parse(maxOffer + defaultPrice)}")));
                        } else { */
                        setState(() {
                          offerPrice = offeringController.text;
                          showVisibleOffer = true;
                          //negoToggled[thisIndex] = !negoToggled[thisIndex];
                          negoToggled[thisIndex] = true;
                        });
                        Navigator.pop(context);
                        // }
                      }
                    },
                    child: Text(
                      "Coba nego",
                      style: TextStyle(fontSize: 25, color: Colors.white),
                    ),
                    minWidth: double.infinity,
                    height: 50,
                    color: primaryColor,
                  ),
                )
              ],
            ),
          );
        });
  }

  void showPayment(BuildContext context) {
    showFlexibleBottomSheet<void>(
        minHeight: 0,
        initHeight: 0.8,
        maxHeight: 1,
        context: context,
        isSafeArea: false,
        bottomSheetColor: Colors.white,
        builder: (context, controller, offset) {
          return Container(
              padding: EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              )),
              child: ListView.builder(
                  itemCount: paymentMethods.length,
                  itemBuilder: ((context, index) {
                    return ListTile(
                      style: ListTileStyle.drawer,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 2, color: Colors.blue),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onTap: () {
                        setState(() {
                          paymentMethod = jsonEncode({
                            "id": paymentMethods[index]
                                .idPaymentmethod
                                .toString(),
                            "name":
                                paymentMethods[index].paymentmethod.toString()
                          });
                          Navigator.pop(context);
                        });
                      },
                      leading: Image.network(
                        paymentMethods[index].icon.toString(),
                        height: 50,
                        width: 50,
                      ),
                      trailing: paymentMethods[index].imageQr != ""
                          ? Image.network(
                              paymentMethods[index].imageQr.toString())
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.payments_rounded,
                                size: 45,
                                color: Colors.green,
                              ),
                            ),
                      title:
                          Text(paymentMethods[index].paymentmethod.toString()),
                    );
                  })));
        });
  }

  void showVoucher(BuildContext context) {
    const Color primaryColor = Colors.pinkAccent;
    const Color secondaryColor = Colors.pinkAccent;
    showFlexibleBottomSheet<void>(
        minHeight: 0,
        initHeight: 0.8,
        maxHeight: 1,
        context: context,
        isSafeArea: false,
        bottomSheetColor: Colors.transparent,
        builder: (context, controller, offset) {
          return Container(
              padding: EdgeInsets.only(left: 10, right: 10, top: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        promo = "Merdeka";
                      });
                      Navigator.pop(context);
                    },
                    child: CouponCard(
                      height: 120,
                      backgroundColor: Colors.yellow[400],
                      clockwise: true,
                      curvePosition: 135,
                      curveRadius: 30,
                      curveAxis: Axis.vertical,
                      borderRadius: 10,
                      firstChild: Container(
                        decoration: const BoxDecoration(
                          color: primaryColor,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Text(
                                      '23%',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'OFF',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(color: Colors.white54, height: 0),
                            Expanded(
                              child: Center(
                                child: InkWell(
                                  child: Card(
                                    color: Colors.pink,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text(
                                        "Pakai sekarang",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      secondChild: Container(
                        width: double.maxFinite,
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Kupon',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'MERDEKA',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                color: secondaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            Text(
                              'Valid Till - 30 Desember 2023',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        promo = "Member Baru";
                      });
                      Navigator.pop(context);
                    },
                    child: CouponCard(
                      height: 120,
                      backgroundColor: Colors.yellow[400],
                      clockwise: true,
                      curvePosition: 135,
                      curveRadius: 30,
                      curveAxis: Axis.vertical,
                      borderRadius: 10,
                      firstChild: Container(
                        decoration: const BoxDecoration(
                          color: primaryColor,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Text(
                                      '50%',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'OFF',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(color: Colors.white54, height: 0),
                            Expanded(
                              child: Center(
                                child: InkWell(
                                  child: Card(
                                    color: Colors.pink,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text(
                                        "Pakai sekarang",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      secondChild: Container(
                        width: double.maxFinite,
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Kupon',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Member Baru',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                color: secondaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            Text(
                              'Valid Till - 30 Desember 2023',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ));
        });
  }

  void disableDates() {
    int _disableDates = DateTime.now().day.toInt();
    for (int i = _disableDates; i >= 1; i--) {
      setState(() {
        dates.add(DateTime(DateTime.now().year, DateTime.now().month, i));
      });
    }
  }

  void showSchedule(BuildContext context) {
    const Color primaryColor = Color(0xfff1e3d3);
    const Color secondaryColor = Color(0xffd88c9a);
    //Time _time = Time(hour: 11, minute: 30, second: 20);
    Time _time = Time(
        hour: TimeOfDay.now().hour, minute: TimeOfDay.now().minute, second: 0);
    Time _timeTomorrow = Time(
        hour: TimeOfDay.now().hour, minute: TimeOfDay.now().minute, second: 0);

    bool iosStyle = true;

    void onTimeChanged(Time newTime) {
      setState(() {
        _time = newTime;
        scheduleDate = DateTime.now().toString().substring(0, 10);
        scheduleTime = "${newTime.hour} : ${newTime.minute}";
        print(newTime);
      });
      Navigator.pop(context);
      //Navigator.pop(context);
    }

    void onChangeDateTomorrow(DateTime newDateTime) {
      setState(() {
        scheduleDate = newDateTime.toString().substring(0, 10);
      });
      print(newDateTime);
    }

    void onChangeTimeTomorrow(Time newTime) {
      setState(() {
        _timeTomorrow = newTime;
        changeTimeNow = "${newTime.hour} : ${newTime.minute}";
        scheduleTime = changeTimeNow;
        print(newTime);
        if (scheduleDate ==
            DateTime.now().toLocal().toString().substring(0, 10)) {
          scheduleDate = DateTime.now()
              .add(Duration(days: 1))
              .toLocal()
              .toString()
              .substring(0, 10);
        }
      });

      print(DateTime.now().toLocal().toString().substring(0, 10));
      print(changeDateTomorrow);
      print(scheduleDate);
      Navigator.pop(context);
      Navigator.pop(context);
    }

    showFlexibleBottomSheet<void>(
        minHeight: 0,
        initHeight: 0.2,
        maxHeight: 1,
        context: context,
        isSafeArea: false,
        bottomSheetColor: Colors.transparent,
        builder: (context, controller, offset) {
          return Container(
              padding:
                  EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              child: Column(children: [
                Container(
                  padding: EdgeInsets.all(10),
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        padding: EdgeInsets.all(5),
                        child: MaterialButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              showPicker(
                                context: context,
                                iosStylePicker: true,
                                is24HrFormat: true,
                                value: _time,
                                sunrise:
                                    TimeOfDay(hour: 6, minute: 0), // optional
                                sunset:
                                    TimeOfDay(hour: 18, minute: 0), // optional
                                duskSpanInMinutes: 60, // optional
                                onChange: onTimeChanged,
                              ),
                            );
                          },
                          color: Colors.green,
                          child: Text(
                            "Hari ini",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        child: MaterialButton(
                          onPressed: () {
                            setState(() {
                              changeDateTomorrow =
                                  DateTime.now().add(Duration(days: 1));
                            });
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    content: Container(
                                      width: 350,
                                      height: 540,
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 320,
                                            height: 180,
                                            color: Colors.white,
                                            child: EasyDateTimeLine(
                                                headerProps: EasyHeaderProps(
                                                    showMonthPicker: false),
                                                disabledDates: dates,
                                                initialDate: changeDateTomorrow,
                                                onDateChange:
                                                    onChangeDateTomorrow
                                                /* (DateTime selectedDate) {
                                                //`selectedDate` the new date selected.
                                                setState(() {
                                                  scheduleDate = selectedDate
                                                      .toString()
                                                      .substring(0, 10);
                                                });
                                              }, */
                                                ),
                                          ),
                                          Container(
                                            //width: 350,
                                            height: 360,
                                            child: showPicker(
                                              height: 350,
                                              dialogInsetPadding:
                                                  EdgeInsets.all(0),
                                              iosStylePicker: true,
                                              is24HrFormat: true,
                                              value: _timeTomorrow,
                                              //hideButtons: true,
                                              isInlinePicker: true,
                                              minuteInterval:
                                                  TimePickerInterval.FIVE,
                                              sunrise: TimeOfDay(
                                                  hour: 6,
                                                  minute: 0), // optional
                                              sunset: TimeOfDay(
                                                  hour: 18,
                                                  minute: 0), // optional
                                              duskSpanInMinutes: 60, // optional
                                              onChange: onChangeTimeTomorrow,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          },
                          color: Colors.blue,
                          child: Text(
                            "Besok",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        child: MaterialButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    content: Container(
                                      width: 350,
                                      height: 540,
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 320,
                                            height: 180,
                                            color: Colors.white,
                                            child: EasyDateTimeLine(
                                                disabledDates: dates,
                                                initialDate: changeDateSchedule,
                                                onDateChange:
                                                    onChangeDateTomorrow),
                                          ),
                                          Container(
                                            //width: 350,
                                            height: 360,
                                            child: showPicker(
                                              barrierColor: Colors.transparent,
                                              height: 350,
                                              dialogInsetPadding:
                                                  EdgeInsets.all(0),
                                              iosStylePicker: true,
                                              is24HrFormat: true,
                                              value: _timeTomorrow,
                                              //hideButtons: true,
                                              isInlinePicker: true,
                                              minuteInterval:
                                                  TimePickerInterval.FIVE,

                                              sunrise: TimeOfDay(
                                                  hour: 6,
                                                  minute: 0), // optional
                                              sunset: TimeOfDay(
                                                  hour: 18,
                                                  minute: 0), // optional
                                              duskSpanInMinutes: 60, // optional
                                              onChange: onChangeTimeTomorrow,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          },
                          color: Colors.pink,
                          child: Text(
                            "Jadwalkan",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]));
        });
  }

  Widget bodyCollapsed() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 15),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              )),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Tipe kendaraan",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        )),
                  ],
                ),
              ),
              Container(
                height: 240,
                child: ListView.builder(
                    itemCount: widget.features.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selectedIndex != index) {
                              // Reset strike-through when another item is selected
                              selectedIndex = index;
                              negoToggled = List.filled(20, false);
                              showVisibleOffer = false;
                              //defaultPrice = "";
                              defaultPrice = (double.parse(widget
                                      .features[selectedIndex].price.price))
                                  .toString();
                              minPrice = double.parse(widget
                                      .features[selectedIndex].price.minPrice
                                      .toString())
                                  .toString();
                              maxOffer = double.parse(widget
                                      .features[selectedIndex].price.maxTawar
                                      .toString())
                                  .toString();
                              print(defaultPrice);
                            } else {
                              selectedIndex =
                                  -1; // Deselect if the same item is selected again
                            }
                          });
                        },
                        child: Card(
                          color: selectedIndex == index
                              ? Colors
                                  .orange[100] // Change color for selected item
                              : Colors.white,
                          elevation: 4,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(widget.features[index].name,
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            child: selectedIndex == index
                                                ? Column(
                                                    children: [
                                                      Text(
                                                        "Rp ${widget.features[index].price.price}",
                                                        // "Rp price card",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            decoration: negoToggled[
                                                                    index]
                                                                ? TextDecoration
                                                                    .lineThrough // Apply strike-through if "Nego" is toggled
                                                                : null),
                                                      ),
                                                      Visibility(
                                                        visible:
                                                            showVisibleOffer,
                                                        child: Text(
                                                          offerPrice,
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Text(
                                                    "Rp ${widget.features[index].price.price.toString()}",
                                                    //"Rp price card",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                          ),
                                          Container(
                                            child: selectedIndex == index
                                                ? InkWell(
                                                    onTap: () {
                                                      showOffer(context, index);
                                                    },
                                                    child: Card(
                                                      elevation: 2,
                                                      color: Colors.orange,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        child: Text(
                                                          "Nego",
                                                          style: TextStyle(
                                                              fontSize: 10),
                                                        ),
                                                      ),
                                                    ),
                                                  ) // Change color for selected item
                                                : Container(),
                                          ),
                                          SizedBox(width: 10),
                                          Icon(Icons.alarm),
                                          SizedBox(width: 5),
                                          Text(
                                            "1-10 menit",
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Image.network(
                                  widget.features[index].iconUrl,
                                  height: 70,
                                  width: 40,
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  late LinearTimerController linearTimerController;
  //List<bool> _timerCompleted = List.generate(5, (_) => false);
  /* Future<void> showListDriver() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              content: Container(
            width: 250,
            height: 350,
            child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return _timerCompleted[index]
                      ? Container()
                      : Container(
                          width: 220,
                          child: Card(
                              child: Column(
                            children: [
                              LinearTimer(
                                duration: Duration(seconds: 5),
                                forward: false,
                                color: primaryColor,
                                onTimerEnd: () {
                                  /* setState(() {
                                    _timerCompleted[index] = true;
                                  }); */
                                },
                              ),
                              ListTile(
                                contentPadding: EdgeInsets.all(8.0),
                                leading: Icon(Icons.person),
                                title: Text("Budi ${index}"),
                                trailing: Icon(Icons.car_rental),
                                subtitle: Text("W1212L0"),
                              ),
                            ],
                          )));
                }),
          ));
        });
  } */

  Future<void> findNearbyDriver(BuildContext context) async {
    SharedPreferences cacheUser = await SharedPreferences.getInstance();
    String userToken = cacheUser.getString("userModel").toString();
    print(offerPriceController.text);
    try {
      final messageData = {
        "to": "/topics/surabaya",
        "priority": "high",
        "direct_boot_ok": true,
        "ttl": "60",
        "notification": {
          "title": "New Transaction",
          "body": {
            "type": "new_transactions",
            "mode": "driver",
            "data": {
              "distance": widget.getDisatance,
              "total_alamat": widget.directionLatLng.length,
              "tarif":
                  offerPriceController.text == 0 ? defaultPrice : offerPrice,
              "jarak_driver": 0,
              "waktu_jemput": 0,
              "pembayaran": paymentMethod,
              "waktu_pickup": "${scheduleDate} ${scheduleTime}",
              "isOpen": true,
              "uid_user": jsonDecode(userToken)["uid"],
              "nama_user": widget.user!.displayName,
              "token_user": jsonDecode(userToken)["token"]
            }
          }
        }
      };

      var responseDriver = await http.post(
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

      print(responseDriver.body);
      /*
      var response = await http.post(
        Uri.parse(ApiNetwork().oldUrl + To().oldNearbyDriver),
        headers: <String, String>{
          'Authorization': basicAuth,
          'Content-Type': "application/json; charset=UTF-8",
        },
        // use for this user
        body: jsonEncode(<String, String>{
          "latitude": widget.directionLatLng.first.latitude.toString(),
          "longitude": widget.directionLatLng.first.longitude.toString(),
          "fitur": widget.features.first.id.toString()
        }),
      );

      print("sign params");
      
      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          print("Data is empty");
        }

        final messageData = {
          "to":
              "elAG-ZXgRPKlkOFxfp4m6s:APA91bFCU9KjPBTO5g2KTNsVHEgByZgacK0zOCZ7AzcYfI9hjcSBS48O3Xy2xFDG-XDGntvzxClDnnERb76JRBC-bbe0i-I1Ieoh5qnrl9wQYBS17sxuxih6uE4Doy71wN8Dv3rsLkub",
          "notification": {
            "title": "bidding",
            "body": {
              "type": "notif_driver_job",
              "mode": "driver",
              "data": [
                {
                  "id_passenger": "1",
                  "nama_passenger": widget.user!.displayName.toString(),
                  "jarak_tujuan": widget.getDisatance,
                  "total_alamat": 2,
                  "tarif": defaultPrice,
                  "bid": offerPrice,
                  "jarak_driver": 5400,
                  "waktu_jemput": 300,
                  "pembayaran": paymentMethod,
                  "tanggal": scheduleDate,
                  "jam": scheduleTime,
                  "isOpen": true,
                  "tokenPassenger":
                      "e4cniyOySa6ueOx4f1Md6m:APA91bEu9DTWqZwbBS8WDbhdO1as1RcvPTQ9yST8bWUH9IW5Eao-h-yVyfZE17Ty_XoLcsfqI4ZOh3sJhYP0rBSD6wlckSD6xde6umPEiSK7z1OlpN6kpC_PhWjEpmGQElLUJDe0bZFD",
                }
              ]
            }
          }
        }; 
        

        var data = jsonEncode(json.decode(response.body)["data"]);
        List<dynamic> parsedJson = jsonDecode(data);
        List<NearDriver> driversList =
            parsedJson.map((e) => NearDriver.fromJson(e)).toList();
        showDriverListNew(driversList, context);
        print(parsedJson);
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
      */
    } catch (error) {
      print('Error: $error');
    }
  }

  List<LinearTimerController> linearTimerControllers = [];
  Future<void> showDriverListNew(
      List<NearDriver> driversList, BuildContext context) async {
    /* int currentShowIndex = 0;
    for (int i = 0; i < driversList.length; i++) {
      await Future.delayed(
          Duration(seconds: 2)); // Display each item for 6 seconds
      //if (currentShowIndex < driversList.length - 1) {
      setState(() {
        currentShowIndex++;
      });
      //}
    } */
    List<Widget> widgetContainer = [];
    late List<bool> isVisibleList;
    isVisibleList = List.filled(driversList.length, false);
    // Initialize timers for hiding containers after 7 seconds
    /* for (int index = 0; index < driversList.length; index++) {
      Timer(Duration(seconds: 7), () {
        if (mounted) {
          setState(() {
            isVisibleList[index] = false; // Hide the Container after 7 seconds
          });
        }
      });
    } */
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(0),
            backgroundColor: Colors.transparent,
            content: DialogContent(
              isVisibleList:
                  isVisibleList, // Replace with your list of visibility
              driversList: driversList, // Replace with your list of drivers
            ),
          );
        });
  }

  Future<void> getPaymentMethod() async {
    var response = await http.post(
      Uri.parse(ApiNetwork().baseUrl + To().paymentMethod),
      headers: <String, String>{
        'Authorization': basicAuth,
        'Content-Type': "application/json; charset=UTF-8",
      },
      // use for this user
      body: jsonEncode(<String, String>{
        "service": "ride",
        "total": "40",
        "area": "surabaya"
      }),
    );
    print("payment method");
    List<dynamic> fromFitur = jsonDecode(response.body)["data"]["fitur"];
    List<PaymentMethod> payments =
        fromFitur.map((map) => PaymentMethod.fromJson(map)).toList();

    setState(() {
      paymentMethods.addAll(payments);
    });

    //print(jsonDecode(response.body)["data"]["fitur"]);
    print(jsonEncode(paymentMethods));
  }

  Future<bool> backToRide() async {
    Navigator.of(context).pop();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => backToRide(),
      child: Scaffold(
        body: SlidingBox(
          controller: boxController,
          minHeight: 200,
          maxHeight: 320,
          //color: Theme.of(context).colorScheme.background,
          style: BoxStyle.sheet,
          backdrop: Backdrop(
              appBar: BackdropAppBar(
                  title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                      onPressed: () {
                        //GoogleSignInAccount? user = widget.user;
                        //print("print");
                        //authBloc.add(GoingPassenger());
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PassengerRide(
                                      user: widget.user,
                                    )));
                      },
                      icon: Icon(
                        Icons.arrow_circle_left,
                        size: 45,
                      ))
                ],
              )),
              // overlay: true,
              color: Theme.of(context).colorScheme.background,
              body: FlutterMap(
                options: MapOptions(
                  center: LatLng(widget.directionLatLng[0].latitude,
                      widget.directionLatLng[0].longitude),
                  zoom: 12,
                  //bounds: LatLngBounds()
                ),
                mapController: _mapController,
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://api.mapbox.com/styles/v1/bibohabib/clpqqrem1014q01o962k54da8/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiYmlib2hhYmliIiwiYSI6ImNscG04MGVzdDA2MWUya3FtdDMxbDBuNDUifQ.ivQ5qmo7cPT4FaC6Q2aalQ",
                    additionalOptions: {
                      'accessToken':
                          'sk.eyJ1IjoiYmlib2hhYmliIiwiYSI6ImNscG5tMGtsYzBwN2UybW9icGk2ZzY5emcifQ.UneRCntojkFKhKCdEQKosg',
                      'id': 'mapbox.streets',
                    },
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(widget.directionLatLng[0].latitude,
                            widget.directionLatLng[0].longitude),
                        builder: (ctx) => Container(
                          child: Icon(
                            Icons.account_circle,
                            color: Colors.red.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(widget.directionLatLng.last.latitude,
                            widget.directionLatLng.last.longitude),
                        builder: (ctx) => Container(
                          margin: EdgeInsets.only(bottom: 12, left: 37),
                          child: Transform.rotate(
                            angle: 180 * pi / 180,
                            child: Icon(
                              Icons.water_drop,
                              color: Colors.red.shade500,
                              size: 35,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  flutterMapDirection.DirectionsLayer(
                    //coordinates: latlngs2,
                    coordinates: widget.directionLatLng,
                    color: Colors.blueAccent,
                    strokeWidth: 2,
                  ),
                ],
              )),
          body: bodyCollapsed(),
          collapsed: true,
          collapsedBody: showPanel(context),
        ),
        persistentFooterButtons: [
          Container(
            padding: EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        showPayment(context);
                      },
                      child: Row(
                        children: [
                          Text(
                            paymentMethod == ""
                                ? "Payment"
                                : jsonDecode(paymentMethod)["name"],
                            style: TextStyle(fontSize: 15),
                          ),
                          Icon(Icons.chevron_right)
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            showVoucher(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: Colors.deepOrange,
                            ),
                            padding: EdgeInsets.all(5),
                            child: Text(
                              promo == "" ? "Promo" : promo,
                              style:
                                  TextStyle(fontSize: 15, color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          onTap: () {
                            showSchedule(context);
                          },
                          child: Icon(
                            Icons.calendar_month_rounded,
                            size: 28,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Text(scheduleMethod),
                SizedBox(
                  height: 5,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      )),
                  child: MaterialButton(
                    minWidth: double.infinity,
                    onPressed: () async {
                      if (defaultPrice != "") {
                        if (paymentMethod != "") {
                          findNearbyDriver(context);
                          //getPaymentMethod();
                        } else {
                          await ScaffoldMessenger.of(context).showSnackBar(
                              new SnackBar(
                                  backgroundColor: Colors.red[450],
                                  content: Text(
                                      "Anda belum memilih metode pembayaran")));
                        }
                      } else {
                        await ScaffoldMessenger.of(context).showSnackBar(
                            new SnackBar(
                                backgroundColor: Colors.red[450],
                                content:
                                    Text("Anda belum memilih tipe kendaraan")));
                      }
                    },
                    height: 45,
                    color: primaryColor,
                    child: Text(
                      "Pesan Sekarang",
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    boxController.dispose();
    super.dispose();
  }
}

class DialogContent extends StatefulWidget {
  final List<bool> isVisibleList;
  final List<NearDriver> driversList;

  const DialogContent(
      {Key? key, required this.isVisibleList, required this.driversList})
      : super(key: key);

  @override
  _DialogContentState createState() => _DialogContentState();
}

class _DialogContentState extends State<DialogContent> {
  @override
  void initState() {
    super.initState();
    for (int i = 0; i <= widget.driversList.length; i++) {
      Future.delayed(Duration(seconds: i * 2), () {
        print("${i} true");
        setState(() {
          widget.isVisibleList[i] = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 900,
      height: 500,
      child: ListView.builder(
          itemCount: widget.driversList.length,
          itemBuilder: (context, index) {
            return Visibility(
              visible: widget.isVisibleList[index],
              child: Container(
                  child: Card(
                      child: Column(
                children: [
                  Container(
                    child: Column(
                      children: [
                        LinearTimer(
                          duration: Duration(seconds: 5),
                          forward: false,
                          color: primaryColor,
                          onTimerEnd: () {
                            setState(() {
                              print("remove ${index}");
                              //widget.driversList.removeAt(index);
                              widget.isVisibleList[index] = false;
                              if (index == widget.driversList.length - 1) {
                                Navigator.pop(context);
                              }
                            });
                          },
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.all(8.0),
                          leading: Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(80))),
                            height: 80,
                            width: 55,
                            child: ClipOval(
                              child: Image.network(
                                widget.driversList[index].foto.toString(),
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.person);
                                },
                              ),
                            ),
                          ),
                          title: Text(
                            widget.driversList[index].namaDriver.toString(),
                            style: TextStyle(fontSize: 14),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                "Rp 25.000",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                  (double.parse(widget
                                              .driversList[index].distance
                                              .toString()) /
                                          1000)
                                      .toString(),
                                  style: const TextStyle(fontSize: 14)),
                              const Text("5 mnt",
                                  style: TextStyle(fontSize: 14)),
                            ],
                          ),
                          subtitle: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    widget.driversList[index].merek.toString()),
                                Text(widget.driversList[index].nomorKendaraan
                                    .toString()),
                                Text(
                                    widget.driversList[index].warna.toString()),
                              ]),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            MaterialButton(
                                shape: const StadiumBorder(),
                                color: Colors.green,
                                child: const Text(
                                  "Accept",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  //widget.driverModel.id = index;
                                  //widget.driverModel.name = items[index];
                                  //Navigator.pop(context);
                                  /* Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => LiveTracking(
                                                              user: widget.user,
                                                              driverModel: widget.driverModel))); */
                                }),
                            MaterialButton(
                                shape: const StadiumBorder(),
                                color: Colors.grey,
                                child: const Text(
                                  "Decline",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  widget.isVisibleList[index] = false;
                                })
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ))),
            );
            /*  } else {
                    return Container();
                  }
                }); */
          }),
    );
  }
}

class IncrementalListViewInDialog extends StatefulWidget {
  IncrementalListViewInDialog(
      {Key? key, required this.driverModel, required this.user})
      : super(key: key);
  final DriverModel driverModel;
  GoogleSignInAccount? user;
  @override
  _IncrementalListViewInDialogState createState() =>
      _IncrementalListViewInDialogState();
}

class _IncrementalListViewInDialogState
    extends State<IncrementalListViewInDialog> {
  List<String> items = [];
  late Timer addTimer;

  @override
  void initState() {
    super.initState();
    addTimer = Timer.periodic(Duration(seconds: 2), (Timer t) {
      if (items.length <= 5) {
        setState(() {
          items.add("Budi ${items.length + 1}");
        });
      }
      Future.delayed(Duration(seconds: 3));
    });
    Future.delayed(Duration(seconds: 10), () {
      Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    addTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      //title: Text('Incremental List in Dialog'),
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      content: Container(
        width: 700,
        height: 600,
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            Timer(Duration(seconds: 7), () {
              if (mounted) {
                setState(() {
                  items.removeAt(index);
                });
              }
            });
            /* return ListTile(
              title: Text(items[index]),
              // Other ListTile properties
            ); */
            return Container(
                width: double.infinity,
                child: Card(
                    child: Column(
                  children: [
                    LinearTimer(
                      duration: Duration(seconds: 7),
                      forward: false,
                      color: primaryColor,
                      onTimerEnd: () {},
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.all(8.0),
                      leading: Icon(Icons.person),
                      title: Text(
                        items[index],
                        style: TextStyle(fontSize: 14),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Rp ${widget.driverModel.price}",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                          Text("1km", style: TextStyle(fontSize: 14)),
                          Text("5 mnt", style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Avanza"),
                            Text("W1203PL"),
                          ]),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        MaterialButton(
                            shape: StadiumBorder(),
                            color: Colors.green,
                            child: Text(
                              "Accept",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              widget.driverModel.id = index;
                              widget.driverModel.name = items[index];
                              //Navigator.pop(context);
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LiveTracking(
                                          user: widget.user,
                                          driverModel: widget.driverModel)));
                            }),
                        MaterialButton(
                            shape: StadiumBorder(),
                            color: Colors.grey,
                            child: Text(
                              "Decline",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {})
                      ],
                    )
                  ],
                )));
          },
        ),
      ),
    );
  }
}
