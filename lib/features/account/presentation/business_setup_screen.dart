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
import '../../auth/application/auth_actions.dart';
import '../../auth/domain/validators.dart';
import '../../auth/presentation/auth_scaffold.dart';
import '../domain/account_models.dart';

const _categories = ['Retail', 'Food and drinks', 'Services', 'Fashion', 'Agriculture', 'Technology', 'Other'];

/// Business set-up in three steps: about, invoice settings, payment details.
class BusinessSetupScreen extends ConsumerStatefulWidget {
  const BusinessSetupScreen({super.key});

  @override
  ConsumerState<BusinessSetupScreen> createState() => _BusinessSetupScreenState();
}

class _BusinessSetupScreenState extends ConsumerState<BusinessSetupScreen> {
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _prefix = TextEditingController(text: 'INV');
  final _vat = TextEditingController(text: '7.5');
  final _bank = TextEditingController();
  final _accNumber = TextEditingController();
  final _accName = TextEditingController();

  int _step = 0;
  String? _category;
  String? _nameError;
  String? _prefixError;
  String? _vatError;
  String? _accNumberError;
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    for (final c in [_name, _address, _prefix, _vat, _bank, _accNumber, _accName]) {
      c.dispose();
    }
    super.dispose();
  }

  void _back() {
    if (_step == 0) {
      context.go(AppRoutes.accountType);
    } else {
      setState(() => _step--);
    }
  }

  Future<void> _next() async {
    setState(() => _error = null);
    if (_step == 0) {
      setState(() => _nameError = Validators.businessName(_name.text));
      if (_nameError == null) setState(() => _step = 1);
    } else if (_step == 1) {
      setState(() {
        _prefixError = Validators.invoicePrefix(_prefix.text);
        _vatError = Validators.vatPercent(_vat.text);
      });
      if (_prefixError == null && _vatError == null) setState(() => _step = 2);
    } else {
      setState(() => _accNumberError = Validators.accountNumber(_accNumber.text));
      if (_accNumberError != null) return;
      await _create();
    }
  }

  Future<void> _create() async {
    setState(() => _loading = true);
    try {
      await ref.read(authActionsProvider).createBusinessAccount(
            BusinessSetup(
              name: _name.text,
              category: _category,
              address: _address.text,
              invoicePrefix: _prefix.text.trim().toUpperCase(),
              vatRateBps: Validators.vatToBps(_vat.text),
              bankName: _bank.text,
              accountNumber: _accNumber.text,
              accountName: _accName.text,
            ),
          );
      if (mounted) context.go(AppRoutes.home);
    } catch (e) {
      if (mounted) setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    const titles = ['About your business', 'Invoice settings', 'Payment details'];
    const subtitles = [
      'Tell us what you run.',
      'These appear on every invoice. You can change them later.',
      'Shown on invoices so customers know where to pay. Optional for now.',
    ];

    return AuthScaffold(
      title: titles[_step],
      subtitle: 'Step ${_step + 1} of 3. ${subtitles[_step]}',
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (_step + 1) / 3,
            minHeight: 6,
            color: palette.action,
            backgroundColor: AppColors.border,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        FormError(_error),
        if (_step == 0) ...[
          AppTextField(
            label: 'Business name',
            controller: _name,
            textCapitalization: TextCapitalization.words,
            errorText: _nameError,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Category (optional)', style: theme.textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final c in _categories)
                ChoiceChip(
                  label: Text(c),
                  selected: _category == c,
                  onSelected: (v) => setState(() => _category = v ? c : null),
                ),
            ],
          ),
        ] else if (_step == 1) ...[
          AppTextField(
            label: 'Business address (optional)',
            controller: _address,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Invoice prefix',
            controller: _prefix,
            maxLength: 8,
            helper: 'Invoices are numbered like INV-0001.',
            textCapitalization: TextCapitalization.characters,
            errorText: _prefixError,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'VAT rate (%)',
            controller: _vat,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
            helper: 'Nigeria standard rate is 7.5%.',
            errorText: _vatError,
          ),
        ] else ...[
          AppTextField(label: 'Bank name', controller: _bank, textCapitalization: TextCapitalization.words),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Account number',
            controller: _accNumber,
            keyboardType: TextInputType.number,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            errorText: _accNumberError,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(label: 'Account name', controller: _accName, textCapitalization: TextCapitalization.words),
        ],
        const SizedBox(height: AppSpacing.xxl),
        AppButton(
          label: _step == 2 ? 'Create business account' : 'Continue',
          onPressed: _next,
          loading: _loading,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(label: 'Back', style: AppButtonStyle.text, onPressed: _loading ? null : _back),
      ],
    );
  }
}
