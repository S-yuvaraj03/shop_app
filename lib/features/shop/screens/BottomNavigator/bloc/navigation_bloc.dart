import 'package:bloc/bloc.dart';

part 'navigation_event.dart';
part 'navigation_state.dart';

// class AuthenticateBloc extends Bloc<AuthenticateEvent, AuthenticateState> {
//   AuthenticateBloc() : super(AuthenticateInitial());

//   Stream<AuthenticateState> mapEventToState(AuthenticateEvent event) async* {
//     if (event is LoginEvent) {
//       yield AuthenticateAuthenticated();
//     }
//   }
// }

class NavigationBloc extends Bloc<NavigationEvent, int> {
  NavigationBloc() : super(0) {
    on<NavigationEvent>((event, emit) {
      switch (event) {
        case NavigationEvent.home:
          emit(0);
          break;
        case NavigationEvent.wishlist:
          emit(1);
          break;
        case NavigationEvent.cart:
          emit(2);
          break;
        // case NavigationEvent.settings:
        //   emit(3);
        //   break;
      }
    });
  }
}

