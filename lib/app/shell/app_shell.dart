import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/account/application/active_account.dart';
import '../../features/account/presentation/account_pill.dart';
import '../../features/notifications/application/notifications_controller.dart';
import '../router/routes.dart';
import 'app_sidebar.dart';
import 'nav_items.dart';

/// The frame around every top-level screen: coloured header with a menu
/// button, account pill and notification bell, plus the sidebar.
/// On phones the sidebar is a drawer (80% of the width, up to 320). From 840 px
/// wide it stays pinned open beside the content.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  static const double pinnedBreakpoint = 840;
  static const double pinnedWidth = 280;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(activeAccountProvider);
    final items = navItemsFor(account);
    final current = items.where((item) => item.matches(location)).firstOrNull;
    final title = current?.label ??
        (location.startsWith(AppRoutes.notifications) ? 'Notifications' : 'Uruvia');

    final unread = ref.watch(unreadCountProvider).valueOrNull ?? 0;
    final width = MediaQuery.sizeOf(context).width;
    final pinned = width >= pinnedBreakpoint;
    final sidebar = AppSidebar(location: location, permanent: pinned);

    final scaffold = Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          AccountPill(type: account, onHero: true),
          IconButton(
            tooltip: unread > 0 ? 'Notifications, $unread unread' : 'Notifications',
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text(unread > 9 ? '9+' : '$unread'),
              child: const Icon(Icons.notifications_none_rounded),
            ),
            onPressed: () => context.go(AppRoutes.notifications),
          ),
          const SizedBox(width: 4),
        ],
      ),
      drawer: pinned ? null : Drawer(width: math.min(width * 0.8, 320), child: sidebar),
      body: child,
    );

    if (!pinned) return scaffold;

    return Row(
      children: [
        SizedBox(
          width: pinnedWidth,
          child: Material(color: Colors.white, child: sidebar),
        ),
        const VerticalDivider(),
        Expanded(child: scaffold),
      ],
    );
  }
}
