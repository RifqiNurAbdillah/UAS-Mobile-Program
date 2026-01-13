import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/splash_screen.dart'; // 1. Tambahkan import ini

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter CRUD App',
      theme: ThemeData(primarySwatch: Colors.blue),
      // 2. Ganti LoginPage() menjadi SplashScreen()
      home: const SplashScreen(),
    );
  }
}
