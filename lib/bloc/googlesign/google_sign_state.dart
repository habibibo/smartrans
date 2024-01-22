part of 'google_sign_bloc.dart';

@immutable
sealed class GoogleSignState {}

final class GoogleSignInitial extends GoogleSignState {}

/* class GoogleSignUpdateState extends GoogleSignState {
  bool? initialState;
 
  GoogleSignUpdateState({
    this.initialState,
  });
}
 */
class GoogleSignStateResult extends GoogleSignState {}
