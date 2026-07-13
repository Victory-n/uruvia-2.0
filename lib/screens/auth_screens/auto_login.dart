import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uruvia/screens/auth_screens/login_registration_screens.dart';
import 'package:uruvia/side_bar.dart';
import 'package:uruvia/organizations/organization_onboarding_screen.dart';
import '../../widgets/custom_text.dart';

class AutoLogin extends StatefulWidget {
  const AutoLogin({super.key});

  @override
  State<AutoLogin> createState() => _AutoLoginState();
}

class _AutoLoginState extends State<AutoLogin> {

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        final user = Supabase.instance.client.auth.currentUser;
        final hasOnboarded = user?.userMetadata?['has_onboarded_business'] ?? false;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => hasOnboarded
                ? const SideBarPage(title: "")
                : const OrganizationOnboardingScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginRegistrationScreens()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  height: 200.0,
                  width: 200.0,
                  child: Image.asset("assets/img/authentication.png"),
                ),
              ),
              SizedBox(height: 10.0,),
              googleSansText(text: "...auto login ...please wait!", colors: Colors.black, fontWeight: FontWeight.normal, size: 16.0, textAlign: TextAlign.center, softWrap: true),
              SizedBox(height: 10.0,),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
