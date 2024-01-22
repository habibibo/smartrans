part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class AppStarted extends AuthEvent {}

class LoggedIn extends AuthEvent {}

class LoggedOut extends AuthEvent {}

class GoingDriver extends AuthEvent {}

class GoingPassenger extends AuthEvent {}
