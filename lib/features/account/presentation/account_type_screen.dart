import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/widgets/app_button.dart';
import '../../auth/application/auth_actions.dart';
import '../../auth/presentation/auth_scaffold.dart';
import '../domain/account_type.dart';

class AccountTypeScreen extends ConsumerStatefulWidget {
  const AccountTypeScreen({super.key});

  @override
  ConsumerState<AccountTypeScreen> createState() => _AccountTypeScreenState();
}

class _AccountTypeScreenState extends ConsumerState<AccountTypeScreen> {
  AccountType? _selected;
  bool _loading = false;
  String? _error;

  Future<void> _continue() async {
    final type = _selected;
    if (type == null) return;
    if (type == AccountType.business) {
      context.go(AppRoutes.businessSetup);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authActionsProvider).createIndividualAccount();
      // Router moves to the PIN step.
    } catch (e) {
      if (mounted) setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'How will you use Uruvia?',
      subtitle: 'You can add the other account later.',
      footer: TextButton(
        onPressed: () => ref.read(authActionsProvider).signOut(),
        child: const Text('Sign out'),
      ),
      children: [
        FormError(_error),
        _TypeCard(
          icon: Icons.person_outline_rounded,
          title: 'Individual',
          body: 'Budgets, expenses and savings for your own money.',
          selected: _selected == AccountType.individual,
          onTap: _loading ? null : () => setState(() => _selected = AccountType.individual),
        ),
        const SizedBox(height: AppSpacing.md),
        _TypeCard(
          icon: Icons.storefront_outlined,
          title: 'Business',
          body: 'Everything above, plus stock, invoices, customers and sales.',
          selected: _selected == AccountType.business,
          onTap: _loading ? null : () => setState(() => _selected = AccountType.business),
        ),
        const SizedBox(height: AppSpacing.xxl),
        AppButton(label: 'Continue', onPressed: _selected == null ? null : _continue, loading: _loading),
      ],
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    return Semantics(
      button: true,
      selected: selected,
      label: '$title. $body',
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: selected ? palette.tint : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: selected ? palette.action : AppColors.border, width: selected ? 2 : 1),
          ),
          child: Row(
            children: [
              Icon(icon, size: 32, color: palette.action),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(body, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft)),
                  ],
                ),
              ),
              if (selected) Icon(Icons.check_circle_rounded, color: palette.action),
            ],
          ),
        ),
      ),
    );
  }
}
