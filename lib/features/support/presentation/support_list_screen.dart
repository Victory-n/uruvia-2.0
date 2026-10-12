import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../application/support_controller.dart';
import '../domain/support_models.dart';
import 'support_hub_widgets.dart';

StatusTone ticketTone(TicketStatus s) => switch (s) {
      TicketStatus.open => StatusTone.warning,
      TicketStatus.inProgress => StatusTone.info,
      TicketStatus.resolved => StatusTone.success,
    };

class SupportListScreen extends ConsumerWidget {
  const SupportListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(ticketsProvider);
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.supportNew),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New request'),
      ),
      body: AsyncView<List<SupportTicket>>(
        value: value,
        onRetry: () => ref.invalidate(ticketsProvider),
        isEmpty: (l) => false,
        empty: const SizedBox.shrink(),
        data: (list) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(ticketsProvider);
            try {
              await ref.read(ticketsProvider.future);
            } catch (_) {}
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(AppSpacing.pageMargin, AppSpacing.lg, AppSpacing.pageMargin, 96),
            children: [
              const ContactCards(),
              const SizedBox(height: AppSpacing.sectionGap),
              Text('Common questions', style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              const FaqList(),
              const SizedBox(height: AppSpacing.sectionGap),
              Text('Your requests', style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              if (list.isEmpty)
                Text('No requests yet. Tap New request if something is not right.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft))
              else
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < list.length; i++) ...[
                      if (i > 0) const Divider(),
                      ListTile(
                        minTileHeight: 72,
                        title: Text(list[i].category, style: theme.textTheme.titleMedium),
                        subtitle: Text(
                          '${list[i].reference} · ${formatRelative(list[i].createdAt)}\n${list[i].description}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                        isThreeLine: true,
                        trailing: StatusChip(list[i].status.label, tone: ticketTone(list[i].status)),
                        onTap: () => context.push(AppRoutes.supportTicket(list[i].id)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
