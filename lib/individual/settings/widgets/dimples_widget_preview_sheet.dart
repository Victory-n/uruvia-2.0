import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/widgets/custom_text.dart';

class DimplesWidgetPreviewSheet extends StatefulWidget {
  const DimplesWidgetPreviewSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DimplesWidgetPreviewSheet(),
    );
  }

  @override
  State<DimplesWidgetPreviewSheet> createState() =>
      _DimplesWidgetPreviewSheetState();
}

class _DimplesWidgetPreviewSheetState extends State<DimplesWidgetPreviewSheet> {
  int _selectedPlatformIndex = 0; // 0: Android, 1: iOS

  @override
  Widget build(BuildContext context) {
    return Container(
      // maxHeight: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16.0),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: ConstantColor.blueBackground.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: const Icon(
                  Icons.widgets_rounded,
                  color: ConstantColor.blueBackground,
                  size: 24.0,
                ),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    googleSansText(
                      text: "OS Home Screen Widget",
                      colors: ConstantColor.headingTextPrimary,
                      fontWeight: FontWeight.bold,
                      size: 17.0,
                    ),
                    googleSansText(
                      text: "Live preview of Dimples outside the Uruvia app",
                      colors: ConstantColor.paragraphTextSecondary,
                      fontWeight: FontWeight.w400,
                      size: 12.0,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // Platform Switcher (Android / iOS)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: ConstantColor.lightBackground,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPlatformIndex = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      decoration: BoxDecoration(
                        color: _selectedPlatformIndex == 0
                            ? ConstantColor.blueBackground
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.android_rounded,
                            size: 18,
                            color: _selectedPlatformIndex == 0
                                ? Colors.white
                                : ConstantColor.paragraphTextPrimary,
                          ),
                          const SizedBox(width: 6.0),
                          googleSansText(
                            text: "Android Widget",
                            colors: _selectedPlatformIndex == 0
                                ? Colors.white
                                : ConstantColor.paragraphTextPrimary,
                            fontWeight: FontWeight.bold,
                            size: 13.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPlatformIndex = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      decoration: BoxDecoration(
                        color: _selectedPlatformIndex == 1
                            ? ConstantColor.blueBackground
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.apple_rounded,
                            size: 18,
                            color: _selectedPlatformIndex == 1
                                ? Colors.white
                                : ConstantColor.paragraphTextPrimary,
                          ),
                          const SizedBox(width: 6.0),
                          googleSansText(
                            text: "iOS WidgetKit",
                            colors: _selectedPlatformIndex == 1
                                ? Colors.white
                                : ConstantColor.paragraphTextPrimary,
                            fontWeight: FontWeight.bold,
                            size: 13.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),

          // Simulated Phone Screen Outer Box
          Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(
                  0xFF1E293B,
                ), // Dark smartphone wallpaper background
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Phone Header status bar mock
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      googleSansText(
                        text: "9:41",
                        colors: Colors.white70,
                        fontWeight: FontWeight.bold,
                        size: 11.0,
                      ),
                      Row(
                        children: const [
                          Icon(Icons.wifi, color: Colors.white70, size: 12),
                          SizedBox(width: 4),
                          Icon(
                            Icons.battery_full_rounded,
                            color: Colors.white70,
                            size: 14,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),

                  // The Simulated Dimples Home Screen Widget Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6.0),
                              decoration: BoxDecoration(
                                color: ConstantColor.blueBackground,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                color: Colors.white,
                                size: 16.0,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            googleSansText(
                              text: "Dimples • Uruvia Intel",
                              colors: ConstantColor.headingTextPrimary,
                              fontWeight: FontWeight.bold,
                              size: 13.0,
                            ),
                            const Spacer(),
                            googleSansText(
                              text: "Just Now",
                              colors: ConstantColor.paragraphTextSecondary,
                              fontWeight: FontWeight.w400,
                              size: 10.0,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        googleSansText(
                          text:
                              "🚀 High sales alert! Your cash flow grew 24% this week. Ready to register your Business with CAC on Uruvia?",
                          colors: ConstantColor.paragraphTextPrimary,
                          fontWeight: FontWeight.w500,
                          size: 12.0,
                        ),
                        const SizedBox(height: 12.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 4.0,
                              ),
                              decoration: BoxDecoration(
                                color: ConstantColor.blueBackground.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: googleSansText(
                                text: "Balance: ₦250,000",
                                colors: ConstantColor.blueBackground,
                                fontWeight: FontWeight.bold,
                                size: 11.0,
                              ),
                            ),
                            googleSansText(
                              text: "Tap to view in App ➔",
                              colors: ConstantColor.blueBackground,
                              fontWeight: FontWeight.bold,
                              size: 11.0,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20.0),

          // Setup Guide
          googleSansText(
            text: _selectedPlatformIndex == 0
                ? "How to add on Android:"
                : "How to add on iOS:",
            colors: ConstantColor.headingTextPrimary,
            fontWeight: FontWeight.bold,
            size: 13.0,
          ),
          const SizedBox(height: 6.0),
          googleSansText(
            text: _selectedPlatformIndex == 0
                ? "1. Long press any blank space on your Android home screen.\n2. Tap Widgets -> search for 'Uruvia'.\n3. Drag the Dimples Mascot widget to your home screen."
                : "1. Long press your iOS home screen until icons wiggle.\n2. Tap the '+' button in the top corner.\n3. Search 'Uruvia' and select the Dimples Mascot widget.",
            colors: ConstantColor.paragraphTextSecondary,
            fontWeight: FontWeight.normal,
            size: 12.0,
          ),
          const SizedBox(height: 20.0),

          // Done Button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: ConstantColor.blueBackground,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: googleSansText(
                text: "Got It",
                colors: Colors.white,
                fontWeight: FontWeight.bold,
                size: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
