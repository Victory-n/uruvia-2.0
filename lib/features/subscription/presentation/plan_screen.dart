import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../../account/application/active_account.dart';
import '../../account/domain/account_type.dart';
import '../application/subscription_controller.dart';
import '../domain/plan_models.dart';

/// Screen 12. Showing the plan and the current status is live; checkout is a placeholder until payments are connected.
class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(planProvider);
    final sub = ref.watch(subscriptionProvider).valueOrNull;
    final type = ref.watch(activeAccountProvider);
    final benefits = type == AccountType.business ? businessProBenefits : individualProBenefits;

    return AsyncView<Plan?>(
      value: plan,
      onRetry: () => ref.invalidate(planProvider),
      isEmpty: (p) => p == null,
      empty: const EmptyState(icon: Icons.workspace_premium_outlined, title: 'Plans are not available yet'),
      data: (p) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.pageMargin),
            children: [
              _PlanCard(plan: p!, subscription: sub, benefits: benefits),
              const SizedBox(height: AppSpacing.lg),
              if (sub != null && sub.isLive())
                _CurrentStatus(subscription: sub)
              else
                AppButton(
                  label: 'Upgrade to ${p.name}',
                  icon: Icons.workspace_premium_outlined,
                  onPressed: () => _checkout(context, p),
                ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'The free plan keeps working with no time limit. Pro adds the extras above.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkout(BuildContext context, Plan plan) {
    return showAppSheet<void>(
      context,
      title: 'Payment is coming soon',
      builder: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'You will be able to pay for ${plan.name} from your Uruvia wallet or with a card. '
            'We will let you know when it opens.',
            style: Theme.of(ctx).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppButton(label: 'Got it', onPressed: () => Navigator.of(ctx).pop()),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.subscription, required this.benefits});
  final Plan plan;
  final Subscription? subscription;
  final List<String> benefits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final live = subscription?.isLive() ?? false;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(plan.name, style: theme.textTheme.titleLarge)),
              if (live) const StatusChip('Your plan', tone: StatusTone.success),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: formatNaira(plan.priceKobo, showKobo: false), style: theme.textTheme.headlineMedium),
                if (plan.periodLabel.isNotEmpty) TextSpan(text: ' ${plan.periodLabel}', style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          Text('or ${plan.usdLabel}', style: theme.textTheme.bodySmall),
          const Divider(height: AppSpacing.xxl),
          for (final b in benefits)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_rounded, size: 20, color: palette.action),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Text(b, style: theme.textTheme.bodyMedium)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CurrentStatus extends StatelessWidget {
  const _CurrentStatus({required this.subscription});
  final Subscription subscription;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = subscription;
    final pastDue = s.status == 'past_due';
    final end = pastDue ? s.graceUntil : s.currentPeriodEnd;
    return AppCard(
      child: Row(
        children: [
          Icon(pastDue ? Icons.warning_amber_rounded : Icons.verified_rounded, color: pastDue ? StatusColors.warningText : StatusColors.success),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              pastDue
                  ? 'Your last payment did not go through.${end == null ? '' : ' Pro stays on until ${formatShortDate(end)}.'}'
                  : end == null
                      ? 'Pro is active.'
                      : 'Pro is active until ${formatShortDate(end)}.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
