import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../business_account/screens/business_dashboard_screen.dart';
import '../../individual_account/screens/dashboard_screen.dart';
import '../../offline/profile_repository.dart';

/// Decides which dashboard a signed-in user should land on.
class SessionRouter {
  SessionRouter._();

  /// Maps `profiles.active_account_type` to its dashboard.
  static Widget screenFor(String accountType) {
    return accountType == 'business'
        ? const BusinessDashboardScreen()
        : const DashboardScreen();
  }

  /// Restores a persisted Supabase session and returns the matching
  /// dashboard, or null when the user has to log in.
  ///
  /// Works offline: the session and profile are read from the device.
  static Future<Widget?> restoreHome() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    try {
      final profile = await ProfileRepository.instance.loadProfile(user.id);
      return screenFor(
        (profile['active_account_type'] as String?) ?? 'individual',
      );
    } catch (_) {
      return null;
    }
  }
}
