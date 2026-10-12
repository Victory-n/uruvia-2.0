import 'package:flutter/material.dart';

import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/config/app_contacts.dart';
import '../../../core/utils/open_link.dart';
import '../../../core/widgets/app_card.dart';

/// WhatsApp, call and email. The numbers are DUMMY (see AppContacts).
class ContactCards extends StatelessWidget {
  const ContactCards({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    Widget card(IconData icon, String title, String sub, String url) => Expanded(
          child: AppCard(
            onTap: () => openLink(context, url),
            child: Column(
              children: [
                CircleAvatar(backgroundColor: palette.tint, child: Icon(icon, color: palette.action, size: 20)),
                const SizedBox(height: AppSpacing.sm),
                Text(title, style: theme.textTheme.titleSmall),
                Text(sub, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.inkSoft), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            card(Icons.chat_outlined, 'WhatsApp', 'Chat with us', AppContacts.whatsappUrl),
            const SizedBox(width: AppSpacing.sm),
            card(Icons.call_outlined, 'Call', 'Speak to us', AppContacts.phoneUrl),
            const SizedBox(width: AppSpacing.sm),
            card(Icons.mail_outline_rounded, 'Email', 'Write to us', AppContacts.emailUrl),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text('We reply ${AppContacts.hours}.', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.inkSoft)),
      ],
    );
  }
}

class _Faq {
  const _Faq(this.q, this.a);
  final String q;
  final String a;
}

const _faqs = [
  _Faq('I forgot my password.', 'On the sign-in screen tap Forgot password. We email you a code to set a new one.'),
  _Faq('How do I change my PIN?', 'Open Settings, then Change PIN. You need your current PIN first.'),
  _Faq('I forgot my PIN.', 'Log out and sign in again with your email and password, then create a new PIN.'),
  _Faq('Can I use Uruvia without internet?', 'You can still add a cash expense. It waits on your phone and is sent when you are back online. Other actions need internet.'),
  _Faq('Is the wallet live?', 'Not yet. The Wallet and Savings screens show sample figures until our bank partner goes live. Nothing you see there moves real money.'),
  _Faq('How do I switch between Individual and Business?', 'Tap the account name at the top of the menu, then choose the other account and confirm with your PIN.'),
  _Faq('How do I delete my account?', 'Open Settings, then Delete my account. This removes your data for good.'),
];

/// Common questions. Static text for now.
class FaqList extends StatelessWidget {
  const FaqList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < _faqs.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            ExpansionTile(
              shape: const Border(),
              collapsedShape: const Border(),
              title: Text(_faqs[i].q, style: theme.textTheme.bodyLarge),
              childrenPadding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(_faqs[i].a, style: theme.textTheme.bodyMedium)],
            ),
          ],
        ],
      ),
    );
  }
}
