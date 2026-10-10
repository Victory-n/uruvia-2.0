import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../application/auth_actions.dart';
import '../domain/validators.dart';
import 'auth_scaffold.dart';

/// Asks for the code Supabase emails after sign-up.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key, required this.email});
  final String email;

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _code = TextEditingController();
  String? _codeError;
  String? _error;
  String? _info;
  bool _loading = false;
  bool _resending = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    setState(() {
      _codeError = Validators.code(_code.text);
      _error = null;
      _info = null;
    });
    if (_codeError != null) return;
    setState(() => _loading = true);
    try {
      await ref.read(authActionsProvider).verifySignUpCode(widget.email, _code.text);
    } catch (e) {
      if (mounted) setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    setState(() {
      _resending = true;
      _error = null;
      _info = null;
    });
    try {
      await ref.read(authActionsProvider).resendSignUpCode(widget.email);
      if (mounted) setState(() => _info = 'We sent a new code.');
    } catch (e) {
      if (mounted) setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Check your email',
      subtitle: 'We sent a code to ${widget.email}. Enter it to confirm your account.',
      backTo: AppRoutes.signUp,
      children: [
        FormError(_error),
        if (_info != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Text(_info!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: StatusColors.success)),
          ),
        AppTextField(
          label: 'Code',
          controller: _code,
          keyboardType: TextInputType.number,
          maxLength: 8,
          autofocus: true,
          autofillHints: const [AutofillHints.oneTimeCode],
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          errorText: _codeError,
          enabled: !_loading,
          onSubmitted: (_) => _verify(),
        ),
        const SizedBox(height: AppSpacing.xxl),
        AppButton(label: 'Confirm', onPressed: _verify, loading: _loading),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Send a new code',
          style: AppButtonStyle.text,
          loading: _resending,
          onPressed: _resend,
        ),
      ],
    );
  }
}
