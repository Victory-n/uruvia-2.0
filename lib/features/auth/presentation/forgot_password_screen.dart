import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../application/auth_actions.dart';
import '../domain/validators.dart';
import 'auth_scaffold.dart';

/// Two steps on one screen: ask for the email, then the emailed code and a new password.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  bool _codeSent = false;
  bool _loading = false;
  String? _emailError;
  String? _codeError;
  String? _passwordError;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    setState(() {
      _emailError = Validators.email(_email.text);
      _error = null;
    });
    if (_emailError != null) return;
    setState(() => _loading = true);
    try {
      await ref.read(authActionsProvider).sendResetCode(_email.text);
      if (mounted) setState(() => _codeSent = true);
    } catch (e) {
      if (mounted) setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reset() async {
    setState(() {
      _codeError = Validators.code(_code.text);
      _passwordError = Validators.newPassword(_password.text);
      _error = null;
    });
    if (_codeError != null || _passwordError != null) return;
    setState(() => _loading = true);
    try {
      await ref.read(authActionsProvider).resetPassword(_email.text, _code.text, _password.text);
      // Signed in now; the router moves on.
    } catch (e) {
      if (mounted) setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Reset your password',
      subtitle: _codeSent
          ? 'Enter the code we emailed to ${_email.text.trim()} and choose a new password.'
          : 'Enter your email and we will send you a code.',
      backTo: AppRoutes.signIn,
      children: [
        FormError(_error),
        if (!_codeSent) ...[
          AppTextField(
            label: 'Email',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            errorText: _emailError,
            enabled: !_loading,
            onSubmitted: (_) => _sendCode(),
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppButton(label: 'Send code', onPressed: _sendCode, loading: _loading),
        ] else ...[
          AppTextField(
            label: 'Code',
            controller: _code,
            keyboardType: TextInputType.number,
            maxLength: 8,
            autofocus: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            errorText: _codeError,
            enabled: !_loading,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'New password',
            controller: _password,
            obscure: true,
            helper: 'At least 8 characters, with letters and numbers.',
            errorText: _passwordError,
            enabled: !_loading,
            onSubmitted: (_) => _reset(),
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppButton(label: 'Save new password', onPressed: _reset, loading: _loading),
          const SizedBox(height: AppSpacing.sm),
          AppButton(label: 'Send a new code', style: AppButtonStyle.text, onPressed: _loading ? null : _sendCode),
        ],
      ],
    );
  }
}
