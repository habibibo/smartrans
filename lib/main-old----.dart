import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:signgoogle/bloc/auth/auth_bloc.dart';
import 'package:signgoogle/screen/intro.dart';
import 'package:signgoogle/screen/passenger/ride.dart';
import 'package:signgoogle/screen/signin.dart';
import 'package:signgoogle/repo/Authentication.dart';
import 'package:signgoogle/utils/SmartransColor.dart';

import 'bloc/googlesign/google_sign_bloc.dart';

void mains() {
  WidgetsFlutterBinding.ensureInitialized();
  final AuthRepository authRepository = AuthRepository();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  runApp(
      MyAppSecond(authRepository: authRepository, navigatorKey: navigatorKey));
  // runApp(const MyApp());
}

final GoogleSignIn _googleSignIn = GoogleSignIn();

class MyAppSecond extends StatelessWidget {
  final AuthRepository authRepository;
  final GlobalKey<NavigatorState> navigatorKey;

  const MyAppSecond(
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Authentication Demo'),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is Authenticated) {
            return _buildLoggedInUI(context, authBloc);
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
    return Center(
      child: ElevatedButton(
        onPressed: () => authBloc.add(LoggedIn()),
        child: Text('Login'),
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