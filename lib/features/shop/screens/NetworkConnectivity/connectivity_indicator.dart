import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'Connectivity_bloc/connectivity_bloc.dart';

class ConnectivityIndicator extends StatefulWidget {
  @override
  _ConnectivityIndicatorState createState() => _ConnectivityIndicatorState();
}

class _ConnectivityIndicatorState extends State<ConnectivityIndicator> {
  bool _isVisible = false;
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityBloc, ConnectivityState>(
      listener: (context, state) {
        if (state is ConnectivityOffline) {
          setState(() {
            _isVisible = true; // Show the indicator
          });
        } else if (state is ConnectivityOnline) {
          setState(() {
            _isVisible = true; // Show the indicator
          });
          _startTimer();
        }
      },
      child: Visibility(
        visible: _isVisible,
        child: Container(
          color: context.watch<ConnectivityBloc>().state is ConnectivityOffline ? Colors.black : Colors.blueAccent[100],
          width: double.infinity,
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                context.watch<ConnectivityBloc>().state is ConnectivityOffline ? Icons.cloud_off : Icons.public,
                color: context.watch<ConnectivityBloc>().state is ConnectivityOffline ? Colors.white : Colors.black,
              ),
              SizedBox(width: 4),
              Text(
                context.watch<ConnectivityBloc>().state is ConnectivityOffline ? 'You are offline' : 'Back online',
                style: TextStyle(
                  color: context.watch<ConnectivityBloc>().state is ConnectivityOffline ? Colors.white : Colors.black,
                  fontSize: 12,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer(Duration(seconds: 2), () {
      setState(() {
        _isVisible = false; // Hide the indicator after 2 seconds
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }
}
