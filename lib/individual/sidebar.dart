import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uruvia/classes/nav_items.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/individual/dashboard.dart';
import 'package:uruvia/individual/finances/events/events.dart';
import 'package:uruvia/individual/finances/finance.dart';
import 'package:uruvia/individual/finances/transaction.dart';
import 'package:uruvia/shared_features/wallet/wallet_page.dart';
import 'package:uruvia/individual/settings/settings.dart';
import 'package:uruvia/shared_features/calculator/savings_calculator_screen.dart';
import 'package:uruvia/widgets/custom_text.dart';

class IndividualSideBar extends StatefulWidget {
  final String? title;
  final String userName;
  final String userEmail;
  final VoidCallback? onLogout;
  final int initialIndex;

  const IndividualSideBar({
    super.key,
    this.title,
    this.userName = "Alex User",
    this.userEmail = "alex@uruvia.app",
    this.onLogout,
    this.initialIndex = 0,
  });

  @override
  State<IndividualSideBar> createState() => _IndividualSideBarState();
}

// Aliases for convenience across imports
typedef IndividualSidebar = IndividualSideBar;
typedef IndividualSideBarPage = IndividualSideBar;
typedef IndividualSidebarPage = IndividualSideBar;

class _IndividualSideBarState extends State<IndividualSideBar> {
  late int _selectedIndex;
  late final List<NavItem> _navItems;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _navItems = [
      NavItem(
        label: 'Dashboard',
        icon: Icons.dashboard_outlined,
        screen: IndividualDashboard(userName: widget.userName),
      ),
      NavItem(
        label: 'Wallet',
        icon: Icons.credit_card_rounded,
        screen: IndividualWalletPage(userName: widget.userName),
      ),
      const NavItem(
        label: 'Finance',
        icon: Icons.account_balance_wallet_outlined,
        screen: IndividualFinancePage(),
      ),
      const NavItem(
        label: 'Transactions',
        icon: Icons.receipt_long_outlined,
        screen: IndividualTransactionPage(),
      ),
      const NavItem(
        label: 'Events',
        icon: Icons.celebration_outlined,
        screen: IndividualEventsPage(),
      ),
      const NavItem(
        label: 'Savings Calculator',
        icon: Icons.calculate_outlined,
        screen: SavingsCalculatorScreen(),
      ),
      NavItem(
        label: 'Settings',
        icon: Icons.settings_outlined,
        screen: IndividualSettingsPage(
          userEmail: widget.userEmail,
          onLogout: widget.onLogout,
        ),
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [Expanded(child: _navItems[_selectedIndex].screen)],
        ),
      ),
      drawer: IndividualDrawer(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        navItems: _navItems,
        userName: widget.userName,
        userEmail: widget.userEmail,
        onLogout: widget.onLogout,
      ),
    );
  }
}

class IndividualDrawer extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int>? onItemTapped;
  final List<NavItem>? navItems;
  final String userName;
  final String userEmail;
  final VoidCallback? onLogout;

  const IndividualDrawer({
    super.key,
    this.selectedIndex = 0,
    this.onItemTapped,
    this.navItems,
    this.userName = "Alex User",
    this.userEmail = "alex@uruvia.app",
    this.onLogout,
  });

  @override
  State<IndividualDrawer> createState() => _IndividualDrawerState();
}

class _IndividualDrawerState extends State<IndividualDrawer> {
  bool _isFinanceExpanded = true;

