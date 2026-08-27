import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/shared/widgets/custom_text.dart';

/// Slide 2 Visual Graphic: Virtual Cards & Multi-Currency Accounts.
class VirtualCardsGraphic extends StatelessWidget {
  const VirtualCardsGraphic({super.key});

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
          // Background Secondary Card (USD Virtual Card)
          Positioned(
            top: 25,
            child: Transform.rotate(
              angle: -0.1,
              child: Container(
                width: 260,
                height: 150,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        interText(
                          text: 'Uruvia Global',
                          colors: Colors.white70,
                          fontWeight: FontWeight.bold,
                          size: 11.0,
                        ),
                        interText(
                          text: 'USD',
                          colors: Colors.amberAccent,
                          fontWeight: FontWeight.bold,
                          size: 12.0,
                        ),
                      ],
                    ),
                    interText(
                      text: '••••  ••••  ••••  8842',
                      colors: Colors.white70,
                      fontWeight: FontWeight.normal,
                      size: 13.0,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Primary Foreground Card (Master Virtual Card)
          Positioned(
            bottom: 25,
            child: Transform.rotate(
              angle: 0.05,
              child: Container(
                width: 270,
                height: 160,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0058BE),
                      Color(0xFF002B66),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: ConstantColor.blueBackground.withOpacity(0.4),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.amber.shade400,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.wifi_rounded,
                              color: Colors.white70,
                              size: 18,
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: interText(
                            text: 'VIRTUAL',
                            colors: Colors.white,
                            fontWeight: FontWeight.bold,
                            size: 9.0,
                          ),
                        ),
                      ],
                    ),
                    interText(
                      text: '4532  ••••  ••••  9012',
                      colors: Colors.white,
                      fontWeight: FontWeight.w600,
                      size: 15.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        interText(
                          text: 'URUVIA USER',
                          colors: Colors.white70,
                          fontWeight: FontWeight.bold,
                          size: 10.0,
                        ),
                        googleSansText(
                          text: '12/28',
                          colors: Colors.white70,
                          fontWeight: FontWeight.normal,
                          size: 11.0,
                        ),
                      ],
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
