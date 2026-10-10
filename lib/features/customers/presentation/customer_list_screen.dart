import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../application/customers_controller.dart';
import '../domain/customer_models.dart';

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final value = ref.watch(customersProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.customersNew),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add customer'),
      ),
      body: AsyncView<List<Customer>>(
        value: value,
        onRetry: () => ref.invalidate(customersProvider),
        isEmpty: (l) => l.isEmpty,
        empty: EmptyState(
          icon: Icons.people_outline_rounded,
          title: 'No customers yet',
          message: 'Save the people you sell to so invoices take a few taps.',
          actionLabel: 'Add your first customer',
          onAction: () => context.push(AppRoutes.customersNew),
        ),
        data: (all) {
          final q = _query.trim().toLowerCase();
          final shown = [
            for (final c in all)
              if (q.isEmpty || c.name.toLowerCase().contains(q) || (c.phone ?? '').contains(q)) c,
          ];
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(customersProvider);
              try {
                await ref.read(customersProvider.future);
              } catch (_) {}
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(AppSpacing.pageMargin, AppSpacing.lg, AppSpacing.pageMargin, 96),
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name or phone',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.control),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.control),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (shown.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.xxl),
                    child: Center(child: Text('No customers match your search.')),
                  )
                else
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (var i = 0; i < shown.length; i++) ...[
                          if (i > 0) const Divider(),
                          CustomerTile(customer: shown[i], onTap: () => context.push(AppRoutes.customerDetail(shown[i].id))),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CustomerTile extends StatelessWidget {
  const CustomerTile({super.key, required this.customer, required this.onTap});
  final Customer customer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final c = customer;
    return ListTile(
      minTileHeight: 64,
      leading: CircleAvatar(
        backgroundColor: palette.tint,
        child: Text(c.name.trim().isEmpty ? '?' : c.name.trim()[0].toUpperCase(), style: TextStyle(color: palette.action)),
      ),
      title: Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium),
      subtitle: c.contactLine == null ? null : Text(c.contactLine!, style: theme.textTheme.bodySmall),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
