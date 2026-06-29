import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavItem {
  final String label;
  final IconData icon;
  final Widget screen;

  const NavItem({required this.label, required this.icon, required this.screen});
}