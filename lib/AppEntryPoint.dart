import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/screens/authenticate_screen.dart';
import 'package:shop_app/screens/home_screen.dart';

import 'features/shop/screens/NetworkConnectivity/Connectivity_bloc/connectivity_bloc.dart';
import 'features/shop/screens/NetworkConnectivity/NetworkDialogscreen.dart';
import 'screens/OnboardingScreen.dart';

class AppEntryPoint extends StatelessWidget {
  @override
/**
 * Widget build method that returns a BlocBuilder<ConnectivityBloc, ConnectivityState> widget.
 * It handles different states of connectivity and displays corresponding screens.
 */
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityBloc, ConnectivityState>(
      builder: (context, state) {
        if (state is ConnectivityOffline) {
          // Show the network error screen if there's no connectivity
          return NetworkErrorDialog();
        }

        return FutureBuilder<bool>(
          future: _checkOnboardingComplete(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasData && !snapshot.data!) {
              // Show onboarding screen if onboarding is not complete
              return OnboardingScreen();
            }

            return StreamBuilder<User?>(
              stream: FirebaseAuth.instance.userChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.data == null) {
                  return AuthenticateScreen();
                }
                return HomeScreen(); // Home screen after sign-in
              },
            );
          },
        );
      },
    );
  }

  Future<bool> _checkOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboardingComplete') ?? false;
  }
}
