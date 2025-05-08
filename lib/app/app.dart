import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import 'theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control de Ganado',
      theme: appTheme,
      home: const HomeScreen(),
    );
  }
}
