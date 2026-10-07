import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'offline/connectivity_service.dart';
import 'theme/individual/app_theme.dart';
import 'shared/screens/auth/splash_screen.dart';
import 'shared/widgets/offline_banner_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mvisrdmdxbenuqezprdn.supabase.co',
    publishableKey: 'sb_publishable_5n0XY_6HBYN-xQwp5XV7eg_o7RqUQVp',
  );

  // Watch network state; reconnecting flushes the offline queue.
  ConnectivityService.instance.initialize();

  runApp(const MyApp());
}

/// Global Supabase client shortcut.
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uruvia',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return OfflineBannerWrapper(child: child ?? const SizedBox.shrink());
      },
      home: const SplashScreen(),
    );
  }
}
