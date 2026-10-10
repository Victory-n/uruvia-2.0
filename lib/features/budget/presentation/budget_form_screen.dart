import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/amount_field.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/sub_page.dart';
import '../../expenses/application/expenses_controller.dart';
import '../../expenses/domain/expense_models.dart';
import '../application/budget_controller.dart';
import '../domain/budget_models.dart';

/// Create a budget, or edit one when [budgetId] is given.
class BudgetFormScreen extends ConsumerWidget {
  const BudgetFormScreen({super.key, this.budgetId});
  final String? budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = budgetId;
    if (id == null) {
      return const SubPage(title: 'New budget', fallbackRoute: AppRoutes.budgets, body: _BudgetForm());
    }
    return SubPage(
      title: 'Edit budget',
      fallbackRoute: AppRoutes.budgetDetail(id),
      body: AsyncView<BudgetProgress?>(
        value: ref.watch(budgetProvider(id)),
        onRetry: () => ref.invalidate(budgetProvider(id)),
        loading: const Center(child: CircularProgressIndicator()),
        isEmpty: (b) => b == null,
        empty: const EmptyState(icon: Icons.search_off_rounded, title: 'Budget not found'),
        data: (b) => _BudgetForm(existing: b),
      ),
    );
  }
}

class _BudgetForm extends ConsumerStatefulWidget {
  const _BudgetForm({this.existing});
  final BudgetProgress? existing;

  @override
  ConsumerState<_BudgetForm> createState() => _BudgetFormState();
}

class _BudgetFormState extends ConsumerState<_BudgetForm> {
  late final _amount = TextEditingController(
    text: widget.existing == null ? '' : (widget.existing!.amountKobo ~/ 100).toString(),
  );
  late String? _categoryId = widget.existing?.categoryId;
  late BudgetPeriod _period = widget.existing?.period ?? BudgetPeriod.monthly;
  late bool _repeat = widget.existing?.repeat ?? true;
  late bool _alert80 = widget.existing?.alert80 ?? true;
  late bool _alert100 = widget.existing?.alert100 ?? true;
  late bool _paused = widget.existing?.paused ?? false;
  int? _kobo;
  String? _amountError;
  String? _categoryError;
  String? _error;
  bool _saving = false;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _kobo = widget.existing?.amountKobo;
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final kobo = _kobo ?? parseNairaToKobo(_amount.text);
    setState(() {
      _amountError = (kobo == null || kobo <= 0) ? 'Enter an amount greater than zero.' : null;
      _categoryError = _categoryId == null ? 'Choose a category.' : null;
      _error = null;
    });
    if (_amountError != null || _categoryError != null) return;

    setState(() => _saving = true);
    try {
      final actions = ref.read(budgetActionsProvider);
      if (_editing) {
        await actions.update(
          widget.existing!.budgetId,
          amountKobo: kobo!,
          repeat: _repeat,
          alert80: _alert80,
          alert100: _alert100,
          paused: _paused,
        );
      } else {
        await actions.create(
          categoryId: _categoryId!,
          amountKobo: kobo!,
          period: _period,
          repeat: _repeat,
          alert80: _alert80,
          alert100: _alert100,
        );
      }
      if (mounted) context.canPop() ? context.pop() : context.go(AppRoutes.budgets);
    } catch (e) {
      if (!mounted) return;
      final duplicate = e is PostgrestException && e.code == '23505';
      setState(() {
        _saving = false;
        _error = duplicate
            ? 'You already have a ${_period.label.toLowerCase()} budget for this category.'
            : friendlyError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final categories = ref.watch(categoriesProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pageMargin),
      children: [
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Text(_error!, style: theme.textTheme.bodyMedium?.copyWith(color: StatusColors.errorText)),
          ),
        Text('Category', style: theme.textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        categories.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => TextButton(
            onPressed: () => ref.invalidate(categoriesProvider),
            child: const Text('Could not load categories. Retry'),
          ),
          data: (list) => Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final c in list)
                ChoiceChip(
                  avatar: Icon(categoryIcon(c.icon), size: 18),
                  label: Text(c.name),
                  selected: _categoryId == c.id,
                  // The category of an existing budget cannot change.
                  onSelected: (_saving || _editing) ? null : (v) => setState(() => _categoryId = v ? c.id : null),
                ),
            ],
          ),
        ),
        if (_categoryError != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(_categoryError!, style: theme.textTheme.bodySmall?.copyWith(color: StatusColors.errorText)),
          ),
        const SizedBox(height: AppSpacing.xl),
        AmountField(
          controller: _amount,
          label: 'Budget amount',
          enabled: !_saving,
          errorText: _amountError,
          onChangedKobo: (v) => _kobo = v,
          quickAmountsKobo: const [2000000, 5000000, 10000000, 20000000],
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Period', style: theme.textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<BudgetPeriod>(
          segments: [for (final p in BudgetPeriod.values) ButtonSegment(value: p, label: Text(p.label))],
          selected: {_period},
          onSelectionChanged: (_saving || _editing) ? null : (s) => setState(() => _period = s.first),
        ),
        const SizedBox(height: AppSpacing.lg),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          activeThumbColor: palette.action,
          title: const Text('Repeat every period'),
          subtitle: const Text('Start a new budget with the same amount when this one ends.'),
          value: _repeat,
          onChanged: _saving ? null : (v) => setState(() => _repeat = v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          activeThumbColor: palette.action,
          title: const Text('Alert me at 80%'),
          value: _alert80,
          onChanged: _saving ? null : (v) => setState(() => _alert80 = v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          activeThumbColor: palette.action,
          title: const Text('Alert me at 100%'),
          value: _alert100,
          onChanged: _saving ? null : (v) => setState(() => _alert100 = v),
        ),
        if (_editing)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeThumbColor: palette.action,
            title: const Text('Pause this budget'),
            subtitle: const Text('Paused budgets are left out of your totals and send no alerts.'),
            value: _paused,
            onChanged: _saving ? null : (v) => setState(() => _paused = v),
          ),
        const SizedBox(height: AppSpacing.xxl),
        AppButton(label: _editing ? 'Save changes' : 'Create budget', onPressed: _save, loading: _saving),
      ],
    );
  }
}
