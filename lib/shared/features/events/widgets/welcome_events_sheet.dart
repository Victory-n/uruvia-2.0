import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../widgets/app_text.dart';

class WelcomeEventsSheet extends StatelessWidget {
  final VoidCallback? onExplore;

  const WelcomeEventsSheet({super.key, this.onExplore});

  static Future<void> show(BuildContext context, {VoidCallback? onExplore}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WelcomeEventsSheet(
        onExplore: () {
          Navigator.pop(context);
          onExplore?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F1FC),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.champagneGlasses,
                    color: Color(0xFF0066DB),
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.subtitle(
                      'Welcome to Events',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 3),
                    AppText.paragraph(
                      'Organize & track your financial milestones',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFFE2E8F0), thickness: 1, height: 1),
          const SizedBox(height: 16),

          // Event type rows
          _buildFeatureItem(
            icon: FontAwesomeIcons.piggyBank,
            iconColor: const Color(0xFF388E3C),
            iconBgColor: const Color(0xFFEAF8ED),
            title: 'Saving Events',
            description:
                'Set targeted goals with timeline progress and personal milestones.',
          ),
          const SizedBox(height: 14),
          _buildFeatureItem(
            icon: FontAwesomeIcons.bullseye,
            iconColor: const Color(0xFFD97706),
            iconBgColor: const Color(0xFFFFF4E5),
            title: 'Expense Tracking Events',
            description:
                'Track trip budgets, wedding costs, or specific project expenses.',
          ),
          const SizedBox(height: 14),
          _buildFeatureItem(
            icon: FontAwesomeIcons.userGroup,
            iconColor: const Color(0xFF9333EA),
            iconBgColor: const Color(0xFFF6EEFA),
            title: 'Group Savings',
            description:
                'Pool funds collaboratively with friends, team, or family members.',
          ),
          const SizedBox(height: 14),
          _buildFeatureItem(
            icon: FontAwesomeIcons.buildingColumns,
            iconColor: const Color(0xFF2563EB),
            iconBgColor: const Color(0xFFEBF3FC),
            title: 'Budget Planning',
            description:
                'Plan monthly budget allocations and automated spending limits.',
          ),
          const SizedBox(height: 14),
          _buildFeatureItem(
            icon: FontAwesomeIcons.wandMagicSparkles,
            iconColor: const Color(0xFF0D9488),
            iconBgColor: const Color(0xFFE6F7F5),
            title: 'And Many More!',
            description:
                'Custom tailor financial events to suit any personal scenario.',
          ),

          const SizedBox(height: 24),

          // Explore Events Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onExplore ?? () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0060E6),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const AppText.button(
                'Explore Events',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required FaIconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: FaIcon(icon, color: iconColor, size: 20)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.custom(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2.5),
              AppText.paragraph(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
