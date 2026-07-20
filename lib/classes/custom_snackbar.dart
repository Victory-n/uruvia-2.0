import 'package:flutter/material.dart';
import 'package:floating_snackbar/floating_snackbar.dart';

class CustomSnackbar {
  /// Displays a success toast notification positioned at the top of the screen.
  static void showSuccess(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    FloatingSnackBar.success(
      context,
      message,
      title: title,
      position: FloatingSnackBarPosition.top,
      duration: duration,
    );
  }

  /// Displays a failed/error toast notification positioned at the top of the screen.
  static void showFailed(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    FloatingSnackBar.error(
      context,
      message,
      title: title,
      position: FloatingSnackBarPosition.top,
      duration: duration,
    );
  }

  /// Displays a normal/info toast notification positioned at the top of the screen.
  static void showNormal(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    FloatingSnackBar.show(
      context,
      message,
      title: title,
      position: FloatingSnackBarPosition.top,
      duration: duration,
    );
  }
}
