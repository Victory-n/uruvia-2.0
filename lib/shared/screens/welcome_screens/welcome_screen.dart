import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/shared/screens/authentication/registration_screens/registration_screen.dart';
import 'package:uruvia/shared/widgets/custom_text.dart';
import 'widgets/budget_analytics_graphic.dart';
import 'widgets/offline_sync_graphic.dart';
import 'widgets/onboarding_page_model.dart';
import 'widgets/page_indicator_widget.dart';
import 'widgets/scale_business_graphic.dart';
import 'widgets/virtual_cards_graphic.dart';
import 'widgets/welcome_hero_graphic.dart';

/// Dedicated Scaffold screen for the 5-page Welcome Onboarding experience.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  static const List<OnboardingPageModel> _pages = [
    OnboardingPageModel(
      badgeText: 'DUAL ACCOUNT ECOSYSTEM',
      title: 'Welcome to Uruvia',
      subtitle:
          'One unified platform for your personal finances and business growth. Seamlessly switch accounts anytime.',
      graphicWidget: WelcomeHeroGraphic(),
      gradientColors: [ConstantColor.blueBackground, Color(0xFF003C8F)],
    ),
    OnboardingPageModel(
      badgeText: 'VIRTUAL ACCOUNTS & CARDS',
      title: 'Global Payments & Cards',
      subtitle:
          'Issue instant virtual cards in USD and local currencies for secure online shopping and global payments.',
      graphicWidget: VirtualCardsGraphic(),
      gradientColors: [Color(0xFF0058BE), Color(0xFF1E293B)],
    ),
    OnboardingPageModel(
      badgeText: 'OFFLINE-FIRST ENGINE',
      title: 'Zero Downtime. Works Offline',
      subtitle:
          'Record transactions, log sales, and manage inventory without internet. Auto-syncs instantly when back online.',
      graphicWidget: OfflineSyncGraphic(),
      gradientColors: [ConstantColor.blueBackground, Color(0xFF0B1C30)],
    ),
    OnboardingPageModel(
      badgeText: 'SMART ANALYTICS',
      title: 'Intelligent Budgeting',
      subtitle:
          'Take full control of your wealth with real-time expense tracking, budget limits, and financial calculators.',
      graphicWidget: BudgetAnalyticsGraphic(),
      gradientColors: [Color(0xFF0058BE), Color(0xFF003C8F)],
    ),
    OnboardingPageModel(
      badgeText: 'BUSINESS GROWTH',
      title: 'Scale Business & Inventory',
      subtitle:
          'Track stock levels, record sales, and monitor business metrics effortlessly in one streamlined workspace.',
      graphicWidget: ScaleBusinessGraphic(),
      gradientColors: [Color(0xFF0B1C30), ConstantColor.blueBackground],
    ),
  ];

  void _onNextPressed() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _onBackPressed() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _finishOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const RegistrationScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentIndex == _pages.length - 1;

    return Scaffold(
      backgroundColor: ConstantColor.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar (Logo & Skip)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Image(
                        image: AssetImage("assets/img/logo.png"),
                        height: 32,
                        width: 32,
                      ),
                      const SizedBox(width: 8),
                      interText(
                        text: 'Uruvia',
                        colors: ConstantColor.headingTextPrimary,
                        fontWeight: FontWeight.bold,
                        size: 18.0,
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _finishOnboarding,
                    style: TextButton.styleFrom(
                      foregroundColor: ConstantColor.paragraphTextSecondary,
                    ),
                    child: googleSansText(
                      text: 'Skip',
                      colors: ConstantColor.paragraphTextSecondary,
                      fontWeight: FontWeight.w600,
                      size: 14.0,
                    ),
                  ),
                ],
              ),
            ),

            // PageView Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Custom Flutter Rendered Graphic Widget
                        page.graphicWidget,
                        const SizedBox(height: 32),

                        // Badge Tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: ConstantColor.blueBackground.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: interText(
                            text: page.badgeText,
                            colors: ConstantColor.blueBackground,
                            fontWeight: FontWeight.bold,
                            size: 10.0,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Slide Title (Heading -> interText)
                        interText(
                          text: page.title,
                          colors: ConstantColor.headingTextPrimary,
                          fontWeight: FontWeight.bold,
                          size: 24.0,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),

                        // Slide Subtitle (Paragraph -> googleSansText)
                        googleSansText(
                          text: page.subtitle,
                          colors: ConstantColor.paragraphTextPrimary,
                          fontWeight: FontWeight.normal,
                          size: 14.0,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Footer
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Page Indicator Dots
                  PageIndicatorWidget(
                    count: _pages.length,
                    currentIndex: _currentIndex,
                  ),
                  const SizedBox(height: 24),

                  // Bottom Action Buttons Row
                  Row(
                    children: [
                      // Back Button (hidden on page 0)
                      if (_currentIndex > 0)
                        IconButton(
                          onPressed: _onBackPressed,
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: ConstantColor.headingTextPrimary,
                          ),
                        )
                      else
                        const SizedBox(width: 48),

                      const SizedBox(width: 12),

                      // Next / Get Started Primary Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _onNextPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ConstantColor.blueBackground,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor:
                                ConstantColor.blueBackground.withOpacity(0.4),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              interText(
                                text: isLastPage ? 'Get Started' : 'Next',
                                colors: Colors.white,
                                fontWeight: FontWeight.bold,
                                size: 16.0,
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isLastPage
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.arrow_forward_rounded,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
