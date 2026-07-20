import 'dart:async';
import 'package:flutter/material.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/screens/auth_screens/login_page.dart';
import 'package:uruvia/widgets/custom_text.dart';
import 'package:uruvia/classes/custom_snackbar.dart';

class OtpVerifyPage extends StatefulWidget {
  final String email;

  const OtpVerifyPage({super.key, required this.email});

  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;

  // Resend Timer properties
  int _resendCountdown = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    // Request focus on keyboard load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendCountdown = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown == 0) {
        setState(() {
          _canResend = true;
        });
        _timer?.cancel();
      } else {
        setState(() {
          _resendCountdown--;
        });
      }
    });
  }

  Future<void> _resendCode() async {
    if (!_canResend || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );
      if (mounted) {
        CustomSnackbar.showSuccess(
          context,
          'Verification code resent successfully',
        );
        _startResendTimer();
      }
    } on AuthException catch (error) {
      if (mounted) {
        CustomSnackbar.showFailed(context, error.message);
      }
    } catch (error) {
      if (mounted) {
        CustomSnackbar.showFailed(context, 'An unexpected error occurred');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyOtp() async {
    final code = _otpController.text.trim();
    if (code.length < 6) {
      CustomSnackbar.showFailed(context, 'Please enter the full 6-digit code');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.signup,
        token: code,
        email: widget.email,
      );

      if (mounted) {
        CustomSnackbar.showSuccess(
          context,
          'Email verified successfully! Please log in.',
        );
        // Navigate to login page and clear navigation stack
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        CustomSnackbar.showFailed(context, error.message);
      }
    } catch (error) {
      if (mounted) {
        CustomSnackbar.showFailed(
          context,
          'An unexpected error occurred during verification',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24.0),
              Image.asset("assets/img/logo.png", height: 70, width: 70),
              const SizedBox(height: 24.0),
              interText(
                text: "Verify Your Email",
                colors: ConstantColor.headingTextPrimary,
                fontWeight: FontWeight.bold,
                size: 26.0,
              ),
              const SizedBox(height: 12.0),
              googleSansText(
                text: "We have sent a 6-digit verification code to",
                colors: ConstantColor.paragraphTextSecondary,
                fontWeight: FontWeight.normal,
                size: 15.0,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4.0),
              googleSansText(
                text: widget.email,
                colors: ConstantColor.blueBackground,
                fontWeight: FontWeight.bold,
                size: 15.0,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40.0),

              // Custom Stack OTP input
              GestureDetector(
                onTap: () => _focusNode.requestFocus(),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Invisible TextFormField to capture input
                    Opacity(
                      opacity: 0.0,
                      child: SizedBox(
                        height: 60,
                        child: TextFormField(
                          controller: _otpController,
                          focusNode: _focusNode,
                          maxLength: 6,
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          onChanged: (val) {
                            setState(() {});
                            if (val.length == 6) {
                              _verifyOtp();
                            }
                          },
                          decoration: const InputDecoration(
                            counterText: "",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    // Row of styled digits
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        final text = _otpController.text;
                        String char = "";
                        if (text.length > index) {
                          char = text[index];
                        }

                        final isFocused =
                            _focusNode.hasFocus &&
                            (text.length == index ||
                                (text.length == 6 && index == 5));

                        return Container(
                          width: 48,
                          height: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: ConstantColor.lightBackground,
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: isFocused
                                  ? ConstantColor.blueBackground
                                  : ConstantColor.paragraphTextSecondary
                                        .withAlpha(76),
                              width: isFocused ? 2.0 : 1.0,
                            ),
                            boxShadow: isFocused
                                ? [
                                    BoxShadow(
                                      color: ConstantColor.blueBackground
                                          .withAlpha(26),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            char,
                            style: const TextStyle(
                              fontFamily: "Inter",
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                              color: ConstantColor.headingTextPrimary,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32.0),

              // Verify Button
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                style: ButtonStyle(
                  fixedSize: WidgetStateProperty.all(
                    Size(MediaQuery.of(context).size.width, 50.0),
                  ),
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.disabled)) {
                      return ConstantColor.blueBackground.withAlpha(153);
                    }
                    return ConstantColor.blueBackground;
                  }),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  elevation: WidgetStateProperty.all(0.0),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24.0,
                        width: 24.0,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : interText(
                        text: "Verify Account",
                        colors: Colors.white,
                        fontWeight: FontWeight.w700,
                        size: 16.0,
                        textAlign: TextAlign.center,
                      ),
              ),
              const SizedBox(height: 24.0),

              // Resend code timer or trigger
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  interText(
                    text: "Didn't receive the code? ",
                    colors: ConstantColor.paragraphTextSecondary,
                    fontWeight: FontWeight.normal,
                    size: 14.0,
                  ),
                  GestureDetector(
                    onTap: _canResend && !_isLoading ? _resendCode : null,
                    child: interText(
                      text: _canResend
                          ? "Resend"
                          : "Resend in ${_resendCountdown}s",
                      colors: _canResend
                          ? ConstantColor.blueBackground
                          : ConstantColor.paragraphTextSecondary,
                      fontWeight: FontWeight.bold,
                      size: 14.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }
}
