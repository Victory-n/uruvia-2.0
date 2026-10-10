import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';

/// Opens a bottom sheet in the app style: 24 radius on top, drag handle,
/// lifted above the keyboard. Use it for pickers, quick-create and confirmations.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  String? title,
  bool isDismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: isDismissible,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageMargin,
            0,
            AppSpacing.pageMargin,
            AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Text(title, style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.lg),
              ],
              builder(sheetContext),
            ],
          ),
        ),
      );
    },
  );
}
