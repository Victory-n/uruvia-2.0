import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/screens/auth_screens/login_registration_screens.dart';
import 'package:uruvia/widgets/custom_text.dart';

class DeleteAccountProgressPage extends StatefulWidget {
  const DeleteAccountProgressPage({super.key});

  @override
  State<DeleteAccountProgressPage> createState() =>
      _DeleteAccountProgressPageState();
}

class _DeleteAccountProgressPageState extends State<DeleteAccountProgressPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isCompleted = false;
  String _statusMessage = "Initializing account deletion...";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    )..addListener(() {
        setState(() {
          double val = _animation.value;
          if (val < 0.3) {
            _statusMessage = "Initializing account deletion...";
          } else if (val < 0.6) {
            _statusMessage = "Removing user preferences & workspace data...";
          } else if (val < 0.9) {
            _statusMessage = "Scheduling permanent data cleanup...";
          } else {
            _statusMessage = "Finalizing process...";
          }
        });
      })..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _onDeletionComplete();
        }
      });

    _controller.forward();
  }

  Future<void> _onDeletionComplete() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {
      // Ignore if already signed out or offline
    }

    if (mounted) {
      setState(() {
        _isCompleted = true;
      });
    }
  }

  void _navigateToLogin() {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginRegistrationScreens(),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent going back during deletion flow
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFC),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Center(
              child: _isCompleted
                  ? _buildCompletionView()
                  : _buildProgressView(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressView() {
    final double percentage = (_animation.value * 100);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80.0,
          height: 80.0,
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFFCDD2), width: 1.5),
          ),
          child: const Icon(
            CupertinoIcons.trash,
            size: 36.0,
            color: Color(0xFFC62828),
          ),
        ),
        const SizedBox(height: 28.0),
        googleSansText(
          text: "Deleting Account",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 22.0,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10.0),
        googleSansText(
          text: _statusMessage,
          colors: ConstantColor.paragraphTextSecondary,
          fontWeight: FontWeight.normal,
          size: 14.0,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 36.0),

        // Animated Progress Bar Container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0xFFEEEEEE)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  googleSansText(
                    text: "Progress",
                    colors: ConstantColor.paragraphTextPrimary,
                    fontWeight: FontWeight.w600,
                    size: 14.0,
                  ),
                  googleSansText(
                    text: "${percentage.toInt()}%",
                    colors: const Color(0xFFC62828),
                    fontWeight: FontWeight.bold,
                    size: 14.0,
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: LinearProgressIndicator(
                  value: _animation.value,
                  minHeight: 10.0,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFC62828),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 84.0,
          height: 84.0,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFA5D6A7), width: 1.5),
          ),
          child: const Icon(
            CupertinoIcons.checkmark_seal_fill,
            size: 42.0,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 24.0),
        googleSansText(
          text: "Account Deleted",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 24.0,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16.0),
        Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0xFFEEEEEE)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              googleSansText(
                text:
                    "Your account has been deleted successfully. Your information will be completely removed within 30 days.",
                colors: ConstantColor.paragraphTextPrimary,
                fontWeight: FontWeight.normal,
                size: 14.5,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.clock,
                    size: 15.0,
                    color: ConstantColor.paragraphTextSecondary,
                  ),
                  const SizedBox(width: 6.0),
                  googleSansText(
                    text: "30-day graceful deletion window",
                    colors: ConstantColor.paragraphTextSecondary,
                    fontWeight: FontWeight.w600,
                    size: 12.5,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32.0),
        SizedBox(
          width: double.infinity,
          height: 50.0,
          child: ElevatedButton(
            onPressed: _navigateToLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: ConstantColor.blueBackground,
              elevation: 0.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: googleSansText(
              text: "Back to Login",
              colors: Colors.white,
              fontWeight: FontWeight.bold,
              size: 15.0,
            ),
          ),
        ),
      ],
    );
  }
}
