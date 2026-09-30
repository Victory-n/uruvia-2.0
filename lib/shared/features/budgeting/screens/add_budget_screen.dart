import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../widgets/app_text.dart';
import '../../../../theme/individual/app_theme.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  bool _hardStopEnabled = false;

  // For simplicity, hardcoded a selected color and icon for now
  final Color _selectedColor = AppTheme.sleekBlue;
  final _selectedIcon = FontAwesomeIcons.basketShopping;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const AppText.subtitle('Add Budget')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText.paragraph('Budget Name'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'e.g. Feeding, Rent, Transport',
              ),
            ),
            const SizedBox(height: 24),
            const AppText.paragraph('Budget Amount'),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                hintText: '0.00',
                prefixText: '\$ ',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.paragraph('Hard Stop at 100%'),
                      SizedBox(height: 4),
                      AppText.custom(
                        'Prevent transactions when budget limit is reached',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _hardStopEnabled,
                  onChanged: (val) {
                    setState(() {
                      _hardStopEnabled = val;
                    });
                  },
                  activeColor: AppTheme.sleekBlue,
                ),
              ],
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Save budget logic
                  Navigator.pop(context);
                },
                child: const AppText.button('Create Budget'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
