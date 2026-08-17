import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/shared_features/budgeting/logic/budget_optimizer_isolate.dart';
import 'package:uruvia/shared_features/budgeting/models/budget_item.dart';
import 'package:uruvia/shared_features/budgeting/models/budget_optimizer_model.dart';
import 'package:uruvia/widgets/custom_text.dart';

class ProBudgetOptimizerScreen extends StatefulWidget {
  final bool isPro;
  final List<BudgetItem> items;
  final ValueChanged<Map<String, double>>? onApplyOptimization;
  final VoidCallback? onUpgradeTap;

  const ProBudgetOptimizerScreen({
    super.key,
    required this.isPro,
    required this.items,
    this.onApplyOptimization,
    this.onUpgradeTap,
  });

  @override
  State<ProBudgetOptimizerScreen> createState() => _ProBudgetOptimizerScreenState();
}

class _ProBudgetOptimizerScreenState extends State<ProBudgetOptimizerScreen> {
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
  void didUpdateWidget(covariant ProBudgetOptimizerScreen oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: googleSansText(
          text: "Pro Intelligent Optimizer",
          colors: Colors.white,
          fontWeight: FontWeight.bold,
          size: 18.0,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: widget.isPro ? Colors.amber.withOpacity(0.2) : Colors.white10,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: widget.isPro ? Colors.amber.withOpacity(0.6) : Colors.white24,
                  ),
                ),
                child: googleSansText(
                  text: widget.isPro ? "PRO UNLOCKED" : "FREE TIER",
                  colors: widget.isPro ? Colors.amber : Colors.white70,
                  fontWeight: FontWeight.bold,
                  size: 10.0,
                ),
              ),
            ),
          ),
        ],
      ),
      body: widget.isPro ? _buildProContent(context) : _buildTeaserContent(context),
    );
  }

  /// Full-Screen Teaser for Free Users
  Widget _buildTeaserContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const SizedBox(height: 20.0),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amber.withOpacity(0.4), width: 2),
              ),
              child: const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 48.0),
            ),
          ),
          const SizedBox(height: 20.0),
          googleSansText(
            text: "Unlock AI Budget Optimization",
            colors: Colors.white,
            fontWeight: FontWeight.bold,
            size: 22.0,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10.0),
          googleSansText(
            text: "Detect spending leaks, simulate budget tightening scenarios, and reach your savings goals up to 3 months faster.",
            colors: Colors.white70,
            fontWeight: FontWeight.normal,
            size: 14.0,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30.0),

          // Feature Highlights
          _buildFeatureRow(
            icon: Icons.speed_rounded,
            title: "Goal Acceleration Engine",
            description: "Automatically recalculates target goal completion dates when tightening non-essential categories.",
          ),
          const SizedBox(height: 16.0),
          _buildFeatureRow(
            icon: Icons.tune_rounded,
            title: "Interactive Category Sliders",
            description: "Simulate category caps dynamically before locking in new limits.",
          ),
          const SizedBox(height: 16.0),
          _buildFeatureRow(
            icon: Icons.auto_awesome_rounded,
            title: "Background Isolate Math",
            description: "Complex financial scenarios calculate instantly in background isolates without UI stutter.",
          ),
          const SizedBox(height: 40.0),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 50.0,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.0),
                ),
              ),
              onPressed: () {
                if (widget.onUpgradeTap != null) {
                  widget.onUpgradeTap!();
                }
              },
              icon: const Icon(Icons.star_rounded, color: Colors.black, size: 22.0),
              label: googleSansText(
                text: "Upgrade to Individual Pro",
                colors: Colors.black,
                fontWeight: FontWeight.bold,
                size: 15.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow({required IconData icon, required String title, required String description}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.cyanAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(icon, color: Colors.cyanAccent, size: 22.0),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                googleSansText(
                  text: title,
                  colors: Colors.white,
                  fontWeight: FontWeight.bold,
                  size: 14.0,
                ),
                const SizedBox(height: 4.0),
                googleSansText(
                  text: description,
                  colors: Colors.white70,
                  fontWeight: FontWeight.normal,
                  size: 12.5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Full Interactive Screen Content for Pro Users
  Widget _buildProContent(BuildContext context) {
    final res = _scenarioResult;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subtitle
                googleSansText(
                  text: "Simulate budget tightening & goal acceleration in real-time.",
                  colors: Colors.white70,
                  fontWeight: FontWeight.normal,
                  size: 13.0,
                ),
                const SizedBox(height: 16.0),

                // Goal Acceleration Banner
                if (_isCalculating)
                  SizedBox(
                    height: 90,
                    child: Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
                  )
                else if (res != null)
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: res.monthsAccelerated > 0 ? Colors.cyanAccent.withOpacity(0.5) : Colors.white24,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: res.monthsAccelerated > 0
                                ? Colors.cyanAccent.withOpacity(0.2)
                                : Colors.white10,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            res.monthsAccelerated > 0 ? Icons.rocket_launch_rounded : Icons.track_changes_rounded,
                            color: res.monthsAccelerated > 0 ? Colors.cyanAccent : Colors.white70,
                            size: 26.0,
                          ),
                        ),
                        const SizedBox(width: 14.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              googleSansText(
                                text: res.monthsAccelerated > 0
                                    ? "Reach '${res.targetGoalTitle}' ${res.monthsAccelerated} Month${res.monthsAccelerated > 1 ? 's' : ''} Faster!"
                                    : "Target Goal: '${res.targetGoalTitle}'",
                                colors: Colors.white,
                                fontWeight: FontWeight.bold,
                                size: 14.0,
                              ),
                              const SizedBox(height: 4.0),
                              googleSansText(
                                text: "Monthly extra savings generated: ₦${res.totalMonthlySavings.toStringAsFixed(0)}",
                                colors: Colors.cyanAccent,
                                fontWeight: FontWeight.w600,
                                size: 12.5,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24.0),

                // Interactive Sliders Header
                googleSansText(
                  text: "Adjust Category Caps to Simulate Savings",
                  colors: Colors.white,
                  fontWeight: FontWeight.bold,
                  size: 14.0,
                ),
                const SizedBox(height: 4.0),
                googleSansText(
                  text: "Drag sliders to tighten category spending limits and boost savings.",
                  colors: Colors.white60,
                  fontWeight: FontWeight.normal,
                  size: 12.0,
                ),
                const SizedBox(height: 16.0),

                // Category Sliders List
                ...widget.items.map((item) {
                  final currentCap = item.allocatedAmount;
                  final adjustedVal = _adjustedCaps[item.id] ?? currentCap;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(14.0),
                      border: Border.all(color: Colors.white10),
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
                                  Icon(item.icon, color: Colors.white70, size: 18.0),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: googleSansText(
                                      text: item.categoryName,
                                      colors: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      size: 13.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            googleSansText(
                              text: "₦${adjustedVal.toStringAsFixed(0)} (Was ₦${currentCap.toStringAsFixed(0)})",
                              colors: adjustedVal < currentCap ? Colors.cyanAccent : Colors.white70,
                              fontWeight: FontWeight.bold,
                              size: 12.5,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4.0,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                          ),
                          child: Slider(
                            value: adjustedVal,
                            min: currentCap * 0.40,
                            max: currentCap,
                            activeColor: Colors.cyanAccent,
                            inactiveColor: Colors.white24,
                            onChanged: (val) {
                              setState(() {
                                _adjustedCaps[item.id] = val;
                              });
                              _recalculateScenario();
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        // Bottom Sticky Action Button
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 48.0,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                ),
                onPressed: () {
                  if (widget.onApplyOptimization != null) {
                    widget.onApplyOptimization!(_adjustedCaps);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Optimized budget caps applied & synced with Savings Goal!"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check_circle_rounded, color: Colors.black, size: 20.0),
                label: googleSansText(
                  text: "Apply & Lock Optimized Limits",
                  colors: Colors.black,
                  fontWeight: FontWeight.bold,
                  size: 14.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