  @override
  Widget build(BuildContext context) {
    final effectiveNavItems =
        widget.navItems ??
        [
          NavItem(
            label: 'Dashboard',
            icon: Icons.dashboard_outlined,
            screen: IndividualDashboard(userName: widget.userName),
          ),
          NavItem(
            label: 'Wallet',
            icon: Icons.credit_card_rounded,
            screen: IndividualWalletPage(userName: widget.userName),
          ),
          const NavItem(
            label: 'Finance',
            icon: Icons.account_balance_wallet_outlined,
            screen: IndividualFinancePage(),
          ),
          const NavItem(
            label: 'Transactions',
            icon: Icons.receipt_long_outlined,
            screen: IndividualTransactionPage(),
          ),
          const NavItem(
            label: 'Events',
            icon: Icons.celebration_outlined,
            screen: IndividualEventsPage(),
          ),
          const NavItem(
            label: 'Savings Calculator',
            icon: Icons.calculate_outlined,
            screen: SavingsCalculatorScreen(),
          ),
          NavItem(
            label: 'Settings',
            icon: Icons.settings_outlined,
            screen: IndividualSettingsPage(
              userEmail: widget.userEmail,
              onLogout: widget.onLogout,
            ),
          ),
        ];

    // Calculate initials
    final initialsList = widget.userName.trim().isEmpty
        ? ['U']
        : widget.userName
              .trim()
              .split(RegExp(r'\s+'))
              .map((w) => w.isNotEmpty ? w[0] : '')
              .toList();
    final String initials = initialsList.join().toUpperCase();
    final String displayInitials = initials.substring(
      0,
      initials.length >= 2 ? 2 : initials.length,
    );

    // Finance is active for indices 2 (Finance Dashboard), 3 (Transactions), 4 (Events), 5 (Calculator)
    final bool isFinanceActive =
        widget.selectedIndex >= 2 && widget.selectedIndex <= 5;

    return Drawer(
      backgroundColor: Colors.white,
      elevation: 0.0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        children: [
          // 1. User Profile Section Header (Pure UI)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20.0, 44.0, 20.0, 20.0),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFC),
              border: Border(
                bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 28.0,
                          backgroundColor: ConstantColor.blueBackground
                              .withOpacity(0.1),
                          child: googleSansText(
                            text: displayInitials.isNotEmpty
                                ? displayInitials
                                : "U",
                            colors: ConstantColor.blueBackground,
                            fontWeight: FontWeight.bold,
                            size: 18.0,
                          ),
                        ),
                        // Status Dot (UI only)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 14.0,
                            height: 14.0,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          googleSansText(
                            text: widget.userName.isNotEmpty
                                ? widget.userName
                                : "Individual User",
                            colors: ConstantColor.headingTextPrimary,
                            fontWeight: FontWeight.bold,
                            size: 16.0,
                            softWrap: true,
                          ),
                          const SizedBox(height: 3.0),
                          // Individual Account Pill Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 2.0,
                            ),
                            decoration: BoxDecoration(
                              color: ConstantColor.blueBackground.withOpacity(
                                0.08,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: googleSansText(
                              text: "Individual Account",
                              colors: ConstantColor.blueBackground,
                              fontWeight: FontWeight.bold,
                              size: 9.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                // User Email & Subtitle
                googleSansText(
                  text: widget.userEmail,
                  colors: ConstantColor.paragraphTextSecondary,
                  fontWeight: FontWeight.w600,
                  size: 13.0,
                  softWrap: true,
                ),
                const SizedBox(height: 2.0),
                googleSansText(
                  text: "Personal Command Centre",
                  colors: ConstantColor.paragraphTextSecondary.withOpacity(0.6),
                  fontWeight: FontWeight.normal,
                  size: 11.0,
                ),
              ],
            ),
          ),

          // 2. Navigation Items List with Dropdown for Finance
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 16.0,
              ),
              children: [
                // --- Dashboard Tile ---
                _buildNavItemTile(
                  index: 0,
                  label: 'Dashboard',
                  icon: Icons.dashboard_outlined,
                  isSelected: widget.selectedIndex == 0,
                ),

                // --- Wallet Tile ---
                _buildNavItemTile(
                  index: 1,
                  label: 'Wallet',
                  icon: Icons.credit_card_rounded,
                  isSelected: widget.selectedIndex == 1,
                ),

                // --- Finance Dropdown Group ---
                Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  decoration: BoxDecoration(
                    color: isFinanceActive
                        ? ConstantColor.blueBackground.withOpacity(0.04)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    children: [
                      // Dropdown Header Tile for Finance
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 2.0,
                        ),
                        leading: Icon(
                          Icons.account_balance_wallet_outlined,
                          color: isFinanceActive
                              ? ConstantColor.blueBackground
                              : ConstantColor.paragraphTextSecondary,
                        ),
                        title: googleSansText(
                          text: "Finance",
                          colors: isFinanceActive
                              ? ConstantColor.blueBackground
                              : ConstantColor.paragraphTextPrimary,
                          fontWeight: isFinanceActive
                              ? FontWeight.bold
                              : FontWeight.w600,
                          size: 15.0,
                          textAlign: TextAlign.left,
                        ),
                        trailing: Icon(
                          _isFinanceExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: isFinanceActive
                              ? ConstantColor.blueBackground
                              : ConstantColor.paragraphTextSecondary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        onTap: () {
                          setState(() {
                            _isFinanceExpanded = !_isFinanceExpanded;
                          });
                        },
                      ),

                      // Dropdown Sub-Items
                      if (_isFinanceExpanded) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16.0,
                            bottom: 4.0,
                          ),
                          child: Column(
                            children: [
                              // Sub-item 1: Finance Overview
                              _buildSubNavItemTile(
                                index: 2,
                                label: 'Finance Dashboard',
                                icon: Icons.grid_view_rounded,
                                isSelected: widget.selectedIndex == 2,
                              ),
                              // Sub-item 2: Transactions
                              _buildSubNavItemTile(
                                index: 3,
                                label: 'Transactions',
                                icon: Icons.receipt_long_outlined,
                                isSelected: widget.selectedIndex == 3,
                              ),
                              // Sub-item 3: Events
                              _buildSubNavItemTile(
                                index: 4,
                                label: 'Events',
                                icon: Icons.celebration_outlined,
                                isSelected: widget.selectedIndex == 4,
                              ),
                              // Sub-item 4: Savings Calculator
                              _buildSubNavItemTile(
                                index: 5,
                                label: 'Savings Calculator',
                                icon: Icons.calculate_outlined,
                                isSelected: widget.selectedIndex == 5,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // --- Settings Tile ---
                _buildNavItemTile(
                  index: 6,
                  label: 'Settings',
                  icon: Icons.settings_outlined,
                  isSelected: widget.selectedIndex == 6,
                ),
              ],
            ),
          ),

          // 3. Anchored Bottom Footer Section
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFC),
              border: Border(
                top: BorderSide(color: Color(0xFFEEEEEE), width: 1.0),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logout Button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                      ),
                      leading: const Icon(
                        CupertinoIcons.square_arrow_right,
                        color: Colors.redAccent,
                      ),
                      title: googleSansText(
                        text: "Logout",
                        colors: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        size: 15.0,
                        textAlign: TextAlign.left,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        if (widget.onLogout != null) {
                          widget.onLogout!();
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  // Version Label
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        CupertinoIcons.info_circle,
                        size: 12.0,
                        color: Color(0xFFBBBBBB),
                      ),
                      SizedBox(width: 4.0),
                      Text(
                        "Uruvia Individual v2.0.0",
                        style: TextStyle(
                          fontFamily: "googleSans",
                          fontSize: 10.0,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFFBBBBBB),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItemTile({
    required int index,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: isSelected
            ? ConstantColor.blueBackground.withOpacity(0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 2.0,
        ),
        leading: Icon(
          icon,
          color: isSelected
              ? ConstantColor.blueBackground
              : ConstantColor.paragraphTextSecondary,
        ),
        title: googleSansText(
          text: label,
          colors: isSelected
              ? ConstantColor.blueBackground
              : ConstantColor.paragraphTextPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          size: 15.0,
          textAlign: TextAlign.left,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        onTap: () => _handleItemTap(index),
      ),
    );
  }

  Widget _buildSubNavItemTile({
    required int index,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4.0),
      decoration: BoxDecoration(
        color: isSelected
            ? ConstantColor.blueBackground.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 0.0,
        ),
        dense: true,
        leading: Icon(
          icon,
          size: 18.0,
          color: isSelected
              ? ConstantColor.blueBackground
              : ConstantColor.paragraphTextSecondary,
        ),
        title: googleSansText(
          text: label,
          colors: isSelected
              ? ConstantColor.blueBackground
              : ConstantColor.paragraphTextPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          size: 13.5,
          textAlign: TextAlign.left,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        onTap: () => _handleItemTap(index),
      ),
    );
  }

  void _handleItemTap(int index) {
    Navigator.pop(context); // Close drawer
    if (widget.onItemTapped != null) {
      widget.onItemTapped!(index);
    } else {
      // Standalone navigation fallback
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => IndividualSideBar(initialIndex: index),
        ),
      );
    }
  }
}
