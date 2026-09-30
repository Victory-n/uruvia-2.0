import 'package:flutter/material.dart';
import 'package:uruvia/theme/business/business_theme.dart';
import '../../../shared/widgets/app_text.dart';
import 'business_registration_form_screen.dart';
import 'business_setup_loading_screen.dart';

class BusinessQuestionnaireScreen extends StatefulWidget {
  const BusinessQuestionnaireScreen({super.key});

  @override
  State<BusinessQuestionnaireScreen> createState() =>
      _BusinessQuestionnaireScreenState();
}

class _BusinessQuestionnaireScreenState
    extends State<BusinessQuestionnaireScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Q1 State
  bool? _isRegistered;
  bool? _wantsUsToRegister;

  // Q2 State
  String? _audienceReach;
  final TextEditingController _industryController = TextEditingController();

  // Q3 State
  bool? _signForPro;

  void _nextPage() {
    FocusScope.of(context).unfocus();
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    // TODO: Finalize business account creation
    if (_signForPro == false) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const BusinessSetupLoadingScreen(),
        ),
      );
    } else {
      const plan = 'Business Pro';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Welcome to $plan!')));
      // Navigate to business dashboard (Placeholder)
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _industryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BusinessTheme.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: BusinessTheme.textDark),
          onPressed: () {
            if (_currentPage > 0) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: AppText.subtitle('Step ${_currentPage + 1} of 3'),
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [_buildQ1(), _buildQ2(), _buildQ3()],
      ),
    );
  }

  Widget _buildQ1() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppText.subtitle(
            'Is your business registered?',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildSelectButton(
                  title: 'Yes',
                  isSelected: _isRegistered == true,
                  onTap: () {
                    setState(() {
                      _isRegistered = true;
                      _wantsUsToRegister = null;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSelectButton(
                  title: 'No',
                  isSelected: _isRegistered == false,
                  selectedBgColor: BusinessTheme.textDark,
                  selectedTxtColor: BusinessTheme.white,
                  onTap: () {
                    setState(() {
                      _isRegistered = false;
                    });
                  },
                ),
              ),
            ],
          ),
          if (_isRegistered == false) ...[
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: BusinessTheme.backgroundLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: BusinessTheme.textDark.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const AppText.paragraph(
                    'Would you want us to handle the registration for you?',
                    style: TextStyle(color: BusinessTheme.charcoal),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  AppText.custom(
                    '(This service is currently only available to users in Nigeria)',
                    style: TextStyle(color: BusinessTheme.textMuted, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSelectButton(
                          title: 'Yes, help me',
                          isSelected: _wantsUsToRegister == true,
                          onTap: () {
                            setState(() {
                              _wantsUsToRegister = true;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSelectButton(
                          title: 'No, thanks',
                          isSelected: _wantsUsToRegister == false,
                          onTap: () {
                            setState(() {
                              _wantsUsToRegister = false;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  (_isRegistered == true ||
                      (_isRegistered == false && _wantsUsToRegister != null))
                  ? () {
                      if (_isRegistered == false && _wantsUsToRegister == true) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const BusinessRegistrationFormScreen(),
                          ),
                        );
                      } else {
                        _nextPage();
                      }
                    }
                  : null,
              child: const AppText.button('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQ2() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppText.subtitle(
            'Tell us about your audience',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const AppText.paragraph(
            'What is your audience reach?',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSelectButton(
                  title: 'Local',
                  isSelected: _audienceReach == 'Local',
                  onTap: () => setState(() => _audienceReach = 'Local'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSelectButton(
                  title: 'Global',
                  isSelected: _audienceReach == 'Global',
                  onTap: () => setState(() => _audienceReach = 'Global'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const AppText.paragraph(
            'What industry are you in?',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _industryController,
            decoration: InputDecoration(
              hintText: 'e.g. Retail, Tech, Freelance...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: BusinessTheme.primaryAmber),
              ),
            ),
            onChanged: (val) => setState(() {}),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  (_audienceReach != null &&
                      _industryController.text.trim().isNotEmpty)
                  ? _nextPage
                  : null,
              child: const AppText.button('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQ3() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star, size: 64, color: BusinessTheme.primaryAmber),
          const SizedBox(height: 24),
          const AppText.subtitle(
            'Upgrade to Business Pro',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const AppText.paragraph(
            'Get the best features to scale your business, manage your team, and access premium tools.',
            textAlign: TextAlign.center,
            style: TextStyle(color: BusinessTheme.textMuted),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: BusinessTheme.charcoal,
                foregroundColor: BusinessTheme.white,
              ),
              onPressed: () {
                setState(() => _signForPro = true);
                _finishOnboarding();
              },
              child: const AppText.button(
                'Yes, Upgrade to Pro',
                style: TextStyle(color: BusinessTheme.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                setState(() => _signForPro = false);
                _finishOnboarding();
              },
              child: const AppText.button(
                'No, continue with Free Plan',
                style: TextStyle(color: BusinessTheme.textMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    Color? selectedBgColor,
    Color? selectedTxtColor,
  }) {
    final bgColor = selectedBgColor ?? BusinessTheme.charcoal;
    final txtColor = selectedTxtColor ?? BusinessTheme.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? bgColor : BusinessTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? bgColor : Colors.black12,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: AppText.button(
          title,
          style: TextStyle(color: isSelected ? txtColor : BusinessTheme.textDark),
        ),
      ),
    );
  }
}
