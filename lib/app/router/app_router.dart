import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/account/application/active_account.dart';
import '../../features/account/domain/account_type.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/home/presentation/home_placeholder.dart';
import '../shell/app_shell.dart';
import '../shell/coming_soon_screen.dart';
import '../shell/nav_items.dart';
import 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Re-run the redirect whenever the active account changes.
  final refresh = ValueNotifier<int>(0);
  ref.listen(activeAccountProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    // Later: also redirect on the Supabase session, KYC state and the
    // app lock (PIN after 3 minutes idle).
    redirect: (context, state) {
      final account = ref.read(activeAccountProvider);
      final location = state.matchedLocation;
      final blocked = account == AccountType.individual &&
          businessOnlyRoutes.any((r) => location == r || location.startsWith('$r/'));
      return blocked ? AppRoutes.home : null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const HomePlaceholder(),
          ),
          for (final item in allNavItems.where((i) => i.route != AppRoutes.home))
            GoRoute(
              path: item.route,
              builder: (_, __) => ComingSoonScreen(title: item.label),
            ),
          GoRoute(
            path: AppRoutes.notifications,
            builder: (_, __) => const ComingSoonScreen(title: 'Notifications'),
          ),
        ],
      ),
    ],
  );
});
