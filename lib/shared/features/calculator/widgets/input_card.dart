import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/services/currency_service.dart';
import '../../../widgets/custom_text.dart';

class SavingsInputCard extends StatelessWidget {
  final TextEditingController incomeController;
  final TextEditingController goalNameController;
  final TextEditingController targetAmountController;
  final int durationMonths;
  final ValueChanged<int> onDurationChanged;
  final VoidCallback onCalculate;
  final bool isBusiness;

  const SavingsInputCard({
    super.key,
    required this.incomeController,
    required this.goalNameController,
    required this.targetAmountController,
    required this.durationMonths,
    required this.onDurationChanged,
    required this.onCalculate,
    this.isBusiness = false,
  });

  @override
  Widget build(BuildContext context) {
    final symbol = CurrencyService.instance.activeSymbol;
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: ConstantColor.blueBackground.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Icon(
                  Icons.calculate_outlined,
                  color: ConstantColor.blueBackground,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 10.0),
              googleSansText(
                text: isBusiness ? "Business Target Inputs" : "Personal Goal Inputs",
                colors: ConstantColor.headingTextPrimary,
                fontWeight: FontWeight.bold,
                size: 16.0,
              ),
            ],
          ),
          const SizedBox(height: 18.0),

          // Monthly Income / Revenue Input
          googleSansText(
            text: isBusiness ? "Monthly Business Revenue ($symbol)" : "Monthly Income / Salary ($symbol)",
            colors: ConstantColor.headingTextPrimary,
            fontWeight: FontWeight.bold,
            size: 13.0,
          ),
          const SizedBox(height: 6.0),
          TextField(
            controller: incomeController,
            keyboardType: TextInputType.number,
            onChanged: (_) => onCalculate(),
            decoration: InputDecoration(
              hintText: isBusiness ? "e.g. 1,500,000" : "e.g. 300,000",
              hintStyle: TextStyle(
                fontFamily: "googleSans",
                fontSize: 13.5,
                color: ConstantColor.paragraphTextSecondary.withOpacity(0.6),
              ),
              prefixIcon: const Icon(Icons.account_balance_wallet_outlined, size: 18.0),
              filled: true,
              fillColor: const Color(0xFFF9FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: ConstantColor.blueBackground, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            ),
          ),
          const SizedBox(height: 14.0),

          // Goal Item Name Input
          googleSansText(
            text: isBusiness ? "Equipment / Goal Name" : "Item / Goal Name",
            colors: ConstantColor.headingTextPrimary,
            fontWeight: FontWeight.bold,
            size: 13.0,
          ),
          const SizedBox(height: 6.0),
          TextField(
            controller: goalNameController,
            onChanged: (_) => onCalculate(),
            decoration: InputDecoration(
              hintText: isBusiness ? "e.g. Server Upgrade" : "e.g. MacBook Pro",
              hintStyle: TextStyle(
                fontFamily: "googleSans",
                fontSize: 13.5,
                color: ConstantColor.paragraphTextSecondary.withOpacity(0.6),
              ),
              prefixIcon: const Icon(Icons.shopping_bag_outlined, size: 18.0),
              filled: true,
              fillColor: const Color(0xFFF9FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: ConstantColor.blueBackground, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            ),
          ),
          const SizedBox(height: 14.0),

          // Target Amount Input
          googleSansText(
            text: "Target Amount ($symbol)",
            colors: ConstantColor.headingTextPrimary,
            fontWeight: FontWeight.bold,
            size: 13.0,
          ),
          const SizedBox(height: 6.0),
          TextField(
            controller: targetAmountController,
            keyboardType: TextInputType.number,
            onChanged: (_) => onCalculate(),
            decoration: InputDecoration(
              hintText: "e.g. 600,000",
              hintStyle: TextStyle(
                fontFamily: "googleSans",
                fontSize: 13.5,
                color: ConstantColor.paragraphTextSecondary.withOpacity(0.6),
              ),
              prefixIcon: const Icon(Icons.savings_outlined, size: 18.0),
              filled: true,
              fillColor: const Color(0xFFF9FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: ConstantColor.blueBackground, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            ),
          ),
          const SizedBox(height: 16.0),

          // Duration Slider / Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              googleSansText(
                text: "Target Duration",
                colors: ConstantColor.headingTextPrimary,
                fontWeight: FontWeight.bold,
                size: 13.0,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: ConstantColor.blueBackground.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: googleSansText(
                  text: "$durationMonths Months",
                  colors: ConstantColor.blueBackground,
                  fontWeight: FontWeight.bold,
                  size: 12.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: ConstantColor.blueBackground,
              inactiveTrackColor: const Color(0xFFE0E0E0),
              thumbColor: ConstantColor.blueBackground,
              overlayColor: ConstantColor.blueBackground.withOpacity(0.12),
              trackHeight: 4.0,
            ),
            child: Slider(
              value: durationMonths.toDouble(),
              min: 1,
              max: 24,
              divisions: 23,
              onChanged: (val) {
                onDurationChanged(val.round());
                onCalculate();
              },
            ),
          ),
        ],
      ),
    );
  }
}
