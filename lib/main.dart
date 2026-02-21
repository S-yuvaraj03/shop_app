import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart' as appProvider;
import 'package:shop_app/data/repositories/authentication_repo/auth_repository.dart';
import 'package:shop_app/firebase_options.dart';
import 'package:shop_app/screens/home_screen.dart';
// import 'package:shop_app/screens/home_screen.dart';
import 'package:shop_app/services/firestore_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'AppEntryPoint.dart';
import 'common/widgets/Notification.dart';
import 'common/widgets/searchfield.dart';
import 'features/shop/screens/NetworkConnectivity/Connectivity_bloc/connectivity_bloc.dart';
import 'features/shop/screens/NetworkConnectivity/connectivity_indicator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // ignore: unused_local_variable
  final fcmToken = await FirebaseMessaging.instance.getToken();
  // print(fcmToken);
  await Permission.camera.request();
  await Permission.microphone.request();
  await Permission.manageExternalStorage.request();
  await Permission.notification.request();
  PermissionStatus locationaccessStatus = await Permission.location.request();
  if (locationaccessStatus.isGranted) {
    runApp( ProviderScope(child: MyApp()));
  } else if (locationaccessStatus.isDenied ||
      locationaccessStatus.isPermanentlyDenied) {
    // Permission denied
    await openAppSettings(); // Optional: Open app settings to allow permission
  }
}

class MyApp extends StatelessWidget {
  // ignore: unused_field
  final PushNotificationService _notificationService =
      PushNotificationService();
  @override
  Widget build(BuildContext context) {
    return appProvider.MultiProvider(
      providers: [
        BlocProvider(
          create: (context) => ConnectivityBloc()..checkInitialConnectivity(),
        ),
        appProvider.Provider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),
        appProvider.Provider<FirestoreService>(
          create: (_) => FirestoreService(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              child!,
              ConnectivityIndicator(), // Add this to show connectivity status globally
            ],
          );
        },
        routes: {
          '/': (BuildContext context) => AppEntryPoint(),
          '/Home': (BuildContext context) => HomeScreen(),
          '/Search': (BuildContext context) => Searchfield(),
        },
      ),
    );
  }
}
