import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/services/auth_service.dart';
import 'package:uruvia/shared/widgets/custom_text.dart';
import '../login_screens/login_screen.dart';
import '../verify_screens/otp_verification_screen.dart';
import 'widgets/region_currency_picker_widget.dart';
import 'widgets/registration_header_widget.dart';
import 'widgets/registration_input_field.dart';

/// Dedicated Scaffold screen for Option B Single-Page User Registration.
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRegion = 'Africa';
  String _selectedCurrency = 'NGN';
  final String _selectedAccountType = 'individual';

  bool _isLoading = false;

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthService.instance.registerUser(
        email: _emailController.text,
        password: _passwordController.text,
        firstname: _firstNameController.text,
        lastname: _lastNameController.text,
        phoneNumber: _phoneController.text,
        region: _selectedRegion,
        currency: _selectedCurrency,
        accountType: _selectedAccountType,
      );

      if (!mounted) return;

      if (response.user != null || response.session != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Registration successful! Verification code sent to your email.',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to OTP Verification screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                OtpVerificationScreen(email: _emailController.text.trim()),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      String errorMessage;
      if (e is AuthException) {
        errorMessage = e.message;
      } else if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        errorMessage =
            'Network error: Unable to connect to Supabase backend. Please check your internet connection or verify the Supabase URL in supabase_config.dart.';
      } else {
        errorMessage = e.toString();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $errorMessage'),
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
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                // Header
                const RegistrationHeaderWidget(),
                const SizedBox(height: 28),

                // First Name & Last Name Row
                Row(
                  children: [
                    Expanded(
                      child: RegistrationInputField(
                        label: 'First Name',
                        hintText: 'John',
                        controller: _firstNameController,
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RegistrationInputField(
                        label: 'Last Name',
                        hintText: 'Doe',
                        controller: _lastNameController,
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Email Address
                RegistrationInputField(
                  label: 'Email Address',
                  hintText: 'john.doe@example.com',
                  controller: _emailController,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Phone Number
                RegistrationInputField(
                  label: 'Phone Number',
                  hintText: '+234 800 000 0000',
                  controller: _phoneController,
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Password
                RegistrationInputField(
                  label: 'Password',
                  hintText: 'Minimum 6 characters',
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Region & Currency Picker
                RegionCurrencyPickerWidget(
                  selectedRegion: _selectedRegion,
                  selectedCurrency: _selectedCurrency,
                  onRegionChanged: (region) {
                    setState(() {
                      _selectedRegion = region;
                    });
                  },
                  onCurrencyChanged: (currency) {
                    setState(() {
                      _selectedCurrency = currency;
                    });
                  },
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegistration,
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
                            text: 'Create Account',
                            colors: Colors.white,
                            fontWeight: FontWeight.bold,
                            size: 16.0,
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login Link Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    interText(
                      text: 'Already have an account? ',
                      colors: ConstantColor.subHeadingTextPrimary,
                      fontWeight: FontWeight.normal,
                      size: 14.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: interText(
                        text: 'Log In',
                        colors: ConstantColor.blueBackground,
                        fontWeight: FontWeight.bold,
                        size: 14.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
