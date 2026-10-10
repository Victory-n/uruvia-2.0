import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_palette.dart';
import '../../app/theme/tokens.dart';

/// Text input with its label above the box, as in the design reference.
/// Set [obscure] for passwords: a show/hide toggle is added automatically.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.helper,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.obscure = false,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.prefixText,
    this.suffix,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.autofocus = false,
    this.autofillHints,
    this.focusNode,
    this.textStyle,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? helper;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscure;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final String? prefixText;
  final Widget? suffix;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final bool autofocus;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final TextStyle? textStyle;
  final TextCapitalization textCapitalization;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _hidden = widget.obscure;

  OutlineInputBorder _border(Color color, [double width = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;

    Widget? suffix = widget.suffix;
    if (widget.obscure) {
      suffix = IconButton(
        tooltip: _hidden ? 'Show password' : 'Hide password',
        icon: Icon(_hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined),
        onPressed: () => setState(() => _hidden = !_hidden),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: theme.textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          obscureText: _hidden,
          maxLines: widget.obscure ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          autofillHints: widget.autofillHints,
          inputFormatters: widget.inputFormatters,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          style: widget.textStyle ?? theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(color: AppColors.inkSoft),
            helperText: widget.helper,
            helperMaxLines: 2,
            errorText: widget.errorText,
            errorMaxLines: 2,
            prefixText: widget.prefixText,
            suffixIcon: suffix,
            counterText: '',
            filled: true,
            fillColor: widget.enabled ? AppColors.surface : AppColors.disabledFill,
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
            border: _border(AppColors.border),
            enabledBorder: _border(AppColors.border),
            disabledBorder: _border(AppColors.border),
            focusedBorder: _border(palette.action, 1.5),
            errorBorder: _border(StatusColors.error),
            focusedErrorBorder: _border(StatusColors.error, 1.5),
          ),
        ),
      ],
    );
  }
}
