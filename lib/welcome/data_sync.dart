import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/side_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uruvia/organizations/organization_onboarding_screen.dart';
import '../widgets/custom_text.dart';

enum SyncStatus { pending, syncing, completed }

class DataSyncPage extends StatefulWidget {
  const DataSyncPage({super.key});

  @override
  State<DataSyncPage> createState() => _DataSyncPageState();
}

class _DataSyncPageState extends State<DataSyncPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  SyncStatus _productsStatus = SyncStatus.syncing;
  SyncStatus _invoicesStatus = SyncStatus.pending;
  SyncStatus _clientsStatus = SyncStatus.pending;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();

    // Pulse animation controller for the glowing cloud icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Simulate sequential database syncing progress
    _startSyncSimulation();
  }

  void _startSyncSimulation() {
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _productsStatus = SyncStatus.completed;
          _invoicesStatus = SyncStatus.syncing;
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) {
        setState(() {
          _invoicesStatus = SyncStatus.completed;
          _clientsStatus = SyncStatus.syncing;
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 3600), () {
      if (mounted) {
        setState(() {
          _clientsStatus = SyncStatus.completed;
          _isCompleted = true;
          _pulseController.stop(); // Stop pulsing when fully completed
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildSyncCard({
    required String label,
    required String iconPath,
    required SyncStatus status,
  }) {
    Widget statusWidget;
    Color cardBorderColor = ConstantColor.paragraphTextPrimary.withAlpha(20);
    Color cardBgColor = Colors.white;

    switch (status) {
      case SyncStatus.pending:
        statusWidget = Icon(
          Icons.radio_button_unchecked,
          color: ConstantColor.paragraphTextSecondary.withAlpha(76),
          size: 22,
        );
        break;
      case SyncStatus.syncing:
        statusWidget = const SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              ConstantColor.blueBackground,
            ),
          ),
        );
        cardBorderColor = ConstantColor.blueBackground.withAlpha(102);
        cardBgColor = ConstantColor.blueBackground.withAlpha(10);
        break;
      case SyncStatus.completed:
        statusWidget = Icon(
          Platform.isAndroid ? Icons.check_circle : Icons.check_circle_outline,
          color: Colors.green,
          size: 22,
        );
        cardBorderColor = Colors.green.withAlpha(102);
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(
              status == SyncStatus.syncing ? 10 : 5,
            ),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                iconPath,
                height: 24,
                width: 24,
                colorFilter: ColorFilter.mode(
                  status == SyncStatus.pending
                      ? ConstantColor.paragraphTextSecondary
                      : ConstantColor.headingTextPrimary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 12.0),
              interText(
                text: label,
                colors: status == SyncStatus.pending
                    ? ConstantColor.paragraphTextSecondary
                    : ConstantColor.headingTextPrimary,
                fontWeight: FontWeight.w600,
                size: 16.0,
              ),
            ],
          ),
          statusWidget,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFF5F8FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 24.0,
            ),
            child: Column(
              children: [
                const Spacer(),

                // Animated glowing Cloud Icon
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final pulseVal = _pulseController.value;
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: ConstantColor.blueBackground.withAlpha(
                              _isCompleted
                                  ? 13
                                  : (26 * (1.0 - pulseVal)).toInt(),
                            ),
                            blurRadius: _isCompleted
                                ? 15
                                : (10 + 20 * pulseVal),
                            spreadRadius: _isCompleted ? 2 : (2 + 6 * pulseVal),
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(
                        "assets/svg/cloud.svg",
                        height: 70,
                        width: 70,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32.0),

                // Sync Headings
                interText(
                  text: _isCompleted
                      ? "Data Synchronized"
                      : "Syncing Command Centre",
                  colors: ConstantColor.headingTextPrimary,
                  fontWeight: FontWeight.bold,
                  size: 26.0,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12.0),
                googleSansText(
                  text: _isCompleted
                      ? "Ready for offline use. Your business command centre is fully updated."
                      : "Connecting with database to download inventory, invoices, and client data...",
                  colors: ConstantColor.paragraphTextSecondary,
                  fontWeight: FontWeight.normal,
                  size: 15.0,
                  textAlign: TextAlign.center,
                ),

                const Spacer(),

                // Sync Summary Section
                Container(
                  padding: const EdgeInsets.all(20.0),
                  width: size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: const Color(0xFFEFF4FF),
                    border: Border.all(
                      color: ConstantColor.blueBackground.withAlpha(26),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      interText(
                        text: "SYNC SUMMARY",
                        colors: ConstantColor.blueBackground,
                        fontWeight: FontWeight.bold,
                        size: 12.0,
                      ),
                      const SizedBox(height: 16.0),
                      _buildSyncCard(
                        label: "Products & Inventory",
                        iconPath: "assets/svg/inventory.svg",
                        status: _productsStatus,
                      ),
                      const SizedBox(height: 12.0),
                      _buildSyncCard(
                        label: "Recent Invoices",
                        iconPath: "assets/svg/receipt.svg",
                        status: _invoicesStatus,
                      ),
                      const SizedBox(height: 12.0),
                      _buildSyncCard(
                        label: "Client Directory",
                        iconPath: "assets/svg/contact.svg",
                        status: _clientsStatus,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Proceed Button
                ElevatedButton(
                  onPressed: _isCompleted
                      ? () {
                          final user = Supabase.instance.client.auth.currentUser;
                          final hasOnboarded = (user?.userMetadata?['has_onboarded_business'] ?? false) ||
                              (user?.userMetadata?['has_skipped_onboarding'] ?? false);
                          if (hasOnboarded) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SideBarPage(title: ""),
                              ),
                              (route) => false,
                            );
                          } else {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const OrganizationOnboardingScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        }
                      : null,
                  style: ButtonStyle(
                    fixedSize: WidgetStateProperty.all(Size(size.width, 54.0)),
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.disabled)) {
                        return ConstantColor.paragraphTextSecondary.withAlpha(
                          51,
                        );
                      }
                      return ConstantColor.blueBackground;
                    }),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    elevation: WidgetStateProperty.all(0.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      interText(
                        text: _isCompleted
                            ? "Proceed to Dashboard"
                            : "Synchronizing Business...",
                        colors: _isCompleted
                            ? Colors.white
                            : ConstantColor.paragraphTextSecondary,
                        fontWeight: FontWeight.w700,
                        size: 16.0,
                        textAlign: TextAlign.center,
                      ),
                      if (_isCompleted) ...[
                        const SizedBox(width: 8.0),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 18.0,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
