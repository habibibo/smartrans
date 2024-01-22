part of 'passenger_bloc.dart';

@immutable
sealed class PassengerState {}

final class PassengerInitial extends PassengerState {}

class PassengerUpdated extends PassengerState {
  final List<NotifListJob> updatedData;

  PassengerUpdated(this.updatedData);
}
