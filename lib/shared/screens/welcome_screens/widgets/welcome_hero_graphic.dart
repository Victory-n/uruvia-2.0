import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/shared/widgets/custom_text.dart';

/// Slide 1 Visual Graphic: Dual Account (Personal & Business) Ecosystem.
class WelcomeHeroGraphic extends StatelessWidget {
  const WelcomeHeroGraphic({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        color: ConstantColor.blueBackground.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft glow circle
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  ConstantColor.blueBackground.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Business Mode Card (Background Stack)
          Positioned(
            top: 30,
            left: 30,
            right: 50,
            child: Transform.rotate(
              angle: -0.06,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1C30),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.store_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          interText(
                            text: 'Business Account',
                            colors: Colors.white,
                            fontWeight: FontWeight.bold,
                            size: 13.0,
                          ),
                          const SizedBox(height: 2),
                          googleSansText(
                            text: 'Sales • Inventory • Billing',
                            colors: Colors.white70,
                            fontWeight: FontWeight.normal,
                            size: 11.0,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: interText(
                        text: 'Active',
                        colors: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        size: 10.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Individual Mode Card (Foreground Stack)
          Positioned(
            bottom: 30,
            left: 50,
            right: 30,
            child: Transform.rotate(
              angle: 0.04,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      ConstantColor.blueBackground,
                      Color(0xFF003C8F),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: ConstantColor.blueBackground.withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          interText(
                            text: 'Personal Wallet',
                            colors: Colors.white,
                            fontWeight: FontWeight.bold,
                            size: 13.0,
                          ),
                          const SizedBox(height: 2),
                          googleSansText(
                            text: 'Budgets • Savings • Transfers',
                            colors: Colors.white70,
                            fontWeight: FontWeight.normal,
                            size: 11.0,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.swap_horiz_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
