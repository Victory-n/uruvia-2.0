import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../shared/features/budgeting/screens/budgeting_main_screen.dart';
import '../../../shared/features/events/group savings/models/ajo_group.dart';
import '../../../shared/features/events/group savings/services/ajo_service.dart';
import '../../../shared/features/events/group savings/widgets/ajo_locked_pocket_card.dart';
import '../../../shared/features/events/screens/events_screen.dart';
import '../../../shared/features/wallet/models/transaction.dart';
import '../../../shared/features/wallet/screens/transactions_screen.dart';
import '../../../shared/features/wallet/screens/transfer_screen.dart';
import '../../../shared/features/wallet/widgets/transaction_tile.dart';
import '../../../shared/features/wallet/widgets/wallet_card.dart';
import '../../../shared/widgets/app_text.dart';
import '../../theme/individual/app_theme.dart';
import '../sidebar/app_sidebar.dart';
import '../widgets/action_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AjoService _ajoService = AjoService.instance;
  List<AjoGroup> _ajoGroups = [];

  @override
  void initState() {
    super.initState();
    _loadAjoGroups();
  }

  Future<void> _loadAjoGroups() async {
    final groups = await _ajoService.getGroups();
    if (mounted) {
      setState(() {
        _ajoGroups = groups;
      });
    }
  }

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

              // Ajo Locked Savings Pocket below Wallet Card
              if (_ajoGroups.isNotEmpty) ...[
                const SizedBox(height: 16),
                AjoLockedPocketCard(
                  group: _ajoGroups.first,
                  onRefresh: _loadAjoGroups,
                ),
              ],

              const SizedBox(height: 24),
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EventsScreen(),
                        ),
                      );
                    },
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
