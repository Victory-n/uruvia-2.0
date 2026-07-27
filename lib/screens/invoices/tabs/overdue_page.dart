import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/offline/database_helper.dart';
import 'package:uruvia/screens/invoices/tabs/invoice_card.dart';
import 'package:uruvia/widgets/custom_text.dart';

class OverduePage extends StatefulWidget {
  final VoidCallback? onRefresh;
  const OverduePage({super.key, this.onRefresh});

  @override
  State<OverduePage> createState() => _OverduePageState();
}

class _OverduePageState extends State<OverduePage> {
  List<Map<String, dynamic>> _invoices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    final dbHelper = DatabaseHelper.instance;
    final cachedInvoices = await dbHelper.queryCache('local_invoices', orderBy: 'created_at DESC');
    
    final now = DateTime.now();
    final List<Map<String, dynamic>> processedInvoices = [];
    for (var inv in cachedInvoices) {
      final statusFromDb = inv['status'] as String? ?? 'Draft';
      final dueDateStr = inv['due_date'] as String?;
      final dueDate = dueDateStr != null ? DateTime.tryParse(dueDateStr) : null;
      
      var status = statusFromDb;
      if (statusFromDb.toLowerCase() != 'paid' && dueDate != null && dueDate.isBefore(now)) {
        status = 'Overdue';
      }
      
      if (status.toLowerCase() == 'overdue') {
        final Map<String, dynamic> mutableInv = Map.from(inv);
        mutableInv['status'] = status;
        processedInvoices.add(mutableInv);
      }
    }

    if (mounted) {
      setState(() {
        _invoices = processedInvoices;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ConstantColor.blueBackground),
        ),
      );
    }

    if (_invoices.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.exclamationmark_shield,
                size: 52.0,
                color: ConstantColor.paragraphTextSecondary.withOpacity(0.4),
              ),
              const SizedBox(height: 14.0),
              googleSansText(
                text: "No overdue invoices.",
                colors: ConstantColor.paragraphTextSecondary,
                fontWeight: FontWeight.normal,
                size: 15.0,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: _invoices.map((inv) {
            final customerName = inv['customer_name'] as String? ?? 'Client';
            final invoiceNumber = inv['id'] as String? ?? '#INV';
            final amount = (inv['amount'] as num? ?? 0.0).toDouble();
            final status = inv['status'] as String? ?? 'Overdue';
            final dueDate = inv['due_date'] != null
                ? DateTime.tryParse(inv['due_date'].toString()) ?? DateTime.now()
                : DateTime.now();

            return InvoiceCard(
              customerName: customerName,
              invoiceNumber: invoiceNumber,
              amount: amount,
              dueDate: dueDate,
              status: status,
              onRefresh: () {
                _loadInvoices();
                if (widget.onRefresh != null) {
                  widget.onRefresh!();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
