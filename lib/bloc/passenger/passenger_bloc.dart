import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:signgoogle/model/notif/notif_list_job.dart';

part 'passenger_event.dart';
part 'passenger_state.dart';

class PassengerBloc extends Bloc<PassengerEvent, PassengerState> {
  PassengerBloc() : super(PassengerInitial()) {
    on<PassengerEvent>((event, emit) {});
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