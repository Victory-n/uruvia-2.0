import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/pin_keypad.dart';
import '../application/app_lock.dart';
import '../application/auth_actions.dart';

/// Shown over the whole app when it is locked.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _entry = '';
  String? _error;
  bool _checking = false;
  bool _bio = false;

  @override
  void initState() {
    super.initState();
    _initBiometrics();
  }

  Future<void> _initBiometrics() async {
    final enabled = await ref.read(lockPinStoreProvider).biometricsEnabled();
    if (!mounted) return;
    setState(() => _bio = enabled);
    if (enabled) _tryBiometrics();
  }

  Future<void> _tryBiometrics() async {
    await ref.read(appLockProvider.notifier).unlockWithBiometrics();
  }

  Future<void> _digit(int d) async {
    if (_checking || _entry.length >= kPinLength) return;
    setState(() {
      _entry += '$d';
      _error = null;
    });
    if (_entry.length < kPinLength) return;

    setState(() => _checking = true);
    final result = await ref.read(appLockProvider.notifier).unlockWithPin(_entry);
    if (!mounted) return;
    switch (result) {
      case UnlockResult.ok:
        break;
      case UnlockResult.wrong:
        final left = ref.read(appLockProvider.notifier).triesLeft;
        setState(() {
          _entry = '';
          _checking = false;
          _error = 'Wrong PIN. $left ${left == 1 ? 'try' : 'tries'} left.';
        });
      case UnlockResult.tooManyTries:
        await ref.read(authActionsProvider).signOut();
    }
  }

  void _backspace() {
    if (_entry.isEmpty || _checking) return;
    setState(() => _entry = _entry.substring(0, _entry.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageMargin),
              child: Column(
                children: [
                  const Spacer(),
                  Image.asset('assets/img/logo.png', width: 72),
                  const SizedBox(height: AppSpacing.xxl),
                  Text('Enter your PIN', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.xxl),
                  PinDots(length: kPinLength, filled: _entry.length, error: _error != null),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 24,
                    child: Text(
                      _error ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(color: StatusColors.errorText),
                    ),
                  ),
                  const Spacer(),
                  PinKeypad(
                    onDigit: _digit,
                    onBackspace: _backspace,
                    onBiometric: _bio ? _tryBiometrics : null,
                    enabled: !_checking,
                  ),
                  AppButton(
                    label: 'Forgot PIN? Sign in again',
                    style: AppButtonStyle.text,
                    onPressed: () => ref.read(authActionsProvider).signOut(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
