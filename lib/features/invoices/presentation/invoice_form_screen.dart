import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/amount_field.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/sub_page.dart';
import '../../customers/application/customers_controller.dart';
import '../../customers/domain/customer_models.dart';
import '../../customers/presentation/customer_picker.dart';
import '../application/invoices_controller.dart';
import '../../account/application/active_account.dart';
import '../../account/domain/account_type.dart';
import '../domain/invoice_models.dart';
import 'item_sheet.dart';

/// Create an invoice, or edit a draft when [invoiceId] is given.
/// [customerId] pre-selects the customer (from the customer page).
class InvoiceFormScreen extends ConsumerWidget {
  const InvoiceFormScreen({super.key, this.invoiceId, this.customerId});
  final String? invoiceId;
  final String? customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final business = ref.watch(businessInfoProvider);
    final id = invoiceId;
    final title = id == null ? 'New invoice' : 'Edit invoice';

    return SubPage(
      title: title,
      fallbackRoute: AppRoutes.invoices,
      body: AsyncView<BusinessInfo?>(
        value: business,
        onRetry: () => ref.invalidate(businessInfoProvider),
        data: (info) {
          final vatRate = info?.vatRateBps ?? 750;
          if (id == null) {
            return _CustomerLoader(
              customerId: customerId,
              builder: (c) => _InvoiceForm(vatRateBps: vatRate, initialCustomer: c),
            );
          }
          final invoice = ref.watch(invoiceProvider(id));
          final items = ref.watch(invoiceItemsProvider(id));
          if (invoice.hasError || items.hasError) {
            return ErrorState(onRetry: () {
              ref.invalidate(invoiceProvider(id));
              ref.invalidate(invoiceItemsProvider(id));
            });
          }
          final inv = invoice.valueOrNull;
          final its = items.valueOrNull;
          if (inv == null || its == null) {
            return invoice.isLoading || items.isLoading
                ? const Center(child: CircularProgressIndicator())
                : const EmptyState(icon: Icons.search_off_rounded, title: 'Invoice not found');
          }
          if (!inv.isDraft) {
            return const EmptyState(
              icon: Icons.lock_outline_rounded,
              title: 'This invoice can no longer be edited',
              message: 'Only drafts can be changed. Open the invoice and choose Edit to reopen it as a draft.',
            );
          }
          return _CustomerLoader(
            customerId: inv.customerId,
            builder: (c) => _InvoiceForm(vatRateBps: inv.vatRateBps, existing: inv, existingItems: its, initialCustomer: c),
          );
        },
      ),
    );
  }
}

/// Loads the customer to pre-select, if any, before building the form.
class _CustomerLoader extends ConsumerWidget {
  const _CustomerLoader({required this.customerId, required this.builder});
  final String? customerId;
  final Widget Function(Customer? customer) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = customerId;
    if (id == null) return builder(null);
    final value = ref.watch(customerProvider(id));
    return value.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => builder(null),
      data: builder,
    );
  }
}

class _InvoiceForm extends ConsumerStatefulWidget {
  const _InvoiceForm({required this.vatRateBps, this.existing, this.existingItems, this.initialCustomer});
  final int vatRateBps;
  final Invoice? existing;
  final List<InvoiceItem>? existingItems;
  final Customer? initialCustomer;

  @override
  ConsumerState<_InvoiceForm> createState() => _InvoiceFormState();
}

class _InvoiceFormState extends ConsumerState<_InvoiceForm> {
  late Customer? _customer = widget.initialCustomer;
  late DateTime _issue = widget.existing?.issueDate ?? dateOnly(DateTime.now());
  late DateTime _due = widget.existing?.dueDate ?? dateOnly(DateTime.now()).add(const Duration(days: 14));
  late final List<InvoiceItem> _items = [...?widget.existingItems];
  late bool _vat = widget.existing?.vatEnabled ?? false;
  late final _discount = TextEditingController(text: _plain(widget.existing?.discountKobo ?? 0));
  late final _charges = TextEditingController(text: _plain(widget.existing?.chargesKobo ?? 0));
  late final _notes = TextEditingController(text: widget.existing?.notes ?? '');
  late final _terms = TextEditingController(text: widget.existing?.terms ?? '');
  String? _error;
  bool _saving = false;

  static String _plain(int kobo) => kobo == 0 ? '' : (kobo % 100 == 0 ? '${kobo ~/ 100}' : (kobo / 100).toStringAsFixed(2));

  @override
  void dispose() {
    for (final c in [_discount, _charges, _notes, _terms]) {
      c.dispose();
    }
    super.dispose();
  }

  int get _discountKobo => parseNairaToKobo(_discount.text) ?? 0;
  int get _chargesKobo => parseNairaToKobo(_charges.text) ?? 0;

  InvoiceTotals get _totals => InvoiceTotals.compute(
        items: _items,
        discountKobo: _discountKobo,
        vatEnabled: _vat,
        vatRateBps: widget.vatRateBps,
        chargesKobo: _chargesKobo,
      );

  Future<void> _pickCustomer() async {
    final c = await showCustomerPicker(context);
    if (c != null && mounted) setState(() => _customer = c);
  }

