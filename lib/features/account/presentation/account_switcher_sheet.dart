import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/app_sheet.dart';
import '../application/active_account.dart';
import '../domain/account_type.dart';

/// Bottom sheet to switch between the Individual and Business accounts.
/// Returns true when the account was changed. The PIN or biometric check and
/// the "Create a business account" path are added with the account screens.
Future<bool> showAccountSwitcher(BuildContext context) async {
  final router = GoRouter.of(context);
  final switched = await showAppSheet<bool>(
    context,
    title: 'Switch account',
    builder: (_) => const _AccountSwitcherBody(),
  );
  if (switched == true) router.go(AppRoutes.home);
  return switched == true;
}

class _AccountSwitcherBody extends ConsumerWidget {
  const _AccountSwitcherBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeAccountProvider);
    return Column(
      children: [
        for (final type in AccountType.values)
          _Row(
            type: type,
            selected: type == active,
            onTap: () {
              if (type != active) {
                ref.read(activeAccountProvider.notifier).switchTo(type);
              }
              Navigator.of(context).pop(type != active);
            },
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.type, required this.selected, required this.onTap});

  final AccountType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final isBusiness = type == AccountType.business;
    return Semantics(
      button: true,
      selected: selected,
      child: ListTile(
        minTileHeight: AppSpacing.minTouchTarget,
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: palette.tint,
          child: Icon(
            isBusiness ? Icons.storefront_outlined : Icons.person_outline_rounded,
            color: palette.action,
          ),
        ),
        title: Text(isBusiness ? 'Business' : 'Individual', style: theme.textTheme.titleMedium),
        trailing: selected ? Icon(Icons.check_circle_rounded, color: palette.action) : null,
        onTap: onTap,
      ),
    );
  }
}
