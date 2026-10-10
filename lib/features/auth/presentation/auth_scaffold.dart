import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';

/// Shared frame for the screens before the user is inside the app:
/// white background, centred column, optional back arrow, title and subtitle.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.backTo,
    this.footer,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  /// Route to go to when the back arrow is tapped. No arrow when null.
  final String? backTo;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageMargin, vertical: AppSpacing.lg),
              children: [
                if (backTo != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      tooltip: 'Back',
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => context.go(backTo!),
                    ),
                  )
                else
                  const SizedBox(height: AppSpacing.xxl),
                const SizedBox(height: AppSpacing.sm),
                Text(title, style: theme.textTheme.headlineMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(subtitle!, style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.inkSoft)),
                ],
                const SizedBox(height: AppSpacing.xxl),
                ...children,
                if (footer != null) ...[const SizedBox(height: AppSpacing.xxl), footer!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Inline error under a form.
class FormError extends StatelessWidget {
  const FormError(this.message, {super.key});
  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, size: 20, color: StatusColors.errorText),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: StatusColors.errorText),
            ),
          ),
        ],
      ),
    );
  }
}
