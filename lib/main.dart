import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:gritzafood/screens/splash_screens.dart';
import 'package:gritzafood/states/cart_state.dart';
import 'package:gritzafood/states/map_states.dart';
import 'package:provider/provider.dart';

// ignore: non_constant_identifier_names
bool USE_FIRESTORE_EMULATOR = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables();
  await Firebase.initializeApp();
  if (USE_FIRESTORE_EMULATOR) {
    FirebaseFirestore.instance.settings = const Settings(
      host: 'localhost:8080',
      sslEnabled: false,
      persistenceEnabled: false,
    );
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MapStates()),
        ChangeNotifierProvider(create: (_) => CartState()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScopeNode focus = FocusScope.of(context);
          if (!focus.hasPrimaryFocus && focus.focusedChild != null) {
            focus.focusedChild.unfocus();
          }
        },
        child: const MaterialApp(
            title: 'Flutter Demo',
            debugShowCheckedModeBanner: false,
            home: SplashScreen()));
  }
}
