import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/account/application/active_account.dart';
import '../../features/account/application/bootstrap.dart';
import '../../features/account/domain/account_type.dart';
import '../../features/account/presentation/account_type_screen.dart';
import '../../features/account/presentation/business_setup_screen.dart';
import '../../features/auth/presentation/create_pin_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../features/auth/presentation/verify_email_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../core/services/local_store.dart';
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
  ref.listen(appStageProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final stage = ref.read(appStageProvider);
      final location = state.matchedLocation;
      final inAuth = location == AppRoutes.onboarding || location.startsWith('/auth/');

      switch (stage) {
        case AppStage.starting:
        case AppStage.failed:
          return location == AppRoutes.splash ? null : AppRoutes.splash;
        case AppStage.signedOut:
          if (location == AppRoutes.splash) {
            final seen = ref.read(sharedPrefsProvider).getBool(kOnboardingSeenKey) ?? false;
            return seen ? AppRoutes.signIn : AppRoutes.onboarding;
          }
          return inAuth ? null : AppRoutes.signIn;
        case AppStage.needsAccount:
          const allowed = {AppRoutes.accountType, AppRoutes.businessSetup};
          return allowed.contains(location) ? null : AppRoutes.accountType;
        case AppStage.needsPin:
          return location == AppRoutes.pin ? null : AppRoutes.pin;
        case AppStage.ready:
          const leave = {AppRoutes.splash, AppRoutes.onboarding, AppRoutes.accountType, AppRoutes.pin};
          if (leave.contains(location) || location.startsWith('/auth/')) return AppRoutes.home;
          final account = ref.read(activeAccountProvider);
          final blocked = account == AccountType.individual &&
              businessOnlyRoutes.any((r) => location == r || location.startsWith('$r/'));
          return blocked ? AppRoutes.home : null;
      }
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(path: AppRoutes.onboarding, builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: AppRoutes.signIn, builder: (_, __) => const SignInScreen()),
      GoRoute(path: AppRoutes.signUp, builder: (_, __) => const SignUpScreen()),
      GoRoute(
        path: AppRoutes.verifyEmail,
        builder: (_, state) => VerifyEmailScreen(email: state.uri.queryParameters['email'] ?? ''),
      ),
      GoRoute(path: AppRoutes.forgotPassword, builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: AppRoutes.accountType, builder: (_, __) => const AccountTypeScreen()),
      GoRoute(path: AppRoutes.businessSetup, builder: (_, __) => const BusinessSetupScreen()),
      GoRoute(path: AppRoutes.pin, builder: (_, __) => const CreatePinScreen()),
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
