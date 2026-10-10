import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/services/local_store.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/pin_prompt.dart';
import '../../auth/application/app_lock.dart';
import '../../auth/application/auth_actions.dart';
import '../application/account_actions.dart';
import '../application/active_account.dart';
import '../application/bootstrap.dart';
import '../domain/account_type.dart';

/// Returns true when the user switched account.
Future<bool> showAccountSwitcher(BuildContext context) async {
  final router = GoRouter.of(context);
  final result = await showAppSheet<_SwitchResult>(
    context,
    title: 'Switch account',
    builder: (_) => const _AccountSwitcherBody(),
  );
  switch (result) {
    case _SwitchResult.switched:
      router.go(AppRoutes.home);
      return true;
    case _SwitchResult.createBusiness:
      router.go(AppRoutes.businessSetup);
      return false;
    case null:
      return false;
  }
}

enum _SwitchResult { switched, createBusiness }

class _AccountSwitcherBody extends ConsumerStatefulWidget {
  const _AccountSwitcherBody();

  @override
  ConsumerState<_AccountSwitcherBody> createState() => _AccountSwitcherBodyState();
}

class _AccountSwitcherBodyState extends ConsumerState<_AccountSwitcherBody> {
  bool _busy = false;

  void _snack(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _switch(AccountType type) async {
    final biometric = await _biometricCheck();
    if (!mounted) return;
    final confirmed = await showPinPrompt(
      context,
      title: 'Enter your PIN',
      message: 'Confirm it is you before switching to your ${type == AccountType.business ? 'Business' : 'Individual'} account.',
      verify: ref.read(accountActionsProvider).verifyPin,
      onBiometric: biometric,
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await ref.read(accountActionsProvider).switchTo(type);
      if (mounted) Navigator.of(context).pop(_SwitchResult.switched);
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        _snack(friendlyError(e));
      }
    }
  }

  /// Fingerprint shortcut, only when the user turned it on.
  Future<Future<bool> Function()?> _biometricCheck() async {
    if (!await ref.read(lockPinStoreProvider).biometricsEnabled()) return null;
    return () => ref.read(biometricsProvider).authenticate('Switch account');
  }

  Future<void> _createIndividual() async {
    setState(() => _busy = true);
    try {
      await ref.read(authActionsProvider).createIndividualAccount();
      if (mounted) Navigator.of(context).pop(_SwitchResult.switched);
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        _snack(friendlyError(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = ref.watch(activeAccountProvider);
    final accounts = ref.watch(bootstrapProvider).valueOrNull?.accounts ?? const [];
    final hasIndividual = accounts.any((a) => a.type == AccountType.individual);
    final hasBusiness = accounts.any((a) => a.type == AccountType.business);

    return Column(
      children: [
        for (final a in accounts)
          _Row(
            icon: a.type == AccountType.business ? Icons.storefront_outlined : Icons.person_outline_rounded,
            title: a.type == AccountType.business ? 'Business' : 'Individual',
            subtitle: a.name,
            selected: a.type == active,
            onTap: _busy ? null : () => a.type == active ? Navigator.of(context).pop() : _switch(a.type),
          ),
        if (!hasBusiness)
          _Row(
            icon: Icons.add_business_outlined,
            title: 'Create a business account',
            subtitle: 'Invoices, stock, customers and sales',
            onTap: _busy ? null : () => Navigator.of(context).pop(_SwitchResult.createBusiness),
          ),
        if (!hasIndividual)
          _Row(
            icon: Icons.person_add_alt_outlined,
            title: 'Create an individual account',
            subtitle: 'Personal budgets, expenses and savings',
            onTap: _busy ? null : _createIndividual,
          ),
        if (_busy)
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.lg),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2.5, semanticsLabel: 'Switching')),
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.title, this.subtitle, this.selected = false, required this.onTap});

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    return Semantics(
      button: true,
      selected: selected,
      child: ListTile(
        minTileHeight: AppSpacing.minTouchTarget + 8,
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(backgroundColor: palette.tint, child: Icon(icon, color: palette.action)),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: subtitle == null ? null : Text(subtitle!, style: theme.textTheme.bodySmall),
        trailing: selected ? Icon(Icons.check_circle_rounded, color: palette.action) : null,
        onTap: onTap,
      ),
    );
  }
}
