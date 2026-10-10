import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/state_views.dart';
import '../../account/application/active_account.dart';
import '../../account/domain/account_type.dart';

/// Temporary body for Home, shown inside the app shell. Replaced when the
/// Home dashboards (screens 7 and 8) are built.
class HomePlaceholder extends ConsumerWidget {
  const HomePlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusiness = ref.watch(activeAccountProvider) == AccountType.business;
    return EmptyState(
      icon: isBusiness ? Icons.storefront_outlined : Icons.home_outlined,
      title: isBusiness ? 'Business home' : 'Individual home',
      message: 'Open the menu to switch account and see the colours change.',
    );
  }
}
