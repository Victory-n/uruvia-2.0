import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/app_card.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.actionLabel, this.onAction});
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
        if (actionLabel != null) TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

/// Small figure card: label, big value, optional note line.
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.label, required this.value, this.note, this.noteColor, this.onTap});
  final String label;
  final Widget value;
  final String? note;
  final Color? noteColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          value,
          if (note != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(note!, style: theme.textTheme.bodySmall?.copyWith(color: noteColor ?? AppColors.inkSoft)),
          ],
        ],
      ),
    );
  }
}

class QuickAction {
  const QuickAction(this.icon, this.label, this.route, {this.push = false});
  final IconData icon;
  final String label;
  final String route;

  /// Open on top of the current screen (forms), so the back arrow returns here.
  final bool push;
}

/// Row of round shortcut buttons.
class QuickActions extends StatelessWidget {
  const QuickActions({super.key, required this.actions});
  final List<QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    return Row(
      children: [
        for (final a in actions)
          Expanded(
            child: Semantics(
              button: true,
              label: a.label,
              excludeSemantics: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.card),
                onTap: () => a.push ? context.push(a.route) : context.go(a.route),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(color: palette.tint, shape: BoxShape.circle),
                        child: Icon(a.icon, color: palette.action),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(a.label, style: theme.textTheme.bodySmall, textAlign: TextAlign.center, maxLines: 2),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Used when a card has nothing to list yet.
class InlineEmpty extends StatelessWidget {
  const InlineEmpty({super.key, required this.icon, required this.title, required this.message, this.actionLabel, this.onAction});
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    return AppCard(
      child: Column(
        children: [
          Icon(icon, size: 32, color: palette.action),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}
