import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:kkfinctracker/pages/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        databaseURL:
            "https://kkfinctrack-default-rtdb.asia-southeast1.firebasedatabase.app//", //  Add the RTDB Database URL
        apiKey: "AIzaSyDBD4nYgSElN6EllDoGYne0RqtBRbDHlA0",
        authDomain: "kkfinctrack.firebaseapp.com",
        projectId: "kkfinctrack",
        storageBucket: "kkfinctrack.appspot.com",
        messagingSenderId: "1010855542350",
        appId: "1:1010855542350:web:764e742d64d244d1128d1f"),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KK Finance Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
