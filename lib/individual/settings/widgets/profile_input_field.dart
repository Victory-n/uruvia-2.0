import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import '../../../shared/widgets/custom_text.dart';

class ProfileInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData prefixIcon;
  final String? hintText;
  final bool isReadOnly;
  final String? helperText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const ProfileInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.prefixIcon,
    this.hintText,
    this.isReadOnly = false,
    this.helperText,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        googleSansText(
          text: label,
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.w600,
          size: 13.0,
        ),
        const SizedBox(height: 6.0),
        TextFormField(
          controller: controller,
          readOnly: isReadOnly,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            fontFamily: "googleSans",
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: isReadOnly
                ? ConstantColor.paragraphTextSecondary
                : ConstantColor.headingTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontFamily: "googleSans",
              fontSize: 14.0,
              color: ConstantColor.paragraphTextSecondary.withOpacity(0.6),
            ),
            filled: true,
            fillColor: isReadOnly ? Colors.grey.withOpacity(0.08) : Colors.white,
            prefixIcon: Icon(
              prefixIcon,
              color: isReadOnly
                  ? ConstantColor.paragraphTextSecondary
                  : ConstantColor.blueBackground,
              size: 20.0,
            ),
            suffixIcon: isReadOnly
                ? const Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.grey,
                    size: 18.0,
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 14.0,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.2),
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: ConstantColor.blueBackground,
                width: 1.5,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.1),
                width: 1.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Colors.redAccent,
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Colors.redAccent,
                width: 1.5,
              ),
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4.0),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: googleSansText(
              text: helperText!,
              colors: ConstantColor.paragraphTextSecondary,
              fontWeight: FontWeight.w400,
              size: 11.5,
            ),
          ),
        ],
      ],
    );
  }
}
