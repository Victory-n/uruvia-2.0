import 'package:flutter/material.dart';

/// Technical HUD / Metadata Label Caps (Inspired by Theme A architectural tokens)
Widget labelCapsText({
  required String text,
  Color colors = const Color(0xFF76777D),
  FontWeight fontWeight = FontWeight.w700,
  double size = 11.0,
  double letterSpacing = 1.2,
  TextAlign? textAlign,
  TextOverflow? overflow,
  int? maxLines,
}) => Text(
  text.toUpperCase(),
  textAlign: textAlign,
  overflow: overflow,
  maxLines: maxLines,
  style: TextStyle(
    fontFamily: "WorkSans",
    fontSize: size,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing,
    color: colors,
  ),
);

Widget workSansText({
  required String text,
  required Color colors,
  required FontWeight fontWeight,
  required double size,
  bool? softWrap,
  double? letterSpacing,
  double? height,
  TextAlign? textAlign,
  TextOverflow? overflow,
  int? maxLines,
}) => Text(
  text,
  textAlign: textAlign,
  softWrap: softWrap,
  overflow: overflow,
  maxLines: maxLines,
  style: TextStyle(
    fontFamily: "WorkSans",
    fontSize: size,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing,
    height: height,
    color: colors,
  ),
);

Widget interText({
  required String text,
  required Color colors,
  required FontWeight fontWeight,
  required double size,
  bool? softWrap,
  double? letterSpacing,
  double? height,
  TextAlign? textAlign,
  TextOverflow? overflow,
  int? maxLines,
}) => Text(
  text,
  textAlign: textAlign,
  softWrap: softWrap,
  overflow: overflow,
  maxLines: maxLines,
  style: TextStyle(
    fontFamily: "Inter",
    fontSize: size,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing,
    height: height,
    color: colors,
  ),
);

Widget googleSansText({
  required String text,
  Color? colors,
  required FontWeight fontWeight,
  required double size,
  bool? softWrap,
  double? letterSpacing,
  double? height,
  TextAlign? textAlign,
  TextOverflow? overflow,
  int? maxLines,
}) => Text(
  text,
  textAlign: textAlign,
  softWrap: softWrap,
  overflow: overflow,
  maxLines: maxLines,
  style: TextStyle(
    fontFamily: "googleSans",
    fontSize: size,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing,
    height: height,
    color: colors,
  ),
);

Widget poppinsText({
  required String text,
  required Color colors,
  required FontWeight fontWeight,
  required double size,
  bool? softWrap,
  double? letterSpacing,
  TextAlign? textAlign,
}) => Text(
  text,
  textAlign: textAlign,
  softWrap: softWrap,
  style: TextStyle(
    fontFamily: "poppins",
    fontSize: size,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing,
    color: colors,
  ),
);

Widget dmSansText({
  required String text,
  required Color colors,
  required FontWeight fontWeight,
  required double size,
  bool? softWrap,
  double? letterSpacing,
  TextAlign? textAlign,
}) => Text(
  text,
  textAlign: textAlign,
  softWrap: softWrap,
  style: TextStyle(
    fontFamily: "dmSans",
    fontSize: size,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing,
    color: colors,
  ),
);
