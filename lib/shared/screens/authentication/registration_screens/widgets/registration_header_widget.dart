import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/shared/widgets/custom_text.dart';

/// Clean header widget for the registration screen.
class RegistrationHeaderWidget extends StatelessWidget {
  const RegistrationHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Image(
              image: AssetImage('assets/img/logo.png'),
              height: 36,
              width: 36,
            ),
            const SizedBox(width: 10),
            interText(
              text: 'Uruvia',
              colors: ConstantColor.headingTextPrimary,
              fontWeight: FontWeight.bold,
              size: 22.0,
            ),
          ],
        ),
        const SizedBox(height: 20),
        interText(
          text: 'Create Your Account',
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 24.0,
        ),
        const SizedBox(height: 6),
        googleSansText(
          text: 'Fill in your details below to get started with Uruvia.',
          colors: ConstantColor.paragraphTextSecondary,
          fontWeight: FontWeight.normal,
          size: 14.0,
        ),
      ],
    );
  }
}
