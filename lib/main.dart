import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:linear_timer/linear_timer.dart';
import 'package:logo_n_spinner/logo_n_spinner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signgoogle/bloc/auth/auth_bloc.dart';
import 'package:signgoogle/bloc/passenger/passenger_bloc.dart';
import 'package:signgoogle/model/notif/notif_list_job.dart';
import 'package:signgoogle/screen/driver/home.dart';
import 'package:signgoogle/screen/intro.dart';
import 'package:signgoogle/screen/passenger/home.dart';
import 'package:signgoogle/screen/passenger/ride.dart';
import 'package:signgoogle/screen/signin.dart';
import 'package:signgoogle/repo/Authentication.dart';
import 'package:signgoogle/utils/SmartransColor.dart';

import 'bloc/googlesign/google_sign_bloc.dart';

int id = 0;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
/* final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast(); */

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

/* const MethodChannel platform =
    MethodChannel('dexterx.dev/flutter_local_notifications_example'); */

const String portName = 'notification_send_port';

/* class ReceivedNotification {
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
} */

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
}

var initializationSettingsAndroid = AndroidInitializationSettings(
    '@mipmap/ic_launcher'); // <- default icon name is @mipmap/ic_launcher
var initializationSettingsIOS = DarwinInitializationSettings();
var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  final AuthRepository authRepository = AuthRepository();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  runApp(MyApp(authRepository: authRepository, navigatorKey: navigatorKey));
  // runApp(const MyApp());
}

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  print("noooooooooootiffff");
  _showNotification(message);
}

Future<void> _showNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('0', 'your channel name',
          channelDescription: 'your channel description',
          importance: Importance.max,
          //priority: Priority.high,
          icon: 'assets/image/logosmart512.png',
          ticker: 'ticker');
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);
  String notificationType = json.decode(
      json.encode(json.decode(message.notification!.body.toString())))["type"];
  if (notificationType == "driver_bid") {
    //showListDriver();
    print("driver bid");
  } else {
    await flutterLocalNotificationsPlugin.show(
        id++,
        message.notification?.title.toString(),
        message.notification?.body.toString(),
        notificationDetails,
        payload: 'item x');
  }
}

Future<void> _showCustomNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('0', 'your channel name',
          channelDescription: 'your channel description',
          importance: Importance.max,
          //priority: Priority.high,
          icon: 'assets/image/logosmart512.png',
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

final GoogleSignIn _googleSignIn = GoogleSignIn();

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp(
      {Key? key, required this.authRepository, required this.navigatorKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) =>
            AuthBloc(authRepository: authRepository, navigatorKey: navigatorKey)
              ..add(AppStarted()),
        child: HomeScreen(),
      ),
    );
  }
}

/* class PushNotification { 
  PushNotification({
    this.title,
    this.body,
  });
  String? title;
  String? body;
}
*/

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleSignInAccount? _currentUser;
  bool _isSigningIn = false;
  late int _totalNotifications;
  late final FirebaseMessaging _messaging;
  //PushNotification? _notificationInfo;
  @override
  void initState() {
    registerNotification();
    getToken();
    setState(() {
      _isSigningIn = false;
    });
    super.initState();
    //getCurrentUser();
  }

  /* List<NotifListJob> listJobs = [];
  Future<void> messageConversion(var messageData) async {
    // final jobBloc = BlocProvider.of<PassengerBloc>(context);
    final SharedPreferences driverCache = await SharedPreferences.getInstance();
    if (messageData["mode"] == "driver") {
      if (messageData["type"] == "notif_driver_job") {
        listJobs.add(NotifListJob(
            id_passenger: messageData["data"][0]["id_passenger"].toString(),
            nama_passenger: messageData["data"][0]["nama_passenger"].toString(),
            jarak_tujuan: messageData["data"][0]["jarak_tujuan"].toString(),
            total_alamat: messageData["data"][0]["total_alamat"].toString(),
            tarif: messageData["data"][0]["tarif"].toString(),
            bid: messageData["data"][0]["bid"].toString(),
            jarak_driver: messageData["data"][0]["jarak_driver"].toString(),
            waktu_jemput: messageData["data"][0]["waktu_jemput"].toString(),
            pembayaran: messageData["data"][0]["pembayaran"].toString()));

        // Convert the list of NotifListJob objects to a List<Map<String, dynamic>>
        List<Map<String, dynamic>> jsonList =
            listJobs.map((job) => job.toJson()).toList();

        // Encode the List<Map<String, dynamic>> to a JSON string
        String jsonString = jsonEncode(jsonList);

        // Store the JSON string in SharedPreferences
        await driverCache.setString("listJob", jsonString);
        //driverCache.setString("listJob", listJobs.toString());
        print(driverCache.get("listJob"));
      }
    }
  } */

  void getToken() async {
    print("token");
    await FirebaseMessaging.instance.getToken().then((value) {
      print(value);
    });
  }

  void registerNotification() async {
    await Firebase.initializeApp();
    _messaging = FirebaseMessaging.instance;
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
    //PushNotification? _notificationInfo;

    /* if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (_notificationInfo != null) {
          
        }
      });
    } else {
      print('User declined or has not accepted permission');
    } */
  }

  // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
    }
    /* await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
    ); */
  }

