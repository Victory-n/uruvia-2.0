import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../shared/widgets/app_text.dart';
import '../../theme/individual/app_theme.dart';
import '../../../shared/features/wallet/widgets/wallet_card.dart';
import '../../../shared/features/wallet/screens/transfer_screen.dart';
import '../sidebar/app_sidebar.dart';
import '../widgets/action_button.dart';
import '../../../shared/features/wallet/screens/transactions_screen.dart';
import '../../../shared/features/wallet/widgets/transaction_tile.dart';
import '../../../shared/features/wallet/models/transaction.dart';
import '../../../shared/features/budgeting/screens/budgeting_main_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebar(),
      appBar: AppBar(title: const AppText.subtitle('Dashboard')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WalletCard(
                balance: '\$12,450.00',
                accountNumber: '**** **** **** 4567',
                cvv: '***',
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ActionButton(
                    icon: FontAwesomeIcons.moneyBillTransfer,
                    label: 'Transfer',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TransferScreen(),
                        ),
                      );
                    },
                  ),
                  ActionButton(
                    icon: FontAwesomeIcons.wallet,
                    label: 'Budget',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BudgetingMainScreen(),
                        ),
                      );
                    },
                  ),
                  ActionButton(
                    icon: FontAwesomeIcons.piggyBank,
                    label: 'Savings',
                    onTap: () {},
                  ),
                  ActionButton(
                    icon: FontAwesomeIcons.chartSimple,
                    label: 'Reports',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText.custom(
                    'Recent Transactions',
                    style: TextStyle(fontSize: 14),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TransactionsScreen(),
                        ),
                      );
                    },
                    child: const AppText.button(
                      'View all',
                      style: TextStyle(color: AppTheme.sleekBlue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TransactionTile(transaction: mockTransactions.first),
            ],
          ),
        ),
      ),
    );
  }
}
