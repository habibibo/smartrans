import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'member_event.dart';
part 'member_state.dart';

class MemberBloc extends Bloc<MemberEvent, MemberState> {
  MemberBloc() : super(MemberInitial()) {
    on<MemberEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
