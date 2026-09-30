import 'package:flutter/material.dart';
import '../../../shared/widgets/app_text.dart';
import '../../../theme/individual/app_theme.dart';
import 'login_screen.dart';

class AutoLoginScreen extends StatefulWidget {
  const AutoLoginScreen({super.key});

  @override
  State<AutoLoginScreen> createState() => _AutoLoginScreenState();
}

class _AutoLoginScreenState extends State<AutoLoginScreen> {

  void _handleBiometricLogin() {
    // TODO: Implement biometric auth or PIN validation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.sleekBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const CircleAvatar(
                radius: 48,
                backgroundColor: AppTheme.white,
                child: Icon(Icons.person, size: 48, color: AppTheme.sleekBlue),
              ),
              const SizedBox(height: 24),
              AppText.subtitle(
                'Welcome Back',
                style: TextStyle(color: AppTheme.white),
              ),
              const SizedBox(height: 8),
              AppText.title(
                'Jonathan', // Mock user name
                style: TextStyle(color: AppTheme.white),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _handleBiometricLogin,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentBlue.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.fingerprint,
                    size: 48,
                    color: AppTheme.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AppText.paragraph(
                'Tap to unlock with Biometrics',
                style: TextStyle(color: AppTheme.white.withValues(alpha: 0.8)),
              ),
              const SizedBox(height: 48),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const AppText.button(
                  'Login with Password',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
