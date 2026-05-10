import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(const TeamTaskApp());

class TeamTaskApp extends StatelessWidget {
  const TeamTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeamTask',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7F77DD)),
        fontFamily: 'sans-serif',
      ),
      home: const HomeScreen(),
    );
  }
}
