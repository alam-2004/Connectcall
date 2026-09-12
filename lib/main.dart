import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/call_provider.dart';

import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const ConnectCallApp());
}

class ConnectCallApp extends StatelessWidget {
  const ConnectCallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        ChangeNotifierProvider(create: (_) => UserProvider()),

        ChangeNotifierProvider(create: (_) => CallProvider()),
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        title: 'ConnectCall',

        theme: ThemeData(useMaterial3: true),

        home: const SplashScreen(),
      ),
    );
  }
}
