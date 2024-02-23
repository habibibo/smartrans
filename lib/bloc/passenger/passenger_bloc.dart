import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signgoogle/model/notif/notif_list_job.dart';
import 'package:signgoogle/model/user.dart';
import 'package:signgoogle/repo/Authentication.dart';
import 'package:signgoogle/repo/passenger.dart';
import 'package:signgoogle/repo/smartrans_cache.dart';
import 'package:signgoogle/utils/api.dart';
import 'package:http/http.dart' as http;
import 'package:signgoogle/utils/basic_auth.dart';

part 'passenger_event.dart';
part 'passenger_state.dart';

class PassengerBloc extends Bloc<PassengerEvent, PassengerState> {
  PassengerBloc() : super(PassengerInitialState()) {
    on<PassengerStart>((event, emit) async {
      emit(PassengerLoadingState());
      try {
        SharedPreferences uid = await SharedPreferences.getInstance();
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

        emit(GetUserModel(
            UserModel.fromJson(jsonDecode(response.body)["data"])));
      } catch (e) {
        emit(FailureState());
      }
    });
    on<PassengerGetUser>((event, emit) async {
      emit(PassengerLoadingState());
      try {
        SharedPreferences uid = await SharedPreferences.getInstance();
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

        emit(GetUserModel(
            UserModel.fromJson(jsonDecode(response.body)["data"])));
      } catch (e) {
        emit(FailureState());
      }
    });
    /* on<UpdatePassengerData>((event, emit) {
      // TODO: implement event handler
      // Access the existing state
      final currentState = state;

      if (currentState is PassengerInitial) {
        // Handle initial state (if needed)
        final updatedData = event.newData; // Update data from the event

        emit(PassengerUpdated(updatedData)); // Emit the updated state
      } else if (currentState is PassengerUpdated) {
        // Handle subsequent updates or transformations to existing data
        final existingData = currentState.updatedData;
        final updatedData =
            existingData + event.newData; // Append new data to existing data

        emit(PassengerUpdated(updatedData)); // Emit the updated state
      }
    }); */
  }

  Future<void> getUser() async {
    add(PassengerStart());
  }

  void initialPage() async {
    late UserModel user;
    GoogleSignInAccount? userAccount = await AuthRepository().getCurrentUser();
    SmartransCache().getUserModel().then((value) {
      user = value;
    });
    emit(GetUserModel(user));
  }
}

/* AuthBloc({required this.authRepository, required this.navigatorKey})
      : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoggedIn>(_onLoggedIn);
    on<LoggedOut>(_onLoggedOut);
  }

  void _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(Loading());
    final bool isSignedIn = await authRepository.isSignedIn();
    if (isSignedIn) {
      GoogleSignInAccount? userAccount = await authRepository.getCurrentUser();
      emit(Authenticated(user: userAccount));
    } else {
      emit(Unauthenticated());
    }
  } */