  Future<void> _pickDate({required bool due}) async {
    final current = due ? _due : _issue;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: due ? _issue : DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (due) {
        _due = dateOnly(picked);
      } else {
        final gap = _due.difference(_issue);
        _issue = dateOnly(picked);
        if (_due.isBefore(_issue)) _due = _issue.add(gap.isNegative ? const Duration(days: 14) : gap);
      }
    });
  }

  Future<void> _addItem() async {
    final item = await showItemSheet(context);
    if (item != null && mounted) setState(() => _items.add(item));
  }

  Future<void> _editItem(int index) async {
    final item = await showItemSheet(context, existing: _items[index]);
    if (item != null && mounted) setState(() => _items[index] = item);
  }

  String? _validate() {
    if (_customer == null) return 'Choose a customer.';
    if (_items.isEmpty) return 'Add at least one item.';
    if (_due.isBefore(_issue)) return 'The due date cannot be before the issue date.';
    if (_discountKobo > _totals.subtotalKobo) return 'The discount cannot be more than the items total.';
    return null;
  }

  Future<void> _save({required bool preview}) async {
    final problem = _validate();
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final id = await ref.read(invoiceActionsProvider).saveDraft(
            invoiceId: widget.existing?.id,
            customerId: _customer!.id,
            issueDate: _issue,
            dueDate: _due,
            discountKobo: _discountKobo,
            vatEnabled: _vat,
            chargesKobo: _chargesKobo,
            notes: _notes.text,
            terms: _terms.text,
            items: _items,
          );
      if (!mounted) return;
      // Editing an existing draft and saving as a draft: go back to its (refreshed) page.
      if (!preview && widget.existing != null && context.canPop()) {
        context.pop();
        return;
      }
      // Replace this form so Back from the next screen does not return to a stale form.
      context.pushReplacement(preview ? AppRoutes.invoicePreview(id) : AppRoutes.invoiceDetail(id));
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
    final totals = _totals;
    final vatPercent = widget.vatRateBps / 100;
    final vatLabel = 'VAT (${vatPercent.toStringAsFixed(widget.vatRateBps % 100 == 0 ? 0 : 1)}%)';

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pageMargin),
      children: [
        Text('Customer', style: theme.textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          onTap: _saving ? null : _pickCustomer,
          child: Row(
            children: [
              Icon(Icons.person_outline_rounded, color: palette.action),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  _customer?.name ?? 'Choose a customer',
                  style: theme.textTheme.titleMedium?.copyWith(color: _customer == null ? AppColors.inkSoft : AppColors.ink),
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(child: _DateTile(label: 'Issue date', date: _issue, onTap: () => _pickDate(due: false))),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _DateTile(label: 'Due date', date: _due, onTap: () => _pickDate(due: true))),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            for (final days in const [7, 14, 30])
              ActionChip(
                label: Text('Due in $days days'),
                onPressed: () => setState(() => _due = _issue.add(Duration(days: days))),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        Row(
          children: [
            Expanded(child: Text('Items', style: theme.textTheme.titleLarge)),
            TextButton.icon(onPressed: _saving ? null : _addItem, icon: const Icon(Icons.add_rounded), label: const Text('Add item')),
          ],
        ),
        if (_items.isEmpty)
          AppCard(
            onTap: _addItem,
            child: Text('Tap to add the first item.', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft)),
          )
        else
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < _items.length; i++) ...[
                  if (i > 0) const Divider(),
                  ListTile(
                    minTileHeight: 64,
                    title: Text(_items[i].description, maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text('${_items[i].qty} × ${formatNaira(_items[i].unitPriceKobo, showKobo: false)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(formatNaira(_items[i].lineTotalKobo, showKobo: false), style: theme.textTheme.titleMedium),
                        IconButton(
                          tooltip: 'Remove item',
                          icon: const Icon(Icons.close_rounded),
                          onPressed: _saving ? null : () => setState(() => _items.removeAt(i)),
                        ),
                      ],
                    ),
                    onTap: _saving ? null : () => _editItem(i),
                  ),
                ],
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.sectionGap),
        AmountField(controller: _discount, label: 'Discount (optional)', onChangedKobo: (_) => setState(() {})),
        const SizedBox(height: AppSpacing.lg),
        AmountField(
          controller: _charges,
          label: 'Other charges (optional)',
          helper: 'Delivery, handling and similar.',
          onChangedKobo: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (ref.watch(activeAccountProvider) == AccountType.business)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Add $vatLabel'),
            subtitle: const Text('Applied after the discount.'),
            value: _vat,
            onChanged: _saving ? null : (v) => setState(() => _vat = v),
          ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            children: [
              _TotalRow('Items total', totals.subtotalKobo),
              if (totals.discountKobo > 0) _TotalRow('Discount', -totals.discountKobo),
              if (_vat) _TotalRow(vatLabel, totals.vatKobo),
              if (totals.chargesKobo > 0) _TotalRow('Other charges', totals.chargesKobo),
              const Divider(height: AppSpacing.xl),
              _TotalRow('Total', totals.totalKobo, strong: true),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(label: 'Notes (optional)', controller: _notes, maxLines: 3, textCapitalization: TextCapitalization.sentences),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Terms (optional)',
          controller: _terms,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          hint: 'For example: payment within 14 days',
        ),
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(_error!, style: theme.textTheme.bodyMedium?.copyWith(color: StatusColors.errorText)),
        ],
        const SizedBox(height: AppSpacing.xxl),
        AppButton(label: 'Save and preview', onPressed: () => _save(preview: true), loading: _saving),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: 'Save as draft',
          style: AppButtonStyle.secondary,
          onPressed: _saving ? null : () => _save(preview: false),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'A draft does not hold any stock. Stock is set aside when you issue the invoice.',
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({required this.label, required this.date, required this.onTap});
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 2),
          Text(formatShortDate(date), style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow(this.label, this.kobo, {this.strong = false});
  final String label;
  final int kobo;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final style = strong ? Theme.of(context).textTheme.titleLarge : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(formatNaira(kobo, showKobo: kobo % 100 != 0), style: style),
        ],
      ),
    );
  }
}
