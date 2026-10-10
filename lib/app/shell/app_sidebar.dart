import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/account/application/active_account.dart';
import '../../features/account/application/profile_name.dart';
import '../../features/account/domain/account_type.dart';
import '../../features/account/presentation/account_pill.dart';
import '../../features/account/presentation/account_switcher_sheet.dart';
import '../../features/auth/application/auth_actions.dart';
import '../../features/subscription/application/pro_status.dart';
import '../theme/app_palette.dart';
import '../theme/tokens.dart';
import 'nav_items.dart';

/// Sidebar content: account block on top, destinations, Log out at the bottom.
/// Used inside a Drawer on phones and pinned open on wide screens.
class AppSidebar extends ConsumerWidget {
  const AppSidebar({super.key, required this.location, required this.permanent});

  final String location;

  /// True when pinned beside the content (no drawer to close after a tap).
  final bool permanent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(activeAccountProvider);
    final isPro = ref.watch(isProProvider);
    final name = ref.watch(profileNameProvider);
    final items = navItemsFor(account);

    void closeDrawer() {
      if (!permanent) Navigator.of(context).pop();
    }

    return SafeArea(
      child: Column(
        children: [
          _AccountBlock(
            name: name,
            account: account,
            onSwitch: () async {
              final switched = await showAccountSwitcher(context);
              if (switched && context.mounted) closeDrawer();
            },
          ),
          const Divider(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
              children: [
                for (final item in items)
                  _SidebarTile(
                    icon: item.icon,
                    label: item.label,
                    selected: item.matches(location),
                    trailing: item.proOnly && !isPro
                        ? const Icon(Icons.lock_rounded, size: 18, color: AppColors.goldDark)
                        : null,
                    onTap: () {
                      closeDrawer();
                      context.go(item.route);
                    },
                  ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _SidebarTile(
              icon: Icons.logout_rounded,
              label: 'Log out',
              selected: false,
              onTap: () {
                closeDrawer();
                ref.read(authActionsProvider).signOut();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountBlock extends StatelessWidget {
  const _AccountBlock({required this.name, required this.account, required this.onSwitch});

  final String name;
  final AccountType account;
  final VoidCallback onSwitch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final initial = name.isEmpty ? '?' : String.fromCharCode(name.runes.first).toUpperCase();
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: palette.tint,
                child: Text(
                  initial,
                  style: theme.textTheme.titleLarge?.copyWith(color: palette.action),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: theme.textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        AccountPill(type: account),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: onSwitch,
            icon: const Icon(Icons.swap_horiz_rounded),
            label: const Text('Switch account'),
          ),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? palette.tint : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.control),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.control),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  Icon(icon, color: selected ? palette.action : AppColors.inkSoft),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: selected ? palette.action : AppColors.ink,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
