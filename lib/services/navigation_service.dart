import 'package:flutter/material.dart';

/// Centralized navigation service to access the root navigator context anywhere.
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Returns the current active BuildContext within the Navigator tree.
  static BuildContext? get currentContext => navigatorKey.currentContext;
}
