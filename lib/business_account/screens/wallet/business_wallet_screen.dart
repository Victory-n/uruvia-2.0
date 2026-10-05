import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uruvia/theme/business/business_theme.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../../../shared/features/wallet/widgets/wallet_card.dart';
import '../../../../shared/features/wallet/widgets/transaction_tile.dart';
import '../../../../shared/features/wallet/screens/transfer_screen.dart';
import '../../../../shared/features/wallet/screens/transactions_screen.dart';
import '../../../../shared/features/wallet/models/transaction.dart';
import '../../sidebar/business_sidebar.dart';

class BusinessWalletScreen extends StatefulWidget {
  const BusinessWalletScreen({super.key});

  @override
  State<BusinessWalletScreen> createState() => _BusinessWalletScreenState();
}

class _BusinessWalletScreenState extends State<BusinessWalletScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedTxFilter = 'All';

  @override
  Widget build(BuildContext context) {
    // Filter transactions according to selected tab
    final transactions = _selectedTxFilter == 'All'
        ? mockTransactions
        : _selectedTxFilter == 'Inflow'
        ? mockTransactions.where((t) => t.isCredit).toList()
        : mockTransactions.where((t) => !t.isCredit).toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: BusinessTheme.backgroundLight,
      drawer: const BusinessSidebar(activeRoute: 'Wallet'),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.bars,
            color: BusinessTheme.charcoal,
            size: 20,
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const AppText.subtitle(
          'Business Wallet',
          style: TextStyle(
            color: BusinessTheme.charcoal,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.arrowsRotate,
              color: BusinessTheme.charcoal,
              size: 18,
            ),
            tooltip: 'Refresh Balance',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Wallet balances refreshed'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.receipt,
              color: BusinessTheme.charcoal,
              size: 18,
            ),
            tooltip: 'Statements',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransactionsScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Shared WalletCard styled specifically for Business Account
              WalletCard(
                balance: '₦2,450,800.00',
                balanceLabel: 'Available Balance',
                accountNumber: '0123 4567 89',
                cvv: '624',
                buttonLabel: 'Withdraw',
                backgroundColor: BusinessTheme.charcoal,
                gradient: const LinearGradient(
                  colors: [Color(0xFF1C1917), Color(0xFF292524)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onWithdraw: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TransferScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Business Wallet Breakdown / Stats
              Row(
                children: [
                  Expanded(
                    child: _buildBreakdownCard(
                      label: 'Settled Today',
                      amount: '₦485,000.00',
                      icon: FontAwesomeIcons.arrowDownLong,
                      iconColor: BusinessTheme.success,
                      iconBg: BusinessTheme.success.withValues(alpha: 0.12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildBreakdownCard(
                      label: 'In Escrow / Pending',
                      amount: '₦120,000.00',
                      icon: FontAwesomeIcons.clock,
                      iconColor: BusinessTheme.primaryAmber,
                      iconBg: BusinessTheme.primaryAmber.withValues(
                        alpha: 0.12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Quick Business Wallet Actions
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: BusinessTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(
                      icon: FontAwesomeIcons.moneyBillTransfer,
                      label: 'Send Funds',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TransferScreen(),
                          ),
                        );
                      },
                    ),
                    _buildActionButton(
                      icon: FontAwesomeIcons.buildingColumns,
                      label: 'Record Sales',
                      onTap: () {
                        _showAccountDetailsModal(context);
                      },
                    ),
                    _buildActionButton(
                      icon: FontAwesomeIcons.fileInvoiceDollar,
                      label: 'Invoices',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Opening Business Invoices...'),
                          ),
                        );
                      },
                    ),
                    _buildActionButton(
                      icon: FontAwesomeIcons.download,
                      label: 'Statement',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TransactionsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Transactions Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText.subtitle(
                    'Transaction History',
                    style: TextStyle(
                      color: BusinessTheme.charcoal,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
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
                    child: const AppText.custom(
                      'View All',
                      style: TextStyle(
                        color: BusinessTheme.primaryAmber,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Transaction Filter Pills
              Row(
                children: ['All', 'Inflow', 'Outflow'].map((filter) {
                  final isSelected = _selectedTxFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedTxFilter = filter);
                        }
                      },
                      selectedColor: BusinessTheme.charcoal,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? BusinessTheme.white
                            : BusinessTheme.textDark,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontSize: 12,
                      ),
                      backgroundColor: Colors.transparent,
                      side: BorderSide(
                        color: isSelected
                            ? BusinessTheme.charcoal
                            : Colors.grey.shade300,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Shared Transaction list
              Container(
                decoration: BoxDecoration(
                  color: BusinessTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactions.take(5).length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey.shade100,
                  ),
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    return TransactionTile(
                      transaction: tx,
                      onTap: () {
                        _showTransactionDetails(context, tx);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownCard({
    required String label,
    required String amount,
    required dynamic icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BusinessTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: FaIcon(icon, color: iconColor, size: 14),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppText.paragraph(
                  label,
                  style: const TextStyle(
                    color: BusinessTheme.textMuted,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppText.subtitle(
            amount,
            style: const TextStyle(
              color: BusinessTheme.charcoal,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required dynamic icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: BusinessTheme.backgroundLight,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Center(
                child: FaIcon(icon, size: 18, color: BusinessTheme.charcoal),
              ),
            ),
            const SizedBox(height: 8),
            AppText.custom(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: BusinessTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountDetailsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: BusinessTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const AppText.subtitle(
                'Business Settlement Account',
                style: TextStyle(
                  color: BusinessTheme.charcoal,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const AppText.paragraph(
                'Direct customer transfers and POS settlements arrive here.',
                style: TextStyle(color: BusinessTheme.textMuted),
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Bank Name', 'Wema Bank / Uruvia Business'),
              const Divider(height: 24),
              _buildDetailRow('Account Number', '0123456789'),
              const Divider(height: 24),
              _buildDetailRow('Account Name', 'VICTORY ENTERPRISES LTD'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Account details copied to clipboard!'),
                      ),
                    );
                  },
                  icon: const FaIcon(FontAwesomeIcons.copy, size: 16),
                  label: const Text('Copy Account Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BusinessTheme.charcoal,
                    foregroundColor: BusinessTheme.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText.paragraph(
          label,
          style: const TextStyle(color: BusinessTheme.textMuted),
        ),
        AppText.button(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: BusinessTheme.charcoal,
          ),
        ),
      ],
    );
  }

  void _showTransactionDetails(BuildContext context, Transaction tx) {
    showModalBottomSheet(
      context: context,
      backgroundColor: BusinessTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AppText.subtitle(
                tx.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              AppText.title(
                '${tx.isCredit ? '+' : '-'}₦${tx.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: tx.isCredit
                      ? BusinessTheme.success
                      : BusinessTheme.danger,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow(
                'Date',
                DateFormat('MMM dd, yyyy • hh:mm a').format(tx.date),
              ),
              const Divider(height: 24),
              _buildDetailRow('Description', tx.subtitle),
              const Divider(height: 24),
              _buildDetailRow('Status', 'Successful'),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
