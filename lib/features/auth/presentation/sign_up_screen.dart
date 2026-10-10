import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../application/auth_actions.dart';
import '../domain/validators.dart';
import 'auth_scaffold.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _nameError = Validators.fullName(_name.text);
      _emailError = Validators.email(_email.text);
      _passwordError = Validators.newPassword(_password.text);
      _error = null;
    });
    if (_nameError != null || _emailError != null || _passwordError != null) return;

    setState(() => _loading = true);
    try {
      final needsCode =
          await ref.read(authActionsProvider).signUp(_name.text, _email.text, _password.text);
      if (needsCode && mounted) {
        context.go('${AppRoutes.verifyEmail}?email=${Uri.encodeQueryComponent(_email.text.trim())}');
      }
    } catch (e) {
      if (mounted) setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Create your account',
      subtitle: 'It takes about a minute.',
      backTo: AppRoutes.onboarding,
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Already have an account?'),
          TextButton(onPressed: () => context.go(AppRoutes.signIn), child: const Text('Sign in')),
        ],
      ),
      children: [
        FormError(_error),
        AppTextField(
          label: 'Full name',
          controller: _name,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
          errorText: _nameError,
          enabled: !_loading,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Email',
          controller: _email,
          hint: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          errorText: _emailError,
          enabled: !_loading,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Password',
          controller: _password,
          obscure: true,
          helper: 'At least 8 characters, with letters and numbers.',
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          errorText: _passwordError,
          enabled: !_loading,
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: AppSpacing.xxl),
        AppButton(label: 'Create account', onPressed: _submit, loading: _loading),
      ],
    );
  }
}
