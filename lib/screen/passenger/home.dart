import 'dart:async';
import 'dart:convert';
import 'package:currency_textfield/currency_textfield.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:intl/intl.dart';

import 'package:animated_list_item/animated_list_item.dart';
import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_sliding_drawer/flutter_sliding_drawer.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logo_n_spinner/logo_n_spinner.dart';
//import 'package:regexpattern/regexpattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signgoogle/bloc/auth/auth_bloc.dart';
import 'package:signgoogle/bloc/passenger/passenger_bloc.dart';
import 'package:signgoogle/main.dart';
import 'package:signgoogle/model/notif/notif_list_job.dart';
import 'package:signgoogle/model/user.dart';
import 'package:signgoogle/screen/passenger/profile.dart';
import 'package:signgoogle/screen/passenger/ride.dart';
//import 'package:signgoogle/screens/home/member/member_home.dart';
import 'package:signgoogle/screen/passenger/side_menu.dart';
import 'package:signgoogle/repo/Authentication.dart';
import 'package:signgoogle/utils/SmartransColor.dart';
import 'package:http/http.dart' as http;
import 'package:signgoogle/utils/user_cache.dart';

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

class PassengerHome extends StatefulWidget {
  PassengerHome({Key? key, required this.user, required this.isDriver})
      : super(key: key);
  GoogleSignInAccount? user;
  final bool isDriver;
  @override
  State<PassengerHome> createState() => _PassengerHomeState();
}

class _PassengerHomeState extends State<PassengerHome> {
  late AuthRepository authRepository = AuthRepository();
  late GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    //setupInteractedMessage();
  }

  Future<bool> getPassengerHome() async {
    //final AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);
    //authBloc.add(GoingPassenger());
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => getPassengerHome(),
        child: MaterialApp(
          home: BlocProvider(
            create: (context) => AuthBloc(
                authRepository: authRepository, navigatorKey: navigatorKey)
              ..add(AppStarted()),
            child: PassengerHomeScreen(
              user: widget.user,
              isDriver: widget.isDriver,
            ),
          ),
        ));
  }
}

class PassengerHomeScreen extends StatefulWidget {
  PassengerHomeScreen({Key? key, required this.user, required this.isDriver})
      : super(key: key);
  GoogleSignInAccount? user;
  final bool isDriver;

  @override
  _PassengerHomeScreenState createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen>
    with SingleTickerProviderStateMixin {
  //late User _user;
  bool _isSigningOut = false;
  String? _token;
  String? initialMessage;
  bool _resolved = false;
  int _messageCount = 1;

  var total;
  var width;
  var height;
  bool recDesp = false;
  final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey<ScaffoldState>();
  var dataAtual = new DateTime.now();
  late UserModel userModel = UserModel();
  String format(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
  }

  int _page = 0;
  late PageController _pageController;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  final slidingDrawerKey = GlobalKey<SlidingDrawerState>();
  Future<bool> disableReturn() async {
    return false;
  }

  final AuthRepository authRepository = AuthRepository();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  TextEditingController dateBirthController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    getUserCache();
    _pageController = PageController(initialPage: _page);
  }

  Future<void> getUserCache() async {
    SharedPreferences cacheUser = await SharedPreferences.getInstance();
    userModel.id = jsonDecode(cacheUser.get("userModel").toString())["id"];
    userModel.email =
        jsonDecode(cacheUser.get("userModel").toString())["email"];
    userModel.uid = jsonDecode(cacheUser.get("userModel").toString())["uid"];
    userModel.deposit =
        jsonDecode(cacheUser.get("userModel").toString())["deposit"];
    userModel.dataDriver =
        jsonDecode(cacheUser.get("userModel").toString())["data_driver"];
    userModel.dataAccount =
        jsonDecode(cacheUser.get("userModel").toString())["data_account"];
    userModel.location =
        jsonDecode(cacheUser.get("userModel").toString())["location"];
    userModel.point =
        jsonDecode(cacheUser.get("userModel").toString())["point"];
    userModel.transaction =
        jsonDecode(cacheUser.get("userModel").toString())["transaction"];
    userModel.rating =
        jsonDecode(cacheUser.get("userModel").toString())["rating"];
    userModel.token =
        jsonDecode(cacheUser.get("userModel").toString())["token"];
    dateBirthController.text =
        jsonDecode(userModel.dataAccount.toString())["tanggal_lahir"];
    print("data akun dari home");
    print(userModel.dataAccount);
  }

