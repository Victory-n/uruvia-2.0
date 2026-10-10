import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';
import '../../app/theme/tokens.dart';

enum AppButtonStyle { primary, secondary, text }

/// The one button used everywhere. Primary is a solid fill, secondary an
/// outline, text a plain link. While [loading] it shows a spinner and keeps
/// its width, and it ignores taps.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = AppButtonStyle.primary,
    this.loading = false,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final bool loading;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;
    final spinnerColor = style == AppButtonStyle.primary ? Colors.white : palette.action;
    final VoidCallback? handler = loading ? null : onPressed;

    final text = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    );

    final child = Stack(
      alignment: Alignment.center,
      children: [
        Opacity(opacity: loading ? 0 : 1, child: text),
        if (loading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: spinnerColor, semanticsLabel: 'Loading'),
          ),
      ],
    );

    final size = Size(expand ? double.infinity : 64, style == AppButtonStyle.text ? AppSpacing.minTouchTarget : AppSpacing.buttonHeight);

    final button = switch (style) {
      AppButtonStyle.primary => FilledButton(
          onPressed: handler,
          style: FilledButton.styleFrom(minimumSize: size),
          child: child,
        ),
      AppButtonStyle.secondary => OutlinedButton(
          onPressed: handler,
          style: OutlinedButton.styleFrom(minimumSize: size),
          child: child,
        ),
      AppButtonStyle.text => TextButton(
          onPressed: handler,
          style: TextButton.styleFrom(minimumSize: size),
          child: child,
        ),
    };

    return button;
  }
}
