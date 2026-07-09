import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uruvia/connection/connectivity_service.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/constants/supabase_config.dart';
import 'package:uruvia/welcome/page_one.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    publishableKey: SupabaseConfig.supabaseAnonKey,
  );

  // Initialize background internet checking
  ConnectivityService.instance.initialize();

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: ConstantColor.lightBackground,
        ),
      ),
      home: PageOne(),
    );
  }
}
