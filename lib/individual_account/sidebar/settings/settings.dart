import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../theme/individual/app_theme.dart';
import '../../../shared/widgets/app_text.dart';
import '../../../business_account/welcome/business_onboarding_prompt_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isBusinessAccount = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const AppText.subtitle('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const AppText.custom(
            'Account',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const FaIcon(
              FontAwesomeIcons.user,
              color: AppTheme.sleekBlue,
              size: 16,
            ),
            title: const AppText.paragraph('Profile Information'),
            trailing: const FaIcon(
              FontAwesomeIcons.chevronRight,
              color: AppTheme.textMuted,
              size: 16,
            ),
            contentPadding: EdgeInsets.zero,
            onTap: () {
              // TODO: Navigate to Profile Information
            },
          ),
          const Divider(thickness: 0.2),
          ListTile(
            leading: const FaIcon(
              FontAwesomeIcons.lock,
              color: AppTheme.sleekBlue,
              size: 16,
            ),
            title: const AppText.paragraph('Security & Password'),
            trailing: const FaIcon(
              FontAwesomeIcons.chevronRight,
              color: AppTheme.textMuted,
              size: 16,
            ),
            contentPadding: EdgeInsets.zero,
            onTap: () {
              // TODO: Navigate to Security & Password
            },
          ),
          const Divider(thickness: 0.2),
          ListTile(
            leading: const FaIcon(
              FontAwesomeIcons.idBadge,
              color: AppTheme.sleekBlue,
            ),
            title: const AppText.paragraph('Account Type'),
            trailing: const AppText.custom(
              'Individual Account',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
            ),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.accentBlue.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText.paragraph(
                        'Switch to Business Account',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      AppText.custom(
                        'Upgrade to manage your business finances, employees, and advanced reporting.',
                        style: TextStyle(
                          color: AppTheme.textMuted.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Switch(
                  value: _isBusinessAccount,
                  onChanged: (value) {
                    setState(() {
                      _isBusinessAccount = value;
                    });
                    if (value) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BusinessOnboardingPromptScreen(),
                        ),
                      ).then((_) {
                        // Reset switch if they cancel onboarding (optional, for better UX)
                        setState(() {
                          _isBusinessAccount = false;
                        });
                      });
                    }
                  },
                  activeColor: AppTheme.sleekBlue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(thickness: 0.2),
        ],
      ),
    );
  }
}
