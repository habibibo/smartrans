import 'dart:convert';

import 'package:button_animations/button_animations.dart';
import 'package:button_animations/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logo_n_spinner/logo_n_spinner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signgoogle/bloc/auth/auth_bloc.dart';
import 'package:signgoogle/main.dart';
import 'package:signgoogle/model/user.dart';
import 'package:signgoogle/repo/Authentication.dart';
import 'package:signgoogle/repo/driver.dart';
import 'package:signgoogle/screen/driver/home.dart';
import 'package:signgoogle/screen/passenger/home.dart';
import 'package:signgoogle/utils/SmartransColor.dart';

class SideMenu extends StatefulWidget {
  //const SideMenu({Key? key, required this.onAction, required this.user}) : super(key: key);
  SideMenu({
    Key? key,
    required this.onAction,
    required this.userModel,
    required this.isDriver,
    required this.area,
  }) : super(key: key);
  //GoogleSignInAccount? user;
  UserModel userModel;
  bool isDriver;
  String area;
  //final User user;
  final VoidCallback onAction;
  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  //late User user;
  bool isLoading = false;
  final AuthRepository authRepository = AuthRepository();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);
    return BlocBuilder<AuthBloc, AuthState>(builder: ((context, state) {
      return Material(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              right: BorderSide(
                color: Color(0xFFCAD5DD),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        //_MenuHeader(onPress: widget.onAction),
                        /* _MenuHeader(
                          user: widget.user,
                          isDriver: widget.isDriver,
                        ), */
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(32),
                                  child: Container(
                                    width: 64,
                                    height: 64,
                                    color: const Color(0xFFBDBDBD),
                                    child: /*  user!.photoUrl != null
                    ? ClipOval(
                        child: Material(
                          shadowColor: Colors.grey,
                          color: Colors.blue,
                          child: Image.network(
                            user!.photoUrl!,
                            fit: BoxFit.fitHeight,
                            height: 45,
                          ),
                        ),
                      )
                    :  */
                                        ClipOval(
                                      child: Material(
                                        color: Colors.grey,
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Icon(
                                            Icons.person,
                                            size: 35,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(top: 15),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.userModel.email.toString(),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          widget.userModel.email.toString(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        /* _MenuContent(
                          user: widget.user, isDriver: widget.isDriver), */
                        //_MenuFooter(onPress: widget.onAction),
                        Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFFCAD5DD),
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                const SizedBox(height: 24),
                                _MenuItem(
                                  text: 'Request History',
                                  icon: Icons.local_library,
                                  onPress: () {},
                                ),
                                _MenuItem(
                                  text: 'Log out',
                                  icon: Icons.logout,
                                  iconColor: Color(0xFF9E9E9E),
                                  onPress: () async {
                                    //authBloc.add(LoggedOut());
                                    print("logout");
                                    SharedPreferences userCache =
                                        await SharedPreferences.getInstance();
                                    await userCache.clear();
                                    await authRepository.signOutFromGoogle();
                                    Future.delayed(Duration(seconds: 2), () {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: ((context) => MyApp(
                                                  authRepository:
                                                      authRepository,
                                                  navigatorKey:
                                                      navigatorKey))));
                                    });
                                  },
                                ),
                                const SizedBox(height: 500),
                                Text("You are a driver"),
                                const SizedBox(
                                  height: 10,
                                ),
                                isLoading
                                    ? CircularProgressIndicator(
                                        color: primaryColor)
                                    : AnimatedButton(
                                        height: 40,
                                        width: 150,
                                        child: Text(
                                          'Change to passenger', // add your text here
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        type: PredefinedThemes.warning,
                                        isOutline: false,
                                        borderWidth: 1,
                                        onTap: () async {
                                          SharedPreferences userCache =
                                              await SharedPreferences
                                                  .getInstance();
                                          DriverRepo driverRepo = DriverRepo();
                                          String getUser = userCache
                                              .get("userModel")
                                              .toString();
                                          driverRepo.changeStatus(
                                              jsonDecode(getUser)["uid"],
                                              "off",
                                              widget.area);
                                          setState(() {
                                            isLoading = true;
                                          });
                                          Future.delayed(Duration(seconds: 2),
                                              () {
                                            isLoading = false;
                                            //authBloc.add(GoingPassenger());
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PassengerHome(
                                                            userModel: widget
                                                                .userModel,
                                                            isDriver: false)));
                                          });
                                        },
                                      ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                //const _AppVersion(),
              ],
            ),
          ),
        ),
      );
    }));
  }
}

