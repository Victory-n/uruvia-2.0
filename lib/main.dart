import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uruvia/individual/dashboard.dart';
import 'package:uruvia/offline/connectivity_service.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/constants/supabase_config.dart';
import 'package:uruvia/services/notification_service.dart';
import 'package:uruvia/welcome/page_one.dart';
import 'package:uruvia/screens/auth_screens/auto_login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    publishableKey: SupabaseConfig.supabaseAnonKey,
  );

  // Initialize background internet checking
  ConnectivityService.instance.initialize();

  // Initialize Notification Service
  await NotificationService.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      title: 'Uruvia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: ConstantColor.lightBackground,
        ),
      ),
      // home: session != null ? const AutoLogin() : const PageOne(),
      // home: session != null ? const AutoLogin() : const Dashboard(),
      home: session == null ? const AutoLogin() : const Dashboard(),
    );
  }
}
