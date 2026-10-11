import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/sub_page.dart';
import '../../auth/domain/validators.dart';
import '../application/settings_controller.dart';
import '../domain/settings_models.dart';

/// Business details and invoice settings, shown for Business accounts.
class BusinessDetailsScreen extends ConsumerWidget {
  const BusinessDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(businessDetailsProvider);
    return SubPage(
      title: 'Business details',
      fallbackRoute: AppRoutes.settings,
      body: AsyncView<BusinessDetails?>(
        value: value,
        onRetry: () => ref.invalidate(businessDetailsProvider),
        isEmpty: (d) => d == null,
        empty: const EmptyState(icon: Icons.storefront_outlined, title: 'No business found'),
        data: (d) => _Form(initial: d!),
      ),
    );
  }
}

class _Form extends ConsumerStatefulWidget {
  const _Form({required this.initial});
  final BusinessDetails initial;

  @override
  ConsumerState<_Form> createState() => _FormState();
}

class _FormState extends ConsumerState<_Form> {
  late final _name = TextEditingController(text: widget.initial.name);
  late final _category = TextEditingController(text: widget.initial.category ?? '');
  late final _address = TextEditingController(text: widget.initial.address ?? '');
  late final _prefix = TextEditingController(text: widget.initial.invoicePrefix);
  late final _vat = TextEditingController(text: widget.initial.vatPercentText);
  late final _bank = TextEditingController(text: widget.initial.bankName ?? '');
  late final _number = TextEditingController(text: widget.initial.accountNumber ?? '');
  late final _holder = TextEditingController(text: widget.initial.accountName ?? '');
  final _errors = <String, String?>{};
  String? _formError;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _category, _address, _prefix, _vat, _bank, _number, _holder]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final errors = {
      'name': Validators.businessName(_name.text),
      'prefix': Validators.invoicePrefix(_prefix.text),
      'vat': Validators.vatPercent(_vat.text),
      'number': Validators.accountNumber(_number.text),
    };
    setState(() {
      _errors
        ..clear()
        ..addAll(errors);
      _formError = null;
    });
    if (errors.values.any((e) => e != null)) return;

    setState(() => _saving = true);
    try {
      await ref.read(settingsActionsProvider).saveBusiness(
            BusinessDetails(
              name: _name.text,
              category: _category.text,
              address: _address.text,
              invoicePrefix: _prefix.text,
              vatRateBps: Validators.vatToBps(_vat.text),
              bankName: _bank.text,
              accountNumber: _number.text,
              accountName: _holder.text,
            ),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Business details saved.')));
      context.pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _formError = friendlyError(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const gap = SizedBox(height: AppSpacing.lg);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pageMargin),
      children: [
        AppTextField(
          label: 'Business name',
          controller: _name,
          errorText: _errors['name'],
          enabled: !_saving,
          textCapitalization: TextCapitalization.words,
        ),
        gap,
        AppTextField(label: 'Category (optional)', controller: _category, enabled: !_saving, textCapitalization: TextCapitalization.sentences),
        gap,
        AppTextField(
          label: 'Address (optional)',
          controller: _address,
          enabled: !_saving,
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        Text('Invoices', style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Invoice prefix',
          controller: _prefix,
          errorText: _errors['prefix'],
          enabled: !_saving,
          maxLength: 8,
          textCapitalization: TextCapitalization.characters,
          helper: 'New invoices are numbered like INV-00001. Existing invoices keep their numbers.',
        ),
        gap,
        AppTextField(
          label: 'VAT rate (%)',
          controller: _vat,
          errorText: _errors['vat'],
          enabled: !_saving,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}\.?\d{0,2}'))],
          helper: 'Used on new invoices. Existing invoices keep their rate.',
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        Text('Where customers pay you', style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        Text('Printed on invoices you share.', style: theme.textTheme.bodySmall),
        const SizedBox(height: AppSpacing.md),
        AppTextField(label: 'Bank name (optional)', controller: _bank, enabled: !_saving, textCapitalization: TextCapitalization.words),
        gap,
        AppTextField(
          label: 'Account number (optional)',
          controller: _number,
          errorText: _errors['number'],
          enabled: !_saving,
          keyboardType: TextInputType.number,
          maxLength: 10,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        gap,
        AppTextField(label: 'Account name (optional)', controller: _holder, enabled: !_saving, textCapitalization: TextCapitalization.words),
        if (_formError != null) ...[
          gap,
          Text(_formError!, style: theme.textTheme.bodyMedium?.copyWith(color: StatusColors.errorText)),
        ],
        const SizedBox(height: AppSpacing.xxl),
        AppButton(label: 'Save', onPressed: _save, loading: _saving),
      ],
    );
  }
}
