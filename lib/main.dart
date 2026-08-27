import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/services/app_initializer.dart';
import 'package:uruvia/shared/screens/splash_screen.dart';

void main() async {
  // Delegate Core System setup (Phase 1) to AppInitializer
  await AppInitializer.instance.initializeCore();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uruvia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: ConstantColor.lightBackground,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

