import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/amount_field.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_text_field.dart';
import '../application/invoices_controller.dart';
import '../domain/invoice_models.dart';

/// Record a payment received outside the app (transfer, cash, POS, card).
/// Paying the full balance marks the invoice paid and records the sale.
/// Returns true when a payment was recorded.
Future<bool?> showPaymentSheet(BuildContext context, Invoice invoice) {
  return showAppSheet<bool>(
    context,
    title: 'Record a payment',
    builder: (_) => _PaymentForm(invoice: invoice),
  );
}

class _PaymentForm extends ConsumerStatefulWidget {
  const _PaymentForm({required this.invoice});
  final Invoice invoice;

  @override
  ConsumerState<_PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends ConsumerState<_PaymentForm> {
  late final _amount = TextEditingController(text: _plain(widget.invoice.balanceKobo));
  final _reference = TextEditingController();
  PaymentMethod _method = PaymentMethod.transfer;
  DateTime _paidOn = dateOnly(DateTime.now());
  late int? _kobo = widget.invoice.balanceKobo;
  String? _error;
  bool _saving = false;

  static String _plain(int kobo) => kobo % 100 == 0 ? '${kobo ~/ 100}' : (kobo / 100).toStringAsFixed(2);

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    super.dispose();
  }

  bool get _clearsBalance => _kobo != null && _kobo == widget.invoice.balanceKobo;

  Future<void> _pickDate() async {
    final now = dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _paidOn,
      firstDate: widget.invoice.issueDate.isAfter(now) ? now : widget.invoice.issueDate,
      lastDate: now,
    );
    if (picked != null && mounted) setState(() => _paidOn = dateOnly(picked));
  }

  Future<void> _save() async {
    final balance = widget.invoice.balanceKobo;
    final kobo = _kobo;
    String? error;
    if (kobo == null || kobo <= 0) {
      error = 'Enter the amount received.';
    } else if (kobo > balance) {
      error = 'That is more than the balance of ${formatNaira(balance)}.';
    }
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(invoiceActionsProvider).recordPayment(
            widget.invoice.id,
            amountKobo: kobo!,
            method: _method,
            paidOn: _paidOn,
            reference: _reference.text,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = friendlyError(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final balance = widget.invoice.balanceKobo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${widget.invoice.number} · balance ${formatNaira(balance)}',
          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
        ),
        const SizedBox(height: AppSpacing.lg),
        AmountField(
          controller: _amount,
          label: 'Amount received',
          enabled: !_saving,
          quickAmountsKobo: [if (balance > 0) balance],
          onChangedKobo: (k) => setState(() {
            _kobo = k;
            _error = null;
          }),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('How was it paid?', style: theme.textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final m in PaymentMethod.values)
              ChoiceChip(
                label: Text(m.label),
                selected: _method == m,
                onSelected: _saving ? null : (_) => setState(() => _method = m),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        ListTile(
          contentPadding: EdgeInsets.zero,
          minTileHeight: 56,
          leading: const Icon(Icons.event_outlined),
          title: const Text('Date received'),
          subtitle: Text(formatShortDate(_paidOn)),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: _saving ? null : _pickDate,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          label: 'Reference (optional)',
          controller: _reference,
          enabled: !_saving,
          hint: 'Transfer reference or receipt number',
          maxLength: 80,
        ),
        if (_clearsBalance) ...[
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(color: palette.tint, borderRadius: BorderRadius.circular(AppRadius.control)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_outline_rounded, color: palette.action),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'This clears the balance. The invoice will be marked as paid and the sale recorded. Only confirm once the money is in your account.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(_error!, style: theme.textTheme.bodyMedium?.copyWith(color: StatusColors.errorText)),
        ],
        const SizedBox(height: AppSpacing.xxl),
        AppButton(
          label: _clearsBalance ? 'Confirm and mark as paid' : 'Record payment',
          onPressed: _save,
          loading: _saving,
        ),
      ],
    );
  }
}
