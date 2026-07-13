import 'package:flutter/material.dart';
import 'package:uruvia/screens/invoices/tabs/invoice_card.dart';

class OverduePage extends StatefulWidget {
  const OverduePage({super.key});

  @override
  State<OverduePage> createState() => _OverduePageState();
}

class _OverduePageState extends State<OverduePage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            InvoiceCard(
              customerName: "Ndukwe Victory",
              invoiceNumber: "INV-2026-091",
              amount: 1245000.0,
              dueDate: DateTime(2026, 1, 24),
              status: "Overdue",
            ),
          ],
        ),
      ),
    );
  }
}
