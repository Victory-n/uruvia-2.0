import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/widgets/pin_keypad.dart';
import '../../../core/widgets/sub_page.dart';
import '../../auth/application/app_lock.dart';
import '../../auth/domain/validators.dart';
import '../application/settings_controller.dart';

enum _Step { current, fresh, confirm }

class ChangePinScreen extends StatelessWidget {
  const ChangePinScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const SubPage(title: 'Change PIN', fallbackRoute: AppRoutes.settings, maxWidth: 400, body: _Body());
}

class _Body extends ConsumerStatefulWidget {
  const _Body();

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  _Step _step = _Step.current;
  String _entry = '';
  String _fresh = '';
  String? _error;
  int _wrong = 0;
  bool _busy = false;

  String get _title => switch (_step) {
        _Step.current => 'Enter your current PIN',
        _Step.fresh => 'Choose a new PIN',
        _Step.confirm => 'Confirm your new PIN',
      };

  void _digit(int d) {
    if (_busy || _entry.length >= kPinLength) return;
    setState(() {
      _entry += '$d';
      _error = null;
    });
    if (_entry.length == kPinLength) _complete();
  }

  void _backspace() {
    if (_busy || _entry.isEmpty) return;
    setState(() => _entry = _entry.substring(0, _entry.length - 1));
  }

  Future<void> _complete() async {
    final actions = ref.read(settingsActionsProvider);
    switch (_step) {
      case _Step.current:
        setState(() => _busy = true);
        final ok = await actions.checkCurrentPin(_entry);
        if (!mounted) return;
        if (ok) {
          setState(() {
            _busy = false;
            _entry = '';
            _step = _Step.fresh;
          });
        } else {
          _wrong++;
          setState(() {
            _busy = false;
            _entry = '';
            _error = _wrong >= kMaxPinTries ? 'Too many wrong tries. Try again later.' : 'That PIN is not right.';
          });
          if (_wrong >= kMaxPinTries && mounted) context.pop();
        }
      case _Step.fresh:
        final weak = Validators.weakPin(_entry);
        if (weak != null) {
          setState(() {
            _entry = '';
            _error = weak;
          });
          return;
        }
        setState(() {
          _fresh = _entry;
          _entry = '';
          _step = _Step.confirm;
        });
      case _Step.confirm:
        if (_entry != _fresh) {
          setState(() {
            _error = 'The PINs do not match. Start again.';
            _entry = '';
            _fresh = '';
            _step = _Step.fresh;
          });
          return;
        }
        setState(() => _busy = true);
        try {
          await actions.changePin(_fresh);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your PIN has been changed.')));
          context.pop();
        } catch (e) {
          if (mounted) {
            setState(() {
              _busy = false;
              _entry = '';
              _fresh = '';
              _step = _Step.fresh;
              _error = friendlyError(e);
            });
          }
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageMargin),
      child: Column(
        children: [
          const Spacer(),
          Text(_title, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xxl),
          PinDots(length: kPinLength, filled: _entry.length, error: _error != null),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 40,
            child: _busy
                ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5)))
                : Text(
                    _error ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(color: StatusColors.errorText),
                    textAlign: TextAlign.center,
                  ),
          ),
          const Spacer(),
          PinKeypad(onDigit: _digit, onBackspace: _backspace, enabled: !_busy),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
