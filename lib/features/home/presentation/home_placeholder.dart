import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/application/active_account.dart';
import '../../account/domain/account_type.dart';

/// Temporary screen that proves the two themes switch. Replaced when the
/// Home dashboards are built.
class HomePlaceholder extends ConsumerWidget {
  const HomePlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(activeAccountProvider);
    final isBusiness = account == AccountType.business;
    return Scaffold(
      appBar: AppBar(title: Text(isBusiness ? 'Business' : 'Individual')),
      body: Center(
        child: FilledButton(
          onPressed: () => ref.read(activeAccountProvider.notifier).switchTo(
                isBusiness ? AccountType.individual : AccountType.business,
              ),
          child: const Text('Switch account'),
        ),
      ),
    );
  }
}
