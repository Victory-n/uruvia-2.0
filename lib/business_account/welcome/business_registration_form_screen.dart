import 'package:flutter/material.dart';
import '../../../shared/widgets/app_text.dart';

class BusinessRegistrationFormScreen extends StatelessWidget {
  const BusinessRegistrationFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const AppText.subtitle('Business Registration')),
      body: const Center(
        child: AppText.paragraph(
          'Registration Form placeholder... We will discuss what goes here!',
        ),
      ),
    );
  }
}
