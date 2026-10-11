import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/amount_field.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/pin_prompt.dart';
import '../../../core/widgets/sub_page.dart';
import '../../account/application/account_actions.dart';
import '../application/savings_controller.dart';
import '../domain/savings_models.dart';
import 'savings_widgets.dart';

/// Screen 26. One form that adapts to the pocket type.
class SavingsCreateScreen extends ConsumerStatefulWidget {
  const SavingsCreateScreen({super.key, required this.typeCode});
  final String typeCode;

  @override
  ConsumerState<SavingsCreateScreen> createState() => _SavingsCreateScreenState();
}

class _SavingsCreateScreenState extends ConsumerState<SavingsCreateScreen> {
  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _target = TextEditingController();
  int? _amountKobo;
  int? _targetKobo;
  int? _months;
  int? _percent;
  bool _terms = false;
  String? _error;

  late final PocketType _type = PocketType.parse(widget.typeCode);

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _target.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final problem = validateNewPocket(
      type: _type,
      name: _name.text,
      amountKobo: _amountKobo ?? 0,
      targetKobo: _targetKobo,
      months: _months,
      spendPercent: _percent,
    );
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    if (_type == PocketType.locked) {
      if (!_terms) {
        setState(() => _error = 'Please accept the terms to continue.');
        return;
      }
      final ok = await showPinPrompt(
        context,
        title: 'Enter your PIN',
        message: 'Confirm that you want to lock this money.',
        verify: ref.read(accountActionsProvider).verifyPin,
      );
      if (ok != true || !mounted) return;
    }
    final pocket = ref.read(savingsProvider.notifier).create(
          type: _type,
          name: _name.text,
          amountKobo: _amountKobo ?? 0,
          targetKobo: _targetKobo,
          months: _months,
          spendPercent: _percent,
        );
    if (!mounted) return;
    context.pushReplacement(
      _type == PocketType.locked ? AppRoutes.savingsConfirm(pocket.id) : AppRoutes.savingsDetail(pocket.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final amount = _amountKobo ?? 0;
    return SubPage(
      title: _type.label,
      fallbackRoute: AppRoutes.savingsNew,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pageMargin),
        children: [
          const SavingsPreviewBanner(),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(label: 'Pocket name', controller: _name, maxLength: 40, hint: 'For example: School fees'),
          const SizedBox(height: AppSpacing.lg),
          if (_type == PocketType.fixed) ...[
            AmountField(
              controller: _target,
              label: 'Target (optional)',
              onChangedKobo: (v) => setState(() => _targetKobo = v),
            ),
            const SizedBox(height: AppSpacing.lg),
            AmountField(
              controller: _amount,
              label: 'Start with (optional)',
              onChangedKobo: (v) => setState(() => _amountKobo = v),
            ),
          ],
          if (_type == PocketType.saveAsYouSpend) ...[
            Text('Set aside from every spend', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final p in spendPercentOptions)
                  ChoiceChip(
                    label: Text('$p%'),
                    selected: _percent == p,
                    onSelected: (_) => setState(() {
                      _percent = p;
                      _error = null;
                    }),
                  ),
              ],
            ),
          ],
          if (_type == PocketType.locked) ...[
            AmountField(
              controller: _amount,
              label: 'Amount to lock',
              helper: 'Money goes in now. You cannot add more later.',
              onChangedKobo: (v) => setState(() => _amountKobo = v),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Lock for', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final m in lockedMonthOptions)
                  ChoiceChip(
                    label: Text('$m months'),
                    selected: _months == m,
                    onSelected: (_) => setState(() {
                      _months = m;
                      _error = null;
                    }),
                  ),
              ],
            ),
            if (_months != null && amount > 0) ...[
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                color: palette.tint,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('You will earn about ${formatNairaShort(projectedInterestKobo(amount, _type.rateBps, _months!))}',
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${_type.rateLabel}. Available on ${formatShortDate(addMonths(DateTime.now(), _months!))}.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _terms,
              onChanged: (v) => setState(() {
                _terms = v ?? false;
                _error = null;
              }),
              title: const Text('I understand I cannot withdraw this money until the date above.'),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(_error!, style: theme.textTheme.bodySmall?.copyWith(color: StatusColors.errorText)),
          ],
          const SizedBox(height: AppSpacing.xxl),
          AppButton(label: _type == PocketType.locked ? 'Lock money' : 'Create pocket', onPressed: _create),
        ],
      ),
    );
  }
}
