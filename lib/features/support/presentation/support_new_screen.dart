import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/sub_page.dart';
import '../application/support_controller.dart';
import '../domain/support_models.dart';

class SupportNewScreen extends StatelessWidget {
  const SupportNewScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const SubPage(title: 'Contact support', fallbackRoute: AppRoutes.support, body: _Form());
}

class _Form extends ConsumerStatefulWidget {
  const _Form();

  @override
  ConsumerState<_Form> createState() => _FormState();
}

class _FormState extends ConsumerState<_Form> {
  String? _category;
  final _text = TextEditingController();
  String? _textError;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final problem = validateSupportText(_text.text);
    setState(() {
      _textError = problem;
      _error = _category == null ? 'Choose what this is about.' : null;
    });
    if (problem != null || _category == null) return;
    setState(() => _saving = true);
    try {
      final id = await ref.read(supportActionsProvider).create(category: _category!, description: _text.text);
      if (!mounted) return;
      context.pushReplacement(AppRoutes.supportTicket(id));
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
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pageMargin),
      children: [
        Text('What is this about?', style: theme.textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final c in supportCategories)
              ChoiceChip(
                label: Text(c),
                selected: _category == c,
                onSelected: _saving ? null : (_) => setState(() => _category = c),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Tell us what happened',
          controller: _text,
          maxLines: 6,
          maxLength: 4000,
          enabled: !_saving,
          errorText: _textError,
          textCapitalization: TextCapitalization.sentences,
          hint: 'Include the invoice or product name if it helps.',
        ),
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(_error!, style: theme.textTheme.bodyMedium?.copyWith(color: StatusColors.errorText)),
        ],
        const SizedBox(height: AppSpacing.xxl),
        AppButton(label: 'Send', onPressed: _send, loading: _saving),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Please do not send your PIN, password or full card number.',
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
