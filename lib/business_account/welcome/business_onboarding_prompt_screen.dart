import 'package:flutter/material.dart';
import 'package:uruvia/theme/business/business_theme.dart';
import '../../../shared/widgets/app_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../individual_account/screens/dashboard_screen.dart';
import 'business_questionnaire_screen.dart';

class BusinessOnboardingPromptScreen extends StatelessWidget {
  const BusinessOnboardingPromptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BusinessTheme.charcoal,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const CircleAvatar(
                radius: 48,
                backgroundColor: BusinessTheme.white,
                child: Icon(Icons.storefront, size: 48, color: BusinessTheme.charcoal),
              ),
              const SizedBox(height: 32),
              const AppText.title(
                'Got a Business?',
                style: TextStyle(color: BusinessTheme.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              AppText.paragraph(
                'Separate your personal finances from your business operations. Set up your business account now to get specialized analytics and tools.',
                style: TextStyle(color: BusinessTheme.white.withValues(alpha: 0.8)),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('has_seen_business_prompt', true);
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BusinessQuestionnaireScreen(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BusinessTheme.primaryAmber,
                    foregroundColor: BusinessTheme.charcoal,
                  ),
                  child: const AppText.button('Set Up My Business'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('has_seen_business_prompt', true);
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const DashboardScreen()),
                      );
                    }
                  },
                  child: const AppText.button(
                    'Skip for Now',
                    style: TextStyle(color: BusinessTheme.white),
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
