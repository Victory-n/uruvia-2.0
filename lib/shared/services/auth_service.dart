import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../offline/connectivity_service.dart';
import '../../offline/database_helper.dart';
import '../../offline/sync_service.dart';
import '../screens/auth/login_screen.dart';
import '../widgets/app_text.dart';

class AuthService {
  AuthService._();

  /// Confirms, syncs pending offline entries, clears the device cache,
  /// signs out and returns to the login screen.
  static Future<void> logout(BuildContext context) async {
    // Grab the navigator now: the caller's context may be a drawer that
    // disappears while we work.
    final navigator = Navigator.of(context, rootNavigator: true);

    final confirmed = await _confirm(
      navigator.context,
      title: 'Log out?',
      message: 'You will need to log in again to access your account.',
      confirmLabel: 'Log out',
    );
    if (confirmed != true) return;

    _showProgress(navigator.context);

    // Push any entries made offline before the local data is removed.
    try {
      if (await ConnectivityService.instance.checkConnection()) {
        await SyncService.instance.processQueue();
      }
    } catch (_) {}

    final pending = await SyncService.instance.pendingCount();
    if (pending > 0) {
      navigator.pop(); // close progress
      final proceed = await _confirm(
        navigator.context,
        title: 'Unsynced changes',
        message:
            'You have $pending change${pending == 1 ? '' : 's'} that '
            "haven't synced yet. Logging out now will permanently delete "
            'them. Connect to the internet and try again to keep them.',
        confirmLabel: 'Log out anyway',
        destructive: true,
      );
      if (proceed != true) return;
      _showProgress(navigator.context);
    }

    // Everything is synced (or the user chose to discard): wipe the cache
    // so the next account starts clean.
    try {
      await DatabaseHelper.instance.clearAllData();
    } catch (_) {}

    try {
      // Local scope works without a network connection.
      await Supabase.instance.client.auth.signOut(scope: SignOutScope.local);
    } catch (_) {}

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  static Future<bool?> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: AppText.subtitle(title),
        content: AppText.paragraph(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const AppText.button('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: AppText.button(
              confirmLabel,
              style: TextStyle(
                color: destructive ? Colors.redAccent : null,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _showProgress(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
