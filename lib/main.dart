import 'package:flutter/material.dart';
import 'pages/login_page.dart'; // Añade esta línea

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SignInScreen(), // Usa tu pantalla de login
    );
  }
}