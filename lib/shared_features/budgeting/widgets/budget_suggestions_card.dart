import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/widgets/custom_text.dart';

class BudgetSuggestionsCard extends StatelessWidget {
  final List<Map<String, dynamic>> suggestions;
  final Function(Map<String, dynamic>)? onActionTap;

  const BudgetSuggestionsCard({
    super.key,
    required this.suggestions,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    final topSuggestion = suggestions.first;
    final title = topSuggestion['title'] ?? 'Smart Budget Tip';
    final desc = topSuggestion['description'] ?? '';
    final actionText = topSuggestion['actionText'] ?? 'View Suggestion';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ConstantColor.blueBackground.withOpacity(0.08),
            Colors.blue.shade50.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: ConstantColor.blueBackground.withOpacity(0.2),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: ConstantColor.blueBackground.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: ConstantColor.blueBackground,
                  size: 16.0,
                ),
              ),
              const SizedBox(width: 8.0),
              googleSansText(
                text: title,
                colors: ConstantColor.blueBackground,
                fontWeight: FontWeight.bold,
                size: 14.0,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: ConstantColor.blueBackground.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: googleSansText(
                  text: "${suggestions.length} Suggestion${suggestions.length > 1 ? 's' : ''}",
                  colors: ConstantColor.blueBackground,
                  fontWeight: FontWeight.w600,
                  size: 10.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          googleSansText(
            text: desc,
            colors: ConstantColor.paragraphTextPrimary,
            fontWeight: FontWeight.normal,
            size: 12.5,
          ),
          const SizedBox(height: 12.0),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: ConstantColor.blueBackground,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                if (onActionTap != null) {
                  onActionTap!(topSuggestion);
                }
              },
              icon: const Icon(Icons.bolt_rounded, size: 14.0, color: Colors.white),
              label: googleSansText(
                text: actionText,
                colors: Colors.white,
                fontWeight: FontWeight.bold,
                size: 12.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
