import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../widgets/app_text.dart';
import '../models/finance_event.dart';

class ContributeDialog extends StatefulWidget {
  final FinanceEvent event;
  final ValueChanged<double> onContributed;

  const ContributeDialog({
    super.key,
    required this.event,
    required this.onContributed,
  });

  static Future<void> show(
    BuildContext context, {
    required FinanceEvent event,
    required ValueChanged<double> onContributed,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => ContributeDialog(
        event: event,
        onContributed: onContributed,
      ),
    );
  }

  @override
  State<ContributeDialog> createState() => _ContributeDialogState();
}

class _ContributeDialogState extends State<ContributeDialog> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount > 0) {
      widget.onContributed(amount);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: AppText.subtitle(
        'Contribute to ${widget.event.title}',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.paragraph(
            'Remaining goal: ${currencyFormatter.format(widget.event.remainingAmount)}',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: '\$ ',
              hintText: '100',
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const AppText.button('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0060E6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const AppText.button(
            'Confirm',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
