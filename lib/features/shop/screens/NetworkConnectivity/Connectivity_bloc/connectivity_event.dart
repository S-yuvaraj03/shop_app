part of 'connectivity_bloc.dart';

abstract class ConnectivityEvent extends Equatable {
  const ConnectivityEvent();

  @override
  List<Object> get props => [];
}

class ConnectivityChanged extends ConnectivityEvent {
  final List<ConnectivityResult> connectivityResults;

  const ConnectivityChanged(this.connectivityResults);

  @override
  List<Object> get props => [connectivityResults];
}
