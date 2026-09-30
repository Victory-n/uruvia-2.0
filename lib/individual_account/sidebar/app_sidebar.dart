import 'package:flutter/material.dart';
import '../../../shared/widgets/app_text.dart';
import '../../theme/individual/app_theme.dart';
import 'settings/settings.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

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
            _buildNavItem(Icons.dashboard_outlined, 'Dashboard', true),
            _buildNavItem(Icons.account_balance_wallet_outlined, 'Transactions', false),
            _buildNavItem(Icons.pie_chart_outline, 'Budget', false),
            _buildNavItem(
              Icons.settings_outlined,
              'Settings',
              false,
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

  Widget _buildNavItem(IconData icon, String title, bool isSelected, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.accentBlue : AppTheme.white),
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
