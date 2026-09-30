import 'package:flutter/material.dart';
import '../../../theme/business/business_theme.dart';
import '../../../shared/widgets/app_text.dart';
import '../business_forms/add_business_form.dart';

class BusinessSetupLoadingScreen extends StatefulWidget {
  const BusinessSetupLoadingScreen({super.key});

  @override
  State<BusinessSetupLoadingScreen> createState() =>
      _BusinessSetupLoadingScreenState();
}

class _BusinessSetupLoadingScreenState
    extends State<BusinessSetupLoadingScreen> {
  String _statusText = 'Setting up account...';

  @override
  void initState() {
    super.initState();
    _startLoadingSequence();
  }

  Future<void> _startLoadingSequence() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _statusText = 'Migrating user data...');
    }
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AddBusinessForm()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BusinessTheme.backgroundLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: BusinessTheme.primaryAmber),
            const SizedBox(height: 24),
            AppText.subtitle(
              _statusText,
              textAlign: TextAlign.center,
              style: const TextStyle(color: BusinessTheme.textDark),
            ),
          ],
        ),
      ),
    );
  }
}
