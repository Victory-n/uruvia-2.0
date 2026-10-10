import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_palette.dart';
import '../../app/theme/tokens.dart';
import 'app_button.dart';
import 'skeleton.dart';

/// Shown when a list or screen has nothing to show yet.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(color: palette.tint, shape: BoxShape.circle),
              child: Icon(icon, size: 32, color: palette.action),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              AppButton(label: actionLabel!, onPressed: onAction, expand: false),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shown when loading failed. Always offers Retry when [onRetry] is given.
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, this.title = 'Something went wrong', this.message, this.onRetry});

  final String title;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(color: AppColors.errorBg, shape: BoxShape.circle),
              child: const Icon(Icons.error_outline_rounded, size: 32, color: StatusColors.error),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                label: 'Retry',
                onPressed: onRetry,
                style: AppButtonStyle.secondary,
                icon: Icons.refresh_rounded,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Slim banner for when the phone has no network: data shown is the last saved copy.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, this.message = 'You are offline. Showing the last saved data.'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        color: AppColors.warningBg,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageMargin, vertical: AppSpacing.sm),
        child: Row(
          children: [
            const Icon(Icons.wifi_off_rounded, size: 18, color: StatusColors.warningText),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: StatusColors.warningText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Turns a Riverpod [AsyncValue] into the right screen state:
/// skeleton while loading, error with Retry, empty state, or the data.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.isEmpty,
    this.empty,
    this.onRetry,
    this.errorMessage = 'We could not load this. Check your connection and try again.',
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget? loading;
  final bool Function(T data)? isEmpty;
  final Widget? empty;
  final VoidCallback? onRetry;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (v) => (empty != null && (isEmpty?.call(v) ?? false)) ? empty! : data(v),
      loading: () => loading ?? const ListSkeleton(),
      error: (_, __) => ErrorState(message: errorMessage, onRetry: onRetry),
    );
  }
}
