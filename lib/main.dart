import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:movease/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: FirebaseOptions(
    apiKey: "AIzaSyB0QOjaq3lpNoernFagA29KZNnxYTvdepc",
    appId: "1:625980372531:android:2cf247bfd4f07773311546",
    messagingSenderId: "625980372531",
    projectId: "movease-6a9fb", ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Login Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
    );
  }
}
