import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/state_views.dart';
import '../application/notifications_controller.dart';
import '../domain/app_notification.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(notificationsProvider);
    final hasUnread = value.valueOrNull?.any((n) => !n.isRead) ?? false;

    return Column(
      children: [
        if (hasUnread)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: TextButton(
                onPressed: () => ref.read(notificationsActionsProvider).markAllRead(),
                child: const Text('Mark all as read'),
              ),
            ),
          ),
        Expanded(
          child: AsyncView<List<AppNotification>>(
            value: value,
            onRetry: () => ref.invalidate(notificationsProvider),
            isEmpty: (items) => items.isEmpty,
            empty: const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'You are all caught up',
              message: 'Budget alerts, invoice reminders and low-stock notices will appear here.',
            ),
            data: (items) => RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(notificationsProvider);
                try {
                  await ref.read(notificationsProvider.future);
                } catch (_) {}
              },
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(indent: 72),
                itemBuilder: (_, i) => _NotificationTile(item: items[i]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

IconData _iconFor(String kind) {
  if (kind.contains('budget')) return Icons.pie_chart_outline_rounded;
  if (kind.contains('invoice')) return Icons.description_outlined;
  if (kind.contains('stock') || kind.contains('reservation')) return Icons.inventory_2_outlined;
  if (kind.contains('kyc')) return Icons.verified_user_outlined;
  return Icons.notifications_none_rounded;
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.item});
  final AppNotification item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    return Semantics(
      label: '${item.isRead ? '' : 'Unread. '}${item.title}',
      child: ListTile(
        minTileHeight: 72,
        tileColor: item.isRead ? null : palette.tint.withValues(alpha: 0.5),
        leading: CircleAvatar(
          backgroundColor: palette.tint,
          child: Icon(_iconFor(item.kind), color: palette.action, size: 20),
        ),
        title: Text(
          item.title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.body != null) Text(item.body!, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 2),
            Text(formatRelative(item.createdAt), style: theme.textTheme.bodySmall),
          ],
        ),
        trailing: item.isRead ? null : Icon(Icons.circle, size: 10, color: palette.action),
        onTap: item.isRead ? null : () => ref.read(notificationsActionsProvider).markRead(item.id),
      ),
    );
  }
}
