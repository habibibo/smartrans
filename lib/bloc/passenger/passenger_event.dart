part of 'passenger_bloc.dart';

@immutable
sealed class PassengerEvent {}

class UpdatePassengerData extends PassengerEvent {
  final List<NotifListJob> newData;

  UpdatePassengerData(this.newData);
}
