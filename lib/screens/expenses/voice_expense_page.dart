import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VoiceExpensePage extends StatefulWidget {
  const VoiceExpensePage({super.key});

  @override
  State<VoiceExpensePage> createState() => _VoiceExpensePageState();
}

class _VoiceExpensePageState extends State<VoiceExpensePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Platform.isAndroid
                ? Icon(Icons.cancel, color: Colors.green)
                : Icon(CupertinoIcons.xmark_circle_fill, color: Colors.green),
          ),
        ],
      ),
    );
  }
}
