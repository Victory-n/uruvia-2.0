import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import '../../../shared/widgets/custom_text.dart';

class EventsIntroModal extends StatelessWidget {
  const EventsIntroModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EventsIntroModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 32.0),
      // mainAxisSize: MainAxisSize.min,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40.0,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          const SizedBox(height: 20.0),

          // Header Badge & Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: ConstantColor.blueBackground.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.celebration_outlined,
                  color: ConstantColor.blueBackground,
                  size: 26.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    googleSansText(
                      text: "Welcome to Events",
                      colors: ConstantColor.headingTextPrimary,
                      fontWeight: FontWeight.bold,
                      size: 20.0,
                    ),
                    const SizedBox(height: 2.0),
                    googleSansText(
                      text: "Organize & track your financial milestones",
                      colors: ConstantColor.paragraphTextSecondary,
                      fontWeight: FontWeight.normal,
                      size: 13.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          const Divider(height: 1.0),
          const SizedBox(height: 20.0),

          // Features Breakdown List
          const _EventFeatureItem(
            icon: Icons.savings_outlined,
            color: Colors.green,
            title: "Saving Events",
            description:
                "Set targeted goals with timeline progress and personal milestones.",
          ),
          const SizedBox(height: 16.0),
          const _EventFeatureItem(
            icon: Icons.track_changes_outlined,
            color: Colors.orange,
            title: "Expense Tracking Events",
            description:
                "Track trip budgets, wedding costs, or specific project expenses.",
          ),
          const SizedBox(height: 16.0),
          const _EventFeatureItem(
            icon: Icons.groups_outlined,
            color: Colors.purple,
            title: "Group Savings",
            description:
                "Pool funds collaboratively with friends, team, or family members.",
          ),
          const SizedBox(height: 16.0),
          const _EventFeatureItem(
            icon: Icons.account_balance_outlined,
            color: ConstantColor.blueBackground,
            title: "Budget Planning",
            description:
                "Plan monthly budget allocations and automated spending limits.",
          ),
          const SizedBox(height: 16.0),
          const _EventFeatureItem(
            icon: Icons.auto_awesome_outlined,
            color: Colors.teal,
            title: "And Many More!",
            description:
                "Custom tailor financial events to suit any personal scenario.",
          ),

          const SizedBox(height: 28.0),

          // Get Started Button
          SizedBox(
            width: double.infinity,
            height: 50.0,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: ConstantColor.blueBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.0),
                ),
                elevation: 0.0,
              ),
              child: googleSansText(
                text: "Explore Events",
                colors: Colors.white,
                fontWeight: FontWeight.bold,
                size: 15.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventFeatureItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const _EventFeatureItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Icon(icon, color: color, size: 20.0),
        ),
        const SizedBox(width: 14.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              googleSansText(
                text: title,
                colors: ConstantColor.headingTextPrimary,
                fontWeight: FontWeight.bold,
                size: 14.5,
              ),
              const SizedBox(height: 3.0),
              googleSansText(
                text: description,
                colors: ConstantColor.paragraphTextSecondary,
                fontWeight: FontWeight.normal,
                size: 12.5,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
