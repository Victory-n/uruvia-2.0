import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/services/local_store.dart';
import '../../../core/widgets/app_button.dart';

const kOnboardingSeenKey = 'onboarding_seen';

class _Slide {
  const _Slide(this.icon, this.title, this.body);
  final IconData icon;
  final String title;
  final String body;
}

const _slides = [
  _Slide(Icons.account_balance_wallet_outlined, 'Know where your money goes',
      'Set budgets, log spending and see your month at a glance.'),
  _Slide(Icons.storefront_outlined, 'Run your business with confidence',
      'Track stock, send invoices and record sales from one place.'),
  _Slide(Icons.lock_outline_rounded, 'Safe by design',
      'Your PIN and your fingerprint keep your money and your records private.'),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish(String route) async {
    await ref.read(sharedPrefsProvider).setBool(kOnboardingSeenKey, true);
    if (mounted) context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final last = _page == _slides.length - 1;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _finish(AppRoutes.signUp),
                    child: const Text('Skip'),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _slides.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (_, i) {
                      final s = _slides[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(color: palette.tint, shape: BoxShape.circle),
                              child: Icon(s.icon, size: 64, color: palette.action),
                            ),
                            const SizedBox(height: AppSpacing.xxxl),
                            Text(s.title, style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              s.body,
                              style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.inkSoft),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < _slides.length; i++)
                      AnimatedContainer(
                        duration: reduceMotion ? Duration.zero : AppDurations.quick,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _page ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _page ? palette.action : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.pageMargin),
                  child: Column(
                    children: [
                      AppButton(
                        label: last ? 'Get started' : 'Next',
                        onPressed: () {
                          if (last) {
                            _finish(AppRoutes.signUp);
                          } else if (reduceMotion) {
                            _controller.jumpToPage(_page + 1);
                          } else {
                            _controller.nextPage(duration: AppDurations.sheet, curve: Curves.easeOut);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppButton(
                        label: 'I already have an account',
                        style: AppButtonStyle.text,
                        onPressed: () => _finish(AppRoutes.signIn),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
