part of 'google_sign_bloc.dart';

@immutable
sealed class GoogleSignEvent {}

class InitialEvent extends GoogleSignEvent {
  InitialEvent();
}

class GoogleSignToBlue extends GoogleSignEvent {
  GoogleSignToBlue();
}

class GoogleSignToRed extends GoogleSignEvent {
  GoogleSignToRed();
}
