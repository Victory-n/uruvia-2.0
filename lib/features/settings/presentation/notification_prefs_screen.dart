import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/sub_page.dart';
import '../../account/application/active_account.dart';
import '../../account/domain/account_type.dart';
import '../application/settings_controller.dart';
import '../domain/settings_models.dart';

class NotificationPrefsScreen extends ConsumerWidget {
  const NotificationPrefsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = ref.watch(activeAccountProvider);
    final kinds = type == AccountType.business ? businessAlerts : individualAlerts;
    final prefs = ref.watch(alertPrefsProvider);

    return SubPage(
      title: 'Notifications',
      fallbackRoute: AppRoutes.settings,
      body: AsyncView<Map<String, bool>>(
        value: prefs,
        onRetry: () => ref.invalidate(alertPrefsProvider),
        data: (map) => ListView(
          padding: const EdgeInsets.all(AppSpacing.pageMargin),
          children: [
            Text(
              'Choose which alerts you want as phone notifications. Everything still shows in the bell inside the app.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < kinds.length; i++) ...[
                    if (i > 0) const Divider(),
                    SwitchListTile(
                      title: Text(kinds[i].title),
                      subtitle: Text(kinds[i].description),
                      value: map[kinds[i].kind] ?? true,
                      onChanged: (v) async {
                        try {
                          await ref.read(settingsActionsProvider).setAlert(kinds[i].kind, v);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyError(e))));
                          }
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
