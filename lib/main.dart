import 'package:flutter/material.dart';
import 'package:login_tasarim/register_page.dart';
import 'login_screen.dart'; // Giriş ekranı dosyanızı ekleyin
import 'login_screen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Giriş Ekranı',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

