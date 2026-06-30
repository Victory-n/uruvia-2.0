import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';

class VoiceExpensePage extends StatefulWidget {
  const VoiceExpensePage({super.key});

  @override
  State<VoiceExpensePage> createState() => _VoiceExpensePageState();
}

class _VoiceExpensePageState extends State<VoiceExpensePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
        color: Colors.red,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                child: Row(
                  children: [
                    Platform.isAndroid
                        ? Icon(Icons.mic_none, color: ConstantColor.headingTextPrimary)
                        : Icon(CupertinoIcons.mic, color: Colors.green),
                  ],
                ),
              ),
              IconButton(
                alignment: Alignment.centerRight,
                onPressed: () {  },
                icon: Platform.isAndroid
                    ? Icon(Icons.cancel, color: Colors.green)
                    : Icon(CupertinoIcons.xmark, color: Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
