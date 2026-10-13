import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/sub_page.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/errors/friendly_error.dart';
import '../../invoices/application/invoices_controller.dart' show businessInfoProvider;
import '../../invoices/domain/invoice_models.dart' show PaymentMethod;
import '../application/receipt_pdf.dart';
import '../application/sales_controller.dart';
import '../domain/sale_models.dart';

class SaleDetailScreen extends ConsumerWidget {
  const SaleDetailScreen({super.key, required this.saleId});
  final String saleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(saleProvider(saleId));
    return SubPage(
      title: value.valueOrNull?.number ?? 'Sale',
      fallbackRoute: AppRoutes.sales,
      actions: [
        if (value.valueOrNull != null && !value.valueOrNull!.isReversed)
          PopupMenuButton<String>(
            tooltip: 'Share receipt',
            icon: const Icon(Icons.share_outlined),
            onSelected: (v) async {
              try {
                final sale = value.valueOrNull!;
                final business = await ref.read(businessInfoProvider.future);
                final name = business?.name ?? 'Uruvia';
                final items = await ref.read(saleItemsProvider(sale.id).future);
                if (v == 'pdf') {
                  final bytes = await buildReceiptPdf(businessName: name, sale: sale, items: items);
                  final dir = await getTemporaryDirectory();
                  final file = File('${dir.path}/${sale.number}.pdf');
                  await file.writeAsBytes(bytes, flush: true);
                  await SharePlus.instance.share(ShareParams(
                    files: [XFile(file.path, mimeType: 'application/pdf')],
                    subject: 'Receipt ${sale.number}',
                  ));
                } else {
                  await SharePlus.instance.share(ShareParams(
                    text: saleReceiptText(businessName: name, sale: sale, items: items),
                    subject: 'Receipt ${sale.number}',
                  ));
                }
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyError(e))));
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'pdf', child: Text('Share as PDF')),
              PopupMenuItem(value: 'text', child: Text('Share as message')),
            ],
          ),
      ],
      body: AsyncView<Sale?>(
        value: value,
        onRetry: () => ref.invalidate(saleProvider(saleId)),
        isEmpty: (s) => s == null,
        empty: const EmptyState(icon: Icons.search_off_rounded, title: 'Sale not found'),
        data: (s) => _Detail(sale: s!),
      ),
    );
  }
}

class _Detail extends ConsumerWidget {
  const _Detail({required this.sale});
  final Sale sale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final s = sale;
    final items = ref.watch(saleItemsProvider(s.id));

    Widget row(String label, String value, {bool strong = false, Color? color}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Expanded(child: Text(label, style: strong ? theme.textTheme.titleMedium : theme.textTheme.bodyMedium)),
              Text(value, style: (strong ? theme.textTheme.titleLarge : theme.textTheme.bodyMedium)?.copyWith(color: color)),
            ],
          ),
        );

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pageMargin),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(s.customerName ?? 'Walk-in customer', style: theme.textTheme.titleLarge)),
                  if (s.isReversed) const StatusChip('Reversed', tone: StatusTone.neutral) else const StatusChip('Completed', tone: StatusTone.success),
                ],
              ),
              Text(
                '${formatShortDate(s.soldAt)} · ${s.soldAt.hour.toString().padLeft(2, '0')}:${s.soldAt.minute.toString().padLeft(2, '0')}',
                style: theme.textTheme.bodySmall,
              ),
              const Divider(height: AppSpacing.xxl),
              row('Sale total', formatNaira(s.totalKobo, showKobo: s.totalKobo % 100 != 0), strong: true),
              if (s.paymentMethod != null) row('Paid by', PaymentMethod.parse(s.paymentMethod!).label),
              if (s.note != null) row('Note', s.note!),
              row('Cost of goods', formatNaira(s.costKobo, showKobo: s.costKobo % 100 != 0)),
              row('Profit', formatNaira(s.profitKobo, showKobo: s.profitKobo % 100 != 0),
                  color: s.profitKobo < 0 ? StatusColors.errorText : palette.action),
            ],
          ),
        ),
        if (s.invoiceId != null) ...[
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'View the invoice',
            icon: Icons.description_outlined,
            style: AppButtonStyle.secondary,
            onPressed: () => context.push(AppRoutes.invoiceDetail(s.invoiceId!)),
          ),
        ],
        const SizedBox(height: AppSpacing.sectionGap),
        Text('Items sold', style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        AsyncView<List<SaleItem>>(
          value: items,
          loading: const Padding(padding: EdgeInsets.all(AppSpacing.xl), child: Center(child: CircularProgressIndicator())),
          onRetry: () => ref.invalidate(saleItemsProvider(s.id)),
          data: (list) => AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var n = 0; n < list.length; n++) ...[
                  if (n > 0) const Divider(),
                  ListTile(
                    minTileHeight: 64,
                    title: Text(list[n].description),
                    subtitle: Text('${list[n].qty} × ${formatNaira(list[n].unitPriceKobo, showKobo: false)}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(formatNaira(list[n].totalKobo, showKobo: false), style: theme.textTheme.titleMedium),
                        Text('profit ${formatNaira(list[n].profitKobo, showKobo: false)}', style: theme.textTheme.bodySmall),
                      ],
                    ),
                    onTap: list[n].productId == null ? null : () => context.push(AppRoutes.productDetail(list[n].productId!)),
                  ),
                ],
              ],
            ),
          ),
        ),
        ref.watch(saleStockEffectsProvider(s.id)).maybeWhen(
          data: (effects) => effects.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sectionGap),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Stock effect', style: theme.textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.sm),
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            for (var n = 0; n < effects.length; n++) ...[
                              if (n > 0) const Divider(),
                              ListTile(
                                minTileHeight: 56,
                                title: Text(effects[n].productName),
                                subtitle: Text('${effects[n].before} in stock before, ${effects[n].after} after'),
                                trailing: Text('${effects[n].change > 0 ? '+' : ''}${effects[n].change}', style: theme.textTheme.titleMedium),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          orElse: () => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
