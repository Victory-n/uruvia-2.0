import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/config/app_links.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/utils/open_link.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/sub_page.dart';
import '../../account/application/account_actions.dart';
import '../../auth/application/app_lock.dart';
import '../../auth/application/auth_actions.dart';
import '../domain/delete_account.dart';

/// Permanently deletes the signed-in user's account and all its data.
class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _word = TextEditingController();
  final _pin = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _word.dispose();
    _pin.dispose();
    super.dispose();
  }

  bool get _ready => isDeleteConfirmed(_word.text) && _pin.text.length == kPinLength && !_busy;

  Future<void> _delete() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final ok = await ref.read(accountActionsProvider).verifyPin(_pin.text);
      if (!ok) {
        setState(() {
          _busy = false;
          _error = 'That PIN is not right.';
        });
        return;
      }
      await ref.read(authActionsProvider).deleteAccount();
      // The session is gone, so the router sends the user to the sign-in screen.
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = friendlyError(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SubPage(
      title: 'Delete account',
      fallbackRoute: AppRoutes.settings,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pageMargin),
        children: [
          AppCard(
            color: AppColors.errorBg,
            child: Text(
              'This cannot be undone. Your sign-in and everything you saved are removed for good.',
              style: theme.textTheme.bodyMedium?.copyWith(color: StatusColors.errorText),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('What is deleted', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          const _Bullet('Your profile, PIN and sign-in (email, Google or Apple).'),
          const _Bullet('Your Individual and Business accounts: expenses, budgets, savings, customers, invoices, sales and stock.'),
          const _Bullet('Your notifications and support conversations.'),
          const SizedBox(height: AppSpacing.md),
          Text('Good to know', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          const _Bullet('Download or share any invoice you still need first. Deleted data cannot be recovered.'),
          const _Bullet('If you pay for Pro through the App Store or Google Play, cancel it there too. Deleting your account does not stop the charge.'),
          const _Bullet('If you added other people to your business, remove them first.'),
          const _Bullet('We may keep records the law requires us to keep.'),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => openLink(context, AppLinks.privacy),
              child: const Text('Read our privacy policy'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Your PIN',
            controller: _pin,
            obscure: true,
            keyboardType: TextInputType.number,
            maxLength: kPinLength,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            enabled: !_busy,
            onChanged: (_) => setState(() => _error = null),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Type $kDeleteConfirmWord to confirm',
            controller: _word,
            textCapitalization: TextCapitalization.characters,
            errorText: _error,
            enabled: !_busy,
            onChanged: (_) => setState(() => _error = null),
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppButton(label: 'Delete my account', loading: _busy, onPressed: _ready ? _delete : null),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Keep my account',
            style: AppButtonStyle.secondary,
            onPressed: _busy ? null : () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.only(top: 2, right: AppSpacing.sm), child: Text('•')),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
