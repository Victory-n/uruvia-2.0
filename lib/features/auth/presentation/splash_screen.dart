import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/tokens.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/widgets/app_button.dart';
import '../../account/application/bootstrap.dart';

/// Logo while the app checks the session. If loading the profile fails, shows Retry.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final failed = ref.watch(appStageProvider) == AppStage.failed;
    final error = ref.watch(bootstrapProvider).error;

    // Before an account type is chosen the app uses the neutral white look.
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/img/logo.png', width: 120),
              const SizedBox(height: AppSpacing.xxl),
              if (!failed)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5, semanticsLabel: 'Loading'),
                )
              else ...[
                Text(
                  error == null ? 'We could not load your account.' : friendlyError(error),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Retry',
                  expand: false,
                  onPressed: () {
                    ref.invalidate(bootstrapProvider);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
