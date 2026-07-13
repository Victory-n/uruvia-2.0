import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/screens/auth_screens/login_registration_screens.dart';
import 'package:uruvia/widgets/custom_text.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // State variables for various interactive switches
  bool _biometricLogin = true;
  bool _newInvoices = true;
  bool _lowStockAlerts = true;
  bool _reminders = false;
  bool _autoSync = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    // Dynamic user retrieval
    final user = Supabase.instance.client.auth.currentUser;
    final userMetadata = user?.userMetadata;
    final String firstName = userMetadata?['first_name'] ?? 'Ada';
    final String lastName = userMetadata?['last_name'] ?? 'Lovelace';
    final String fullName = "$firstName $lastName";
    final String email = user?.email ?? 'ada.lovelace@example.com';
    final String userInitials = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'A';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        backgroundColor: const Color(0xFFF9FAFC),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(CupertinoIcons.bars, color: ConstantColor.headingTextPrimary),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: googleSansText(
          text: "Settings",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 20.0,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Profile Details Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.015),
                        blurRadius: 10.0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 38.0,
                            backgroundColor: const Color(0xFFEFF6FF),
                            child: googleSansText(
                              text: userInitials,
                              colors: ConstantColor.blueBackground,
                              fontWeight: FontWeight.bold,
                              size: 28.0,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4.0),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(CupertinoIcons.checkmark_alt, size: 10.0, color: Colors.white),
                          )
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      googleSansText(
                        text: fullName,
                        colors: ConstantColor.headingTextPrimary,
                        fontWeight: FontWeight.bold,
                        size: 18.0,
                      ),
                      const SizedBox(height: 2.0),
                      googleSansText(
                        text: email,
                        colors: ConstantColor.paragraphTextSecondary,
                        fontWeight: FontWeight.normal,
                        size: 13.0,
                      ),
                      const SizedBox(height: 10.0),
                      // Pro Plan Active Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(CupertinoIcons.sparkles, color: ConstantColor.blueBackground, size: 12.0),
                            const SizedBox(width: 4.0),
                            googleSansText(
                              text: "Pro Plan Active",
                              colors: ConstantColor.blueBackground,
                              fontWeight: FontWeight.bold,
                              size: 11.5,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      // Manage Plan Button
                      SizedBox(
                        width: 140.0,
                        height: 38.0,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: googleSansText(
                                  text: "Loading billing gateway...",
                                  colors: Colors.white,
                                  fontWeight: FontWeight.normal,
                                  size: 14.0,
                                ),
                                backgroundColor: ConstantColor.blueBackground,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ConstantColor.blueBackground,
                            elevation: 0.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: googleSansText(
                            text: "Manage Plan",
                            colors: Colors.white,
                            fontWeight: FontWeight.bold,
                            size: 13.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),

                // 2. Settings Group: ACCOUNT
                _buildSectionHeader("ACCOUNT"),
                _buildGroupedCard([
                  _buildListTile(
                    label: "Personal Details",
                    leadingIcon: CupertinoIcons.person,
                    trailing: const Icon(CupertinoIcons.chevron_right, size: 14.0, color: Color(0xFFBBBBBB)),
                    onTap: () {},
                  ),
                  _buildListTile(
                    label: "Security & Passwords",
                    leadingIcon: CupertinoIcons.shield,
                    trailing: const Icon(CupertinoIcons.chevron_right, size: 14.0, color: Color(0xFFBBBBBB)),
                    onTap: () {},
                  ),
                  _buildListTileWithSwitch(
                    label: "Biometric Login",
                    subtitle: "Use FaceID / Fingerprint",
                    leadingIcon: CupertinoIcons.device_phone_portrait,
                    value: _biometricLogin,
                    onChanged: (val) {
                      setState(() {
                        _biometricLogin = val;
                      });
                    },
                  ),
                ]),
                const SizedBox(height: 20.0),

                // 3. Settings Group: NOTIFICATIONS
                _buildSectionHeader("NOTIFICATIONS"),
                _buildGroupedCard([
                  _buildListTileWithSwitch(
                    label: "New Invoices",
                    leadingIcon: CupertinoIcons.doc_text,
                    value: _newInvoices,
                    onChanged: (val) {
                      setState(() {
                        _newInvoices = val;
                      });
                    },
                  ),
                  _buildListTileWithSwitch(
                    label: "Low Stock Alerts",
                    leadingIcon: CupertinoIcons.archivebox,
                    value: _lowStockAlerts,
                    onChanged: (val) {
                      setState(() {
                        _lowStockAlerts = val;
                      });
                    },
                  ),
                  _buildListTileWithSwitch(
                    label: "Reminders",
                    leadingIcon: CupertinoIcons.calendar,
                    value: _reminders,
                    onChanged: (val) {
                      setState(() {
                        _reminders = val;
                      });
                    },
                  ),
                ]),
                const SizedBox(height: 20.0),

                // 4. Settings Group: SYNC & STORAGE
                _buildSectionHeader("SYNC & STORAGE"),
                _buildGroupedCard([
                  _buildListTile(
                    label: "Manual Sync",
                    subtitle: "Last synced 2m ago",
                    leadingIcon: CupertinoIcons.arrow_2_circlepath,
                    trailing: InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: googleSansText(
                              text: "Synchronized commands successfully!",
                              colors: Colors.white,
                              fontWeight: FontWeight.bold,
                              size: 14.0,
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: googleSansText(
                          text: "Sync Now",
                          colors: ConstantColor.blueBackground,
                          fontWeight: FontWeight.bold,
                          size: 13.0,
                        ),
                      ),
                    ),
                    onTap: () {},
                  ),
                  _buildListTileWithSwitch(
                    label: "Auto-sync Data",
                    leadingIcon: CupertinoIcons.arrow_up_doc,
                    value: _autoSync,
                    onChanged: (val) {
                      setState(() {
                        _autoSync = val;
                      });
                    },
                  ),
                  _buildListTile(
                    label: "Clear Cache",
                    leadingIcon: CupertinoIcons.delete,
                    trailing: googleSansText(
                      text: "142 MB",
                      colors: ConstantColor.paragraphTextSecondary,
                      fontWeight: FontWeight.bold,
                      size: 13.0,
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: googleSansText(
                            text: "Cache cleared successfully!",
                            colors: Colors.white,
                            fontWeight: FontWeight.normal,
                            size: 14.0,
                          ),
                          backgroundColor: Colors.black87,
                        ),
                      );
                    },
                  ),
                ]),
                const SizedBox(height: 20.0),

                // 5. Settings Group: PREFERENCES
                _buildSectionHeader("PREFERENCES"),
                _buildGroupedCard([
                  _buildListTileWithSwitch(
                    label: "Dark Mode",
                    leadingIcon: CupertinoIcons.moon,
                    value: _darkMode,
                    onChanged: (val) {
                      setState(() {
                        _darkMode = val;
                      });
                    },
                  ),
                  _buildListTile(
                    label: "Language",
                    leadingIcon: CupertinoIcons.globe,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        googleSansText(
                          text: "English (US)",
                          colors: ConstantColor.paragraphTextSecondary,
                          fontWeight: FontWeight.normal,
                          size: 13.0,
                        ),
                        const SizedBox(width: 4.0),
                        const Icon(CupertinoIcons.chevron_right, size: 14.0, color: Color(0xFFBBBBBB)),
                      ],
                    ),
                    onTap: () {},
                  ),
                  _buildListTile(
                    label: "Font Size",
                    leadingIcon: CupertinoIcons.textformat,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        googleSansText(
                          text: "Medium",
                          colors: ConstantColor.paragraphTextSecondary,
                          fontWeight: FontWeight.normal,
                          size: 13.0,
                        ),
                        const SizedBox(width: 4.0),
                        const Icon(CupertinoIcons.chevron_right, size: 14.0, color: Color(0xFFBBBBBB)),
                      ],
                    ),
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: 20.0),

                // 6. Settings Group: SUPPORT
                _buildSectionHeader("SUPPORT"),
                _buildGroupedCard([
                  _buildListTile(
                    label: "WhatsApp Chat Help",
                    leadingIcon: CupertinoIcons.chat_bubble_2,
                    trailing: const Icon(CupertinoIcons.share, size: 14.0, color: Color(0xFFBBBBBB)),
                    onTap: () {},
                  ),
                  _buildListTile(
                    label: "FAQ",
                    leadingIcon: CupertinoIcons.question_circle,
                    trailing: const Icon(CupertinoIcons.chevron_right, size: 14.0, color: Color(0xFFBBBBBB)),
                    onTap: () {},
                  ),
                  _buildListTile(
                    label: "About Uruvia",
                    subtitle: "v1.0.4",
                    leadingIcon: CupertinoIcons.info,
                    trailing: const Icon(CupertinoIcons.chevron_right, size: 14.0, color: Color(0xFFBBBBBB)),
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: 28.0),

                // 7. Log Out Option Button
                Container(
                  width: double.infinity,
                  height: 50.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: const Color(0xFFFFCDD2), width: 1.0),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        await Supabase.instance.client.auth.signOut();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginRegistrationScreens()),
                            (route) => false,
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(CupertinoIcons.square_arrow_right, color: Color(0xFFC62828), size: 18.0),
                          const SizedBox(width: 8.0),
                          googleSansText(
                            text: "Log Out",
                            colors: const Color(0xFFC62828),
                            fontWeight: FontWeight.bold,
                            size: 15.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Section header helper
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: googleSansText(
        text: title,
        colors: ConstantColor.paragraphTextSecondary,
        fontWeight: FontWeight.bold,
        size: 11.5,
      ),
    );
  }

  // Grouped Card container helper
  Widget _buildGroupedCard(List<Widget> children) {
    List<Widget> items = [];
    for (int i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i < children.length - 1) {
        items.add(const Divider(color: Color(0xFFF1F5F9), height: 1.0, indent: 48.0));
      }
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(children: items),
    );
  }

  // Individual setting list tile helper
  Widget _buildListTile({
    required String label,
    String? subtitle,
    required IconData leadingIcon,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 32.0,
        height: 32.0,
        decoration: const BoxDecoration(
          color: Color(0xFFEFF6FF),
          shape: BoxShape.circle,
        ),
        child: Icon(leadingIcon, color: ConstantColor.blueBackground, size: 16.0),
      ),
      title: googleSansText(
        text: label,
        colors: ConstantColor.headingTextPrimary,
        fontWeight: FontWeight.bold,
        size: 14.5,
      ),
      subtitle: subtitle != null
          ? googleSansText(
              text: subtitle,
              colors: ConstantColor.paragraphTextSecondary,
              fontWeight: FontWeight.normal,
              size: 11.0,
            )
          : null,
      trailing: trailing,
      dense: subtitle == null,
    );
  }

  // Switch list tile helper
  Widget _buildListTileWithSwitch({
    required String label,
    String? subtitle,
    required IconData leadingIcon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return _buildListTile(
      label: label,
      subtitle: subtitle,
      leadingIcon: leadingIcon,
      trailing: Transform.scale(
        scale: 0.8,
        child: CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeColor: ConstantColor.blueBackground,
        ),
      ),
      onTap: () => onChanged(!value),
    );
  }
}
