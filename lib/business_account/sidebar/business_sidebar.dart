import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../shared/widgets/app_text.dart';
import 'package:uruvia/theme/business/business_theme.dart';
import '../screens/business_dashboard_screen.dart';
import '../screens/wallet/business_wallet_screen.dart';
import '../../../shared/features/inventory/screens/inventory_list_screen.dart';
import '../../../shared/function/delete_account.dart';
import '../../../shared/features/support/screens/support_screen.dart';
import '../../offline/profile_repository.dart';
import '../../shared/services/auth_service.dart';

class BusinessSidebar extends StatelessWidget {
  final String activeRoute;
  const BusinessSidebar({super.key, this.activeRoute = 'Dashboard'});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 260,
          margin: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: BusinessTheme.backgroundLight,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(4, 0),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 20, bottom: 8),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: BusinessTheme.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: FutureBuilder<Map<String, dynamic>?>(
                    future: ProfileRepository.instance.getCachedProfile(),
                    builder: (context, snapshot) {
                      final profile = snapshot.data;
                      final name =
                          '${profile?['first_name'] ?? ''} ${profile?['last_name'] ?? ''}'
                              .trim();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.subtitle(
                            name.isEmpty ? 'Uruvia User' : name,
                            style: const TextStyle(
                              color: BusinessTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const AppText.paragraph(
                            'Business Account',
                            style: TextStyle(color: BusinessTheme.textMuted),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                _buildDivider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildNavItem(
                          icon: FontAwesomeIcons.house,
                          label: 'Dashboard',
                          isSelected: activeRoute == 'Dashboard',
                          onTap: () {
                            Navigator.pop(context); // Close the drawer
                            if (activeRoute != 'Dashboard') {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const BusinessDashboardScreen(),
                                ),
                              );
                            }
                          },
                        ),
                        _buildNavItem(
                          icon: FontAwesomeIcons.wallet,
                          label: 'Wallet',
                          isSelected: activeRoute == 'Wallet',
                          onTap: () {
                            Navigator.pop(context); // Close the drawer
                            if (activeRoute != 'Wallet') {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const BusinessWalletScreen(),
                                ),
                              );
                            }
                          },
                        ),
                        _buildDivider(),
                        _buildNavItem(
                          icon: FontAwesomeIcons.chartPie,
                          label: 'Analytics',
                          isSelected: false,
                        ),
                        _buildNavItem(
                          icon: FontAwesomeIcons.users,
                          label: 'Customers',
                          isSelected: false,
                        ),
                        _buildNavItem(
                          icon: FontAwesomeIcons.cartShopping,
                          label: 'Orders',
                          isSelected: false,
                        ),
                        _buildNavItem(
                          icon: FontAwesomeIcons.boxesStacked,
                          label: 'Inventory',
                          isSelected: activeRoute == 'Inventory',
                          onTap: () {
                            Navigator.pop(context);
                            if (activeRoute != 'Inventory') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const InventoryListScreen(),
                                ),
                              );
                            }
                          },
                        ),
                        _buildNavItem(
                          icon: FontAwesomeIcons.fileInvoiceDollar,
                          label: 'Invoice',
                          isSelected: false,
                        ),
                        _buildDivider(),
                        _buildNavItem(
                          icon: FontAwesomeIcons.store,
                          label: 'Outlet',
                          isSelected: false,
                        ),
                        _buildNavItem(
                          icon: FontAwesomeIcons.userTie,
                          label: 'Employee',
                          isSelected: false,
                        ),
                        _buildNavItem(
                          icon: FontAwesomeIcons.truck,
                          label: 'Shipment',
                          isSelected: false,
                        ),
                        _buildNavItem(
                          icon: FontAwesomeIcons.bullhorn,
                          label: 'Marketing',
                          isSelected: false,
                        ),
                        _buildNavItem(
                          icon: FontAwesomeIcons.headset,
                          label: 'Support & Help',
                          isSelected: activeRoute == 'Support',
                          onTap: () {
                            Navigator.pop(context);
                            if (activeRoute != 'Support') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SupportScreen(isBusiness: true),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _buildNavItem(
                  icon: FontAwesomeIcons.trashCan,
                  label: 'Delete Account',
                  isSelected: false,
                  iconColor: BusinessTheme.textMuted,
                  textColor: BusinessTheme.textMuted,
                  onTap: () {
                    Navigator.pop(context);
                    showDeleteAccountDialog(context, isBusiness: true);
                  },
                ),
                _buildNavItem(
                  icon: FontAwesomeIcons.rightFromBracket,
                  label: 'Logout',
                  isSelected: false,
                  onTap: () => AuthService.logout(context),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: InkWell(
                    onTap: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: BusinessTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: BusinessTheme.textMuted.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.arrowRightArrowLeft,
                            size: 14,
                            color: BusinessTheme.textMuted,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: AppText.paragraph(
                              'Switch to Personal',
                              style: TextStyle(
                                color: BusinessTheme.textDark,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: BusinessTheme.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required dynamic icon,
    required String label,
    required bool isSelected,
    Color? iconColor,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    final effectiveIconColor = iconColor ??
        (isSelected ? BusinessTheme.primaryAmber : BusinessTheme.textMuted);
    final effectiveTextColor = textColor ??
        (isSelected ? BusinessTheme.charcoal : BusinessTheme.textMuted);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? BusinessTheme.primaryAmber.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              FaIcon(
                icon,
                size: 16,
                color: effectiveIconColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppText.button(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: effectiveTextColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Divider(
        height: 1,
        thickness: 1,
        color: BusinessTheme.textMuted.withValues(alpha: 0.2),
      ),
    );
  }
}

