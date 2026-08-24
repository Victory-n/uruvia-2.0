import 'package:flutter/material.dart';

Widget interText({
  required String text,
  required Color colors,
  required FontWeight fontWeight,
  required double size,
  bool? softWrap,
  TextAlign? textAlign,
}) => Text(
  text,
  textAlign: textAlign,
  style: TextStyle(
    fontFamily: "Inter",
    fontSize: size,
    fontWeight: fontWeight,
    color: colors,
  ),
);

// Widget workSansText({
//   required String text,
//   required Color colors,
//   required FontWeight fontWeight,
//   required double size,
//   bool? softWrap,
//   TextAlign? textAlign,
// }) => Text(
//   text,
//   textAlign: textAlign,
//   style: TextStyle(
//     fontFamily: "WorkSans",
//     fontSize: size,
//     fontWeight: fontWeight,
//     color: colors,
//   ),
// );

Widget googleSansText({
  required String text,
  Color? colors,
  required FontWeight fontWeight,
  required double size,
  bool? softWrap,
  double? letterSpacing,
  TextAlign? textAlign,
}) => Text(
  text,
  textAlign: textAlign,
  style: TextStyle(
    fontFamily: "googleSans",
    fontSize: size,
    fontWeight: fontWeight,
    color: colors,
  ),
);

Widget poppinsText({
  required String text,
  required Color colors,
  required FontWeight fontWeight,
  required double size,
  bool? softWrap,
  TextAlign? textAlign,
}) => Text(
  text,
  textAlign: textAlign,
  style: TextStyle(
    fontFamily: "poppins",
    fontSize: size,
    fontWeight: fontWeight,
    color: colors,
  ),
);

Widget dmSansText({
  required String text,
  required Color colors,
  required FontWeight fontWeight,
  required double size,
  bool? softWrap,
  TextAlign? textAlign,
}) => Text(
  text,
  textAlign: textAlign,
  style: TextStyle(
    fontFamily: "dmSans",
    fontSize: size,
    fontWeight: fontWeight,
    color: colors,
  ),
);
