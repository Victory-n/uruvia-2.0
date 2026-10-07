import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../shared/features/events/screens/events_screen.dart';
import '../../../shared/features/inventory/screens/inventory_list_screen.dart';
import '../../../shared/widgets/app_text.dart';
import '../../../shared/function/delete_account.dart';
import '../../../shared/features/support/screens/support_screen.dart';
import '../screens/dashboard_screen.dart';
import '../../theme/individual/app_theme.dart';
import 'settings/settings.dart';
import '../../offline/profile_repository.dart';
import '../../shared/services/auth_service.dart';

class AppSidebar extends StatelessWidget {
  final String activeItem;

  const AppSidebar({
    super.key,
    this.activeItem = 'Dashboard',
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.sleekBlue,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: AppTheme.white,
                    child: Icon(Icons.person, size: 32, color: AppTheme.sleekBlue),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<Map<String, dynamic>?>(
                    future: ProfileRepository.instance.getCachedProfile(),
                    builder: (context, snapshot) {
                      final profile = snapshot.data;
                      final name =
                          '${profile?['first_name'] ?? ''} ${profile?['last_name'] ?? ''}'
                              .trim();
                      return AppText.subtitle(
                        name.isEmpty ? 'Uruvia User' : name,
                        style: const TextStyle(color: AppTheme.white),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  AppText.paragraph(
                    'Individual Account',
                    style: TextStyle(color: AppTheme.white.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24),
            _buildNavItem(
              Icons.dashboard_outlined,
              'Dashboard',
              activeItem == 'Dashboard',
              onTap: () {
                Navigator.pop(context);
                if (activeItem != 'Dashboard') {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const DashboardScreen()),
                    (route) => route.isFirst,
                  );
                }
              },
            ),
            _buildNavItem(
              Icons.account_balance_wallet_outlined,
              'Transactions',
              activeItem == 'Transactions',
            ),
            _buildNavItem(
              Icons.pie_chart_outline,
              'Budget',
              activeItem == 'Budget',
            ),
            _buildNavItem(
              FontAwesomeIcons.champagneGlasses,
              'Events',
              activeItem == 'Events',
              onTap: () {
                Navigator.pop(context);
                if (activeItem != 'Events') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EventsScreen()),
                  );
                }
              },
            ),
            _buildNavItem(
              FontAwesomeIcons.boxesStacked,
              'Inventory',
              activeItem == 'Inventory',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InventoryListScreen()),
                );
              },
            ),
            _buildNavItem(
              Icons.settings_outlined,
              'Settings',
              activeItem == 'Settings',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
            _buildNavItem(
              FontAwesomeIcons.headset,
              'Support & Help',
              activeItem == 'Support',
              onTap: () {
                Navigator.pop(context);
                if (activeItem != 'Support') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SupportScreen()),
                  );
                }
              },
            ),
            const Spacer(),
            const Divider(color: Colors.white24),
            _buildNavItem(
              FontAwesomeIcons.trashCan,
              'Delete Account',
              false,
              iconColor: AppTheme.white.withValues(alpha: 0.6),
              textColor: AppTheme.white.withValues(alpha: 0.6),
              onTap: () {
                Navigator.pop(context);
                showDeleteAccountDialog(context, isBusiness: false);
              },
            ),
            _buildNavItem(
              Icons.logout,
              'Logout',
              false,
              onTap: () => AuthService.logout(context),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    dynamic icon,
    String title,
    bool isSelected, {
    VoidCallback? onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    final Color effectiveIconColor =
        iconColor ?? (isSelected ? AppTheme.accentBlue : AppTheme.white);
    final Color effectiveTextColor =
        textColor ?? (isSelected ? AppTheme.accentBlue : AppTheme.white);
    return ListTile(
      leading: icon is IconData
          ? Icon(icon, color: effectiveIconColor)
          : FaIcon(icon, color: effectiveIconColor, size: 20),
      title: AppText.button(
        title,
        style: TextStyle(
          color: effectiveTextColor,
        ),
      ),
      onTap: onTap ?? () {},
    );
  }
}

