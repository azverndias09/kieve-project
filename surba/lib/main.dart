import 'package:SurbaMart/login.dart';
import 'package:SurbaMart/models/cartItem.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SurbaMart',
      home: LoginScreen(),
      debugShowCheckedModeBanner: false, // Add this line to remove the debug banner
    );
  }
}
