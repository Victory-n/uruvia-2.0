import 'package:flutter/material.dart';
import 'package:uruvia/screens/expenses/voice_expense_page.dart';

Future<Map<String, dynamic>?> showHalfScreenModal(BuildContext context) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return const FractionallySizedBox(
        heightFactor: 0.8,
        child: SingleChildScrollView(child: VoiceExpensePage()),
      );
    },
  );
}
