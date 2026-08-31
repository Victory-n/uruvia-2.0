import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/individual/dashboard.dart';
import 'package:uruvia/individual/finances/finance.dart';
import 'package:uruvia/individual/settings/settings.dart';
import 'package:uruvia/services/auth_service.dart';
import 'package:uruvia/shared/features/budgeting/budgeting_screen.dart';
import 'package:uruvia/shared/features/calculator/savings_calculator_screen.dart';
import 'package:uruvia/shared/features/wallet/wallet_page.dart';
import 'package:uruvia/shared/screens/welcome_screens/welcome_screen.dart';
import 'package:uruvia/shared/widgets/custom_text.dart';

enum IndividualSidebarRoute {
  dashboard,
  finances,
  wallet,
  budgeting,
  calculator,
  settings,
  none,
}

class IndividualSidebar extends StatefulWidget {
  final IndividualSidebarRoute currentRoute;
  final String userName;
  final String userEmail;

  const IndividualSidebar({
    super.key,
    this.currentRoute = IndividualSidebarRoute.none,
    this.userName = "Alex",
    this.userEmail = "alex@uruvia.app",
  });

  @override
  State<IndividualSidebar> createState() => _IndividualSidebarState();
}

class _IndividualSidebarState extends State<IndividualSidebar> {
  String _displayName = "";
  String _displayEmail = "";

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      final meta = currentUser.userMetadata;
      final firstName = meta?['firstname'] ?? meta?['first_name'] ?? "";
      final lastName = meta?['lastname'] ?? meta?['last_name'] ?? "";
      final fullName = "$firstName".trim();

      if (mounted) {
        setState(() {
          _displayName = fullName.isNotEmpty
              ? fullName
              : (widget.userName != "Alex" ? widget.userName : "User");
          _displayEmail = currentUser.email ?? widget.userEmail;
        });
      }

