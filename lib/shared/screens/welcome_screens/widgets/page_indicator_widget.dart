import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';

/// Reusable animated page indicator pill bar.
class PageIndicatorWidget extends StatelessWidget {
  final int count;
  final int currentIndex;

  const PageIndicatorWidget({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) {
          final isSelected = index == currentIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            height: 8.0,
            width: isSelected ? 28.0 : 8.0,
            decoration: BoxDecoration(
              color: isSelected
                  ? ConstantColor.blueBackground
                  : ConstantColor.paragraphTextSecondary.withOpacity(0.25),
              borderRadius: BorderRadius.circular(4.0),
            ),
          );
        },
      ),
    );
  }
}
