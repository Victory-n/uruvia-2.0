import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/welcome/page_one.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: ConstantColor.lightBackground),
      ),
      home: PageOne(),
    );
  }
}
