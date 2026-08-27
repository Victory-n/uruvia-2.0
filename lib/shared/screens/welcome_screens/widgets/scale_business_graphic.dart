import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/shared/widgets/custom_text.dart';

/// Slide 5 Visual Graphic: Scale Your Business & Growth.
class ScaleBusinessGraphic extends StatelessWidget {
  const ScaleBusinessGraphic({super.key});

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
          // Background Gradient Rocket Node
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  ConstantColor.blueBackground.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Business Dashboard Snapshot Card
          Container(
            width: 270,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1C30),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.rocket_launch_rounded,
                            color: Colors.orangeAccent,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            interText(
                              text: 'Business Suite',
                              colors: Colors.white,
                              fontWeight: FontWeight.bold,
                              size: 13.0,
                            ),
                            googleSansText(
                              text: 'Sales & Inventory',
                              colors: Colors.white70,
                              fontWeight: FontWeight.normal,
                              size: 11.0,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.trending_up_rounded,
                      color: Colors.greenAccent,
                      size: 22,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Stat Row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            googleSansText(
                              text: 'Total Revenue',
                              colors: Colors.white60,
                              fontWeight: FontWeight.normal,
                              size: 10.0,
                            ),
                            const SizedBox(height: 2),
                            interText(
                              text: '\$14,850.00',
                              colors: Colors.white,
                              fontWeight: FontWeight.bold,
                              size: 13.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            googleSansText(
                              text: 'Inventory Stock',
                              colors: Colors.white60,
                              fontWeight: FontWeight.normal,
                              size: 10.0,
                            ),
                            const SizedBox(height: 2),
                            interText(
                              text: '1,240 Items',
                              colors: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                              size: 13.0,
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
    );
  }
}
