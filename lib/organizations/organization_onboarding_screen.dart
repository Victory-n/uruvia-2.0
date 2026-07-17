import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/widgets/custom_text.dart';
import 'package:uruvia/side_bar.dart';
import 'package:uruvia/offline/connectivity_service.dart';

class OrganizationOnboardingScreen extends StatefulWidget {
  const OrganizationOnboardingScreen({super.key});

  @override
  State<OrganizationOnboardingScreen> createState() =>
      _OrganizationOnboardingScreenState();
}

class _OrganizationOnboardingScreenState
    extends State<OrganizationOnboardingScreen> {
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();

  int _currentStep = 0;
  bool _isLoading = false;

  // Step 1 Controllers & State
  final _businessNameController = TextEditingController();

  // Logo upload state
  String? _uploadedLogoName;
  String? _uploadedLogoSize;
  bool _isUploadingLogo = false;
  double _uploadProgress = 0.0;

  void _simulateLogoUpload() {
    setState(() {
      _isUploadingLogo = true;
      _uploadProgress = 0.0;
    });

    // Simulate file upload progress
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _uploadProgress += 0.1;
        if (_uploadProgress >= 1.0) {
          _uploadProgress = 1.0;
          _isUploadingLogo = false;
          _uploadedLogoName = "company_brand_logo.png";
          _uploadedLogoSize = "840 KB";
          timer.cancel();
        }
      });
    });
  }

  void _removeLogo() {
    setState(() {
      _uploadedLogoName = null;
      _uploadedLogoSize = null;
      _uploadProgress = 0.0;
      _isUploadingLogo = false;
    });
  }

  // Step 2 Controllers & State
  final _countryController = TextEditingController(text: "United States");
  final _currencyController = TextEditingController(text: "USD");
  String _selectedBusinessSize = '';

  // Step 3 Controllers & State
  final List<String> _selectedGoals = [];
  final _tinController = TextEditingController();

  // Premium Custom Colors
  static const Color _accentIndigo = Color(0xFF6366F1);
  static const Color _cardBg = Color(0xFFF3F4F6);
  static const Color _inputBorderColor = Color(0xFFE5E7EB);
  static const Color _gradientStart = Color(0xFFEEF2FF);
  static const Color _gradientEnd = Color(0xFFE0E7FF);

  final List<String> _businessSizes = [
    '1 - 5 employees (Micro)',
    '6 - 20 employees (Small)',
    '21 - 100 employees (Medium)',
    '101+ employees (Enterprise)',
  ];

  final List<Map<String, dynamic>> _goalsList = [
    {'name': 'Invoice Clients', 'icon': Icons.receipt_long},
    {'name': 'Track Inventory', 'icon': Icons.inventory_2_outlined},
    {'name': 'Log Expenses', 'icon': Icons.monetization_on_outlined},
    {'name': 'Team Collaboration', 'icon': Icons.people_outline},
    {'name': 'Business Health Score', 'icon': Icons.analytics_outlined},
  ];

  // Custom interactive file upload interface is used for the business logo instead of pre-built avatars

  @override
  void dispose() {
    _businessNameController.dispose();
    _countryController.dispose();
    _currencyController.dispose();
    _tinController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_formKey1.currentState!.validate()) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 1) {
      if (_formKey2.currentState!.validate()) {
        if (_selectedBusinessSize.isEmpty) {
          _showSnackBar("Please select your business size", Colors.amber[800]!);
          return;
        }
        setState(() => _currentStep++);
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _showSnackBar(String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    if (_currentStep == 2) {
      setState(() => _isLoading = true);

      final isOnline = ConnectivityService.instance.isConnected.value;

      try {
        if (isOnline) {
          // Save configuration directly to Supabase User Metadata
          await Supabase.instance.client.auth.updateUser(
            UserAttributes(
              data: {
                'has_onboarded_business': true,
                'business_name': _businessNameController.text.trim(),
                'business_logo_name': _uploadedLogoName,
                'business_logo_size': _uploadedLogoSize,
                'business_country': _countryController.text.trim(),
                'business_currency': _currencyController.text.trim(),
                'business_size': _selectedBusinessSize,
                'business_goals': _selectedGoals,
                'business_tin': _tinController.text.trim(),
              },
            ),
          );
          _showSnackBar(
            "Business workspace set up successfully!",
            Colors.green,
          );
        } else {
          // Offline mode fallback: we notify the user but proceed since it will sync
          _showSnackBar(
            "Saved locally! Details will sync once you are back online.",
            Colors.orange,
          );
        }

        if (mounted) {
          // Go to Dashboard Sidebar page
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const SideBarPage(title: ""),
            ),
            (route) => false,
          );
        }
      } catch (error) {
        if (mounted) {
          _showSnackBar(
            "Error saving setup: ${error.toString()}",
            Colors.redAccent,
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  // Modern input field builder
  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText(
          text: label,
          colors: ConstantColor.paragraphTextPrimary,
          fontWeight: FontWeight.w600,
          size: 14.0,
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontFamily: "Inter",
            fontSize: 15.0,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: "Inter",
              color: ConstantColor.paragraphTextSecondary,
              fontSize: 14.0,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 14.0,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(
                color: _inputBorderColor,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(
                color: ConstantColor.blueBackground,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // Welcome / Intro Widget
  Widget _buildWelcomeHeader() {
    return Column(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: ConstantColor.blueBackground.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.business_center,
            color: ConstantColor.blueBackground,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        interText(
          text: "Let's set up your business",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 24.0,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        googleSansText(
          text:
              "Tell us a bit about your organization so we can customize your workspace experience.",
          colors: ConstantColor.paragraphTextSecondary,
          fontWeight: FontWeight.normal,
          size: 14.0,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Stepper Header
  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green
                      : (isActive
                            ? ConstantColor.blueBackground
                            : Colors.white),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted
                        ? Colors.green
                        : (isActive
                              ? ConstantColor.blueBackground
                              : _inputBorderColor),
                    width: 2.0,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: ConstantColor.blueBackground.withOpacity(
                              0.3,
                            ),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : Text(
                          "${index + 1}",
                          style: TextStyle(
                            fontFamily: "Inter",
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isActive
                                ? Colors.white
                                : ConstantColor.paragraphTextSecondary,
                          ),
                        ),
                ),
              ),
              if (index < 2)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 3,
                  width: 50,
                  color: index < _currentStep
                      ? Colors.green
                      : _inputBorderColor,
                ),
            ],
          );
        }),
      ),
    );
  }

  // STEP 1: Business Details
  Widget _buildStep1() {
    return Form(
      key: _formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildField(
            label: "Business / SME Name",
            hint: "e.g. Acme Corp or Jane's Bakery",
            controller: _businessNameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Business name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Business Logo File Upload UI
          interText(
            text: "Business Logo (Optional)",
            colors: ConstantColor.paragraphTextPrimary,
            fontWeight: FontWeight.w600,
            size: 14.0,
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: (_isUploadingLogo || _uploadedLogoName != null)
                ? null
                : _simulateLogoUpload,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 24.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                color: _uploadedLogoName != null
                    ? Colors.green.withOpacity(0.02)
                    : (_isUploadingLogo
                          ? ConstantColor.blueBackground.withOpacity(0.02)
                          : Colors.white),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _uploadedLogoName != null
                      ? Colors.green.withOpacity(0.4)
                      : (_isUploadingLogo
                            ? ConstantColor.blueBackground
                            : _inputBorderColor),
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_uploadedLogoName == null && !_isUploadingLogo) ...[
                    const Icon(
                      Icons.cloud_upload_outlined,
                      color: ConstantColor.blueBackground,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    interText(
                      text: "Click to upload business logo",
                      colors: ConstantColor.headingTextPrimary,
                      fontWeight: FontWeight.w600,
                      size: 14.0,
                    ),
                    const SizedBox(height: 4),
                    interText(
                      text: "Supports PNG, JPG, JPEG up to 3MB",
                      colors: ConstantColor.paragraphTextSecondary,
                      fontWeight: FontWeight.normal,
                      size: 12.0,
                    ),
                  ] else if (_isUploadingLogo) ...[
                    const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ConstantColor.blueBackground,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: _uploadProgress,
                      backgroundColor: _inputBorderColor,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        ConstantColor.blueBackground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    interText(
                      text:
                          "Uploading logo... ${(_uploadProgress * 100).toInt()}%",
                      colors: ConstantColor.paragraphTextPrimary,
                      fontWeight: FontWeight.w600,
                      size: 13.0,
                    ),
                  ] else if (_uploadedLogoName != null) ...[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.image_outlined,
                            color: Colors.green,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              interText(
                                text: _uploadedLogoName!,
                                colors: ConstantColor.headingTextPrimary,
                                fontWeight: FontWeight.bold,
                                size: 14.0,
                              ),
                              const SizedBox(height: 2),
                              interText(
                                text: _uploadedLogoSize!,
                                colors: ConstantColor.paragraphTextSecondary,
                                fontWeight: FontWeight.normal,
                                size: 12.0,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          onPressed: _removeLogo,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 2: Scale & Location
  Widget _buildStep2() {
    return Form(
      key: _formKey2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildField(
            label: "Operating Country",
            hint: "e.g. United States, Nigeria, United Kingdom",
            controller: _countryController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Country is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildField(
            label: "Primary Currency",
            hint: "e.g. USD, EUR, NGN, GBP",
            controller: _currencyController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Currency is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Business Size
          interText(
            text: "Business Size (Team Members)",
            colors: ConstantColor.paragraphTextPrimary,
            fontWeight: FontWeight.w600,
            size: 14.0,
          ),
          const SizedBox(height: 8),
          Column(
            children: _businessSizes.map((size) {
              final isSelected = _selectedBusinessSize == size;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedBusinessSize = size;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 14.0,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ConstantColor.blueBackground.withOpacity(0.06)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? ConstantColor.blueBackground
                          : _inputBorderColor,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isSelected
                            ? ConstantColor.blueBackground
                            : ConstantColor.paragraphTextSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      interText(
                        text: size,
                        colors: ConstantColor.headingTextPrimary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        size: 14.0,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // STEP 3: Goals & Focus
  Widget _buildStep3() {
    return Form(
      key: _formKey3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primary goals chips
          interText(
            text: "What are your primary goals on Uruvia?",
            colors: ConstantColor.paragraphTextPrimary,
            fontWeight: FontWeight.w600,
            size: 14.0,
          ),
          const SizedBox(height: 4),
          interText(
            text: "Select all that apply to customize your home dashboard",
            colors: ConstantColor.paragraphTextSecondary,
            fontWeight: FontWeight.normal,
            size: 12.0,
          ),
          const SizedBox(height: 12),
          Column(
            children: _goalsList.map((goal) {
              final goalName = goal['name'] as String;
              final isSelected = _selectedGoals.contains(goalName);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedGoals.remove(goalName);
                    } else {
                      _selectedGoals.add(goalName);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 14.0,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _accentIndigo.withOpacity(0.06)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? _accentIndigo : _inputBorderColor,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        goal['icon'] as IconData,
                        color: isSelected
                            ? _accentIndigo
                            : ConstantColor.paragraphTextSecondary,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: interText(
                          text: goalName,
                          colors: ConstantColor.headingTextPrimary,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          size: 14.0,
                        ),
                      ),
                      Checkbox(
                        value: isSelected,
                        activeColor: _accentIndigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedGoals.add(goalName);
                            } else {
                              _selectedGoals.remove(goalName);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // TIN or VAT Number
          _buildField(
            label: "Tax / VAT Identification Number (Optional)",
            hint: "e.g. US-12345678 or GB-987654321",
            controller: _tinController,
            validator: (value) => null, // Optional, no validation
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_gradientStart, _gradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Welcome header + Stepper inside a scrollable card area
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _buildWelcomeHeader(),
                      const SizedBox(height: 16),
                      _buildStepIndicator(),
                      const SizedBox(height: 16),

                      // Content container
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        width: size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _currentStep == 0
                              ? _buildStep1()
                              : (_currentStep == 1
                                    ? _buildStep2()
                                    : _buildStep3()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom navigation buttons
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button or Skip button
                    if (_currentStep == 0)
                      TextButton(
                        onPressed: () {
                          // Allow skipping
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SideBarPage(title: ""),
                            ),
                            (route) => false,
                          );
                        },
                        child: interText(
                          text: "Skip Setup",
                          colors: ConstantColor.paragraphTextSecondary,
                          fontWeight: FontWeight.w600,
                          size: 15.0,
                        ),
                      )
                    else
                      TextButton.icon(
                        onPressed: _isLoading ? null : _prevStep,
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 16,
                          color: ConstantColor.paragraphTextPrimary,
                        ),
                        label: interText(
                          text: "Back",
                          colors: ConstantColor.paragraphTextPrimary,
                          fontWeight: FontWeight.w600,
                          size: 15.0,
                        ),
                      ),

                    // Continue or Submit button
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : (_currentStep == 2
                                ? _completeOnboarding
                                : _nextStep),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ConstantColor.blueBackground,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 14.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              children: [
                                interText(
                                  text: _currentStep == 2
                                      ? "Complete Setup"
                                      : "Continue",
                                  colors: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  size: 15.0,
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _currentStep == 2
                                      ? Icons.check_circle_outline
                                      : Icons.arrow_forward,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
