import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/account/application/active_account.dart';
import '../features/account/domain/account_type.dart';
import '../features/auth/presentation/app_lock_gate.dart';
import 'router/app_router.dart';
import 'theme/app_palette.dart';
import 'theme/app_theme.dart';
import 'theme/tokens.dart';

class UruviaApp extends ConsumerWidget {
  const UruviaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(activeAccountProvider);
    final palette = account == AccountType.business
        ? AppPalette.business
        : AppPalette.individual;
    return MaterialApp.router(
      title: 'Uruvia',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(palette),
      // Header and sidebar colours glide to the new account's colours.
      themeAnimationDuration: AppDurations.accountSwitch,
      themeAnimationCurve: Curves.easeOut,
      builder: (context, child) => AppLockGate(child: child ?? const SizedBox.shrink()),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
