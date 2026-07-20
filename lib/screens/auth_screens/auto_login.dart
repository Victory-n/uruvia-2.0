import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/screens/auth_screens/login_registration_screens.dart';
import 'package:uruvia/side_bar.dart';
import 'package:uruvia/organizations/organization_onboarding_screen.dart';
import '../../widgets/custom_text.dart';

class AutoLogin extends StatefulWidget {
  const AutoLogin({super.key});

  @override
  State<AutoLogin> createState() => _AutoLoginState();
}

class _AutoLoginState extends State<AutoLogin> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        final user = Supabase.instance.client.auth.currentUser;
        final hasOnboarded = (user?.userMetadata?['has_onboarded_business'] ?? false) ||
            (user?.userMetadata?['has_skipped_onboarding'] ?? false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => hasOnboarded
                ? const SideBarPage(title: "")
                : const OrganizationOnboardingScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginRegistrationScreens()),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    String greeting = "Welcome back!";
    if (user != null) {
      final firstName = user.userMetadata?['first_name'] as String?;
      if (firstName != null && firstName.trim().isNotEmpty) {
        greeting = "Welcome back, ${firstName.trim()}!";
      } else if (user.email != null && user.email!.isNotEmpty) {
        greeting = "Welcome back, ${user.email!.split('@').first}!";
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFF2F6FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),

                // Animated Logo / Brand Card
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: ConstantColor.blueBackground.withAlpha(30),
                            blurRadius: 25,
                            spreadRadius: 4,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        "assets/img/logo.png",
                        height: 85,
                        width: 85,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 36.0),

                // Personalised Greeting & Status Subtitle
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      interText(
                        text: greeting,
                        colors: ConstantColor.headingTextPrimary,
                        fontWeight: FontWeight.bold,
                        size: 26.0,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10.0),
                      googleSansText(
                        text: "Verifying secure session & launching your command centre...",
                        colors: ConstantColor.paragraphTextSecondary,
                        fontWeight: FontWeight.normal,
                        size: 15.0,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36.0),

                // Sleek Linear Progress Indicator
                SizedBox(
                  width: 140,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const LinearProgressIndicator(
                      minHeight: 4.5,
                      backgroundColor: Color(0xFFE0E7FF),
                      valueColor: AlwaysStoppedAnimation<Color>(ConstantColor.blueBackground),
                    ),
                  ),
                ),

                const Spacer(),

                // Encrypted Session Security Badge
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 16.0,
                        color: ConstantColor.paragraphTextSecondary.withAlpha(180),
                      ),
                      const SizedBox(width: 6.0),
                      googleSansText(
                        text: "Encrypted Session • Supabase Auth",
                        colors: ConstantColor.paragraphTextSecondary.withAlpha(180),
                        fontWeight: FontWeight.w500,
                        size: 13.0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
