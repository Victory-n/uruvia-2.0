import 'package:flutter/material.dart';
import 'package:uruvia/screens/invoices/tabs/invoice_card.dart';

class PaidPage extends StatefulWidget {
  const PaidPage({super.key});

  @override
  State<PaidPage> createState() => _PaidPageState();
}

class _PaidPageState extends State<PaidPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            InvoiceCard(
              customerName: "Tech Corp Solutions",
              invoiceNumber: "INV-2023-089",
              amount: 450000.0,
              dueDate: DateTime(2026, 10, 12),
              status: "Paid",
            ),
          ],
        ),
      ),
    );
  }
}
