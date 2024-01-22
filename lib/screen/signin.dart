import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:signgoogle/bloc/googlesign/google_sign_bloc.dart';
import 'package:signgoogle/utils/SmartransColor.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

final GoogleSignIn _googleSignIn = GoogleSignIn();

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    // return BlocBuilder<GoogleSignBloc, GoogleSignState>(
    //     builder: (context, state) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text("login"),
          ),
        ],
      ),
    );
    //  });

    /* FutureBuilder(
                future: Authentication.initializeFirebase(context: context),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error initializing Firebase');
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    return GoogleSignInButton();
                  }
                  return CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      primaryColor,
                    ),
                  );
                },
              ), */
  }
}
