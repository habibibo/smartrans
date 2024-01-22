import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'google_sign_event.dart';
part 'google_sign_state.dart';

class GoogleSignBloc extends Bloc<GoogleSignEvent, GoogleSignState> {
  bool initState = true;
  GoogleSignBloc() : super(GoogleSignInitial()) {
    on<GoogleSignEvent>((event, emit) {
      //Implement an event handler
    });
    on<InitialEvent>((event, emit) {
      //  implement event handler
      //emit(GoogleSignUpdateState(initialState: initState));
    });
    on<GoogleSignToBlue>((event, emit) {
      //implement event handler
      //initState = true;
      //emit(GoogleSignUpdateState(initialState: initState));
    });
    on<GoogleSignToRed>((event, emit) {
      initState = false;
      // emit(GoogleSignUpdateState(initialState: initState));
    });
  }
}
