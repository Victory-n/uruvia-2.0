import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/services/local_store.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/pin_keypad.dart';
import '../../account/application/bootstrap.dart';
import '../application/app_lock.dart';
import '../application/auth_actions.dart';
import 'auth_scaffold.dart';

enum _PinStep { create, confirm, biometrics }

/// Create the PIN (twice), then offer fingerprint / face unlock.
/// First time: the PIN also becomes the transaction PIN. On a new phone for an
/// existing user it is only the PIN that unlocks the app on this phone.
class CreatePinScreen extends ConsumerStatefulWidget {
  const CreatePinScreen({super.key});

  @override
  ConsumerState<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends ConsumerState<CreatePinScreen> {
  _PinStep _step = _PinStep.create;
  String _entry = '';
  String _first = '';
  String? _error;
  bool _saving = false;
  bool _bioAvailable = false;

  @override
  void initState() {
    super.initState();
    ref.read(biometricsProvider).isAvailable().then((v) {
      if (mounted) setState(() => _bioAvailable = v);
    });
  }

  void _digit(int d) {
    if (_saving || _entry.length >= kPinLength) return;
    setState(() {
      _entry += '$d';
      _error = null;
    });
    if (_entry.length == kPinLength) _complete();
  }

  void _backspace() {
    if (_entry.isEmpty) return;
    setState(() => _entry = _entry.substring(0, _entry.length - 1));
  }

  void _complete() {
    if (_step == _PinStep.create) {
      setState(() {
        _first = _entry;
        _entry = '';
        _step = _PinStep.confirm;
      });
    } else if (_step == _PinStep.confirm) {
      if (_entry == _first) {
        if (_bioAvailable) {
          setState(() => _step = _PinStep.biometrics);
        } else {
          _save(false);
        }
      } else {
        setState(() {
          _error = 'The PINs do not match. Start again.';
          _entry = '';
          _first = '';
          _step = _PinStep.create;
        });
      }
    }
  }

  Future<void> _enableBiometrics() async {
    final ok = await ref.read(biometricsProvider).authenticate('Turn on fingerprint unlock');
    if (!mounted) return;
    if (ok) {
      await _save(true);
    } else {
      setState(() => _error = 'We could not confirm your fingerprint. Try again or skip.');
    }
  }

  Future<void> _save(bool biometrics) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(authActionsProvider).createPin(_first, enableBiometrics: biometrics);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = friendlyError(e);
          _entry = '';
          _first = '';
          _step = _PinStep.create;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final firstTime = ref.watch(bootstrapProvider).valueOrNull?.hasTransactionPin == false;

    if (_step == _PinStep.biometrics) {
      return AuthScaffold(
        title: 'Unlock with your fingerprint?',
        subtitle: 'Skip typing your PIN each time. Your PIN still works as a back-up.',
        children: [
          FormError(_error),
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(color: palette.tint, shape: BoxShape.circle),
              child: Icon(Icons.fingerprint_rounded, size: 64, color: palette.action),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          AppButton(label: 'Turn on', loading: _saving, onPressed: _enableBiometrics),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Not now',
            style: AppButtonStyle.text,
            onPressed: _saving ? null : () => _save(false),
          ),
        ],
      );
    }

    final confirming = _step == _PinStep.confirm;
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
                  Text(confirming ? 'Confirm your PIN' : 'Create your PIN', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    firstTime
                        ? 'You will use it to open Uruvia and to approve payments.'
                        : 'You will use it to open Uruvia on this phone.',
                    style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.inkSoft),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  PinDots(length: kPinLength, filled: _entry.length, error: _error != null),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 40,
                    child: _saving
                        ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5)))
                        : Text(
                            _error ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(color: StatusColors.errorText),
                            textAlign: TextAlign.center,
                          ),
                  ),
                  const Spacer(),
                  PinKeypad(onDigit: _digit, onBackspace: _backspace, enabled: !_saving),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
