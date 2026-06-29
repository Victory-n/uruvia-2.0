import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/dashboard.dart';
import 'package:uruvia/screens/inventory/inventory_main_page.dart';
import 'package:uruvia/widgets/custom_text.dart';

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
    NavItem(label: 'Inventory', icon: Icons.inventory, screen: InventoryMainPage()),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _navItems[_selectedIndex].screen,
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
                        CircleAvatar(
                          radius: 35,
                        ),
                        SizedBox(width: 12.0,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            interText(text: "Ada Lovelace", colors: Colors.black, fontWeight: FontWeight.normal, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                            interText(text: "Pro Plan Member", colors: ConstantColor.blueBackground, fontWeight: FontWeight.normal, size: 11.0, textAlign: TextAlign.center, softWrap: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.0,),
                  Flexible(
                    child: interText(text: "Business Owner", colors: Colors.black, fontWeight: FontWeight.bold, size: 18.0, textAlign: TextAlign.center, softWrap: true),
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
          ],
        ),
      ),
    );
  }
}