class _MenuHeader extends StatelessWidget {
  /* const _MenuHeader({
    super.key,
    this.onPress,
  }); */
  _MenuHeader({Key? key, required this.user, required this.isDriver})
      : super(key: key);

  GoogleSignInAccount? user;
  bool isDriver;
  // final VoidCallback? onPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.topLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Container(
                width: 64,
                height: 64,
                color: const Color(0xFFBDBDBD),
                child: user!.photoUrl != null
                    ? ClipOval(
                        child: Material(
                          shadowColor: Colors.grey,
                          color: Colors.blue,
                          child: Image.network(
                            user!.photoUrl!,
                            fit: BoxFit.fitHeight,
                            height: 45,
                          ),
                        ),
                      )
                    : ClipOval(
                        child: Material(
                          color: Colors.grey,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Icon(
                              Icons.person,
                              size: 35,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user!.displayName.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      user!.email.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/* 
class _MenuContent extends StatelessWidget {
  _MenuContent({Key? key, required this.user, required this.isDriver});
  GoogleSignInAccount? user;
  bool isDriver;
  //final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);
    return BlocBuilder<AuthBloc, AuthState>(builder: ((context, state) {
      return Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFCAD5DD),
              width: 0.5,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 24),
              _MenuItem(
                text: 'Request History',
                icon: Icons.local_library,
                onPress: () {},
              ),
              _MenuItem(
                text: 'Log out',
                icon: Icons.logout,
                iconColor: Color(0xFF9E9E9E),
                onPress: () async {
                  authBloc.add(LoggedOut());
                },
              ),
              const SizedBox(height: 500),
              Text("Change mode ?"),
              const SizedBox(
                height: 10,
              ),
              AnimatedButton(
                height: 40,
                width: 140,
                child: Text(
                  'I am a Driver', // add your text here
                  style: TextStyle(color: Colors.black),
                ),
                type: PredefinedThemes.warning,
                isOutline: false,
                borderWidth: 1,
                onTap: () {
                  Container(
                    height: 110,
                    child: const LogoandSpinner(
                      imageAssets: 'images/loadingsmartrans.png',
                      reverse: false,
                      arcColor: primaryColor,
                      spinSpeed: Duration(milliseconds: 500),
                    ),
                  );
                  Future.delayed(Duration(seconds: 2), () {
                    authBloc.add(GoingPassenger());
                  });
                },
              ),
            ],
          ),
        ),
      );
    }));
  }
} */

/* class _MenuFooter extends StatelessWidget {
  const _MenuFooter({
    super.key,
    required this.onPress,
  });

  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 12),
          _MenuItem(
            text: 'FAQ',
            onPress: onPress,
          ),
          _MenuItem(
            text: 'Privacy policy',
            onPress: onPress,
          ),
          _MenuItem(
            text: 'Terms of service',
            onPress: onPress,
          ),
        ],
      ),
    );
  }
} */

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    super.key,
    required this.text,
    this.icon,
    this.iconColor,
    required this.onPress,
  });

  final String text;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: SizedBox(
        height: 44,
        child: Row(
          children: <Widget>[
            if (icon != null) ...[
              Icon(
                icon,
                color: iconColor ?? Colors.orange,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                text,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppVersion extends StatelessWidget {
  const _AppVersion({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        color: Colors.white,
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Version of application 1.0.0',
            textAlign: TextAlign.start,
          ),
        ),
      ),
    );
  }
}