/*   void checkForInitialMessage() async {
    await Firebase.initializeApp();
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

  } */

  /* Future<void> getCurrentUser() async {
    final user = await _googleSignIn.signIn();
    setState(() {
      _currentUser = user;
    });
    print("passenger");
    print(user);
  } */

  @override
  Widget build(BuildContext context) {
    final AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Loading) {
            return Center(
              child: Container(
                height: 110,
                child: const LogoandSpinner(
                  imageAssets: 'images/loadingsmartrans.png',
                  reverse: false,
                  arcColor: primaryColor,
                  spinSpeed: Duration(milliseconds: 500),
                ),
              ),
            );
          } else if (state is Authenticated) {
            //return _buildLoggedInUI(context, authBloc);
            return state.isDriver
                ? DriverHome(
                    userModel: state.userModel, isDriver: state.isDriver)
                : PassengerHome(
                    userModel: state.userModel, isDriver: state.isDriver);
          } else if (state is Unauthenticated) {
            return _buildLoggedOutUI(context, authBloc);
          } else {
            return Center(
              child: Text('Initializing...'),
            );
          }
        },
      ),
    );
  }

  Widget _buildLoggedInUI(BuildContext context, AuthBloc authBloc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Logged In!'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => authBloc.add(LoggedOut()),
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedOutUI(BuildContext context, AuthBloc authBloc) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          bottom: 20.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 1,
                    child: Image.asset(
                      'images/logosmart512.png',
                      height: 160,
                    ),
                  ),
                  Text(
                    'SMARTRANS',
                    style: TextStyle(
                        color: primaryColor,
                        fontSize: 40,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _isSigningIn
                  ? Container(
                      height: 110,
                      child: const LogoandSpinner(
                        imageAssets: 'images/loadingsmartrans.png',
                        reverse: false,
                        arcColor: primaryColor,
                        spinSpeed: Duration(milliseconds: 500),
                      ),
                    )
                  : OutlinedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(secondColor),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        setState(() {
                          _isSigningIn = true;
                        });
                        authBloc.add(LoggedIn());
                        setState(() {
                          _isSigningIn = false;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image(
                              image: AssetImage("images/google-logo.png"),
                              height: 35.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                'Sign in with Google',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}

class NotificationBadge extends StatelessWidget {
  final int totalNotifications;

  const NotificationBadge({required this.totalNotifications});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: new BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '$totalNotifications',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }
}

/* class _HomeScreenState extends State<HomeScreen> {
  GoogleSignInAccount? _currentUser;
  // google signin method
  Future<void> signIn() async {
    try {
      final auth = await _googleSignIn.signIn();
      setState(() {
        _currentUser = auth;
      });
      print(_currentUser);
    } catch (e) {
      print('Error signing in $e');
    }
  }

  //google signout method
  void signOut() async {
    final auth = await _googleSignIn.disconnect();

    setState(() {
      _currentUser = auth;
    });
  }

  @override
  void initState() {
    super.initState();
    checkSignAccount();
  }

  Future<void> checkSignAccount() async {
    GoogleSignInAccount? user = _currentUser;
    print(user);
    if (user != null) {}
  }

  Widget _buildWidget() {
    GoogleSignInAccount? user = _currentUser;
    if (user != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Signed in successfully',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(
            height: 10,
          ),
          //make image with circle shape
          Container(
            width: 175,
            height: 175,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(200),
                child: Image.network(
                  user.photoUrl!,
                  fit: BoxFit.cover,
                )),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            user.displayName!,
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            user.email,
            style: TextStyle(fontSize: 20),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: ElevatedButton(
                onPressed: signOut,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock,
                        size: 30,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text('Sign out', style: TextStyle(fontSize: 30))
                    ],
                  ),
                )),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FlutterLogo(
            size: 250,
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'You are not signed in',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: ElevatedButton(
                onPressed: signIn,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock,
                        size: 30,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text('Sign in Google', style: TextStyle(fontSize: 30))
                    ],
                  ),
                )),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: _currentUser == ""
            ? PassengerHome()
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    bottom: 20.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              flex: 1,
                              child: Image.asset(
                                'images/logosmart512.png',
                                height: 160,
                              ),
                            ),
                            Text(
                              'SMARTRANS',
                              style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: OutlinedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(secondColor),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                          ),
                          onPressed: () async {
                            signIn();
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Image(
                                  image: AssetImage("images/google-logo.png"),
                                  height: 35.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    'Sign in with Google',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
 */
/* final GoogleSignIn _googleSignIn = GoogleSignIn();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMARTRANS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'SMARTRANS'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  GoogleSignInAccount? _currentUser;
  // google signin method
  Future<void> signIn() async {
    try {
      final auth = await _googleSignIn.signIn();
      setState(() {
        _currentUser = auth;
      });
      print(_currentUser);
    } catch (e) {
      print('Error signing in $e');
    }
  }

  //google signout method
  void signOut() async {
    final auth = await _googleSignIn.disconnect();

    setState(() {
      _currentUser = auth;
    });
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Widget _buildWidget() {
    GoogleSignInAccount? user = _currentUser;
    if (user != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Signed in successfully',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(
            height: 10,
          ),
          //make image with circle shape
          Container(
            width: 175,
            height: 175,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(200),
                child: Image.network(
                  user.photoUrl!,
                  fit: BoxFit.cover,
                )),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            user.displayName!,
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            user.email,
            style: TextStyle(fontSize: 20),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: ElevatedButton(
                onPressed: signOut,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock,
                        size: 30,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text('Sign out', style: TextStyle(fontSize: 30))
                    ],
                  ),
                )),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FlutterLogo(
            size: 250,
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'You are not signed in',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: ElevatedButton(
                onPressed: signIn,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock,
                        size: 30,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text('Sign in Google', style: TextStyle(fontSize: 30))
                    ],
                  ),
                )),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:
          BlocProvider(create: (_) => GoogleSignBloc(), child: const SignIn()),
    );
  }
}
 */
