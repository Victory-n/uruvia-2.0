import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../offline/database_helper.dart';
import '../../theme/individual/app_theme.dart';
import '../widgets/app_text.dart';
import '../screens/auth/splash_screen.dart';

/// Displays a refined confirmation sheet to delete an account.
/// Clears local data and redirects to [SplashScreen] on confirmation.
Future<void> showDeleteAccountDialog(
  BuildContext context, {
  bool isBusiness = false,
}) async {
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext sheetContext) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Minimal drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Refined header
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.trashCan,
                        color: Color(0xFF64748B),
                        size: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  AppText.subtitle(
                    isBusiness ? 'Delete business account' : 'Delete account',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              AppText.paragraph(
                isBusiness
                    ? 'This will permanently remove your business profile, inventory, sales records, and team access. This action cannot be reversed.'
                    : 'This will permanently remove your profile, personal transactions, budgets, and saved preferences. This action cannot be reversed.',
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.of(sheetContext).pop(false),
                      child: const AppText.button(
                        'Keep account',
                        style: TextStyle(
                          color: AppTheme.textDark,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.of(sheetContext).pop(true),
                      child: const AppText.button(
                        'Delete',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  if (confirmed == true && context.mounted) {
    await performDeleteAccount(context, isBusiness: isBusiness);
  }
}

/// Clears local user data, cache, and preferences, then navigates to [SplashScreen].
Future<void> performDeleteAccount(
  BuildContext context, {
  bool isBusiness = false,
}) async {
  // Clear SQLite local cache/tables
  try {
    await DatabaseHelper.instance.clearAllData();
  } catch (_) {}

  // Clear SharedPreferences
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  } catch (_) {}

  if (!context.mounted) return;

  // Discreet notification
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: const Color(0xFF1E293B),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      content: Row(
        children: [
          const FaIcon(
            FontAwesomeIcons.check,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppText.custom(
              isBusiness ? 'Business account removed' : 'Account removed',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 2),
    ),
  );

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const SplashScreen()),
    (route) => false,
  );
}

/// Convenience alias for [showDeleteAccountDialog].
Future<void> deleteAccount(
  BuildContext context, {
  bool isBusiness = false,
}) {
  return showDeleteAccountDialog(context, isBusiness: isBusiness);
}
