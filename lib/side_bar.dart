import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/dashboard.dart';
import 'package:uruvia/screens/auth_screens/login_registration_screens.dart';
import 'package:uruvia/screens/inventory/inventory_main_page.dart';
import 'package:uruvia/screens/invoices/invoice_main_page.dart';
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
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 35,
                          child: Icon(Icons.person, size: 35),
                        ),
                        const SizedBox(width: 12.0,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            interText(text: fullName.isNotEmpty ? fullName : "Uruvia User", colors: Colors.black, fontWeight: FontWeight.normal, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                            interText(text: "Pro Plan Member", colors: ConstantColor.blueBackground, fontWeight: FontWeight.normal, size: 11.0, textAlign: TextAlign.center, softWrap: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0,),
                  Flexible(
                    child: interText(text: email.isNotEmpty ? email : "Business Owner", colors: Colors.black, fontWeight: FontWeight.bold, size: 14.0, textAlign: TextAlign.center, softWrap: true),
                  ),
                  Flexible(
                    child: interText(text: "Uruvia Command Centre", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.w600, size: 11.0, textAlign: TextAlign.center, softWrap: true),
                  ),
                ],
              ),
            ),
            ..._navItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item  = entry.value;
              return ListTile(
                leading: Icon(item.icon),
                title: interText(text: item.label, colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.normal, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                selected: _selectedIndex == index,
                selectedTileColor: Colors.blue.withOpacity(0.1),
                selectedColor: Colors.blue,
                onTap: () {
                  _onItemTapped(index);
                  Navigator.pop(context); // close the drawer
                },
              );
            }),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: interText(text: "Logout", colors: Colors.redAccent, fontWeight: FontWeight.normal, size: 16.0, textAlign: TextAlign.center, softWrap: true),
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
          ],
        ),
      ),
    );
  }
}