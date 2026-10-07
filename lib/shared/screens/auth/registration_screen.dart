import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/widgets/app_text.dart';
import '../../../theme/individual/app_theme.dart';
import 'login_screen.dart';
import 'otp_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: AppText.paragraph(message)),
    );
  }

  void _handleRegistration() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || phone.isEmpty) {
      _showMessage('Please fill in all fields');
      return;
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _showMessage('Please enter a valid email address');
      return;
    }
    if (password.length < 6) {
      _showMessage('Password must be at least 6 characters');
      return;
    }
    if (password != _confirmPasswordController.text) {
      _showMessage('Passwords do not match');
      return;
    }
    if (!_agreeToTerms) {
      _showMessage('You must agree to the terms and conditions');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // The handle_new_user DB trigger creates the profile row on the
      // default 'individual' account using this metadata.
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'agreed_to_terms': true,
        },
      );

      if (!mounted) return;

      // With email confirmation enabled no session is returned yet and
      // the user must enter the emailed OTP.
      if (response.session == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => OtpScreen(email: email)),
        );
        return;
      }

      // Confirmation disabled: user is already verified. Sign out so they
      // log in through the normal flow.
      await Supabase.instance.client.auth.signOut();
      if (!mounted) return;
      _showMessage('Account created! Please log in.');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } on AuthException catch (e) {
      if (mounted) _showMessage(e.message);
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
              const AppText.title('Create Account'),
              const SizedBox(height: 8),
              const AppText.paragraph(
                'Join Uruvia and start managing your finances effortlessly.',
              ),
              const SizedBox(height: 32),
              
              // Name Fields
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        hintText: 'First Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        hintText: 'Last Name',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Email Field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              
              // Phone Field
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),
              
              // Password Field
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
              
              // Confirm Password Field
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      color: AppTheme.textMuted,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Terms Checkbox
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _agreeToTerms,
                      activeColor: AppTheme.accentBlue,
                      checkColor: AppTheme.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        text: 'I agree to the ',
                        style: TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 14,
                          fontFamily: 'Inter',
                        ),
                        children: [
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                              color: AppTheme.accentBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: AppTheme.accentBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Sign Up Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegistration,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const AppText.button('Sign Up'),
                ),
              ),
              const SizedBox(height: 24),
              
              // Login Redirect
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 14,
                        fontFamily: 'Inter',
                      ),
                      children: [
                        TextSpan(
                          text: 'Login',
                          style: TextStyle(
                            color: AppTheme.accentBlue,
                            fontWeight: FontWeight.bold,
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
