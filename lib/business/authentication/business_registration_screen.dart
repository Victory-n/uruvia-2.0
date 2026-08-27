import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/individual/dashboard.dart';
import 'package:uruvia/services/auth_service.dart';
import 'package:uruvia/shared/widgets/custom_text.dart';

class BusinessRegistrationScreen extends StatefulWidget {
  final String userName;

  const BusinessRegistrationScreen({super.key, required this.userName});

  @override
  State<BusinessRegistrationScreen> createState() =>
      _BusinessRegistrationScreenState();
}

class _BusinessRegistrationScreenState
    extends State<BusinessRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _businessNameController = TextEditingController();
  final _businessEmailController = TextEditingController();
  final _businessPhoneController = TextEditingController();
  final _regNumberController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessEmailController.dispose();
    _businessPhoneController.dispose();
    _regNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleBusinessSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.instance.createBusinessAccount(
        businessName: _businessNameController.text.trim(),
        businessEmail: _businessEmailController.text.trim().isNotEmpty
            ? _businessEmailController.text.trim()
            : null,
        businessPhoneNumber: _businessPhoneController.text.trim().isNotEmpty
            ? _businessPhoneController.text.trim()
            : null,
        certificateOfRegistration: _regNumberController.text.trim().isNotEmpty
            ? _regNumberController.text.trim()
            : null,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Business profile created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => IndividualDashboard(userName: widget.userName),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create business account: ${e.toString()}'),
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
                interText(
                  text: 'Business Details',
                  colors: ConstantColor.headingTextPrimary,
                  fontWeight: FontWeight.bold,
                  size: 26.0,
                ),
                const SizedBox(height: 6),
                interText(
                  text:
                      'Enter your business profile details to complete registration.',
                  colors: ConstantColor.subHeadingTextPrimary,
                  fontWeight: FontWeight.normal,
                  size: 14.0,
                ),
                const SizedBox(height: 28),

                // Business Name Field
                _buildLabel('Business Name'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _businessNameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Business name is required';
                    }
                    return null;
                  },
                  decoration: _buildInputDecoration(
                    hint: 'e.g. Acme Global Logistics',
                    icon: Icons.business_rounded,
                  ),
                ),
                const SizedBox(height: 18),

                // Business Email Field
                _buildLabel('Business Email (Optional)'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _businessEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _buildInputDecoration(
                    hint: 'e.g. contact@acmeglobal.com',
                    icon: Icons.email_outlined,
                  ),
                ),
                const SizedBox(height: 18),

                // Business Phone Field
                _buildLabel('Business Phone (Optional)'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _businessPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _buildInputDecoration(
                    hint: 'e.g. +234 800 123 4567',
                    icon: Icons.phone_outlined,
                  ),
                ),
                const SizedBox(height: 18),

                // Reg Number Field
                _buildLabel('CAC / Registration Number (Optional)'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _regNumberController,
                  decoration: _buildInputDecoration(
                    hint: 'e.g. RC-1234567',
                    icon: Icons.verified_user_outlined,
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleBusinessSubmit,
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
                            text: 'Create Business Profile',
                            colors: Colors.white,
                            fontWeight: FontWeight.bold,
                            size: 16.0,
                          ),
                  ),
                ),
                const SizedBox(height: 24),
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
