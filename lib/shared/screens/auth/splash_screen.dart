import 'package:flutter/material.dart';
import '../../../shared/widgets/app_text.dart';
import '../../../theme/individual/app_theme.dart';
import '../../services/session_router.dart';
import 'login_screen.dart';
import 'registration_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  // If a session already exists, skip the welcome screen and open the
  // dashboard for the user's active account type.
  Future<void> _restoreSession() async {
    final home = await SessionRouter.restoreHome();
    if (!mounted) return;

    if (home != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => home),
      );
    } else {
      setState(() => _checkingSession = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingSession) {
      return Scaffold(
        backgroundColor: AppTheme.sleekBlue,
        body: Center(
          child: Image.asset(
            'assets/img/logo.png',
            height: 48,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.account_balance_wallet,
              size: 48,
              color: AppTheme.white,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.sleekBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Image.asset(
                'assets/img/logo.png',
                height: 48,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.account_balance_wallet,
                  size: 48,
                  color: AppTheme.white,
                ),
              ),
              const Spacer(),
              AppText.custom(
                'Track Your\nSpending\nEffortlessly',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppTheme.white,
                  fontSize: 40,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 24),
              AppText(
                'Manage your finances easily using our intuitive and user-friendly interface and set financial goals and monitor your progress',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegistrationScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: AppTheme.darkGreen,
                  ),
                  child: const AppText.custom(
                    'Get Started',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 12,
                        fontFamily: 'Inter',
                      ),
                      children: [
                        TextSpan(
                          text: 'Login',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
