import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/amount_field.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/sub_page.dart';
import '../application/savings_controller.dart';
import '../domain/savings_models.dart';
import 'savings_widgets.dart';

/// Screen 27. DUMMY pocket detail with add and withdraw.
class SavingsDetailScreen extends ConsumerWidget {
  const SavingsDetailScreen({super.key, required this.pocketId});
  final String pocketId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    ref.watch(savingsProvider);
    final pocket = ref.read(savingsProvider.notifier).byId(pocketId);
    if (pocket == null) {
      return const SubPage(
        title: 'Pocket',
        fallbackRoute: AppRoutes.savings,
        body: EmptyState(icon: Icons.search_off_rounded, title: 'Pocket not found'),
      );
    }
    final locked = pocket.isLocked();
    final days = DateTime.now().difference(pocket.createdAt).inDays;
    final interest = accruedInterestKobo(pocket.balanceKobo, pocket.type.rateBps, days);
    final progress = pocket.progress;

    return SubPage(
      title: pocket.name,
      fallbackRoute: AppRoutes.savings,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pageMargin),
        children: [
          const SavingsPreviewBanner(),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(color: palette.hero, borderRadius: BorderRadius.circular(AppRadius.card)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pocket.type.label, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                const SizedBox(height: AppSpacing.xs),
                AmountText(pocket.balanceKobo, size: AmountSize.xl, color: Colors.white),
                if (progress != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      color: palette.accent,
                      backgroundColor: Colors.white24,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text('${(progress * 100).round()}% of ${formatNairaShort(pocket.targetKobo!)}',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (pocket.type == PocketType.locked)
            StatusChip(
              locked ? 'Locked until ${formatShortDate(pocket.maturesOn!)}' : 'Matured. You can withdraw now.',
              tone: locked ? StatusTone.info : StatusTone.success,
            )
          else
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Add money',
                    icon: Icons.add_rounded,
                    onPressed: () => _moneySheet(context, ref, pocket, deposit: true),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    label: 'Withdraw',
                    style: AppButtonStyle.secondary,
                    onPressed: pocket.balanceKobo > 0 ? () => _moneySheet(context, ref, pocket, deposit: false) : null,
                  ),
                ),
              ],
            ),
          if (pocket.type == PocketType.locked && !locked && pocket.balanceKobo > 0) ...[
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Withdraw to wallet',
              onPressed: () => _moneySheet(context, ref, pocket, deposit: false),
            ),
          ],
          const SizedBox(height: AppSpacing.sectionGap),
          AppCard(
            child: Column(
              children: [
                _row(theme, 'Interest rate', pocket.type.rateLabel),
                const Divider(height: 1),
                _row(theme, 'Interest so far', formatNairaShort(interest)),
                if (pocket.spendPercent != null) ...[
                  const Divider(height: 1),
                  _row(theme, 'Set aside', '${pocket.spendPercent}% of each spend'),
                ],
                const Divider(height: 1),
                _row(theme, 'Started', formatShortDate(pocket.createdAt)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          Text('Activity', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          if (pocket.entries.isEmpty)
            Text('Nothing yet.', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft))
          else
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  for (var i = 0; i < pocket.entries.length; i++) ...[
                    if (i > 0) const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_entryLabel(pocket.entries[i].kind), style: theme.textTheme.bodyLarge),
                                Text(formatRelative(pocket.entries[i].at),
                                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.inkSoft)),
                              ],
                            ),
                          ),
                          AmountText(
                            pocket.entries[i].signedKobo,
                            signed: true,
                            color: pocket.entries[i].signedKobo > 0 ? StatusColors.success : AppColors.ink,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  static String _entryLabel(EntryKind k) => switch (k) {
        EntryKind.contribution => 'Money added',
        EntryKind.withdrawal => 'Withdrawal',
        EntryKind.interest => 'Interest',
      };

  static Widget _row(ThemeData theme, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Expanded(child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft))),
            Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Future<void> _moneySheet(BuildContext context, WidgetRef ref, SavingsPocket pocket, {required bool deposit}) {
    return showAppSheet<void>(
      context,
      title: deposit ? 'Add money' : 'Withdraw',
      builder: (sheetContext) => _MoneySheet(
        pocket: pocket,
        deposit: deposit,
        onSubmit: (kobo) {
          final n = ref.read(savingsProvider.notifier);
          if (deposit) {
            n.deposit(pocket.id, kobo);
          } else {
            n.withdraw(pocket.id, kobo);
          }
          Navigator.of(sheetContext).pop();
        },
      ),
    );
  }
}

class _MoneySheet extends StatefulWidget {
  const _MoneySheet({required this.pocket, required this.deposit, required this.onSubmit});
  final SavingsPocket pocket;
  final bool deposit;
  final void Function(int kobo) onSubmit;

  @override
  State<_MoneySheet> createState() => _MoneySheetState();
}

class _MoneySheetState extends State<_MoneySheet> {
  final _c = TextEditingController();
  int? _kobo;
  String? _error;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _go() {
    final k = _kobo ?? 0;
    if (k <= 0) {
      setState(() => _error = 'Enter an amount.');
    } else if (!widget.deposit && k > widget.pocket.balanceKobo) {
      setState(() => _error = 'That is more than the balance.');
    } else {
      widget.onSubmit(k);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AmountField(
          controller: _c,
          autofocus: true,
          errorText: _error,
          helper: widget.deposit ? 'Taken from your sample wallet.' : 'Goes back to your sample wallet.',
          onChangedKobo: (v) => setState(() {
            _kobo = v;
            _error = null;
          }),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(label: widget.deposit ? 'Add' : 'Withdraw', onPressed: _go),
      ],
    );
  }
}

/// Screen 28. Shown after money is locked.
class SavingsConfirmScreen extends ConsumerWidget {
  const SavingsConfirmScreen({super.key, required this.pocketId});
  final String pocketId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    ref.watch(savingsProvider);
    final p = ref.read(savingsProvider.notifier).byId(pocketId);
    if (p == null || p.maturesOn == null) {
      return const SubPage(
        title: 'Locked',
        fallbackRoute: AppRoutes.savings,
        body: EmptyState(icon: Icons.search_off_rounded, title: 'Pocket not found'),
      );
    }
    final months = (p.maturesOn!.year - p.createdAt.year) * 12 + p.maturesOn!.month - p.createdAt.month;
    return SubPage(
      title: 'Money locked',
      fallbackRoute: AppRoutes.savings,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.pageMargin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: palette.tint,
              child: Icon(Icons.lock_rounded, size: 36, color: palette.action),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Your money is locked', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            AmountText(p.balanceKobo, size: AmountSize.l),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Available on ${formatShortDate(p.maturesOn!)}. You will earn about '
              '${formatNairaShort(projectedInterestKobo(p.balanceKobo, p.type.rateBps, months))}.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            AppButton(
              label: 'View pocket',
              style: AppButtonStyle.secondary,
              onPressed: () => context.pushReplacement(AppRoutes.savingsDetail(p.id)),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(label: 'Done', onPressed: () => context.go(AppRoutes.savings)),
          ],
        ),
      ),
    );
  }
}
