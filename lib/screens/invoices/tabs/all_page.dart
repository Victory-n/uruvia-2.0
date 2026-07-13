import 'package:flutter/material.dart';
import 'package:uruvia/screens/invoices/tabs/invoice_card.dart';

class AllPage extends StatefulWidget {
  const AllPage({super.key});

  @override
  State<AllPage> createState() => _AllPageState();
}

class _AllPageState extends State<AllPage> {
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
            InvoiceCard(
              customerName: "720_bananabread",
              invoiceNumber: "INV-2026-090",
              amount: 8200.0,
              dueDate: DateTime(2026, 5, 26),
              status: "Sent",
            ),
            InvoiceCard(
              customerName: "Ndukwe Victory",
              invoiceNumber: "INV-2026-091",
              amount: 1245000.0,
              dueDate: DateTime(2026, 1, 24),
              status: "Overdue",
            ),
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
