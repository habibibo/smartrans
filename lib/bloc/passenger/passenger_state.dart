part of 'passenger_bloc.dart';

@immutable
sealed class PassengerState {}

final class PassengerInitialState extends PassengerState {}

class PassengerLoadingState extends PassengerState {}

class PassengerUpdated extends PassengerState {
  final List<NotifListJob> updatedData;

  PassengerUpdated(this.updatedData);
}

class GetUserModel extends PassengerState {
  UserModel userModel;
  GetUserModel(this.userModel);
}

class FailureState extends PassengerState {}
