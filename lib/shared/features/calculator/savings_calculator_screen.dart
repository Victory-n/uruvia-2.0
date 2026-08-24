import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/individual/finances/events/forms/create_saving_event_form.dart';
import 'package:uruvia/shared/features/calculator/widgets/breakdown_results_card.dart';
import 'package:uruvia/shared/features/calculator/widgets/input_card.dart';
import 'package:uruvia/shared/features/calculator/widgets/pro_insights_card.dart';
import '../../widgets/custom_text.dart';
import 'logic/calculator_isolate.dart';

class SavingsCalculatorScreen extends StatefulWidget {
  final bool isBusiness;
  final bool isPro;

  const SavingsCalculatorScreen({
    super.key,
    this.isBusiness = false,
    this.isPro = false,
  });

  @override
  State<SavingsCalculatorScreen> createState() => _SavingsCalculatorScreenState();
}

typedef SavingsCalculatorPage = SavingsCalculatorScreen;

class _SavingsCalculatorScreenState extends State<SavingsCalculatorScreen> {
  final TextEditingController _incomeController = TextEditingController(text: "300000");
  final TextEditingController _goalNameController = TextEditingController(text: "MacBook Pro");
  final TextEditingController _targetAmountController = TextEditingController(text: "600000");
  int _durationMonths = 6;
  bool _userIsPro = false;

  SavingsCalculationResult? _result;
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _userIsPro = widget.isPro;
    _runCalculation();
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _goalNameController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  Future<void> _runCalculation() async {
    final double income = double.tryParse(_incomeController.text.replaceAll(',', '')) ?? 0.0;
    final double target = double.tryParse(_targetAmountController.text.replaceAll(',', '')) ?? 0.0;

    final input = SavingsCalculationInput(
      income: income,
      targetAmount: target,
      durationMonths: _durationMonths,
      isBusiness: widget.isBusiness,
    );

    setState(() => _isCalculating = true);

    // Offload mathematical calculation to background Isolate (notes.txt rule #2)
    final res = await SavingsCalculatorIsolateService.calculate(input);

    if (mounted) {
      setState(() {
        _result = res;
        _isCalculating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantColor.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: Builder(
          builder: (scaffoldContext) => IconButton(
            icon: const Icon(Icons.menu, color: ConstantColor.headingTextPrimary),
            onPressed: () {
              Scaffold.of(scaffoldContext).openDrawer();
            },
          ),
        ),
        title: googleSansText(
          text: widget.isBusiness ? "Business Savings Calculator" : "Savings & Expense Calculator",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 18.0,
        ),
        actions: [
          IconButton(
            icon: Icon(
              _userIsPro ? Icons.star_rounded : Icons.star_outline_rounded,
              color: _userIsPro ? Colors.amber : ConstantColor.headingTextPrimary,
            ),
            onPressed: () => _showProUpgradeModal(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.isBusiness
                      ? const [Color(0xFF1E3A8A), Color(0xFF0F172A)]
                      : const [ConstantColor.blueBackground, Color(0xFF003C8F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  googleSansText(
                    text: widget.isBusiness ? "Business Capital & Reserve Calculator" : "Savings Micro-Target Calculator",
                    colors: Colors.white,
                    fontWeight: FontWeight.bold,
                    size: 19.0,
                  ),
                  const SizedBox(height: 6.0),
                  googleSansText(
                    text: "Calculate daily, weekly, bi-weekly & monthly savings targets effortlessly.",
                    colors: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.normal,
                    size: 13.0,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),

            // 1. Input Card Widget
            SavingsInputCard(
              incomeController: _incomeController,
              goalNameController: _goalNameController,
              targetAmountController: _targetAmountController,
              durationMonths: _durationMonths,
              isBusiness: widget.isBusiness,
              onDurationChanged: (val) => setState(() => _durationMonths = val),
              onCalculate: _runCalculation,
            ),
            const SizedBox(height: 20.0),

            // 2. Results Breakdown Card Widget
            if (_isCalculating)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(color: ConstantColor.blueBackground),
                ),
              )
            else
              BreakdownResultsCard(
                result: _result,
                onConvertToSavingEvent: () {
                  CreateSavingEventForm.show(context, initialType: 'Target Goal');
                },
              ),
            const SizedBox(height: 20.0),

            // 3. Pro Insights Card Widget (Locked for Free, Unlocked for Pro)
            ProInsightsCard(
              isPro: _userIsPro,
              result: _result,
              onUpgradeTap: () => _showProUpgradeModal(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showProUpgradeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star_rounded, color: Colors.amber, size: 36.0),
            ),
            const SizedBox(height: 16.0),
            googleSansText(
              text: "Upgrade to Individual Pro",
              colors: ConstantColor.headingTextPrimary,
              fontWeight: FontWeight.bold,
              size: 20.0,
            ),
            const SizedBox(height: 8.0),
            googleSansText(
              text: "Unlock impulse expense reduction analysis, AI budget allocations, and custom goal automation.",
              colors: ConstantColor.paragraphTextSecondary,
              fontWeight: FontWeight.normal,
              size: 13.5,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            SizedBox(
              width: double.infinity,
              height: 48.0,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _userIsPro = true);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: googleSansText(
                        text: "Individual Pro Unlocked! (UI Demo Mode)",
                        colors: Colors.white,
                        fontWeight: FontWeight.bold,
                        size: 13.5,
                      ),
                      backgroundColor: Colors.amber.shade900,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ConstantColor.blueBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: googleSansText(
                  text: "Unlock Individual Pro (Demo)",
                  colors: Colors.white,
                  fontWeight: FontWeight.bold,
                  size: 14.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
