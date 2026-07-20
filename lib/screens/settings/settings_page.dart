import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/organizations/organization_onboarding_screen.dart';
import 'package:uruvia/screens/auth_screens/login_registration_screens.dart';
import 'package:uruvia/widgets/custom_text.dart';
import 'package:uruvia/offline/database_helper.dart';
import 'package:uruvia/services/subscription_service.dart';
import 'package:uruvia/widgets/paywall_dialog.dart';
import 'package:uruvia/classes/custom_snackbar.dart';

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

  // Business Account state
  bool _isBusinessAccount = false;

  // New settings for Auto-Create Tasks & Reminders
  bool _autoTaskLowStock = true;
  bool _autoTaskOverdueInvoice = true;
  bool _autoTaskExpenseReminder = false;
  bool _autoTaskSalesFulfillment = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final dbHelper = DatabaseHelper.instance;
    final biometric = await dbHelper.getSetting(
      'setting_biometric_login',
      defaultValue: true,
    );
    final newInvoices = await dbHelper.getSetting(
      'setting_notification_new_invoices',
      defaultValue: true,
    );
    final lowStockAlerts = await dbHelper.getSetting(
      'setting_notification_low_stock',
      defaultValue: true,
    );
    final reminders = await dbHelper.getSetting(
      'setting_notification_reminders',
      defaultValue: true,
    );

    final lowStock = await dbHelper.getSetting(
      'setting_auto_task_low_stock',
      defaultValue: true,
    );
    final overdueInvoice = await dbHelper.getSetting(
      'setting_auto_task_overdue_invoice',
      defaultValue: true,
    );
    final expenseReminder = await dbHelper.getSetting(
      'setting_auto_task_expense_reminder',
      defaultValue: false,
    );
    final salesFulfillment = await dbHelper.getSetting(
      'setting_auto_task_sales_fulfillment',
      defaultValue: true,
    );

    final user = Supabase.instance.client.auth.currentUser;
    final isBusiness = user?.userMetadata?['has_onboarded_business'] ?? false;

    if (mounted) {
      setState(() {
        _biometricLogin = biometric;
        _newInvoices = newInvoices;
        _lowStockAlerts = lowStockAlerts;
        _reminders = reminders;

        _autoTaskLowStock = lowStock;
        _autoTaskOverdueInvoice = overdueInvoice;
        _autoTaskExpenseReminder = expenseReminder;
        _autoTaskSalesFulfillment = salesFulfillment;
        _isBusinessAccount = isBusiness;
      });
    }
  }

  Future<void> _toggleBusinessAccount(bool val) async {
    if (val) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const OrganizationOnboardingScreen(isFromSettings: true),
        ),
      );
      _loadSettings();
    } else {
      await _handleDisableBusinessAccount();
    }
  }

  Future<void> _handleDisableBusinessAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: googleSansText(
          text: "Deactivate Business Account?",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 18.0,
        ),
        content: googleSansText(
          text:
              "Switching back to personal mode will hide business organization details. You can switch back to a business account anytime.",
          colors: ConstantColor.paragraphTextSecondary,
          fontWeight: FontWeight.normal,
          size: 14.0,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: googleSansText(
              text: "Cancel",
              colors: ConstantColor.paragraphTextSecondary,
              fontWeight: FontWeight.w600,
              size: 14.0,
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: googleSansText(
              text: "Deactivate",
              colors: Colors.white,
              fontWeight: FontWeight.bold,
              size: 14.0,
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(data: {'has_onboarded_business': false}),
        );
        _loadSettings();
        if (mounted) {
          CustomSnackbar.showNormal(context, "Switched to Personal Account mode.");
        }
      } catch (error) {
        if (mounted) {
          CustomSnackbar.showFailed(context, "Failed to update account mode: $error");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic user retrieval
    final user = Supabase.instance.client.auth.currentUser;
    final userMetadata = user?.userMetadata;
    final String firstName = userMetadata?['first_name'] ?? 'Ada';
    final String lastName = userMetadata?['last_name'] ?? 'Lovelace';
    final String fullName = "$firstName $lastName";
    final String email = user?.email ?? 'ada.lovelace@example.com';
    final String userInitials = firstName.isNotEmpty
        ? firstName[0].toUpperCase()
        : 'A';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        backgroundColor: const Color(0xFFF9FAFC),
        leading: Navigator.canPop(context)
            ? null
            : IconButton(
                icon: const Icon(
                  CupertinoIcons.bars,
                  color: ConstantColor.headingTextPrimary,
                ),
                onPressed: () => Scaffold.maybeOf(context)?.openDrawer(),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
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
                            child: const Icon(
                              CupertinoIcons.checkmark_alt,
                              size: 10.0,
                              color: Colors.white,
                            ),
                          ),
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
                      // Dynamic Plan Active Badge
                      Builder(
                        builder: (context) {
                          final capabilities = SubscriptionService.instance.currentCapabilities;
                          final isPremium = capabilities.isPremium;

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 4.5,
                            ),
                            decoration: BoxDecoration(
                              color: isPremium ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isPremium ? CupertinoIcons.sparkles : CupertinoIcons.person_fill,
                                  color: isPremium ? ConstantColor.blueBackground : ConstantColor.paragraphTextSecondary,
                                  size: 12.0,
                                ),
                                const SizedBox(width: 4.0),
                                googleSansText(
                                  text: isPremium ? "Pro Plan Active" : "Free Plan Active",
                                  colors: isPremium ? ConstantColor.blueBackground : ConstantColor.paragraphTextSecondary,
                                  fontWeight: FontWeight.bold,
                                  size: 11.5,
                                ),
                              ],
                            ),
                          );
                        }
                      ),
                      const SizedBox(height: 16.0),
                      // Manage Plan Button
                      SizedBox(
                        width: 140.0,
                        height: 38.0,
                        child: ElevatedButton(
                          onPressed: () async {
                            await PaywallDialog.show(context);
                            setState(() {});
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
                  _buildListTileWithSwitch(
                    label: "Business Account",
                    subtitle: _isBusinessAccount
                        ? "Business workspace active"
                        : "Switch to business account & setup organization",
                    leadingIcon: CupertinoIcons.briefcase,
                    value: _isBusinessAccount,
                    onChanged: (val) {
                      _toggleBusinessAccount(val);
                    },
                  ),
                  _buildListTile(
                    label: "Personal Details",
                    leadingIcon: CupertinoIcons.person,
                    trailing: const Icon(
                      CupertinoIcons.chevron_right,
                      size: 14.0,
                      color: Color(0xFFBBBBBB),
                    ),
                    onTap: () {},
                  ),
                  _buildListTile(
                    label: "Security & Passwords",
                    leadingIcon: CupertinoIcons.shield,
                    trailing: const Icon(
                      CupertinoIcons.chevron_right,
                      size: 14.0,
                      color: Color(0xFFBBBBBB),
                    ),
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
                      DatabaseHelper.instance.setSetting(
                        'setting_biometric_login',
                        val,
                      );
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
                      DatabaseHelper.instance.setSetting(
                        'setting_notification_new_invoices',
                        val,
                      );
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
                      DatabaseHelper.instance.setSetting(
                        'setting_notification_low_stock',
                        val,
                      );
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
                      DatabaseHelper.instance.setSetting(
                        'setting_notification_reminders',
                        val,
                      );
                    },
                  ),
                ]),
                const SizedBox(height: 20.0),

                // 3.5 Settings Group: AUTO-TASKS & REMINDERS
                _buildSectionHeader("AUTO-TASKS & REMINDERS"),
                _buildGroupedCard([
                  _buildListTileWithSwitch(
                    label: "Low Stock Auto-Tasks",
                    subtitle: "Auto-create tasks when stock is low",
                    leadingIcon: CupertinoIcons.archivebox_fill,
                    value: _autoTaskLowStock,
                    onChanged: (val) {
                      setState(() {
                        _autoTaskLowStock = val;
                      });
                      DatabaseHelper.instance.setSetting(
                        'setting_auto_task_low_stock',
                        val,
                      );
                    },
                  ),
                  _buildListTileWithSwitch(
                    label: "Overdue Invoice Follow-ups",
                    subtitle: "Auto-create tasks when invoice is overdue",
                    leadingIcon: CupertinoIcons.doc_text_fill,
                    value: _autoTaskOverdueInvoice,
                    onChanged: (val) {
                      setState(() {
                        _autoTaskOverdueInvoice = val;
                      });
                      DatabaseHelper.instance.setSetting(
                        'setting_auto_task_overdue_invoice',
                        val,
                      );
                    },
                  ),
                  _buildListTileWithSwitch(
                    label: "Expense Payment Reminders",
                    subtitle: "Auto-create tasks for expense reminders",
                    leadingIcon: CupertinoIcons.creditcard_fill,
                    value: _autoTaskExpenseReminder,
                    onChanged: (val) {
                      setState(() {
                        _autoTaskExpenseReminder = val;
                      });
                      DatabaseHelper.instance.setSetting(
                        'setting_auto_task_expense_reminder',
                        val,
                      );
                    },
                  ),
                  _buildListTileWithSwitch(
                    label: "Sales Fulfillment Tasks",
                    subtitle: "Auto-create tasks when order is paid",
                    leadingIcon: CupertinoIcons.bag_fill,
                    value: _autoTaskSalesFulfillment,
                    onChanged: (val) {
                      setState(() {
                        _autoTaskSalesFulfillment = val;
                      });
                      DatabaseHelper.instance.setSetting(
                        'setting_auto_task_sales_fulfillment',
                        val,
                      );
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
                        CustomSnackbar.showSuccess(
                          context,
                          "Synchronized commands successfully!",
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
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
                      CustomSnackbar.showSuccess(
                        context,
                        "Cache cleared successfully!",
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
                      CustomSnackbar.showNormal(
                        context,
                        "Dark mode preference is coming soon!",
                      );
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
                        const Icon(
                          CupertinoIcons.chevron_right,
                          size: 14.0,
                          color: Color(0xFFBBBBBB),
                        ),
                      ],
                    ),
                    onTap: () {
                      CustomSnackbar.showNormal(
                        context,
                        "Language preference is coming soon!",
                      );
                    },
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
                        const Icon(
                          CupertinoIcons.chevron_right,
                          size: 14.0,
                          color: Color(0xFFBBBBBB),
                        ),
                      ],
                    ),
                    onTap: () {
                      CustomSnackbar.showNormal(
                        context,
                        "Font size preference is coming soon!",
                      );
                    },
                  ),
                ]),
                const SizedBox(height: 20.0),

                // 6. Settings Group: SUPPORT
                _buildSectionHeader("SUPPORT"),
                _buildGroupedCard([
                  _buildListTile(
                    label: "WhatsApp Chat Help",
                    leadingIcon: CupertinoIcons.chat_bubble_2,
                    trailing: const Icon(
                      CupertinoIcons.share,
                      size: 14.0,
                      color: Color(0xFFBBBBBB),
                    ),
                    onTap: () {},
                  ),
                  _buildListTile(
                    label: "FAQ",
                    leadingIcon: CupertinoIcons.question_circle,
                    trailing: const Icon(
                      CupertinoIcons.chevron_right,
                      size: 14.0,
                      color: Color(0xFFBBBBBB),
                    ),
                    onTap: () {},
                  ),
                  _buildListTile(
                    label: "About Uruvia",
                    subtitle: "v1.0.4",
                    leadingIcon: CupertinoIcons.info,
                    trailing: const Icon(
                      CupertinoIcons.chevron_right,
                      size: 14.0,
                      color: Color(0xFFBBBBBB),
                    ),
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
                    border: Border.all(
                      color: const Color(0xFFFFCDD2),
                      width: 1.0,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        await Supabase.instance.client.auth.signOut();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const LoginRegistrationScreens(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            CupertinoIcons.square_arrow_right,
                            color: Color(0xFFC62828),
                            size: 18.0,
                          ),
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
        items.add(
          const Divider(color: Color(0xFFF1F5F9), height: 1.0, indent: 48.0),
        );
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
        child: Icon(
          leadingIcon,
          color: ConstantColor.blueBackground,
          size: 16.0,
        ),
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
