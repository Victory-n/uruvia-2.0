import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../shared/features/events/screens/events_screen.dart';
import '../../../shared/features/inventory/screens/inventory_list_screen.dart';
import '../../../shared/widgets/app_text.dart';
import '../screens/dashboard_screen.dart';
import '../../theme/individual/app_theme.dart';
import 'settings/settings.dart';

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
                  const AppText.subtitle(
                    'Jonathan',
                    style: TextStyle(color: AppTheme.white),
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
            const Spacer(),
            const Divider(color: Colors.white24),
            _buildNavItem(Icons.logout, 'Logout', false),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(dynamic icon, String title, bool isSelected, {VoidCallback? onTap}) {
    final Color iconColor = isSelected ? AppTheme.accentBlue : AppTheme.white;
    return ListTile(
      leading: icon is IconData
          ? Icon(icon, color: iconColor)
          : FaIcon(icon, color: iconColor, size: 20),
      title: AppText.button(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.accentBlue : AppTheme.white,
        ),
      ),
      onTap: onTap ?? () {},
    );
  }
}
