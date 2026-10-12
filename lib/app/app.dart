import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/account/application/active_account.dart';
import '../features/account/domain/account_type.dart';
import '../features/expenses/application/expenses_controller.dart';
import '../core/widgets/offline_shell.dart';
import '../features/app_status/presentation/app_status_gate.dart';
import '../features/auth/application/auth_actions.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/app_lock_gate.dart';
import 'router/app_router.dart';
import 'theme/app_palette.dart';
import 'theme/app_theme.dart';
import 'theme/tokens.dart';

final _messengerKey = GlobalKey<ScaffoldMessengerState>();

class UruviaApp extends ConsumerWidget {
  const UruviaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(outboxSyncProvider); // sends cash expenses saved while offline
    // A session that ends without the user logging out (expired or revoked) gets a plain explanation.
    ref.listen(sessionProvider, (prev, next) {
      final wasIn = prev?.valueOrNull != null;
      final isOut = next.hasValue && next.valueOrNull == null;
      if (wasIn && isOut) {
        if (!userInitiatedSignOut) {
          _messengerKey.currentState?.showSnackBar(const SnackBar(content: Text('Your session ended. Please sign in again.')));
        }
        userInitiatedSignOut = false;
      }
    });
    final account = ref.watch(activeAccountProvider);
    final palette = account == AccountType.business
        ? AppPalette.business
        : AppPalette.individual;
    return MaterialApp.router(
      title: 'Uruvia',
      scaffoldMessengerKey: _messengerKey,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(palette),
      // Header and sidebar colours glide to the new account's colours.
      themeAnimationDuration: AppDurations.accountSwitch,
      themeAnimationCurve: Curves.easeOut,
      // Text follows the phone's font size, but stops at 130% so layouts hold.
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        minScaleFactor: 1,
        maxScaleFactor: 1.3,
        child: AppStatusGate(
          child: AppLockGate(child: OfflineShell(child: child ?? const SizedBox.shrink())),
        ),
      ),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
