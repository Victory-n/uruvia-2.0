import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_palette.dart';
import '../../app/theme/tokens.dart';
import '../connectivity/connectivity.dart';

/// Shows a slim "You are offline" strip above every screen while the phone has no connection.
class OfflineShell extends ConsumerWidget {
  const OfflineShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(isOnlineProvider);
    if (online) return child;
    return Column(
      children: [
        Material(
          color: AppColors.warningBg,
          child: SafeArea(
            bottom: false,
            child: Semantics(
              liveRegion: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageMargin, vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 18, color: StatusColors.warningText),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'You are offline. Cash expenses are saved on this phone and sent when you are back online.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: StatusColors.warningText),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(child: MediaQuery.removePadding(context: context, removeTop: true, child: child)),
      ],
    );
  }
}
