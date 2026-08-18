import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/shared_features/calculator/logic/calculator_isolate.dart';
import 'package:uruvia/widgets/custom_text.dart';

class ProInsightsCard extends StatelessWidget {
  final bool isPro;
  final SavingsCalculationResult? result;
  final VoidCallback? onUpgradeTap;

  const ProInsightsCard({
    super.key,
    this.isPro = false,
    required this.result,
    this.onUpgradeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isPro ? Colors.amber.shade400 : const Color(0xFFEEEEEE),
          width: isPro ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.amber,
                              size: 20.0,
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          googleSansText(
                            text: "Advanced Pro Insights",
                            colors: ConstantColor.headingTextPrimary,
                            fontWeight: FontWeight.bold,
                            size: 16.0,
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                        decoration: BoxDecoration(
                          color: isPro ? Colors.amber.withOpacity(0.2) : Colors.grey.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: googleSansText(
                          text: isPro ? "UNLOCKED" : "PRO FEATURE",
                          colors: isPro ? Colors.amber.shade900 : ConstantColor.paragraphTextSecondary,
                          fontWeight: FontWeight.bold,
                          size: 10.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // Impulse Cut Down Section
                  googleSansText(
                    text: "✂️ Expense Cut-Down Recommendations",
                    colors: ConstantColor.headingTextPrimary,
                    fontWeight: FontWeight.bold,
                    size: 13.5,
                  ),
                  const SizedBox(height: 8.0),
                  Column(
                    children: (result?.impulseCutDownSuggestions ?? const [
                      "Reduce dining out & delivery by ₦15,000/mo",
                      "Pause unstreamed entertainment subscriptions",
                    ]).map((sug) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: Colors.green, size: 16.0),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: googleSansText(
                                text: sug,
                                colors: ConstantColor.paragraphTextPrimary,
                                fontWeight: FontWeight.w500,
                                size: 12.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16.0),

                  // Smart Budget Allocation Section
                  googleSansText(
                    text: "📊 Smart Budget Allocation Rule",
                    colors: ConstantColor.headingTextPrimary,
                    fontWeight: FontWeight.bold,
                    size: 13.5,
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFC),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        _BudgetPill(label: "Needs", percentage: "50%"),
                        _BudgetPill(label: "Wants", percentage: "30%"),
                        _BudgetPill(label: "Goal", percentage: "20%"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Locked Overlay (When isPro == false)
            if (!isPro)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: ConstantColor.blueBackground.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_outline_rounded,
                            color: ConstantColor.blueBackground,
                            size: 28.0,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        googleSansText(
                          text: "Unlock Advanced Calculator Insights",
                          colors: ConstantColor.headingTextPrimary,
                          fontWeight: FontWeight.bold,
                          size: 15.0,
                        ),
                        const SizedBox(height: 4.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: googleSansText(
                            text: "Discover impulse spending cut-downs & AI budget allocation.",
                            colors: ConstantColor.paragraphTextSecondary,
                            fontWeight: FontWeight.normal,
                            size: 12.0,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 14.0),
                        ElevatedButton(
                          onPressed: onUpgradeTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ConstantColor.blueBackground,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            elevation: 0.0,
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                          ),
                          child: googleSansText(
                            text: "Upgrade to Individual Pro",
                            colors: Colors.white,
                            fontWeight: FontWeight.bold,
                            size: 13.0,
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
    );
  }
}

class _BudgetPill extends StatelessWidget {
  final String label;
  final String percentage;

  const _BudgetPill({
    required this.label,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        googleSansText(
          text: percentage,
          colors: ConstantColor.blueBackground,
          fontWeight: FontWeight.bold,
          size: 15.0,
        ),
        const SizedBox(height: 2.0),
        googleSansText(
          text: label,
          colors: ConstantColor.paragraphTextSecondary,
          fontWeight: FontWeight.w500,
          size: 11.5,
        ),
      ],
    );
  }
}
