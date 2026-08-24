import 'package:flutter/material.dart';

Widget columnText({
  required Widget headingText,
  required Widget subtext
}) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
children: [
  headingText,
  SizedBox(height: 5.0,),
  subtext,
],
);