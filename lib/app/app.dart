import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/account/application/active_account.dart';
import '../features/account/domain/account_type.dart';
import 'router/app_router.dart';
import 'theme/app_palette.dart';
import 'theme/app_theme.dart';

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
      routerConfig: ref.watch(routerProvider),
    );
  }
}
