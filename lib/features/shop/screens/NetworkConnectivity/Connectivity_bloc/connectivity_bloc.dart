import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final Connectivity _connectivity = Connectivity();

  ConnectivityBloc() : super(ConnectivityInitial()) {
    // Event handler for ConnectivityChanged
    on<ConnectivityChanged>((event, emit) {
      // Check if any of the connectivity results is 'none'
      if (event.connectivityResults.contains(ConnectivityResult.none)) {
        emit(ConnectivityOffline());
      } else {
        emit(ConnectivityOnline());
      }
    });

    // Listen to connectivity changes and add ConnectivityChanged event
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // Pass the list of ConnectivityResult directly
      add(ConnectivityChanged(results));
    });

    // Check initial connectivity status
    checkInitialConnectivity(); // Now calling the public method directly inside the constructor
  }

  // Changed the method to public by removing the leading underscore
  void checkInitialConnectivity() async {
    final initialResult = await _connectivity.checkConnectivity();
    add(ConnectivityChanged([initialResult.first]));
  }

  @override
  Future<void> close() {
    // Dispose of any resources if needed
    return super.close();
  }
}