  late AnimationController _animationController;
  Widget homeWidget() {
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
                                                          user: widget.user,
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
  }

  Widget historyScreen() {
    return Container(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            //color: primaryColor,
            margin: EdgeInsets.only(bottom: 20),
            child: Card(
              color: primaryColor,
              child: Padding(
                padding:
                    EdgeInsets.only(top: 40, left: 10, right: 10, bottom: 20),
                child: Text("Perjalanan bulan ini"),
              ),
            ),
          ),
          Card(
            elevation: 2,
            child: Container(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Kamu sering disini",
                          style: TextStyle(
                              color: Colors.pinkAccent,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.pin_drop_outlined,
                          color: primaryColor,
                          size: 35,
                        ),
                        title: Text("Tunjungan Surabaya"),
                        subtitle: Container(
                            padding: EdgeInsets.only(bottom: 5),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.grey))),
                            child: Text(
                                "Jl. Embong malang no 52 Tunjungan Surabaya")),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 18,
          ),
          Container(
            height: MediaQuery.sizeOf(context).height * 0.6,
            padding: EdgeInsets.only(top: 10),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Perjalanan sebelumnya",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.pin_drop_outlined,
                        color: primaryColor,
                        size: 35,
                      ),
                      title: Text("Tunjungan Surabaya"),
                      subtitle: Container(
                          padding: EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.grey))),
                          child: Text(
                              "Jl. Embong malang no 52 Tunjungan Surabaya")),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.pin_drop_outlined,
                        color: primaryColor,
                        size: 35,
                      ),
                      title: Text("Bungurasih Waru Sidoarjo"),
                      subtitle: Container(
                          padding: EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.grey))),
                          child: Text("Jl. Bungurasu waru no 12 Sidoarjo")),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.pin_drop_outlined,
                        color: primaryColor,
                        size: 35,
                      ),
                      title: Text("Cito Sidoarjo"),
                      subtitle: Container(
                          padding: EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.grey))),
                          child: Text("Jl. A. Yani no 120 Sidoarjo")),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.pin_drop_outlined,
                        color: primaryColor,
                        size: 35,
                      ),
                      title: Text("Tunjungan Surabaya"),
                      subtitle: Container(
                          padding: EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.grey))),
                          child: Text(
                              "Jl. Embong malang no 52 Tunjungan Surabaya")),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

/*
  Widget profileScreen() {
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
                          child: Image.network(jsonDecode(
                              userModel.dataAccount.toString())["foto_akun"]),
                          /* child: Image.network(jsonDecode(
                              userModel.dataAccount.toString())["foto_akun"]), */
                        ),
                      ),
                      title: Text(userModel.email.toString()),
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
                              //DateTime.now() - not to allow to choose before today.
                              lastDate: DateTime(2100));
                          print(dateTime);
                          
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
*/
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    //final AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);

    //_allMovMes(dataFormatada);

    return WillPopScope(
      onWillPop: () => disableReturn(),
      child: SlidingDrawer(
        key: slidingDrawerKey,
        // Build content widget
        contentBuilder: (context) {
          return BlocProvider<AuthBloc>(
              create: (context) => AuthBloc(
                  authRepository: authRepository, navigatorKey: navigatorKey)
                ..add(AppStarted()),
              child: Scaffold(
                body:
                    BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
                  if (state is Unauthenticated) {
                    return MyApp(
                        authRepository: authRepository,
                        navigatorKey: navigatorKey);
                  }
                  return PageView(
                    controller: _pageController,
                    onPageChanged: (int index) {
                      setState(() {
                        _page = index;
                      });
                    },
                    children: [
                      homeWidget(),
                      historyScreen(),
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
                        Icons.menu_book,
                        grade: 10,
                      ),
                      label: 'History',
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
              ));
        },
        drawerBuilder: (_) {
          return SideMenu(
            onAction: () => slidingDrawerKey.close(),
            user: widget.user,
            isDriver: widget.isDriver,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
