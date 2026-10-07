import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/widgets/app_text.dart';
import '../../../theme/individual/app_theme.dart';
import 'forgot_password_screen.dart';
import 'registration_screen.dart';
import 'auto_login_screen.dart';
import 'otp_screen.dart';
import '../../../offline/profile_repository.dart';
import '../../services/session_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: AppText.paragraph(message)),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter your email and password');
      return;
    }

    setState(() => _isLoading = true);
    final client = Supabase.instance.client;
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw const AuthException('Login failed. Please try again.');
      }

      // First login on this device reads the profile from Supabase; later
      // logins read the local copy first (so offline entries are never lost)
      // and sync in the background. New users default to 'individual'.
      Map<String, dynamic> profile;
      try {
        profile = await ProfileRepository.instance.loadProfile(user.id);
      } catch (_) {
        await client.auth.signOut();
        if (mounted) {
          _showMessage('Could not load your account. Check your connection.');
        }
        return;
      }
      final accountType =
          (profile['active_account_type'] as String?) ?? 'individual';

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SessionRouter.screenFor(accountType)),
      );
    } on AuthException catch (e) {
      if (e.code == 'email_not_confirmed') {
        // Send a fresh code and continue verification.
        try {
          await client.auth.resend(type: OtpType.signup, email: email);
        } catch (_) {}
        if (!mounted) return;
        _showMessage('Please verify your email to continue');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OtpScreen(email: email)),
        );
      } else if (mounted) {
        _showMessage(
          e.code == 'invalid_credentials'
              ? 'Incorrect email or password'
              : e.message,
        );
      }
    } catch (_) {
      if (mounted) _showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const AppText.button('Login'),
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
