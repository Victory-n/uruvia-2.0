import 'package:flutter/material.dart';
import 'package:uruvia/screens/expenses/voice_expense_page.dart';
import 'package:uruvia/widgets/half_screen_page.dart';

showHalfScreenModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return FractionallySizedBox(
        heightFactor: 0.8,
        child: SingleChildScrollView(
          child: VoiceExpensePage(),
        ),
      );
    },
  );
}