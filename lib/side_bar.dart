import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/dashboard.dart';
import 'package:uruvia/offline/connectivity_service.dart';
import 'package:uruvia/screens/auth_screens/login_registration_screens.dart';
import 'package:uruvia/screens/expenses/expense_list_page.dart';
import 'package:uruvia/screens/business health/business_health.dart';
import 'package:uruvia/screens/inventory/inventory_main_page.dart';
import 'package:uruvia/screens/invoices/invoice_main_page.dart';
import 'package:uruvia/screens/settings/settings_page.dart';
import 'package:uruvia/widgets/custom_text.dart';
import 'package:uruvia/widgets/offline_banner.dart';

import 'classes/nav_items.dart';

class SideBarPage extends StatefulWidget {
  const SideBarPage({super.key, required this.title});

  final String title;

  @override
  State<SideBarPage> createState() => _SideBarPageState();
}

class _SideBarPageState extends State<SideBarPage> {
  int _selectedIndex = 0;

  static const List<NavItem> _navItems = [
    NavItem(label: 'Dashboard', icon: Icons.dashboard_outlined, screen: Dashboard()),
    NavItem(label: 'Inventory', icon: Icons.inventory_outlined, screen: InventoryMainPage()),
    NavItem(label: 'Invoice', icon: Icons.receipt_long, screen: InvoiceMainPage()),
    NavItem(label: 'Expenses', icon: Icons.payments_outlined, screen: ExpenseListPage()),
    NavItem(label: 'Business Health', icon: Icons.health_and_safety_outlined, screen: BusinessHealthPage()),
    NavItem(label: 'Settings & Profile', icon: Icons.settings_outlined, screen: SettingsPage()),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final firstName = user?.userMetadata?['first_name'] ?? 'Guest';
    final lastName = user?.userMetadata?['last_name'] ?? 'User';
    final fullName = '$firstName $lastName'.trim();
    final email = user?.email ?? '';

    // Calculate initials
    final initialsList = fullName.trim().isEmpty
        ? ['U']
        : fullName.trim().split(RegExp(r'\s+')).map((w) => w.isNotEmpty ? w[0] : '').toList();
    final String initials = initialsList.join().toUpperCase();
    final String displayInitials = initials.substring(0, initials.length >= 2 ? 2 : initials.length);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: _navItems[_selectedIndex].screen,
            ),
          ],
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        elevation: 0.0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child: Column(
          children: [
            // 1. Profile Section Header
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
                            backgroundColor: ConstantColor.blueBackground.withOpacity(0.1),
                            child: googleSansText(
                              text: displayInitials.isNotEmpty ? displayInitials : "U",
                              colors: ConstantColor.blueBackground,
                              fontWeight: FontWeight.bold,
                              size: 18.0,
                            ),
                          ),
                          // Live Online Status Dot
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: ValueListenableBuilder<bool>(
                              valueListenable: ConnectivityService.instance.isConnected,
                              builder: (context, isOnline, _) {
                                return Container(
                                  width: 14.0,
                                  height: 14.0,
                                  decoration: BoxDecoration(
                                    color: isOnline ? Colors.green : Colors.orange,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2.0),
                                  ),
                                );
                              },
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
                              text: fullName.isNotEmpty ? fullName : "Uruvia User",
                              colors: ConstantColor.headingTextPrimary,
                              fontWeight: FontWeight.bold,
                              size: 16.0,
                              softWrap: true,
                            ),
                            const SizedBox(height: 3.0),
                            // Premium Pill Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                color: ConstantColor.blueBackground.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: googleSansText(
                                text: "Pro Plan Member",
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
                  // User Email & Detail
                  googleSansText(
                    text: email.isNotEmpty ? email : "business@uruvia.app",
                    colors: ConstantColor.paragraphTextSecondary,
                    fontWeight: FontWeight.w600,
                    size: 13.0,
                    softWrap: true,
                  ),
                  const SizedBox(height: 2.0),
                  googleSansText(
                    text: "Uruvia Command Centre",
                    colors: ConstantColor.paragraphTextSecondary.withOpacity(0.6),
                    fontWeight: FontWeight.normal,
                    size: 11.0,
                  ),
                ],
              ),
            ),

            // 2. Navigation items List (scrolling if needed)
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                children: [
                  ..._navItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item  = entry.value;
                    final isSelected = _selectedIndex == index;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? ConstantColor.blueBackground.withOpacity(0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
                        leading: Icon(
                          item.icon,
                          color: isSelected
                              ? ConstantColor.blueBackground
                              : ConstantColor.paragraphTextSecondary,
                        ),
                        title: googleSansText(
                          text: item.label,
                          colors: isSelected
                              ? ConstantColor.blueBackground
                              : ConstantColor.paragraphTextPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          size: 15.0,
                          textAlign: TextAlign.left, // Left align correctly!
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        onTap: () {
                          _onItemTapped(index);
                          Navigator.pop(context); // close the drawer
                        },
                      ),
                    );
                  }),
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
                    // Logout list button
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                        leading: const Icon(CupertinoIcons.square_arrow_right, color: Colors.redAccent),
                        title: googleSansText(
                          text: "Logout",
                          colors: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          size: 15.0,
                          textAlign: TextAlign.left, // Left align correctly!
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
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
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    // Version label
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(CupertinoIcons.info_circle, size: 12.0, color: Color(0xFFBBBBBB)),
                        const SizedBox(width: 4.0),
                        googleSansText(
                          text: "Uruvia Command Centre v2.0.0",
                          colors: const Color(0xFFBBBBBB),
                          fontWeight: FontWeight.normal,
                          size: 10.0,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}