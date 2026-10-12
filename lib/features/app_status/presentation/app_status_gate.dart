import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/utils/open_link.dart';
import '../../../core/widgets/app_button.dart';
import '../data/app_status_provider.dart';
import '../domain/app_status.dart';

/// Shows a full-screen notice when the app is in maintenance or too old. Otherwise shows [child].
class AppStatusGate extends ConsumerWidget {
  const AppStatusGate({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(appStatusProvider).valueOrNull ?? AppStatus.open;
    switch (status.gate) {
      case AppGate.open:
        return child;
      case AppGate.maintenance:
        return _Notice(
          icon: Icons.build_circle_outlined,
          title: 'We are making Uruvia better',
          message: status.message ?? 'Uruvia is down for a short while. Please try again soon.',
          buttonLabel: 'Try again',
          onPressed: () => ref.invalidate(appStatusProvider),
        );
      case AppGate.updateRequired:
        final url = status.storeUrl;
        return _Notice(
          icon: Icons.system_update_outlined,
          title: 'Please update Uruvia',
          message: 'This version is no longer supported. Update to keep using the app.',
          buttonLabel: url == null || url.isEmpty ? 'Try again' : 'Update now',
          onPressed: () => url == null || url.isEmpty ? ref.invalidate(appStatusProvider) : openLink(context, url),
        );
    }
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.title, required this.message, required this.buttonLabel, required this.onPressed});
  final IconData icon;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.pageMargin),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 64, color: palette.action),
                  const SizedBox(height: AppSpacing.lg),
                  Text(title, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.sm),
                  Text(message, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.xxl),
                  AppButton(label: buttonLabel, onPressed: onPressed),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
