import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/sub_page.dart';
import '../domain/voice_parser.dart';

/// Screen 32. DUMMY: the microphone is simulated until a speech provider is chosen.
/// The sentence parser is real, so typing a sentence works the same way speech will.
class VoiceExpenseScreen extends StatefulWidget {
  const VoiceExpenseScreen({super.key});

  @override
  State<VoiceExpenseScreen> createState() => _VoiceExpenseScreenState();
}

class _VoiceExpenseScreenState extends State<VoiceExpenseScreen> {
  static const _samples = [
    'Spent 3,500 naira on lunch yesterday',
    'Bought airtime for 2k today',
    'Paid 12,000 for fuel 2 days ago',
  ];

  final _text = TextEditingController();
  Timer? _timer;
  bool _listening = false;
  int _next = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _text.dispose();
    super.dispose();
  }

  void _toggleMic() {
    if (_listening) {
      _timer?.cancel();
      setState(() => _listening = false);
      return;
    }
    setState(() => _listening = true);
    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _listening = false;
        _text.text = _samples[_next % _samples.length];
        _next++;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final sentence = _text.text.trim();
    final parsed = sentence.isEmpty ? null : parseVoiceExpense(sentence);

    return SubPage(
      title: 'Voice expense',
      fallbackRoute: AppRoutes.expenses,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pageMargin),
        children: [
          DecoratedBox(
            decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(AppRadius.control)),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                'Preview: the microphone is simulated and fills in a sample sentence. You can also type your own.',
                style: theme.textTheme.bodySmall?.copyWith(color: StatusColors.warningText),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Center(
            child: Semantics(
              button: true,
              label: _listening ? 'Stop listening' : 'Start listening',
              child: InkResponse(
                onTap: _toggleMic,
                radius: 56,
                child: AnimatedContainer(
                  duration: AppDurations.quick,
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: _listening ? StatusColors.error : palette.action,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_listening ? Icons.stop_rounded : Icons.mic_rounded, color: Colors.white, size: 40),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              _listening ? 'Listening…' : 'Tap and say what you spent',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppTextField(
            label: 'What you said',
            controller: _text,
            hint: 'Spent 3,500 naira on lunch yesterday',
            maxLines: 2,
            onChanged: (_) => setState(() {}),
          ),
          if (parsed != null) ...[
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('We understood', style: theme.textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.sm),
                  _line(theme, 'Amount', parsed.amountKobo == null ? 'Not found' : null, amount: parsed.amountKobo),
                  _line(theme, 'Category', parsed.categoryHint == null ? 'Not found' : _cap(parsed.categoryHint!)),
                  _line(theme, 'Date', formatDayHeader(parsed.spentAt)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Review and save',
              onPressed: () => context.pushReplacement(AppRoutes.expensesNew, extra: parsed),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('Nothing is saved until you confirm on the next screen.',
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.inkSoft)),
          ],
        ],
      ),
    );
  }

  static String _cap(String s) => s[0].toUpperCase() + s.substring(1);

  Widget _line(ThemeData theme, String label, String? text, {int? amount}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Expanded(child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft))),
            if (amount != null)
              AmountText(amount)
            else
              Text(text ?? '', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      );
}
