import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/individual/dashboard.dart';
import 'package:uruvia/services/app_initializer.dart';
import 'welcome_screens/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  String _statusText = 'Starting Uruvia...';

  @override
  void initState() {
    super.initState();

    // 1. Initialize logo entrance animation
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
      ),
    );

    _animController.forward();

    // 2. Remove native splash and trigger session bootstrapping
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAppBootstrapping();
    });
  }

  Future<void> _startAppBootstrapping() async {
    // Smooth handoff: remove the native OS splash screen
    FlutterNativeSplash.remove();

    final result = await AppInitializer.instance.bootstrapSessionAndData(
      onProgress: (status) {
        if (mounted) {
          setState(() {
            _statusText = status;
          });
        }
      },
    );

    if (!mounted) return;

    // Route to appropriate screen based on init result
    switch (result) {
      case InitResult.authenticated:
        final user = Supabase.instance.client.auth.currentUser;
        final meta = user?.userMetadata;
        final name = (meta?['firstname'] ?? meta?['first_name'] ?? '').toString().trim();
        _navigateToTarget(IndividualDashboard(userName: name.isNotEmpty ? name : "User"));
        break;
      case InitResult.unauthenticated:
      case InitResult.error:
        _navigateToTarget(const WelcomeScreen());
        break;
    }
  }

  void _navigateToTarget(Widget destinationScreen) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            destinationScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: ConstantColor.lightBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // Center Logo Animation
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/img/logo.png',
                        width: 130,
                        height: 130,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 90,
                          color: ConstantColor.blueBackground,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'URUVIÁ',
                        style: TextStyle(
                          fontFamily: 'googleSans',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: ConstantColor.headingTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Progress & Status Message
            Positioned(
              bottom: 48,
              left: 24,
              right: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ConstantColor.blueBackground,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      _statusText,
                      key: ValueKey<String>(_statusText),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: ConstantColor.paragraphTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
