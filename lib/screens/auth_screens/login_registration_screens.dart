import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/widgets/custom_text.dart';
import 'package:uruvia/classes/custom_snackbar.dart';
import 'login_page.dart';
import 'registration_page.dart';

class LoginRegistrationScreens extends StatefulWidget {
  const LoginRegistrationScreens({super.key});

  @override
  State<LoginRegistrationScreens> createState() =>
      _LoginRegistrationScreensState();
}

class _LoginRegistrationScreensState extends State<LoginRegistrationScreens> {
  bool _isLoading = false;

  Future<void> _signInWithOAuth(OAuthProvider provider) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        provider,
        redirectTo: 'uruvia://login-callback',
      );
    } on AuthException catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        CustomSnackbar.showFailed(context, error.message);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        CustomSnackbar.showFailed(context, 'An unexpected error occurred');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Color(0xFFF0F5FF), // Soft premium ambient blue tint
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              constraints: BoxConstraints(
                minHeight: size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 20.0),

                  // Logo & Branding
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(13),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          "assets/img/logo.png",
                          height: 60,
                          width: 60,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      interText(
                        text: "Uruvia",
                        colors: ConstantColor.headingTextPrimary,
                        fontWeight: FontWeight.bold,
                        size: 32.0,
                      ),
                      const SizedBox(height: 8.0),
                      googleSansText(
                        text: "Your business command centre",
                        colors: ConstantColor.paragraphTextSecondary,
                        fontWeight: FontWeight.normal,
                        size: 15.0,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40.0),

                  // Actions & Auth Options
                  Column(
                    children: [
                      // Log in button
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () => slideRightWidget(
                                  newPage: const LoginPage(),
                                  context: context,
                                ),
                        style: ButtonStyle(
                          fixedSize: WidgetStateProperty.all(
                            Size(size.width, 50.0),
                          ),
                          backgroundColor: WidgetStateProperty.all(
                            ConstantColor.blueBackground,
                          ),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          elevation: WidgetStateProperty.all(0.0),
                        ),
                        child: interText(
                          text: "Log In",
                          colors: Colors.white,
                          fontWeight: FontWeight.w700,
                          size: 16.0,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 12.0),

                      // Sign up button
                      OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => slideRightWidget(
                                  newPage: const RegistrationPage(),
                                  context: context,
                                ),
                        style: OutlinedButton.styleFrom(
                          fixedSize: Size(size.width, 50.0),
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: ConstantColor.blueBackground.withAlpha(51),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 0.0,
                        ),
                        child: interText(
                          text: "Sign up for free",
                          colors: ConstantColor.blueBackground,
                          fontWeight: FontWeight.w700,
                          size: 16.0,
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 24.0),

                      // Divider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              height: 1.0,
                              color: ConstantColor.paragraphTextSecondary
                                  .withAlpha(38),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: interText(
                              text: "OR CONTINUE WITH",
                              colors: ConstantColor.paragraphTextSecondary
                                  .withAlpha(178),
                              fontWeight: FontWeight.w600,
                              size: 11.0,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1.0,
                              color: ConstantColor.paragraphTextSecondary
                                  .withAlpha(38),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20.0),

                      // Google Sign-In Button
                      OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => _signInWithOAuth(OAuthProvider.google),
                        style: OutlinedButton.styleFrom(
                          fixedSize: Size(size.width, 50.0),
                          side: BorderSide(
                            color: ConstantColor.paragraphTextSecondary
                                .withAlpha(76),
                            width: 1.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 0.0,
                          backgroundColor: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 22.0,
                              height: 22.0,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.blue.shade100,
                                  width: 1.0,
                                ),
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Text(
                                "G",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "googleSans",
                                  fontSize: 13.0,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            interText(
                              text: "Continue with Google",
                              colors: ConstantColor.paragraphTextPrimary,
                              fontWeight: FontWeight.w600,
                              size: 15.0,
                            ),
                          ],
                        ),
                      ),
                      // Apple / iCloud Sign-In Button (iOS only)
                      if (Theme.of(context).platform == TargetPlatform.iOS) ...[
                        const SizedBox(height: 12.0),
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () => _signInWithOAuth(OAuthProvider.apple),
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(size.width, 50.0),
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            elevation: 0.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                CupertinoIcons.app_fill,
                                color: Colors.white,
                                size: 20.0,
                              ),
                              const SizedBox(width: 12.0),
                              interText(
                                text: "Continue with Apple",
                                colors: Colors.white,
                                fontWeight: FontWeight.w600,
                                size: 15.0,
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20.0),

                      // Biometrics/Passkey Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Fingerprint button
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              height: 52.0,
                              width: 52.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: ConstantColor.paragraphTextSecondary
                                      .withAlpha(38),
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(8),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  "assets/svg/fingerprint.svg",
                                  width: 22,
                                  height: 22,
                                  colorFilter: const ColorFilter.mode(
                                    ConstantColor.paragraphTextPrimary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20.0),

                          // Passkey button
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              height: 52.0,
                              width: 52.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: ConstantColor.paragraphTextSecondary
                                      .withAlpha(38),
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(8),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  "assets/svg/passkey.svg",
                                  width: 22,
                                  height: 22,
                                  colorFilter: const ColorFilter.mode(
                                    ConstantColor.paragraphTextPrimary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
