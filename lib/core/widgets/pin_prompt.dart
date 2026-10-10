import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';
import '../../app/theme/tokens.dart';
import '../errors/friendly_error.dart';
import 'app_sheet.dart';
import 'pin_keypad.dart';

/// Asks for the PIN in a bottom sheet. [verify] returns true when the PIN is right.
/// [onBiometric], when given, shows a fingerprint key and returns true when it succeeds.
/// Resolves to true once the user is verified, otherwise null.
Future<bool?> showPinPrompt(
  BuildContext context, {
  required String title,
  String? message,
  required Future<bool> Function(String pin) verify,
  Future<bool> Function()? onBiometric,
  int length = 4,
}) {
  return showAppSheet<bool>(
    context,
    title: title,
    builder: (_) => _PinPromptBody(message: message, verify: verify, onBiometric: onBiometric, length: length),
  );
}

class _PinPromptBody extends StatefulWidget {
  const _PinPromptBody({this.message, required this.verify, this.onBiometric, required this.length});
  final String? message;
  final Future<bool> Function(String pin) verify;
  final Future<bool> Function()? onBiometric;
  final int length;

  @override
  State<_PinPromptBody> createState() => _PinPromptBodyState();
}

class _PinPromptBodyState extends State<_PinPromptBody> {
  String _entry = '';
  String? _error;
  bool _busy = false;

  Future<void> _digit(int d) async {
    if (_busy || _entry.length >= widget.length) return;
    setState(() {
      _entry += '$d';
      _error = null;
    });
    if (_entry.length < widget.length) return;

    setState(() => _busy = true);
    try {
      final ok = await widget.verify(_entry);
      if (!mounted) return;
      if (ok) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _entry = '';
          _busy = false;
          _error = 'Wrong PIN. Try again.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _entry = '';
        _busy = false;
        _error = friendlyError(e);
      });
    }
  }

  Future<void> _biometric() async {
    final check = widget.onBiometric;
    if (check == null || _busy) return;
    if (await check() && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        if (widget.message != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Text(widget.message!, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft)),
          ),
        Center(child: PinDots(length: widget.length, filled: _entry.length, error: _error != null)),
        SizedBox(
          height: 32,
          child: Center(
            child: Text(_error ?? '', style: theme.textTheme.bodyMedium?.copyWith(color: StatusColors.errorText)),
          ),
        ),
        PinKeypad(
          onDigit: _digit,
          onBackspace: () {
            if (_entry.isNotEmpty && !_busy) setState(() => _entry = _entry.substring(0, _entry.length - 1));
          },
          onBiometric: widget.onBiometric == null ? null : _biometric,
          enabled: !_busy,
        ),
      ],
    );
  }
}
