import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/open_link.dart';
import '../../../core/utils/phone_links.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/sub_page.dart';
import '../../invoices/application/invoices_controller.dart';
import '../../invoices/domain/invoice_models.dart';
import '../../invoices/presentation/invoice_widgets.dart';
import '../../sales/application/sales_controller.dart';
import '../../sales/domain/sale_models.dart';
import '../../sales/presentation/sale_list_screen.dart' show SaleTile;
import '../application/customers_controller.dart';
import '../domain/customer_models.dart';

class CustomerDetailScreen extends ConsumerWidget {
  const CustomerDetailScreen({super.key, required this.customerId});
  final String customerId;

  Future<void> _archive(BuildContext context, WidgetRef ref, Customer c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Archive ${c.name}?'),
        content: const Text('They will no longer show in your customer list. Their invoices and sales stay in your records.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Archive')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(customerActionsProvider).archive(c.id);
      if (context.mounted) context.go(AppRoutes.customers);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyError(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(customerProvider(customerId));
    final customer = value.valueOrNull;
    return SubPage(
      title: customer?.name ?? 'Customer',
      fallbackRoute: AppRoutes.customers,
      actions: [
        if (customer != null)
          PopupMenuButton<String>(
            tooltip: 'More',
            onSelected: (v) {
              if (v == 'edit') context.push(AppRoutes.customerEdit(customerId));
              if (v == 'archive') _archive(context, ref, customer);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit customer')),
              PopupMenuItem(value: 'archive', child: Text('Archive customer')),
            ],
          ),
      ],
      body: AsyncView<Customer?>(
        value: value,
        onRetry: () => ref.invalidate(customerProvider(customerId)),
        isEmpty: (c) => c == null,
        empty: const EmptyState(icon: Icons.search_off_rounded, title: 'Customer not found'),
        data: (c) => _Detail(customer: c!),
      ),
    );
  }
}

class _Detail extends ConsumerWidget {
  const _Detail({required this.customer});
  final Customer customer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final c = customer;
    final invoices = ref.watch(customerInvoicesProvider(c.id));
    final sales = ref.watch(customerSalesProvider(c.id)).valueOrNull ?? const <Sale>[];
    final list = invoices.valueOrNull ?? const <Invoice>[];
    final totals = customerInvoiceTotals(list);
    final owed = totals.outstandingKobo;
    final bought = summarizeSales(sales).totalKobo;

    final info = [
      if (c.phone != null) (Icons.phone_outlined, c.phone!),
      if (c.email != null) (Icons.mail_outline_rounded, c.email!),
      if (c.address != null) (Icons.location_on_outlined, c.address!),
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pageMargin),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Owes you', style: theme.textTheme.bodySmall),
                        Text(
                          formatNaira(owed, showKobo: false),
                          style: theme.textTheme.headlineSmall?.copyWith(color: owed > 0 ? StatusColors.errorText : AppColors.ink),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total bought', style: theme.textTheme.bodySmall),
                        Text(formatNaira(bought, showKobo: false), style: theme.textTheme.headlineSmall),
                      ],
                    ),
                  ),
                ],
              ),
              if (list.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Billed ${formatNaira(totals.billedKobo, showKobo: false)} · Paid ${formatNaira(totals.paidKobo, showKobo: false)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
              if (info.isNotEmpty) const Divider(height: AppSpacing.xxl),
              for (final (icon, text) in info)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, size: 20, color: palette.action),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
                    ],
                  ),
                ),
              if (c.notes != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(c.notes!, style: theme.textTheme.bodySmall),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (telLink(c.phone) != null) ...[
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Call',
                  icon: Icons.call_outlined,
                  style: AppButtonStyle.secondary,
                  onPressed: () => openLink(context, telLink(c.phone)!),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: 'WhatsApp',
                  icon: Icons.chat_outlined,
                  style: AppButtonStyle.secondary,
                  onPressed: () => openLink(context, whatsappLink(c.phone, message: 'Hello ${c.name}, ')!),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        AppButton(
          label: 'New invoice',
          icon: Icons.description_outlined,
          onPressed: () => context.push('${AppRoutes.invoicesNew}?customer=${c.id}'),
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        Text('Invoices', style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        AsyncView<List<Invoice>>(
          value: invoices,
          loading: const Padding(padding: EdgeInsets.all(AppSpacing.xl), child: Center(child: CircularProgressIndicator())),
          onRetry: () => ref.invalidate(customerInvoicesProvider(c.id)),
          isEmpty: (l) => l.isEmpty,
          empty: Text('No invoices for this customer yet.', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft)),
          data: (l) => AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < l.length; i++) ...[
                  if (i > 0) const Divider(),
                  InvoiceTile(invoice: l[i], showCustomer: false),
                ],
              ],
            ),
          ),
        ),
        if (sales.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sectionGap),
          Text('Purchases', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < sales.length && i < 10; i++) ...[
                  if (i > 0) const Divider(),
                  SaleTile(sale: sales[i]),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
