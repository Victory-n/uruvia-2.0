import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import '../../../widgets/custom_text.dart';
import '../logic/budget_optimizer_isolate.dart';
import '../models/budget_item.dart';
import '../models/budget_optimizer_model.dart';
import '../pro_budget_optimizer_screen.dart';

class ProBudgetOptimizerCard extends StatefulWidget {
  final bool isPro;
  final List<BudgetItem> items;
  final ValueChanged<Map<String, double>>? onApplyOptimization;
  final VoidCallback? onUpgradeTap;

  const ProBudgetOptimizerCard({
    super.key,
    required this.isPro,
    required this.items,
    this.onApplyOptimization,
    this.onUpgradeTap,
  });

  @override
  State<ProBudgetOptimizerCard> createState() => _ProBudgetOptimizerCardState();
}

class _ProBudgetOptimizerCardState extends State<ProBudgetOptimizerCard> {
  final Map<String, double> _adjustedCaps = {};
  OptimizerScenarioResult? _scenarioResult;
  bool _isCalculating = false;
  final String _targetGoalTitle = "MacBook Pro M3 Fund";
  final double _targetGoalRemaining = 120000.0;

  @override
  void initState() {
    super.initState();
    _initCaps();
    if (widget.isPro) {
      _recalculateScenario();
    }
  }

  @override
  void didUpdateWidget(covariant ProBudgetOptimizerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items || oldWidget.isPro != widget.isPro) {
      _initCaps();
      if (widget.isPro) {
        _recalculateScenario();
      }
    }
  }

  void _initCaps() {
    for (final item in widget.items) {
      if (!_adjustedCaps.containsKey(item.id)) {
        _adjustedCaps[item.id] = item.allocatedAmount;
      }
    }
  }

  Future<void> _recalculateScenario() async {
    setState(() => _isCalculating = true);

    final result = await BudgetOptimizerIsolateService.calculateScenario(
      items: widget.items,
      targetGoalTitle: _targetGoalTitle,
      targetGoalRemaining: _targetGoalRemaining,
      currentMonthlySavingsRate: 30000.0,
      adjustedCaps: _adjustedCaps,
    );

    if (mounted) {
      setState(() {
        _scenarioResult = result;
        _isCalculating = false;
      });
    }
  }

  void _openOptimizerScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProBudgetOptimizerScreen(
          isPro: widget.isPro,
          items: widget.items,
          onApplyOptimization: widget.onApplyOptimization,
          onUpgradeTap: widget.onUpgradeTap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openOptimizerScreen(context),
      child: widget.isPro ? _buildProCardSummary(context) : _buildFreeTeaserCard(context),
    );
  }

  /// Teaser Banner Card for Free Users
  Widget _buildFreeTeaserCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E293B),
            Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 20),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: googleSansText(
                          text: "Pro Intelligent Budget Optimizer",
                          colors: Colors.white,
                          fontWeight: FontWeight.bold,
                          size: 15.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  googleSansText(
                    text: "Detect spending leaks, simulate tightening scenarios, and reach your Savings Goals faster.",
                    colors: Colors.white70,
                    fontWeight: FontWeight.normal,
                    size: 13.0,
                    softWrap: true,
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBlurredStat("Potential Savings", "₦18,500/mo"),
                      _buildBlurredStat("Goal Acceleration", "+2.5 Months"),
                    ],
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
                child: Container(
                  color: Colors.black.withOpacity(0.45),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.lock_rounded, color: Colors.amber, size: 22.0),
                          ),
                          const SizedBox(height: 6.0),
                          googleSansText(
                            text: "PRO EXCLUSIVE FEATURE",
                            colors: Colors.amber,
                            fontWeight: FontWeight.bold,
                            size: 11.0,
                          ),
                          const SizedBox(height: 4.0),
                          googleSansText(
                            text: "Tap to view AI Budget Tightening & Goal Acceleration screen.",
                            colors: Colors.white,
                            fontWeight: FontWeight.bold,
                            size: 12.0,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10.0),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                              minimumSize: const Size(0, 34),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            onPressed: () => _openOptimizerScreen(context),
                            icon: const Icon(Icons.open_in_full_rounded, size: 16.0, color: Colors.black),
                            label: googleSansText(
                              text: "Open Pro Optimizer",
                              colors: Colors.black,
                              fontWeight: FontWeight.bold,
                              size: 12.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlurredStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        googleSansText(text: label, colors: Colors.white60, fontWeight: FontWeight.normal, size: 11.0),
        googleSansText(text: value, colors: Colors.cyanAccent, fontWeight: FontWeight.bold, size: 15.0),
      ],
    );
  }

  /// Sleek Card Summary for Pro Users
  Widget _buildProCardSummary(BuildContext context) {
    final res = _scenarioResult;

    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: ConstantColor.blueBackground.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bolt_rounded, color: Colors.amber, size: 20.0),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          googleSansText(
                            text: "Pro Intelligent Optimizer",
                            colors: Colors.white,
                            fontWeight: FontWeight.bold,
                            size: 15.0,
                          ),
                          googleSansText(
                            text: "Tap to open full optimization screen",
                            colors: Colors.white70,
                            fontWeight: FontWeight.normal,
                            size: 11.5,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.amber.withOpacity(0.5)),
                ),
                child: googleSansText(
                  text: "PRO UNLOCKED",
                  colors: Colors.amber,
                  fontWeight: FontWeight.bold,
                  size: 9.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),

          if (res != null) ...[
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                children: [
                  const Icon(Icons.rocket_launch_rounded, color: Colors.cyanAccent, size: 20.0),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: googleSansText(
                      text: res.monthsAccelerated > 0
                          ? "Accelerating '${res.targetGoalTitle}' by ${res.monthsAccelerated} month(s)"
                          : "Simulating budget scenario for '${res.targetGoalTitle}'",
                      colors: Colors.white,
                      fontWeight: FontWeight.w600,
                      size: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12.0),
          ],

          SizedBox(
            width: double.infinity,
            height: 40.0,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.cyanAccent,
                side: const BorderSide(color: Colors.cyanAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onPressed: () => _openOptimizerScreen(context),
              icon: const Icon(Icons.fullscreen_rounded, size: 18.0),
              label: googleSansText(
                text: "Launch Full Screen Optimizer",
                colors: Colors.cyanAccent,
                fontWeight: FontWeight.bold,
                size: 13.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
