import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../individual_account/sidebar/app_sidebar.dart';
import '../../../../business_account/sidebar/business_sidebar.dart';
import '../../../../theme/individual/app_theme.dart';
import '../../../../theme/business/business_theme.dart';
import '../../../../shared/widgets/app_text.dart';
import '../widgets/support_channel_card.dart';
import '../widgets/support_complaint_form.dart';
import '../widgets/support_header_card.dart';

class SupportScreen extends StatefulWidget {
  final bool isBusiness;

  const SupportScreen({
    super.key,
    this.isBusiness = false,
  });

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _launchExternalUrl(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: widget.isBusiness
                ? BusinessTheme.charcoal
                : AppTheme.sleekBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: AppText.custom(
              'Unable to launch channel: $urlString',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        );
      }
    }
  }

  void _handleComplaintSubmitted(
    String name,
    String email,
    String category,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: widget.isBusiness
            ? BusinessTheme.charcoal
            : AppTheme.sleekBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            FaIcon(
              FontAwesomeIcons.circleCheck,
              color: widget.isBusiness
                  ? BusinessTheme.success
                  : AppTheme.primaryGreen,
              size: 16,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppText.custom(
                widget.isBusiness
                    ? 'Inquiry received. Your account officer will contact you shortly.'
                    : 'Complaint submitted! Our team will respond within 24 hours.',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBiz = widget.isBusiness;
    final canPop = Navigator.canPop(context);

    final scaffoldBg = isBiz
        ? BusinessTheme.backgroundLight
        : AppTheme.backgroundLight;

    final titleColor = isBiz
        ? BusinessTheme.textDark
        : AppTheme.textDark;

    final sectionHeaderColor = isBiz
        ? BusinessTheme.textMuted
        : AppTheme.textMuted;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: scaffoldBg,
      drawer: isBiz
          ? const BusinessSidebar(activeRoute: 'Support')
          : const AppSidebar(activeItem: 'Support'),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: canPop
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: titleColor,
                  size: 18,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.bars,
                  color: titleColor,
                  size: 18,
                ),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
        title: AppText.subtitle(
          'Support & Help',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: titleColor,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // How can we help you banner
            SupportHeaderCard(isBusiness: isBiz),
            const SizedBox(height: 24),

            // Direct Channels Header
            AppText.custom(
              isBiz ? 'DIRECT BUSINESS CHANNELS' : 'DIRECT CHANNELS',
              style: TextStyle(
                color: sectionHeaderColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),

            // WhatsApp Chat
            SupportChannelCard(
              icon: FontAwesomeIcons.whatsapp,
              iconColor: const Color(0xFF16A34A),
              iconBackgroundColor: const Color(0xFFDCFCE7),
              title: isBiz ? 'WhatsApp Support Desk' : 'WhatsApp Chat',
              subtitle: '+234 901 234 5678',
              actionLabel: 'Chat Now',
              isBusiness: isBiz,
              onTap: () => _launchExternalUrl('https://wa.me/2349012345678'),
            ),
            const SizedBox(height: 12),

            // Phone Call
            SupportChannelCard(
              icon: FontAwesomeIcons.phone,
              iconColor: const Color(0xFF2563EB),
              iconBackgroundColor: const Color(0xFFEFF6FF),
              title: isBiz ? 'Merchant Support Line' : 'Phone Call',
              subtitle: '+234 812 345 6789',
              actionLabel: 'Call Us',
              isBusiness: isBiz,
              onTap: () => _launchExternalUrl('tel:+2348123456789'),
            ),
            const SizedBox(height: 12),

            // Email Address
            SupportChannelCard(
              icon: FontAwesomeIcons.envelope,
              iconColor: const Color(0xFFEF4444),
              iconBackgroundColor: const Color(0xFFFEE2E2),
              title: 'Email Address',
              subtitle: isBiz ? 'business@uruvia.com' : 'support@uruvia.com',
              actionLabel: 'Send Email',
              isBusiness: isBiz,
              onTap: () => _launchExternalUrl(
                'mailto:${isBiz ? 'business@uruvia.com' : 'support@uruvia.com'}?subject=Support%20Request',
              ),
            ),
            const SizedBox(height: 28),

            // Submit a Complaint Header
            AppText.custom(
              isBiz ? 'SUBMIT INQUIRY OR COMPLAINT' : 'SUBMIT A COMPLAINT',
              style: TextStyle(
                color: sectionHeaderColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),

            // Complaint Form
            SupportComplaintForm(
              isBusiness: isBiz,
              onSubmit: _handleComplaintSubmitted,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
