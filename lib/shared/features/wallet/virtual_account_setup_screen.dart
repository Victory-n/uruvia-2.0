import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import '../../widgets/custom_text.dart';
import 'models/wallet_account_type.dart';

class VirtualAccountSetupScreen extends StatefulWidget {
  final WalletAccountType accountType;
  final VoidCallback onSetupComplete;

  const VirtualAccountSetupScreen({
    super.key,
    this.accountType = WalletAccountType.individual,
    required this.onSetupComplete,
  });

  @override
  State<VirtualAccountSetupScreen> createState() => _VirtualAccountSetupScreenState();
}

class _VirtualAccountSetupScreenState extends State<VirtualAccountSetupScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _currentStep = 0;
  bool _isFinished = false;
  Timer? _stepTimer;

  late final List<String> _steps;

  @override
  void initState() {
    super.initState();

    _steps = widget.accountType.isBusiness
        ? const [
            "Initializing business account profile...",
            "Allocating dedicated business account number...",
            "Issuing Business Virtual Debit Card...",
            "Configuring payout & invoicing rules...",
            "Finalizing business virtual account setup...",
          ]
        : const [
            "Initializing virtual account configuration...",
            "Generating dedicated account number...",
            "Issuing Virtual Debit Card...",
            "Securing account credentials...",
            "Finalizing virtual account setup...",
          ];

    // Animation lasts at least 5 seconds
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..forward();

    // Progress through steps evenly over 5 seconds (1 sec per step)
    _stepTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (_currentStep < _steps.length - 1) {
        setState(() {
          _currentStep++;
        });
      } else {
        timer.cancel();
      }
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isFinished = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _stepTimer?.cancel();
    super.dispose();
  }

  void _finishAndReturn() {
    widget.onSetupComplete();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          if (_isFinished)
            IconButton(
              icon: const Icon(Icons.close, color: ConstantColor.headingTextPrimary),
              onPressed: _finishAndReturn,
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _isFinished ? _buildSuccessView() : _buildLoadingView(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    final primaryThemeColor = widget.accountType.isBusiness
        ? Colors.teal.shade800
        : ConstantColor.blueBackground;

    return Column(
      key: const ValueKey("loading_view"),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Circular progress animation container
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return CircularProgressIndicator(
                    value: _animationController.value,
                    strokeWidth: 8.0,
                    backgroundColor: primaryThemeColor.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(primaryThemeColor),
                  );
                },
              ),
            ),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: primaryThemeColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.accountType.isBusiness
                    ? Icons.storefront_rounded
                    : Icons.account_balance_rounded,
                color: primaryThemeColor,
                size: 48,
              ),
            ),
          ],
        ),
        const SizedBox(height: 36.0),

        googleSansText(
          text: widget.accountType.isBusiness
              ? "Setting Up Business Virtual Account"
              : "Setting Up Virtual Account",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 21.0,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12.0),
        googleSansText(
          text: widget.accountType.isBusiness
              ? "Please wait while we create your business account and issue your business debit card..."
              : "Please wait while we create your account and issue your virtual card...",
          colors: ConstantColor.paragraphTextSecondary,
          fontWeight: FontWeight.w400,
          size: 13.5,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 36.0),

        // Steps Progress Indicators
        Column(
          children: List.generate(_steps.length, (index) {
            final isDone = index < _currentStep;
            final isCurrent = index == _currentStep;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isDone
                          ? Colors.green
                          : (isCurrent ? primaryThemeColor : Colors.grey.shade300),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isDone
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : (isCurrent
                              ? const SizedBox(
                                  width: 10,
                                  height: 10,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Container()),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: googleSansText(
                      text: _steps[index],
                      colors: isDone || isCurrent
                          ? ConstantColor.headingTextPrimary
                          : Colors.grey.shade400,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                      size: 13.0,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    final primaryThemeColor = widget.accountType.isBusiness
        ? Colors.teal.shade800
        : ConstantColor.blueBackground;

    return Column(
      key: const ValueKey("success_view"),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: Colors.green,
            size: 72,
          ),
        ),
        const SizedBox(height: 28.0),

        googleSansText(
          text: widget.accountType.isBusiness
              ? "Business Account Ready!"
              : "Virtual Account Ready!",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 23.0,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12.0),
        googleSansText(
          text: widget.accountType.isBusiness
              ? "Your business virtual account and business debit card are active and ready to receive client payouts."
              : "Your virtual account and debit card have been successfully set up and are ready for use.",
          colors: ConstantColor.paragraphTextSecondary,
          fontWeight: FontWeight.w400,
          size: 14.0,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32.0),

        // Summary Card Preview
        Container(
          padding: const EdgeInsets.all(18.0),
          decoration: BoxDecoration(
            color: ConstantColor.lightBackground,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildDetailRow("Bank Name", "Uruvia MFB"),
              const Divider(height: 16),
              _buildDetailRow("Account Number", "8123456789"),
              const Divider(height: 16),
              _buildDetailRow(
                widget.accountType.isBusiness ? "Business Name" : "Account Name",
                widget.accountType.isBusiness ? "Apex Web Studio" : "Alex User",
              ),
              const Divider(height: 16),
              _buildDetailRow(
                "Card Type",
                widget.accountType.isBusiness
                    ? "Business Virtual Debit"
                    : "Personal Virtual Debit",
              ),
            ],
          ),
        ),
        const SizedBox(height: 36.0),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _finishAndReturn,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryThemeColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.0),
              ),
            ),
            child: googleSansText(
              text: "View Virtual Card on Dashboard",
              colors: Colors.white,
              fontWeight: FontWeight.bold,
              size: 16.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        googleSansText(
          text: label,
          colors: ConstantColor.paragraphTextSecondary,
          fontWeight: FontWeight.w500,
          size: 13.0,
        ),
        googleSansText(
          text: value,
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 13.5,
        ),
      ],
    );
  }
}
