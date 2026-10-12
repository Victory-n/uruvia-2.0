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
import '../../auth/application/auth_actions.dart';
import '../../auth/domain/validators.dart';

/// Change the sign-in password. Asks for the current one first.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _current = TextEditingController();
  final _fresh = TextEditingController();
  final _again = TextEditingController();
  String? _currentError;
  String? _freshError;
  String? _againError;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _current.dispose();
    _fresh.dispose();
    _again.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final cur = Validators.password(_current.text);
    final fresh = Validators.newPassword(_fresh.text);
    final again = _fresh.text == _again.text ? null : 'The passwords do not match.';
    final same = fresh == null && _fresh.text == _current.text ? 'Choose a password you have not used just now.' : null;
    setState(() {
      _currentError = cur;
      _freshError = fresh ?? same;
      _againError = again;
      _error = null;
    });
    if (cur != null || fresh != null || again != null || same != null) return;
    setState(() => _busy = true);
    try {
      await ref.read(authActionsProvider).changePassword(current: _current.text, fresh: _fresh.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your password has been changed.')));
      context.pop();
    } catch (e) {
      if (!mounted) return;
      final msg = friendlyError(e);
      setState(() {
        _busy = false;
        // A wrong current password comes back as "Email or password is not correct."
        if (msg.startsWith('Email or password')) {
          _currentError = 'Your current password is not right.';
        } else {
          _error = msg;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SubPage(
      title: 'Change password',
      fallbackRoute: AppRoutes.settings,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pageMargin),
        children: [
          AppTextField(label: 'Current password', controller: _current, obscure: true, errorText: _currentError, enabled: !_busy),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'New password',
            controller: _fresh,
            obscure: true,
            helper: 'At least 8 characters, with letters and numbers.',
            errorText: _freshError,
            enabled: !_busy,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Confirm new password',
            controller: _again,
            obscure: true,
            errorText: _againError,
            enabled: !_busy,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(_error!, style: theme.textTheme.bodySmall?.copyWith(color: StatusColors.errorText)),
          ],
          const SizedBox(height: AppSpacing.xxl),
          AppButton(label: 'Change password', onPressed: _busy ? null : _save, loading: _busy),
        ],
      ),
    );
  }
}
