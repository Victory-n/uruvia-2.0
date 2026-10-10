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
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/sub_page.dart';
import '../application/expenses_controller.dart';
import '../domain/expense_models.dart';

/// Add a new expense, or edit one when [expenseId] is given.
class ExpenseFormScreen extends ConsumerWidget {
  const ExpenseFormScreen({super.key, this.expenseId});
  final String? expenseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = expenseId;
    if (id == null) {
      return const SubPage(
        title: 'Add expense',
        fallbackRoute: AppRoutes.expenses,
        body: _ExpenseForm(),
      );
    }
    final existing = ref.watch(expenseProvider(id));
    return SubPage(
      title: 'Edit expense',
      fallbackRoute: AppRoutes.expenses,
      body: AsyncView<Expense?>(
        value: existing,
        onRetry: () => ref.invalidate(expenseProvider(id)),
        loading: const Center(child: CircularProgressIndicator()),
        isEmpty: (e) => e == null,
        empty: const EmptyState(
          icon: Icons.search_off_rounded,
          title: 'Expense not found',
          message: 'It may have been deleted.',
        ),
        data: (e) => _ExpenseForm(existing: e),
      ),
    );
  }
}

class _ExpenseForm extends ConsumerStatefulWidget {
  const _ExpenseForm({this.existing});
  final Expense? existing;

  @override
  ConsumerState<_ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends ConsumerState<_ExpenseForm> {
  late final _amount = TextEditingController(
    text: widget.existing == null ? '' : _plain(widget.existing!.amountKobo),
  );
  late final _note = TextEditingController(text: widget.existing?.note ?? '');
  late DateTime _date = widget.existing?.spentAt ?? DateTime.now();
  late String? _categoryId = widget.existing?.categoryId;
  int? _kobo;
  String? _amountError;
  String? _error;
  bool _saving = false;

  static String _plain(int kobo) {
    final naira = kobo ~/ 100;
    final rest = kobo % 100;
    return rest == 0 ? '$naira' : '$naira.${rest.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _kobo = widget.existing?.amountKobo;
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(now) ? now : _date,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
    );
    if (picked != null) {
      // Keep the time of day when editing today's expense; otherwise use midday so time zones cannot shift the day.
      final sameDay = picked.year == _date.year && picked.month == _date.month && picked.day == _date.day;
      setState(() => _date = sameDay ? _date : DateTime(picked.year, picked.month, picked.day, 12));
    }
  }

  Future<void> _addCategory() async {
    final created = await showAppSheet<ExpenseCategory>(
      context,
      title: 'New category',
      builder: (_) => const _NewCategoryForm(),
    );
    if (created != null) setState(() => _categoryId = created.id);
  }

  Future<void> _save() async {
    final kobo = _kobo ?? parseNairaToKobo(_amount.text);
    if (kobo == null || kobo <= 0) {
      setState(() => _amountError = 'Enter an amount greater than zero.');
      return;
    }
    setState(() {
      _amountError = null;
      _error = null;
      _saving = true;
    });
    try {
      await ref.read(expensesActionsProvider).save(
            id: widget.existing?.id,
            amountKobo: kobo,
            spentAt: _date,
            categoryId: _categoryId,
            note: _note.text,
          );
      if (mounted) context.canPop() ? context.pop() : context.go(AppRoutes.expenses);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = friendlyError(e);
        });
      }
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this expense?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _saving = true);
    try {
      await ref.read(expensesActionsProvider).delete(widget.existing!.id);
      if (mounted) context.canPop() ? context.pop() : context.go(AppRoutes.expenses);
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
    final categories = ref.watch(categoriesProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pageMargin),
      children: [
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Text(_error!, style: theme.textTheme.bodyMedium?.copyWith(color: StatusColors.errorText)),
          ),
        AmountField(
          controller: _amount,
          autofocus: widget.existing == null,
          enabled: !_saving,
          errorText: _amountError,
          onChangedKobo: (v) => _kobo = v,
          quickAmountsKobo: const [50000, 100000, 200000, 500000],
        ),
        const SizedBox(height: AppSpacing.xl),
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
                  onSelected: _saving ? null : (v) => setState(() => _categoryId = v ? c.id : null),
                ),
              ActionChip(
                avatar: const Icon(Icons.add_rounded, size: 18),
                label: const Text('New'),
                onPressed: _saving ? null : _addCategory,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Date', style: theme.textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: _saving ? null : _pickDate,
          icon: const Icon(Icons.calendar_today_outlined),
          label: Text(formatDayHeader(_date) == 'Today' || formatDayHeader(_date) == 'Yesterday'
              ? formatDayHeader(_date)
              : formatShortDate(_date)),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppTextField(
          label: 'Note (optional)',
          controller: _note,
          maxLength: 200,
          enabled: !_saving,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: AppSpacing.xxl),
        AppButton(label: 'Save', onPressed: _save, loading: _saving),
        if (widget.existing != null) ...[
          const SizedBox(height: AppSpacing.sm),
          AppButton(label: 'Delete expense', style: AppButtonStyle.text, onPressed: _saving ? null : _delete),
        ],
      ],
    );
  }
}

class _NewCategoryForm extends ConsumerStatefulWidget {
  const _NewCategoryForm();

  @override
  ConsumerState<_NewCategoryForm> createState() => _NewCategoryFormState();
}

class _NewCategoryFormState extends ConsumerState<_NewCategoryForm> {
  final _name = TextEditingController();
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty || name.length > 60) {
      setState(() => _error = 'Enter a name up to 60 characters.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final created = await ref.read(expensesActionsProvider).addCategory(name);
      if (mounted) Navigator.of(context).pop(created);
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
    return Column(
      children: [
        AppTextField(
          label: 'Category name',
          controller: _name,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          errorText: _error,
          enabled: !_saving,
          onSubmitted: (_) => _save(),
        ),
        const SizedBox(height: AppSpacing.xxl),
        AppButton(label: 'Add category', onPressed: _save, loading: _saving),
      ],
    );
  }
}
