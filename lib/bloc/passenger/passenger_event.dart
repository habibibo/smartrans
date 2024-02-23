part of 'passenger_bloc.dart';

sealed class PassengerEvent {}

class PassengerStart extends PassengerEvent {}

class PassengerGetUser extends PassengerEvent {}

class PassengerLoading {}

class GetPassengersEvent {}

class UpdatePassengerData extends PassengerEvent {
  final List<NotifListJob> newData;

  UpdatePassengerData(this.newData);
}