      try {
        final profile = await AuthService.instance.getUserProfile(currentUser.id);
        if (profile != null && profile.firstname.trim().isNotEmpty && mounted) {
          setState(() {
            _displayName = profile.firstname.trim();
          });
        }
      } catch (_) {}
    } else {
      if (mounted) {
        setState(() {
          _displayName = widget.userName;
          _displayEmail = widget.userEmail;
        });
      }
    }
  }

  void _navigateTo(Widget targetScreen, IndividualSidebarRoute targetRoute) {
    Navigator.of(context).pop(); // Close drawer first

    if (widget.currentRoute == targetRoute) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: googleSansText(
          text: "Confirm Logout",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 18.0,
        ),
        content: googleSansText(
          text: "Are you sure you want to sign out of your Uruvia account?",
          colors: ConstantColor.paragraphTextSecondary,
          fontWeight: FontWeight.normal,
          size: 14.0,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: googleSansText(
              text: "Cancel",
              colors: ConstantColor.paragraphTextSecondary,
              fontWeight: FontWeight.w600,
              size: 14.0,
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              elevation: 0,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: googleSansText(
              text: "Logout",
              colors: Colors.white,
              fontWeight: FontWeight.bold,
              size: 14.0,
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await AuthService.instance.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String initial = _displayName.isNotEmpty
        ? _displayName[0].toUpperCase()
        : "U";

    return Drawer(
      backgroundColor: Colors.white,
      elevation: 16.0,
      child: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 50.0,
              bottom: 24.0,
              left: 20.0,
              right: 20.0,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [ConstantColor.blueBackground, Color(0xFF003C8F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white.withOpacity(0.25),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white,
                        child: googleSansText(
                          text: initial,
                          colors: ConstantColor.blueBackground,
                          fontWeight: FontWeight.bold,
                          size: 22.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: googleSansText(
                                  text: _displayName,
                                  colors: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  size: 16.5,
                                ),
                              ),
                              const SizedBox(width: 4.0),
                              const Icon(
                                Icons.verified_rounded,
                                color: Colors.lightBlueAccent,
                                size: 16.0,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2.0),
                          googleSansText(
                            text: _displayEmail,
                            colors: Colors.white.withOpacity(0.85),
                            fontWeight: FontWeight.w400,
                            size: 12.0,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7.0,
                        height: 7.0,
                        decoration: const BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6.0),
                      googleSansText(
                        text: "INDIVIDUAL ACCOUNT",
                        colors: Colors.white,
                        fontWeight: FontWeight.bold,
                        size: 10.0,
                        letterSpacing: 0.5,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu Navigation List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 8.0,
              ),
              children: [
                _buildSectionHeader("OVERVIEW"),
                _buildNavItem(
                  icon: Icons.dashboard_rounded,
                  label: "Dashboard",
                  route: IndividualSidebarRoute.dashboard,
                  onTap: () => _navigateTo(
                    IndividualDashboard(userName: _displayName),
                    IndividualSidebarRoute.dashboard,
                  ),
                ),
                const SizedBox(height: 12.0),

                _buildSectionHeader("FINANCIAL SERVICES"),
                _buildNavItem(
                  icon: Icons.account_balance_wallet_rounded,
                  label: "Finances & Activity",
                  route: IndividualSidebarRoute.finances,
                  onTap: () => _navigateTo(
                    const IndividualFinancePage(),
                    IndividualSidebarRoute.finances,
                  ),
                ),
                _buildNavItem(
                  icon: Icons.credit_card_rounded,
                  label: "Wallet & Virtual Cards",
                  route: IndividualSidebarRoute.wallet,
                  onTap: () => _navigateTo(
                    IndividualWalletPage(userName: _displayName),
                    IndividualSidebarRoute.wallet,
                  ),
                ),
                _buildNavItem(
                  icon: Icons.pie_chart_rounded,
                  label: "Budget Planner",
                  route: IndividualSidebarRoute.budgeting,
                  onTap: () => _navigateTo(
                    const BudgetingScreen(isBusiness: false),
                    IndividualSidebarRoute.budgeting,
                  ),
                ),
                _buildNavItem(
                  icon: Icons.calculate_rounded,
                  label: "Savings Calculator",
                  route: IndividualSidebarRoute.calculator,
                  onTap: () => _navigateTo(
                    const SavingsCalculatorScreen(isBusiness: false),
                    IndividualSidebarRoute.calculator,
                  ),
                ),
                const SizedBox(height: 12.0),

                _buildSectionHeader("PREFERENCES"),
                _buildNavItem(
                  icon: Icons.settings_rounded,
                  label: "Settings & Security",
                  route: IndividualSidebarRoute.settings,
                  onTap: () => _navigateTo(
                    IndividualSettingsPage(
                      userEmail: _displayEmail,
                      onLogout: _handleLogout,
                    ),
                    IndividualSidebarRoute.settings,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1.0, color: Color(0xFFEEEEEE)),

          // Footer Logout & App Info
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                InkWell(
                  onTap: _handleLogout,
                  borderRadius: BorderRadius.circular(12.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 12.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.logout_rounded,
                          color: Colors.redAccent,
                          size: 20.0,
                        ),
                        const SizedBox(width: 12.0),
                        googleSansText(
                          text: "Log Out",
                          colors: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          size: 14.0,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                googleSansText(
                  text: "Uruvia Enterprise v2.0",
                  colors: ConstantColor.paragraphTextSecondary,
                  fontWeight: FontWeight.w400,
                  size: 11.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, top: 8.0, bottom: 6.0),
      child: googleSansText(
        text: title,
        colors: ConstantColor.paragraphTextSecondary,
        fontWeight: FontWeight.bold,
        size: 11.0,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required IndividualSidebarRoute route,
    required VoidCallback onTap,
  }) {
    final isSelected = widget.currentRoute == route;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 11.0,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? ConstantColor.blueBackground.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 21.0,
                  color: isSelected
                      ? ConstantColor.blueBackground
                      : ConstantColor.headingTextPrimary.withOpacity(0.7),
                ),
                const SizedBox(width: 14.0),
                Expanded(
                  child: googleSansText(
                    text: label,
                    colors: isSelected
                        ? ConstantColor.blueBackground
                        : ConstantColor.headingTextPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    size: 13.5,
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 6.0,
                    height: 6.0,
                    decoration: const BoxDecoration(
                      color: ConstantColor.blueBackground,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
