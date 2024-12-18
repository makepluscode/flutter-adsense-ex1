import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() => runApp(const AdSenseApp());

class AdSenseApp extends StatelessWidget {
  const AdSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AdSense Dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
