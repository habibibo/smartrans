import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signgoogle/main.dart';
import 'package:signgoogle/model/user.dart';
import 'package:signgoogle/repo/login.dart';
import 'package:signgoogle/repo/smartrans_cache.dart';
import 'package:signgoogle/screen/passenger/home.dart';
import 'package:signgoogle/screen/passenger/ride.dart';
import 'package:signgoogle/repo/Authentication.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:signgoogle/utils/api.dart';
import 'package:http/http.dart' as http;
import 'package:signgoogle/utils/basic_auth.dart';
part 'auth_event.dart';
part 'auth_state.dart';

/* class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
 */
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final GlobalKey<NavigatorState> navigatorKey;
  AuthBloc({required this.authRepository, required this.navigatorKey})
      : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoggedIn>(_onLoggedIn);
    on<LoggedOut>(_onLoggedOut);
    on<GoingDriver>(_onGoingDriver);
    on<GoingPassenger>(_onGoingPassenger);
  }
  void _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(Loading());
    final bool isSignedIn = await authRepository.isSignedIn();
    if (isSignedIn) {
      GoogleSignInAccount? userAccount = await authRepository.getCurrentUser();
      SharedPreferences uid = await SharedPreferences.getInstance();
      uid.setString("uid", userAccount!.id);
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

      emit(Authenticated(
          userModel: UserModel.fromJson(jsonDecode(response.body)),
          isDriver: false));
    } else {
      emit(Unauthenticated());
    }
  }

  void _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) async {
    await authRepository.signOutFromGoogle();
    //emit(Unauthenticated());
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(
          builder: (context) => MyApp(
                authRepository: AuthRepository(),
                navigatorKey: navigatorKey,
              )),
    );
  }

  void _onLoggedIn(LoggedIn event, Emitter<AuthState> emit) async {
    await authRepository.signInWithGoogle();
    GoogleSignInAccount? userAccount = await authRepository.getCurrentUser();
    //SmartransCache().getUserModel(userAccount!.id.toString());
    if (userAccount != null) {
      bool hasUser = await LoginRepo().login(userAccount);

      if (hasUser) {
        SharedPreferences uid = await SharedPreferences.getInstance();
        uid.setString("uid", userAccount.id);
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

        emit(Authenticated(
            userModel: UserModel.fromJson(jsonDecode(response.body)),
            isDriver: false));
        /* navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(
              builder: (context) =>
                  PassengerHome(user: userAccount, isDriver: false)),
        ); */
      } else {
        emit(Unauthenticated());
      }
    }

    //AuthBloc? authBloc;
    /* navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(
          builder: (context) =>
              PassengerHome(user: userAccount, isDriver: false)),
    ); */
  }

  void _onGoingDriver(GoingDriver event, Emitter<AuthState> emit) async {
    GoogleSignInAccount? userAccount = await authRepository.getCurrentUser();
    final data = {"uid": userAccount!.id};
    final getUserUrl = Uri.parse("${ApiNetwork().baseUrl}${To().getUser}");
    var response = await http.post(
      getUserUrl,
      headers: <String, String>{
        'Authorization': basicAuth,
        'Content-Type': "application/json; charset=UTF-8",
      },
      body: jsonEncode(data),
    );

    emit(Authenticated(
        userModel: UserModel.fromJson(jsonDecode(response.body)),
        isDriver: true));
  }

  void _onGoingPassenger(GoingPassenger event, Emitter<AuthState> emit) async {
    GoogleSignInAccount? userAccount = await authRepository.getCurrentUser();
    final data = {"uid": userAccount!.id};
    final getUserUrl = Uri.parse("${ApiNetwork().baseUrl}${To().getUser}");
    var response = await http.post(
      getUserUrl,
      headers: <String, String>{
        'Authorization': basicAuth,
        'Content-Type': "application/json; charset=UTF-8",
      },
      body: jsonEncode(data),
    );

    emit(Authenticated(
        userModel: UserModel.fromJson(jsonDecode(response.body)),
        isDriver: false));
  }

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    if (event is AppStarted) {
      yield* _mapAppStartedToState();
    } else if (event is LoggedIn) {
      GoogleSignInAccount? userAccount = await authRepository.getCurrentUser();
      final data = {"uid": userAccount!.id};
      final getUserUrl = Uri.parse("${ApiNetwork().baseUrl}${To().getUser}");
      var response = await http.post(
        getUserUrl,
        headers: <String, String>{
          'Authorization': basicAuth,
          'Content-Type': "application/json; charset=UTF-8",
        },
        body: jsonEncode(data),
      );

      emit(Authenticated(
          userModel: UserModel.fromJson(jsonDecode(response.body)),
          isDriver: false));
    } else if (event is LoggedOut) {
      yield Unauthenticated();
    }
  }

  Stream<AuthState> _mapAppStartedToState() async* {
    yield Loading();
    final bool isSignedIn = await authRepository.isSignedIn();
    if (isSignedIn) {
      GoogleSignInAccount? userAccount = await authRepository.getCurrentUser();
      final data = {"uid": userAccount!.id};
      final getUserUrl = Uri.parse("${ApiNetwork().baseUrl}${To().getUser}");
      var response = await http.post(
        getUserUrl,
        headers: <String, String>{
          'Authorization': basicAuth,
          'Content-Type': "application/json; charset=UTF-8",
        },
        body: jsonEncode(data),
      );

      emit(Authenticated(
          userModel: UserModel.fromJson(jsonDecode(response.body)),
          isDriver: false));
    } else {
      yield Unauthenticated();
    }
  }
}
