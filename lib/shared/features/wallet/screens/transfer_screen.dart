import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../../../theme/individual/app_theme.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _accountController = TextEditingController();
  final _bankController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _accountController.dispose();
    _bankController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _showPinPrompt() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText.subtitle('Enter Transfer PIN'),
              const SizedBox(height: 16),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(
                  hintText: '4-digit PIN',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(14.0),
                    child: FaIcon(FontAwesomeIcons.lock, size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Logic to verify PIN and send
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: AppText.paragraph(
                          'Transfer Successful',
                          style: TextStyle(color: AppTheme.white),
                        ),
                      ),
                    );
                    Navigator.pop(context); // Go back to dashboard
                  },
                  child: const AppText.button('Confirm Transfer'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText.subtitle('Transfer Funds'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText.paragraph('Enter transfer details below:'),
              const SizedBox(height: 24),
              TextField(
                controller: _accountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Account Number',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(14.0),
                    child: FaIcon(FontAwesomeIcons.hashtag, size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _bankController,
                decoration: const InputDecoration(
                  hintText: 'Bank Name',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(14.0),
                    child: FaIcon(FontAwesomeIcons.buildingColumns, size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: 'Amount',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(14.0),
                    child: FaIcon(FontAwesomeIcons.dollarSign, size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Description',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: FaIcon(FontAwesomeIcons.penToSquare, size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showPinPrompt,
                  child: const AppText.button('Send'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
