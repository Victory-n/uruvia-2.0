import 'package:flutter/material.dart';
import '../../../shared/widgets/app_text.dart';
import '../../../theme/individual/app_theme.dart';
import 'forgot_password_screen.dart';
import 'registration_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auto_login_screen.dart';
import '../../../individual_account/screens/dashboard_screen.dart';
import '../../../business_account/welcome/business_onboarding_prompt_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenPrompt = prefs.getBool('has_seen_business_prompt') ?? false;

    if (mounted) {
      if (!hasSeenPrompt) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BusinessOnboardingPromptScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),

      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText.title('Welcome Back!'),
              const SizedBox(height: 8),
              const AppText.paragraph(
                'Login to your account',
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppTheme.textMuted,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                    );
                  },
                  child: const AppText.button(
                    'Forgot Password?',
                    style: TextStyle(color: AppTheme.accentBlue, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  child: const AppText.button('Login'),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const RegistrationScreen()),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 14,
                        fontFamily: 'Inter',
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign Up',
                          style: TextStyle(color: AppTheme.accentBlue, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AutoLoginScreen()),
                    );
                  },
                  child: const AppText.button(
                    'Use Auto Login (Biometric/PIN)',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
