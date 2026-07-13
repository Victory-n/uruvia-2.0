import 'package:flutter/material.dart';
import 'package:uruvia/screens/invoices/tabs/invoice_card.dart';

class DraftPage extends StatefulWidget {
  const DraftPage({super.key});

  @override
  State<DraftPage> createState() => _DraftPageState();
}

class _DraftPageState extends State<DraftPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            InvoiceCard(
              customerName: "Acme Corporation",
              invoiceNumber: "INV-2026-092",
              amount: 3200.0,
              dueDate: DateTime(2026, 7, 26),
              status: "Draft",
            ),
          ],
        ),
      ),
    );
  }
}
