import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_text.dart';
import '../models/transaction.dart';
import '../widgets/transaction_tile.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText.subtitle('All Transactions'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(24.0),
          itemCount: mockTransactions.length,
          separatorBuilder: (context, index) =>
              const Divider(height: 24, thickness: 1, color: Color(0xFFE5E5EA)),
          itemBuilder: (context, index) {
            final transaction = mockTransactions[index];
            return TransactionTile(
              transaction: transaction,
              onTap: () {
                // Implement transaction details view if needed later
              },
            );
          },
        ),
      ),
    );
  }
}
