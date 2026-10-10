import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/tokens.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/state_views.dart';
import '../../account/application/active_account.dart';
import '../../account/application/profile_name.dart';
import '../../account/domain/account_type.dart';
import '../application/home_controller.dart';
import 'business_home.dart';
import 'individual_home.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = ref.watch(activeAccountProvider);
    final data = ref.watch(homeDataProvider);
    final theme = Theme.of(context);
    final first = ref.watch(profileNameProvider).split(' ').first;

    return AsyncView(
      value: data,
      onRetry: () => ref.invalidate(homeDataProvider),
      loading: const _HomeSkeleton(),
      data: (d) => RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(homeDataProvider);
          try {
            await ref.read(homeDataProvider.future);
          } catch (_) {}
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.pageMargin),
          children: [
            Text('${greetingFor(DateTime.now())}, $first', style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.lg),
            if (type == AccountType.business) BusinessHome(data: d) else IndividualHome(data: d),
          ],
        ),
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading',
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.pageMargin),
        children: const [
          SkeletonBox(width: 200, height: 24),
          SizedBox(height: AppSpacing.lg),
          SkeletonBox(height: 168, radius: AppRadius.card),
          SizedBox(height: AppSpacing.sectionGap),
          SkeletonBox(height: 96, radius: AppRadius.card),
          SizedBox(height: AppSpacing.sectionGap),
          SkeletonBox(height: 200, radius: AppRadius.card),
        ],
      ),
    );
  }
}
