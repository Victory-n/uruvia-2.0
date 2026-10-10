import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/services/local_store.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/status_chip.dart';
import '../../account/application/account_actions.dart';
import '../../account/application/profile_name.dart';
import '../../auth/application/app_lock.dart';
import '../../auth/application/auth_actions.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/domain/validators.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final name = ref.watch(profileNameProvider);
    final email = ref.watch(sessionProvider).valueOrNull?.user.email ?? '';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pageMargin),
          children: [
            Text('Profile', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    minTileHeight: 64,
                    title: const Text('Name'),
                    subtitle: Text(name),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: () => _editName(context, name),
                  ),
                  const Divider(),
                  ListTile(
                    minTileHeight: 64,
                    title: const Text('Email'),
                    subtitle: Text(email),
                    trailing: const StatusChip('Verified', tone: StatusTone.success),
                  ),
                  const Divider(),
                  const ListTile(
                    minTileHeight: 64,
                    title: Text('Phone number'),
                    subtitle: Text('Added and verified in the identity check (KYC), coming soon.'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            Text('Security', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            const AppCard(padding: EdgeInsets.zero, child: _BiometricsTile()),
            const SizedBox(height: AppSpacing.sectionGap),
            AppButton(
              label: 'Log out',
              style: AppButtonStyle.secondary,
              icon: Icons.logout_rounded,
              onPressed: () => _confirmLogout(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editName(BuildContext context, String current) {
    return showAppSheet<void>(
      context,
      title: 'Your name',
      builder: (_) => _NameForm(initial: current == 'Your name' ? '' : current),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need your email and password to sign in again.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Log out')),
        ],
      ),
    );
    if (ok == true) await ref.read(authActionsProvider).signOut();
  }
}

class _NameForm extends ConsumerStatefulWidget {
  const _NameForm({required this.initial});
  final String initial;

  @override
  ConsumerState<_NameForm> createState() => _NameFormState();
}

class _NameFormState extends ConsumerState<_NameForm> {
  late final _controller = TextEditingController(text: widget.initial);
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final problem = Validators.fullName(_controller.text);
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(accountActionsProvider).updateName(_controller.text);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = friendlyError(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTextField(
          label: 'Full name',
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          errorText: _error,
          enabled: !_saving,
          onSubmitted: (_) => _save(),
        ),
        const SizedBox(height: AppSpacing.xxl),
        AppButton(label: 'Save', onPressed: _save, loading: _saving),
      ],
    );
  }
}

class _BiometricsTile extends ConsumerStatefulWidget {
  const _BiometricsTile();

  @override
  ConsumerState<_BiometricsTile> createState() => _BiometricsTileState();
}

class _BiometricsTileState extends ConsumerState<_BiometricsTile> {
  bool? _available;

  @override
  void initState() {
    super.initState();
    ref.read(biometricsProvider).isAvailable().then((v) {
      if (mounted) setState(() => _available = v);
    });
  }

  Future<void> _toggle(bool on) async {
    final store = ref.read(lockPinStoreProvider);
    if (on) {
      final ok = await ref.read(biometricsProvider).authenticate('Turn on fingerprint unlock');
      if (!ok) return;
    }
    await store.setBiometrics(on);
    ref.invalidate(biometricsEnabledProvider);
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;
    final enabled = ref.watch(biometricsEnabledProvider).valueOrNull ?? false;
    final available = _available ?? false;
    return SwitchListTile(
      minTileHeight: 64,
      activeThumbColor: palette.action,
      title: const Text('Unlock with fingerprint'),
      subtitle: Text(available
          ? 'Skip typing your PIN when you open the app.'
          : 'Not available on this phone. Set up a fingerprint in your phone settings first.'),
      value: enabled && available,
      onChanged: available ? _toggle : null,
    );
  }
}
