import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/sub_page.dart';
import '../application/support_controller.dart';
import '../domain/support_models.dart';
import 'support_list_screen.dart';

class SupportTicketScreen extends ConsumerWidget {
  const SupportTicketScreen({super.key, required this.ticketId});
  final String ticketId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(ticketProvider(ticketId));
    return SubPage(
      title: value.valueOrNull?.reference ?? 'Request',
      fallbackRoute: AppRoutes.support,
      body: AsyncView<SupportTicket?>(
        value: value,
        onRetry: () => ref.invalidate(ticketProvider(ticketId)),
        isEmpty: (t) => t == null,
        empty: const EmptyState(icon: Icons.search_off_rounded, title: 'Request not found'),
        data: (t) => _Thread(ticket: t!),
      ),
    );
  }
}

class _Thread extends ConsumerStatefulWidget {
  const _Thread({required this.ticket});
  final SupportTicket ticket;

  @override
  ConsumerState<_Thread> createState() => _ThreadState();
}

class _ThreadState extends ConsumerState<_Thread> {
  final _reply = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  void _toast(String m) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> _send() async {
    final problem = validateSupportText(_reply.text);
    if (problem != null) {
      _toast(problem);
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(supportActionsProvider).reply(widget.ticket.id, _reply.text);
      _reply.clear();
    } catch (e) {
      _toast(friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resolve() async {
    setState(() => _busy = true);
    try {
      await ref.read(supportActionsProvider).resolve(widget.ticket.id);
    } catch (e) {
      _toast(friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = widget.ticket;
    final messages = ref.watch(ticketMessagesProvider(t.id));

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.pageMargin),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(t.category, style: theme.textTheme.titleMedium)),
                        StatusChip(t.status.label, tone: ticketTone(t.status)),
                      ],
                    ),
                    Text(formatRelative(t.createdAt), style: theme.textTheme.bodySmall),
                    const SizedBox(height: AppSpacing.md),
                    Text(t.description, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AsyncView<List<SupportMessage>>(
                value: messages,
                loading: const Padding(padding: EdgeInsets.all(AppSpacing.xl), child: Center(child: CircularProgressIndicator())),
                onRetry: () => ref.invalidate(ticketMessagesProvider(t.id)),
                isEmpty: (l) => l.isEmpty,
                empty: Text(
                  'We have your request. A reply will appear here.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
                ),
                data: (list) => Column(
                  children: [for (final m in list) _Bubble(message: m)],
                ),
              ),
              if (!t.isResolved)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _busy ? null : _resolve,
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Mark as resolved'),
                  ),
                ),
            ],
          ),
        ),
        if (!t.isResolved)
          Container(
            padding: const EdgeInsets.fromLTRB(AppSpacing.pageMargin, AppSpacing.sm, AppSpacing.sm, AppSpacing.sm),
            decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.border))),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _reply,
                    enabled: !_busy,
                    minLines: 1,
                    maxLines: 4,
                    maxLength: 4000,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(hintText: 'Write a reply', counterText: ''),
                  ),
                ),
                IconButton(
                  tooltip: 'Send reply',
                  onPressed: _busy ? null : _send,
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.all(AppSpacing.pageMargin),
            child: AppButton(label: 'Start a new request', style: AppButtonStyle.secondary, onPressed: () => context.push(AppRoutes.supportNew)),
          ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});
  final SupportMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final staff = message.isStaff;
    return Align(
      alignment: staff ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
        decoration: BoxDecoration(
          color: staff ? AppColors.neutralBg : palette.tint,
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(staff ? 'Uruvia support' : 'You', style: theme.textTheme.labelSmall),
            Text(message.body, style: theme.textTheme.bodyMedium),
            Text(formatRelative(message.createdAt), style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
