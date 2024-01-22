part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

class Authenticated extends AuthState {
  Authenticated({required this.user, required this.isDriver});
  GoogleSignInAccount? user;
  bool isDriver;
}

class Unauthenticated extends AuthState {}

class Loading extends AuthState {}
