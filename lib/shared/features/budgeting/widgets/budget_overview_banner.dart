import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/services/currency_service.dart';
import '../../../widgets/custom_text.dart';

class BudgetOverviewBanner extends StatelessWidget {
  final String cycleDisplayName;
  final int remainingDays;
  final double totalSpent;
  final double totalAllocated;
  final double dailySafeSpend;
  final double unallocatedIncome;
  final bool isLoading;

  const BudgetOverviewBanner({
    super.key,
    required this.cycleDisplayName,
    required this.remainingDays,
    required this.totalSpent,
    required this.totalAllocated,
    required this.dailySafeSpend,
    required this.unallocatedIncome,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final symbol = CurrencyService.instance.activeSymbol;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Color(0xFF003C8F),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: ConstantColor.blueBackground.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Cycle Title & Days Left Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              googleSansText(
                text: "$cycleDisplayName Budget Summary",
                colors: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w600,
                size: 13.0,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 3.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: googleSansText(
                  text: "$remainingDays Days Left",
                  colors: Colors.white,
                  fontWeight: FontWeight.bold,
                  size: 10.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),

          // Main Stat: Spent / Allocated
          googleSansText(
            text: isLoading
                ? "Calculating..."
                : "$symbol${totalSpent.toStringAsFixed(0)} / $symbol${totalAllocated.toStringAsFixed(0)}",
            colors: Colors.white,
            fontWeight: FontWeight.bold,
            size: 24.0,
          ),
          const SizedBox(height: 16.0),

          // Safe Spend & Unbudgeted Income Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      googleSansText(
                        text: "Safe Daily Velocity",
                        colors: Colors.white70,
                        size: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                      const SizedBox(height: 2.0),
                      googleSansText(
                        text: isLoading
                            ? "..."
                            : "$symbol${dailySafeSpend.toStringAsFixed(0)} / day",
                        colors: Colors.white,
                        fontWeight: FontWeight.bold,
                        size: 13.0,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      googleSansText(
                        text: "Unbudgeted Income",
                        colors: Colors.white70,
                        size: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                      const SizedBox(height: 2.0),
                      googleSansText(
                        text: isLoading
                            ? "..."
                            : "$symbol${unallocatedIncome.toStringAsFixed(0)}",
                        colors: Colors.amberAccent,
                        fontWeight: FontWeight.bold,
                        size: 13.0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
