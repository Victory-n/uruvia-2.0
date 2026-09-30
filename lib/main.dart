import 'package:flutter/material.dart';
import 'theme/individual/app_theme.dart';
import 'shared/screens/auth/splash_screen.dart';
import 'shared/widgets/offline_banner_wrapper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uruvia',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return OfflineBannerWrapper(
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const SplashScreen(),
    );
  }
}
