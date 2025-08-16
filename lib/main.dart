import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ig/auth/auth.dart';
import 'package:ig/auth/login_or_register.dart';
import 'package:ig/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: AuthPage());
  }
}
