import 'package:flutter/material.dart';

enum AppTextType { title, subtitle, paragraph, button, custom }

class AppText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final AppTextType type;

  const AppText.title(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : type = AppTextType.title;

  const AppText.subtitle(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : type = AppTextType.subtitle;

  const AppText.paragraph(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : type = AppTextType.paragraph;

  const AppText.button(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : type = AppTextType.button;

  const AppText.custom(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : type = AppTextType.custom;

  // Keeping default constructor as custom so we don't break everything instantly
  const AppText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : type = AppTextType.custom;

  double? get _fontSize {
    switch (type) {
      case AppTextType.title:
        return 30.0;
      case AppTextType.subtitle:
        return 20.0;
      case AppTextType.paragraph:
        return 12.0;
      case AppTextType.button:
        return 12.0;
      case AppTextType.custom:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle baseStyle = style ?? const TextStyle();
    if (_fontSize != null) {
      baseStyle = baseStyle.copyWith(fontSize: _fontSize);
    }

    return Text(
      data,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: baseStyle.copyWith(fontFamily: 'googleSans'),
    );
  }
}
