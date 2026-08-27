import 'package:flutter/material.dart';
import 'package:uruvia/business/authentication/business_setup_prompt_screen.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/individual/dashboard.dart';
import 'package:uruvia/services/auth_service.dart';
import 'package:uruvia/shared/widgets/custom_text.dart';
import '../registration_screens/registration_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? prefilledEmail;

  const LoginScreen({super.key, this.prefilledEmail});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.prefilledEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthService.instance.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (response.user != null) {
        final profile = await AuthService.instance.getUserProfile(
          response.user!.id,
        );

        if (!mounted) return;

        final userName = profile?.firstname.isNotEmpty == true
            ? profile!.firstname
            : 'User';

        if (profile?.accountType == 'individual' || profile == null) {
          // Route to Post-Login Business Prompt
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) =>
                  BusinessSetupPromptScreen(userName: userName),
            ),
            (route) => false,
          );
        } else {
          // Business user -> route directly to Dashboard
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => IndividualDashboard(userName: userName),
            ),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantColor.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: ConstantColor.headingTextPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                interText(
                  text: 'Welcome Back',
                  colors: ConstantColor.headingTextPrimary,
                  fontWeight: FontWeight.bold,
                  size: 28.0,
                ),
                const SizedBox(height: 6),
                interText(
                  text: 'Sign in to access your Uruvia account.',
                  colors: ConstantColor.subHeadingTextPrimary,
                  size: 15.0,
                  fontWeight: FontWeight.normal,
                ),
                const SizedBox(height: 32),

                // Email Field
                _buildLabel('Email Address'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!value.contains('@')) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                  decoration: _buildInputDecoration(
                    hint: 'e.g. alex@example.com',
                    icon: Icons.email_outlined,
                  ),
                ),
                const SizedBox(height: 20),

                // Password Field
                _buildLabel('Password'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                  decoration: _buildInputDecoration(
                    hint: 'Enter your password',
                    icon: Icons.lock_outline_rounded,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: ConstantColor.subHeadingTextPrimary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Password reset link feature coming soon.',
                          ),
                        ),
                      );
                    },
                    child: interText(
                      text: 'Forgot Password?',
                      colors: ConstantColor.blueBackground,
                      fontWeight: FontWeight.w600,
                      size: 14.0,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ConstantColor.blueBackground,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: ConstantColor.blueBackground.withOpacity(
                        0.4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : interText(
                            text: 'Sign In',
                            colors: Colors.white,
                            fontWeight: FontWeight.bold,
                            size: 16.0,
                          ),
                  ),
                ),
                const SizedBox(height: 28),

                // Register Link Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    interText(
                      text: 'Don\'t have an account? ',
                      colors: ConstantColor.subHeadingTextPrimary,
                      fontWeight: FontWeight.normal,
                      size: 14.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const RegistrationScreen(),
                          ),
                        );
                      },
                      child: interText(
                        text: 'Sign Up',
                        colors: ConstantColor.blueBackground,
                        fontWeight: FontWeight.bold,
                        size: 14.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return interText(
      text: label,
      colors: ConstantColor.headingTextPrimary,
      fontWeight: FontWeight.w600,
      size: 14.0,
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14.0,
        color: ConstantColor.subHeadingTextPrimary.withOpacity(0.6),
      ),
      prefixIcon: Icon(
        icon,
        color: ConstantColor.subHeadingTextPrimary,
        size: 20,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: ConstantColor.subHeadingTextPrimary.withOpacity(0.2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: ConstantColor.blueBackground,
          width: 1.8,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.8),
      ),
    );
  }
}
