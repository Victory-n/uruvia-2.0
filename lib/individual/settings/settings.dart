import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'profile_information_screen.dart';
import '../sidebar/individual_sidebar.dart';
import '../../shared/widgets/custom_text.dart';

class IndividualSettingsPage extends StatefulWidget {
  final String userEmail;
  final VoidCallback? onLogout;

  const IndividualSettingsPage({
    super.key,
    this.userEmail = "user@uruvia.app",
    this.onLogout,
  });

  @override
  State<IndividualSettingsPage> createState() => _IndividualSettingsPageState();
}

class _IndividualSettingsPageState extends State<IndividualSettingsPage> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _dimplesMascotEnabled = true;
  bool _homeWidgetSyncEnabled = true;
  bool _comedicNudgesEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantColor.lightBackground,
      drawer: IndividualSidebar(
        currentRoute: IndividualSidebarRoute.settings,
        userEmail: widget.userEmail,
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: Builder(
          builder: (scaffoldContext) => IconButton(
            icon: const Icon(Icons.menu, color: ConstantColor.headingTextPrimary),
            onPressed: () {
              Scaffold.of(scaffoldContext).openDrawer();
            },
          ),
        ),
        title: googleSansText(
          text: "Settings",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 18.0,
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        children: [
          // Account Section Header
          googleSansText(
            text: "Account",
            colors: ConstantColor.paragraphTextSecondary,
            fontWeight: FontWeight.bold,
            size: 13.0,
          ),
          const SizedBox(height: 8.0),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline, color: ConstantColor.blueBackground),
                  title: googleSansText(
                    text: "Profile Information",
                    colors: ConstantColor.headingTextPrimary,
                    fontWeight: FontWeight.w600,
                    size: 14.5,
                  ),
                  subtitle: googleSansText(
                    text: widget.userEmail,
                    colors: ConstantColor.paragraphTextSecondary,
                    fontWeight: FontWeight.normal,
                    size: 12.0,
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ProfileInformationScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_outline, color: ConstantColor.blueBackground),
                  title: googleSansText(
                    text: "Security & Password",
                    colors: ConstantColor.headingTextPrimary,
                    fontWeight: FontWeight.w600,
                    size: 14.5,
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24.0),

          // Uruvia Intelligence & Dimples Mascot Section
          googleSansText(
            text: "Uruvia Intelligence & Mascot",
            colors: ConstantColor.paragraphTextSecondary,
            fontWeight: FontWeight.bold,
            size: 13.0,
          ),
          const SizedBox(height: 8.0),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: _dimplesMascotEnabled,
                  onChanged: (val) => setState(() => _dimplesMascotEnabled = val),
                  activeColor: ConstantColor.blueBackground,
                  secondary: const Icon(
                    Icons.auto_awesome_rounded,
                    color: ConstantColor.blueBackground,
                  ),
                  title: googleSansText(
                    text: "Enable Dimples Mascot",
                    colors: ConstantColor.headingTextPrimary,
                    fontWeight: FontWeight.bold,
                    size: 14.5,
                  ),
                  subtitle: googleSansText(
                    text: "App intelligence companion & funny account marketer",
                    colors: ConstantColor.paragraphTextSecondary,
                    fontWeight: FontWeight.w400,
                    size: 12.0,
                  ),
                ),
                if (_dimplesMascotEnabled) ...[
                  const Divider(height: 1),
                  SwitchListTile(
                    value: _homeWidgetSyncEnabled,
                    onChanged: (val) => setState(() => _homeWidgetSyncEnabled = val),
                    activeColor: ConstantColor.blueBackground,
                    secondary: const Icon(
                      Icons.widgets_outlined,
                      color: ConstantColor.blueBackground,
                    ),
                    title: googleSansText(
                      text: "OS Home Screen Widget Sync",
                      colors: ConstantColor.headingTextPrimary,
                      fontWeight: FontWeight.w600,
                      size: 14.5,
                    ),
                    subtitle: googleSansText(
                      text: "Sync Dimples & account intel to phone home screen",
                      colors: ConstantColor.paragraphTextSecondary,
                      fontWeight: FontWeight.w400,
                      size: 12.0,
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    value: _comedicNudgesEnabled,
                    onChanged: (val) => setState(() => _comedicNudgesEnabled = val),
                    activeColor: ConstantColor.blueBackground,
                    secondary: const Icon(
                      Icons.campaign_outlined,
                      color: ConstantColor.blueBackground,
                    ),
                    title: googleSansText(
                      text: "Comedic Pro & Business Nudges",
                      colors: ConstantColor.headingTextPrimary,
                      fontWeight: FontWeight.w600,
                      size: 14.5,
                    ),
                    subtitle: googleSansText(
                      text: "Humorous marketing advice for sales spikes & plan upgrades",
                      colors: ConstantColor.paragraphTextSecondary,
                      fontWeight: FontWeight.w400,
                      size: 12.0,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24.0),

          // Preferences Section
          googleSansText(
            text: "Preferences",
            colors: ConstantColor.paragraphTextSecondary,
            fontWeight: FontWeight.bold,
            size: 13.0,
          ),
          const SizedBox(height: 8.0),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: _notificationsEnabled,
                  onChanged: (val) => setState(() => _notificationsEnabled = val),
                  activeColor: ConstantColor.blueBackground,
                  title: googleSansText(
                    text: "Push Notifications",
                    colors: ConstantColor.headingTextPrimary,
                    fontWeight: FontWeight.w600,
                    size: 14.5,
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: _biometricEnabled,
                  onChanged: (val) => setState(() => _biometricEnabled = val),
                  activeColor: ConstantColor.blueBackground,
                  title: googleSansText(
                    text: "Biometric Login",
                    colors: ConstantColor.headingTextPrimary,
                    fontWeight: FontWeight.w600,
                    size: 14.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24.0),

          // Sign Out Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: ListTile(
              leading: const Icon(CupertinoIcons.square_arrow_right, color: Colors.redAccent),
              title: googleSansText(
                text: "Log Out",
                colors: Colors.redAccent,
                fontWeight: FontWeight.bold,
                size: 14.5,
              ),
              onTap: () {
                if (widget.onLogout != null) {
                  widget.onLogout!();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
