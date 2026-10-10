import 'package:flutter/material.dart';

import '../../features/account/domain/account_type.dart';
import '../router/routes.dart';

/// One row of the sidebar.
class NavItem {
  const NavItem(this.label, this.icon, this.route, {this.proOnly = false});

  final String label;
  final IconData icon;
  final String route;

  /// Free users see a gold lock on this row (Business Hub).
  final bool proOnly;

  bool matches(String location) => location == route || location.startsWith('$route/');
}

const individualNav = [
  NavItem('Home', Icons.home_outlined, AppRoutes.home),
  NavItem('Wallet', Icons.account_balance_wallet_outlined, AppRoutes.wallet),
  NavItem('Budget', Icons.pie_chart_outline_rounded, AppRoutes.budgets),
  NavItem('Savings', Icons.savings_outlined, AppRoutes.savings),
  NavItem('Expenses', Icons.receipt_long_outlined, AppRoutes.expenses),
  NavItem('Subscription', Icons.workspace_premium_outlined, AppRoutes.plan),
  NavItem('Support', Icons.support_agent_outlined, AppRoutes.support),
  NavItem('Settings', Icons.settings_outlined, AppRoutes.settings),
];

const businessNav = [
  NavItem('Home', Icons.home_outlined, AppRoutes.home),
  NavItem('Wallet', Icons.account_balance_wallet_outlined, AppRoutes.wallet),
  NavItem('Inventory', Icons.inventory_2_outlined, AppRoutes.inventory),
  NavItem('Invoices', Icons.description_outlined, AppRoutes.invoices),
  NavItem('Sales', Icons.shopping_bag_outlined, AppRoutes.sales),
  NavItem('Customers', Icons.people_outline_rounded, AppRoutes.customers),
  NavItem('Reports', Icons.bar_chart_rounded, AppRoutes.reports),
  NavItem('Business Hub', Icons.storefront_outlined, AppRoutes.hub, proOnly: true),
  NavItem('Subscription', Icons.workspace_premium_outlined, AppRoutes.plan),
  NavItem('Support', Icons.support_agent_outlined, AppRoutes.support),
  NavItem('Settings', Icons.settings_outlined, AppRoutes.settings),
];

List<NavItem> navItemsFor(AccountType type) =>
    type == AccountType.business ? businessNav : individualNav;

/// Paths an Individual account may not open. The database blocks the data as well.
const businessOnlyRoutes = [
  AppRoutes.inventory,
  AppRoutes.invoices,
  AppRoutes.sales,
  AppRoutes.customers,
  AppRoutes.reports,
  AppRoutes.hub,
];

/// Every distinct sidebar destination, used to register routes.
final allNavItems = {
  for (final item in [...individualNav, ...businessNav]) item.route: item,
}.values.toList();
