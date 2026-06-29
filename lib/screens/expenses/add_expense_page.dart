import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:uruvia/screens/expenses/voice_expense_page.dart';

import '../../classes/show_half_screen.dart';
import '../../constants/colors.dart';
import '../../widgets/custom_text.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final bool _animate = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: interText(text: "Add Expense", colors: Colors.black, fontWeight: FontWeight.bold, size: 20.0, textAlign: TextAlign.center, softWrap: true),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: AvatarGlow(
                    startDelay: const Duration(milliseconds: 1000),
                    glowColor: Colors.green,
                    glowShape: BoxShape.rectangle,
                    glowRadiusFactor: 0.2,
                    animate: _animate,
                    curve: Curves.elasticOut,
                    child: Material(
                      shape: const CircleBorder(),
                      color: Colors.transparent,
                      child: IconButton(
                        // onPressed: () => slideUpWidget(newPage: VoiceExpensePage(), context: context),
                        onPressed: () => showHalfScreenModal(context),
                        icon: Platform.isAndroid ? const Icon(Icons.mic, color: Colors.black, size: 30.0,) : const Icon(CupertinoIcons.mic_fill, color: Colors.black, size: 30.0,),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30.0,),
                Container(
                  padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 40.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Color(0xFFC6C6CD), width: 1.0,),
                    color: Color(0xFFC6C6CD).withAlpha(70),
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: interText(text: "AMOUNT", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.w600, size: 12.0, textAlign: TextAlign.center, softWrap: true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
