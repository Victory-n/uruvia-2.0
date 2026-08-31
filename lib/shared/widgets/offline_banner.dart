import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/services/navigation_service.dart';
import '../../offline/connectivity_service.dart';
import 'custom_text.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ConnectivityService.instance.isConnected,
      builder: (context, isOnline, _) {
        if (isOnline) {
          return const SizedBox.shrink();
        }

        final topPadding = MediaQuery.of(context).padding.top;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: topPadding + 6.0,
            bottom: 10.0,
            left: 16.0,
            right: 16.0,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF1E293B), // Sleek Dark Slate
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    color: Colors.amberAccent,
                    size: 17.0,
                  ),
                  const SizedBox(width: 8.0),
                  interText(
                    text: "Offline mode. Changes will sync later.",
                    colors: Colors.white,
                    size: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _showOfflineInfoDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: interText(
                    text: "Learn More",
                    colors: Colors.white,
                    size: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOfflineInfoDialog(BuildContext context) {
    final navContext = NavigationService.currentContext ?? context;
    showDialog(
      context: navContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: ConstantColor.blueBackground,
              size: 24.0,
            ),
            const SizedBox(width: 10.0),
            googleSansText(
              text: "Offline Mode Active",
              colors: ConstantColor.headingTextPrimary,
              fontWeight: FontWeight.bold,
              size: 17.0,
            ),
          ],
        ),
        content: googleSansText(
          text:
              "You are currently offline. You can continue viewing your cached profile, wallet information, and account details. Any changes you make will be securely queued and automatically synchronized once your internet connection is restored.",
          colors: ConstantColor.paragraphTextSecondary,
          fontWeight: FontWeight.normal,
          size: 13.5,
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ConstantColor.blueBackground,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: googleSansText(
              text: "Got It",
              colors: Colors.white,
              fontWeight: FontWeight.bold,
              size: 13.5,
            ),
          ),
        ],
      ),
    );
  }
}
