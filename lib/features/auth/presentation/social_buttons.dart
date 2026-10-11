import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/widgets/app_button.dart';
import '../application/auth_actions.dart';

/// "Continue with Google" on Android and "Continue with Apple" on iOS.
/// The router moves on by itself once the session arrives.
class SocialSignInButtons extends ConsumerStatefulWidget {
  const SocialSignInButtons({super.key, this.onError});

  /// Called with a friendly message when sign-in fails.
  final ValueChanged<String>? onError;

  @override
  ConsumerState<SocialSignInButtons> createState() => _SocialSignInButtonsState();
}

class _SocialSignInButtonsState extends ConsumerState<SocialSignInButtons> {
  bool _busy = false;

  Future<void> _run(Future<bool> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      widget.onError?.call(friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final platform = defaultTargetPlatform;
    final google = platform == TargetPlatform.android;
    final apple = platform == TargetPlatform.iOS;
    if (!google && !apple) return const SizedBox.shrink();
    final actions = ref.read(authActionsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text('or', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.inkSoft)),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        if (google)
          AppButton(
            label: 'Continue with Google',
            icon: Icons.g_mobiledata_rounded,
            style: AppButtonStyle.secondary,
            onPressed: _busy ? null : () => _run(actions.signInWithGoogle),
          ),
        if (apple)
          AppButton(
            label: 'Continue with Apple',
            icon: Icons.apple,
            style: AppButtonStyle.secondary,
            onPressed: _busy ? null : () => _run(actions.signInWithApple),
          ),
      ],
    );
  }
}
