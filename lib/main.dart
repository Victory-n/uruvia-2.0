import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/offline/connectivity_service.dart';
import 'package:uruvia/services/app_initializer.dart';
import 'package:uruvia/services/navigation_service.dart';
import 'package:uruvia/shared/screens/splash_screen.dart';
import 'package:uruvia/shared/widgets/offline_banner.dart';

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
      navigatorKey: NavigationService.navigatorKey,
      title: 'Uruvia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: ConstantColor.lightBackground,
        ),
      ),
      builder: (context, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: ConnectivityService.instance.isConnected,
          builder: (context, isOnline, _) {
            final Widget content = isOnline
                ? (child ?? const SizedBox.shrink())
                : MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: child ?? const SizedBox.shrink(),
                  );

            return ScaffoldMessenger(
              child: Material(
                type: MaterialType.transparency,
                child: Column(
                  children: [
                    const OfflineBanner(),
                    Expanded(child: content),
                  ],
                ),
              ),
            );
          },
        );
      },
      home: const SplashScreen(),
    );
  }
}
