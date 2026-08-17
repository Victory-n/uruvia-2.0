import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/widgets/custom_text.dart';

class DimplesMascotCard extends StatefulWidget {
  final VoidCallback? onPreviewHomeScreenWidget;

  const DimplesMascotCard({
    super.key,
    this.onPreviewHomeScreenWidget,
  });

  @override
  State<DimplesMascotCard> createState() => _DimplesMascotCardState();
}

class _DimplesMascotCardState extends State<DimplesMascotCard> {
  int _selectedToneIndex = 0;
  int _currentQuoteIndex = 0;

  final List<String> _tones = [
    "Comedic Marketer",
    "Sassy Coach",
    "Strict Accountant",
  ];

  final Map<int, List<String>> _quotes = {
    0: [
      "Whoa, look at all these sales! 🚀 You're practically a conglomerate now! Time to switch to a Business Account and register your company!",
      "You used 85% of your free savings goals! Upgrade to Individual Pro before I start charging rent for storing your targets! 😉",
      "I smell growth! 📈 High transaction volume detected—Business Pro is calling your name!",
    ],
    1: [
      "Another late-night transfer? Dimples is keeping score... ☕️ Keep your eyes on the monthly budget target!",
      "You hit 80% of your discretionary spending limit! Step away from the checkout button slowly! 🛑",
      "Savings milestone reached! 🎉 Dimples demands a virtual high-five!",
    ],
    2: [
      "Financial Audit Notice: Discretionary expenses increased by 12% this week. Rebalancing required.",
      "Monthly cash flow analysis complete: Recommend allocating ₦20,000 to Emergency Fund.",
      "Account security & budget metrics optimal. All parameters operating within normal ranges.",
    ],
  };

  void _nextQuote() {
    final quotesList = _quotes[_selectedToneIndex] ?? [];
    setState(() {
      _currentQuoteIndex = (_currentQuoteIndex + 1) % quotesList.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuotes = _quotes[_selectedToneIndex] ?? [];
    final quoteText = currentQuotes[_currentQuoteIndex % currentQuotes.length];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: ConstantColor.blueBackground.withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: ConstantColor.blueBackground.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Avatar & Status
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [ConstantColor.blueBackground, Color(0xFF003C8F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14.0),
                  boxShadow: [
                    BoxShadow(
                      color: ConstantColor.blueBackground.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 26.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        googleSansText(
                          text: "Dimples Mascot",
                          colors: ConstantColor.headingTextPrimary,
                          fontWeight: FontWeight.bold,
                          size: 16.0,
                        ),
                        const SizedBox(width: 6.0),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6.0,
                            vertical: 2.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: googleSansText(
                            text: "AI Active",
                            colors: Colors.amber.shade900,
                            fontWeight: FontWeight.bold,
                            size: 10.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2.0),
                    googleSansText(
                      text: "Uruvia Account Intelligence & OS Home Widget Command",
                      colors: ConstantColor.paragraphTextSecondary,
                      fontWeight: FontWeight.w400,
                      size: 12.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),

          // Speech Bubble Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: ConstantColor.lightBackground,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: ConstantColor.blueBackground.withOpacity(0.12),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.format_quote_rounded,
                  color: ConstantColor.blueBackground,
                  size: 20.0,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: googleSansText(
                    text: quoteText,
                    colors: ConstantColor.headingTextPrimary,
                    fontWeight: FontWeight.w500,
                    size: 13.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14.0),

          // Personality Tone Selection Chips
          googleSansText(
            text: "Dimples' Personality Tone:",
            colors: ConstantColor.paragraphTextSecondary,
            fontWeight: FontWeight.w600,
            size: 12.0,
          ),
          const SizedBox(height: 6.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(_tones.length, (index) {
                final isSelected = _selectedToneIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: googleSansText(
                      text: _tones[index],
                      colors: isSelected
                          ? Colors.white
                          : ConstantColor.paragraphTextPrimary,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      size: 12.0,
                    ),
                    selected: isSelected,
                    selectedColor: ConstantColor.blueBackground,
                    backgroundColor: ConstantColor.lightBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedToneIndex = index;
                          _currentQuoteIndex = 0;
                        });
                      }
                    },
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 14.0),

          // Actions Row: Cycle Quote & Home Screen Widget Simulator
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _nextQuote,
                  icon: const Icon(
                    Icons.casino_outlined,
                    size: 16,
                    color: ConstantColor.blueBackground,
                  ),
                  label: googleSansText(
                    text: "Next Banter",
                    colors: ConstantColor.blueBackground,
                    fontWeight: FontWeight.bold,
                    size: 12.5,
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: ConstantColor.blueBackground,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.onPreviewHomeScreenWidget,
                  icon: const Icon(
                    Icons.widgets_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: googleSansText(
                    text: "OS Widget Preview",
                    colors: Colors.white,
                    fontWeight: FontWeight.bold,
                    size: 12.5,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ConstantColor.blueBackground,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
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
