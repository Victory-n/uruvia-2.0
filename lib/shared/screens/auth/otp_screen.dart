import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/widgets/app_text.dart';
import '../../../theme/individual/app_theme.dart';
import 'login_screen.dart';

/// Verifies a newly registered user's email with the one-time code
/// Supabase sends after sign up.
class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _otpLength = 6;
  static const int _resendCooldownSeconds = 60;

  // A single invisible field drives the boxes so paste and
  // SMS/email autofill work naturally.
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();

  bool _isVerifying = false;
  bool _isResending = false;
  int _secondsLeft = _resendCooldownSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendCooldownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft <= 1) timer.cancel();
      setState(() => _secondsLeft--);
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: AppText.paragraph(message)),
    );
  }

  Future<void> _handleVerify() async {
    final code = _otpController.text.trim();
    if (code.length != _otpLength) {
      _showMessage('Enter the $_otpLength-digit code sent to your email');
      return;
    }

    setState(() => _isVerifying = true);
    try {
      final client = Supabase.instance.client;
      await client.auth.verifyOTP(
        email: widget.email,
        token: code,
        type: OtpType.signup,
      );

      // Verification signs the user in; send them through the normal
      // login flow instead.
      await client.auth.signOut();
      if (!mounted) return;

      _showMessage('Email verified! Please log in.');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } on AuthException catch (e) {
      if (mounted) {
        _otpController.clear();
        _showMessage(e.message);
      }
    } catch (_) {
      if (mounted) _showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _handleResend() async {
    setState(() => _isResending = true);
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );
      if (!mounted) return;
      _showMessage('A new code has been sent');
      _startCooldown();
    } on AuthException catch (e) {
      if (mounted) _showMessage(e.message);
    } catch (_) {
      if (mounted) _showMessage('Could not resend the code. Try again.');
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Widget _buildCodeBoxes() {
    final code = _otpController.text;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _focusNode.requestFocus(),
      child: Stack(
        children: [
          Row(
            children: List.generate(_otpLength, (i) {
              final isFilled = i < code.length;
              final isActive = _focusNode.hasFocus &&
                  i == (code.length < _otpLength ? code.length : _otpLength - 1);

              return Expanded(
                child: Container(
                  height: 56,
                  margin: EdgeInsets.only(right: i == _otpLength - 1 ? 0 : 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: isActive
                          ? AppTheme.textDark
                          : const Color(0xFFE5E5EA),
                      width: isActive ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    isFilled ? code[i] : '',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              );
            }),
          ),
          // Invisible input sitting on top of the boxes.
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: _otpController,
                focusNode: _focusNode,
                autofocus: true,
                keyboardType: TextInputType.number,
                maxLength: _otpLength,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                showCursor: false,
                enableInteractiveSelection: false,
                decoration: const InputDecoration(counterText: ''),
                onChanged: (value) {
                  setState(() {});
                  if (value.length == _otpLength && !_isVerifying) {
                    _handleVerify();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canResend = _secondsLeft <= 0 && !_isResending;

    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText.title('Verify your email'),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  text: 'Enter the $_otpLength-digit code we sent to ',
                  children: [
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 14,
                  height: 1.4,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 40),
              _buildCodeBoxes(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _handleVerify,
                  child: _isVerifying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const AppText.button('Verify'),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: canResend ? _handleResend : null,
                  child: RichText(
                    text: TextSpan(
                      text: "Didn't get the code? ",
                      style: const TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 14,
                        fontFamily: 'Inter',
                      ),
                      children: [
                        TextSpan(
                          text: canResend
                              ? 'Resend'
                              : _isResending
                                  ? 'Sending...'
                                  : 'Resend in ${_secondsLeft}s',
                          style: TextStyle(
                            color: canResend
                                ? AppTheme.accentBlue
                                : AppTheme.textMuted,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
